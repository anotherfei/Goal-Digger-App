import * as admin from "firebase-admin";
import { logger } from "firebase-functions";

import { defaultModel } from "../ai";
import {
  NotificationAgentSignals,
  NotificationCandidate,
  NotificationDecision,
  notificationContextFromProfile,
  triageNotification,
} from "./notificationTriage";

const RECENT_NOTIFICATION_LIMIT = 16;
const DUPLICATE_WINDOW_MS = 6 * 60 * 60 * 1000;
const PUSH_BUDGET_WINDOW_MS = 60 * 60 * 1000;
const DELIVERY_LEASE_MS = 2 * 60 * 1000;
const MAX_MULTICAST_TOKENS = 500;

interface NotificationAgentRunInput {
  uid: string;
  notificationId: string;
  eventId: string;
  notificationRef: admin.firestore.DocumentReference;
  data: Record<string, unknown>;
}

interface RecentNotification {
  type: string;
  sourceId: string;
  title: string;
  body: string;
  createdAtMs: number;
  pushedAtMs: number | null;
}

interface TypeEngagement {
  decisions: number;
  reads: number;
}

function asRecord(value: unknown): Record<string, unknown> {
  if (value === null || typeof value !== "object" || Array.isArray(value)) {
    return {};
  }
  return value as Record<string, unknown>;
}

function numberValue(value: unknown): number {
  return typeof value === "number" && Number.isFinite(value) ? value : 0;
}

function timestampMillis(value: unknown): number | null {
  if (value instanceof admin.firestore.Timestamp) {
    return value.toMillis();
  }
  if (value instanceof Date) return value.getTime();
  return null;
}

function safeTypeKey(value: string): string {
  return /^[A-Za-z][A-Za-z0-9_]{0,39}$/.test(value) ? value : "other";
}

function candidateFromData(data: Record<string, unknown>): NotificationCandidate {
  const rawPayload = data.payload;
  return {
    title: String(data.title ?? "Goal Digger"),
    body: String(data.body ?? ""),
    type: String(data.type ?? ""),
    delivery: String(data.delivery ?? "inApp"),
    sourceId: String(data.sourceId ?? ""),
    important: data.important === true,
    payload: asRecord(rawPayload),
  };
}

function recentNotificationFromDoc(
  doc: admin.firestore.QueryDocumentSnapshot
): RecentNotification {
  const data = doc.data();
  const agent = asRecord(data.notificationAgent);
  const execution = asRecord(agent.execution);
  const wasSent =
    agent.action === "push_now" && execution.status === "sent";
  return {
    type: String(data.type ?? ""),
    sourceId: String(data.sourceId ?? ""),
    title: String(data.title ?? ""),
    body: String(data.body ?? ""),
    createdAtMs: timestampMillis(data.createdAt) ?? 0,
    pushedAtMs: wasSent ? timestampMillis(execution.sentAt) : null,
  };
}

function engagementFromMemory(
  memoryValue: unknown,
  notificationType: string
): TypeEngagement {
  const memory = asRecord(memoryValue);
  const agent = asRecord(memory.notificationAgent);
  const engagementByType = asRecord(agent.engagementByType);
  const typeStats = asRecord(engagementByType[safeTypeKey(notificationType)]);
  return {
    decisions: Math.max(0, Math.round(numberValue(typeStats.decisions))),
    reads: Math.max(0, Math.round(numberValue(typeStats.reads))),
  };
}

function decisionFromStoredAgent(
  value: Record<string, unknown>
): NotificationDecision | null {
  const action = value.action;
  const source = value.source;
  const tone = value.tone;
  if (action !== "push_now" && action !== "inbox_only") return null;
  if (source !== "ai" && source !== "fallback" && source !== "policy") {
    return null;
  }
  if (
    tone !== "preserve" &&
    tone !== "supportive" &&
    tone !== "urgent" &&
    tone !== "celebratory" &&
    tone !== "concise"
  ) {
    return null;
  }

  return {
    action,
    important: value.important === true,
    shouldPush: action === "push_now",
    score: Math.max(0, Math.min(100, Math.round(numberValue(value.score)))),
    reason: String(value.reason ?? "Stored notification agent decision."),
    source,
    tone,
    pushTitle: String(value.pushTitle ?? "Goal Digger"),
    pushBody: String(value.pushBody ?? ""),
    policyApplied: Array.isArray(value.policyApplied)
      ? value.policyApplied.map(String)
      : [],
  };
}

function buildSignals(
  candidate: NotificationCandidate,
  recent: RecentNotification[],
  engagement: TypeEngagement,
  nowMs: number
): NotificationAgentSignals {
  const duplicate = recent.some((item) => {
    if (nowMs - item.createdAtMs > DUPLICATE_WINDOW_MS) return false;
    return (
      item.type === candidate.type &&
      item.sourceId === candidate.sourceId &&
      item.title === candidate.title &&
      item.body === candidate.body
    );
  });
  const recentPushCount = recent.filter(
    (item) =>
      item.pushedAtMs !== null &&
      nowMs - item.pushedAtMs <= PUSH_BUDGET_WINDOW_MS
  ).length;

  return {
    duplicate,
    recentPushCount,
    typeDecisionCount: engagement.decisions,
    typeReadCount: engagement.reads,
  };
}

async function persistDecision(
  input: NotificationAgentRunInput,
  decision: NotificationDecision
): Promise<NotificationDecision> {
  const db = admin.firestore();
  const memoryRef = db.collection("agent_memory").doc(input.uid);
  const typeKey = safeTypeKey(input.data.type?.toString() ?? "");

  return await db.runTransaction(async (transaction) => {
    const current = await transaction.get(input.notificationRef);
    const currentAgent = asRecord(current.data()?.notificationAgent);
    if (currentAgent.decisionEventId === input.eventId) {
      return decisionFromStoredAgent(currentAgent) ?? decision;
    }

    transaction.set(
      input.notificationRef,
      {
        important: decision.important,
        notificationAgent: {
          version: 1,
          decisionEventId: input.eventId,
          action: decision.action,
          important: decision.important,
          score: decision.score,
          reason: decision.reason,
          source: decision.source,
          tone: decision.tone,
          pushTitle: decision.pushTitle,
          pushBody: decision.pushBody,
          policyApplied: decision.policyApplied,
          model: decision.source === "ai" ? defaultModel : null,
          decidedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
      },
      { merge: true }
    );

    transaction.set(
      memoryRef,
      {
        notificationAgent: {
          totalDecisions: admin.firestore.FieldValue.increment(1),
          pushDecisions: admin.firestore.FieldValue.increment(
            decision.action === "push_now" ? 1 : 0
          ),
          inboxDecisions: admin.firestore.FieldValue.increment(
            decision.action === "inbox_only" ? 1 : 0
          ),
          engagementByType: {
            [typeKey]: {
              decisions: admin.firestore.FieldValue.increment(1),
              pushDecisions: admin.firestore.FieldValue.increment(
                decision.action === "push_now" ? 1 : 0
              ),
              inboxDecisions: admin.firestore.FieldValue.increment(
                decision.action === "inbox_only" ? 1 : 0
              ),
              lastDecisionAt: admin.firestore.FieldValue.serverTimestamp(),
            },
          },
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
      },
      { merge: true }
    );
    return decision;
  });
}

async function setExecutionStatus(
  notificationRef: admin.firestore.DocumentReference,
  status: string,
  details: Record<string, unknown> = {}
): Promise<void> {
  await notificationRef.set(
    {
      notificationAgent: {
        execution: {
          status,
          ...details,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
      },
    },
    { merge: true }
  );
}

async function claimPushDelivery(
  notificationRef: admin.firestore.DocumentReference,
  eventId: string
): Promise<boolean> {
  const db = admin.firestore();
  return db.runTransaction(async (transaction) => {
    const current = await transaction.get(notificationRef);
    const agent = asRecord(current.data()?.notificationAgent);
    const execution = asRecord(agent.execution);
    const status = String(execution.status ?? "");
    const leaseAtMs = timestampMillis(execution.leaseAt);

    if (status === "sent") return false;
    if (
      status === "sending" &&
      leaseAtMs !== null &&
      Date.now() - leaseAtMs < DELIVERY_LEASE_MS
    ) {
      return false;
    }

    transaction.set(
      notificationRef,
      {
        notificationAgent: {
          execution: {
            status: "sending",
            eventId,
            leaseAt: admin.firestore.FieldValue.serverTimestamp(),
          },
        },
      },
      { merge: true }
    );
    return true;
  });
}

async function recordSuccessfulPush(
  uid: string,
  notificationType: string
): Promise<void> {
  const typeKey = safeTypeKey(notificationType);
  await admin
    .firestore()
    .collection("agent_memory")
    .doc(uid)
    .set(
      {
        notificationAgent: {
          deliveredPushes: admin.firestore.FieldValue.increment(1),
          engagementByType: {
            [typeKey]: {
              deliveredPushes: admin.firestore.FieldValue.increment(1),
              lastPushAt: admin.firestore.FieldValue.serverTimestamp(),
            },
          },
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
      },
      { merge: true }
    );
}

async function executePush(
  input: NotificationAgentRunInput,
  candidate: NotificationCandidate,
  decision: NotificationDecision
): Promise<void> {
  if (candidate.type === "reward") {
    await setExecutionStatus(input.notificationRef, "inbox_only", {
      reason: "Reward notifications are never delivered as phone pushes.",
    });
    return;
  }

  if (!(await claimPushDelivery(input.notificationRef, input.eventId))) {
    logger.info("Notification agent skipped an already-claimed delivery", {
      uid: input.uid,
      notificationId: input.notificationId,
    });
    return;
  }

  const tokenSnapshot = await admin
    .firestore()
    .collection("users")
    .doc(input.uid)
    .collection("fcmTokens")
    .limit(MAX_MULTICAST_TOKENS)
    .get();
  const tokenDocs = tokenSnapshot.docs
    .map((doc) => ({ doc, token: String(doc.data().token ?? "") }))
    .filter(({ token }) => token.length > 0);

  if (tokenDocs.length === 0) {
    await setExecutionStatus(input.notificationRef, "no_tokens");
    return;
  }

  try {
    const response = await admin.messaging().sendEachForMulticast({
      tokens: tokenDocs.map(({ token }) => token),
      notification: {
        title: decision.pushTitle,
        body: decision.pushBody,
      },
      android: {
        priority: decision.important ? "high" : "normal",
        notification: {
          channelId: decision.important
            ? "goal_digger_important"
            : "goal_digger_standard_v2",
        },
      },
      data: {
        notificationId: input.notificationId,
        type: candidate.type,
        sourceId: candidate.sourceId,
        important: String(decision.important),
        importanceScore: String(decision.score),
        agentAction: decision.action,
        agentTone: decision.tone,
        triageSource: decision.source,
        actorUid: String(input.data.actorUid ?? ""),
        route: String(candidate.payload.route ?? ""),
        chatId: String(candidate.payload.chatId ?? ""),
        friendUid: String(candidate.payload.friendUid ?? ""),
      },
    });

    const invalidDocs = response.responses
      .map((result, index) => ({ result, doc: tokenDocs[index].doc }))
      .filter(({ result }) => {
        const code = result.error?.code;
        return (
          !result.success &&
          (code === "messaging/invalid-registration-token" ||
            code === "messaging/registration-token-not-registered")
        );
      })
      .map(({ doc }) => doc);

    if (invalidDocs.length > 0) {
      const batch = admin.firestore().batch();
      for (const doc of invalidDocs) batch.delete(doc.ref);
      await batch.commit();
    }

    await setExecutionStatus(input.notificationRef, "sent", {
      successCount: response.successCount,
      failureCount: response.failureCount,
      invalidTokenCount: invalidDocs.length,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    if (response.successCount > 0) {
      await recordSuccessfulPush(input.uid, candidate.type);
    }
  } catch (error) {
    await setExecutionStatus(input.notificationRef, "failed", {
      error: String(error).slice(0, 500),
    });
    throw error;
  }
}

export async function runNotificationAgent(
  input: NotificationAgentRunInput
): Promise<NotificationDecision> {
  const db = admin.firestore();
  const userRef = db.collection("users").doc(input.uid);
  const memoryRef = db.collection("agent_memory").doc(input.uid);
  const candidate = candidateFromData(input.data);

  const [profileSnapshot, memorySnapshot, recentSnapshot] = await Promise.all([
    userRef.get(),
    memoryRef.get(),
    userRef
      .collection("notifications")
      .orderBy("createdAt", "desc")
      .limit(RECENT_NOTIFICATION_LIMIT)
      .get(),
  ]);

  const recent = recentSnapshot.docs
    .filter((doc) => doc.id !== input.notificationId)
    .map(recentNotificationFromDoc);
  const engagement = engagementFromMemory(
    memorySnapshot.data(),
    candidate.type
  );
  const signals = buildSignals(candidate, recent, engagement, Date.now());
  const decision = await triageNotification(
    candidate,
    notificationContextFromProfile(profileSnapshot.data()),
    signals
  );

  const effectiveDecision = await persistDecision(input, decision);

  logger.info("Notification agent planned an action", {
    uid: input.uid,
    notificationId: input.notificationId,
    action: effectiveDecision.action,
    important: effectiveDecision.important,
    score: effectiveDecision.score,
    source: effectiveDecision.source,
    tone: effectiveDecision.tone,
    policyApplied: effectiveDecision.policyApplied,
  });

  if (effectiveDecision.action === "push_now") {
    await executePush(input, candidate, effectiveDecision);
  } else {
    await setExecutionStatus(input.notificationRef, "inbox_only");
  }

  return effectiveDecision;
}

export async function learnFromNotificationRead(input: {
  uid: string;
  eventId: string;
  notificationRef: admin.firestore.DocumentReference;
  before: Record<string, unknown>;
  after: Record<string, unknown>;
}): Promise<void> {
  if (input.before.readAt != null || input.after.readAt == null) return;

  const agent = asRecord(input.after.notificationAgent);
  const action = String(agent.action ?? "");
  if (action !== "push_now" && action !== "inbox_only") return;

  const typeKey = safeTypeKey(String(input.after.type ?? ""));
  const decidedAtMs = timestampMillis(agent.decidedAt);
  const readAtMs = timestampMillis(input.after.readAt) ?? Date.now();
  const latencyMinutes =
    decidedAtMs === null
      ? 0
      : Math.max(0, Math.round((readAtMs - decidedAtMs) / 60000));
  const db = admin.firestore();
  const memoryRef = db.collection("agent_memory").doc(input.uid);

  await db.runTransaction(async (transaction) => {
    const current = await transaction.get(input.notificationRef);
    const currentAgent = asRecord(current.data()?.notificationAgent);
    const learning = asRecord(currentAgent.learning);
    if (learning.eventId === input.eventId) return;

    transaction.set(
      memoryRef,
      {
        notificationAgent: {
          totalReads: admin.firestore.FieldValue.increment(1),
          engagementByType: {
            [typeKey]: {
              reads: admin.firestore.FieldValue.increment(1),
              pushReads: admin.firestore.FieldValue.increment(
                action === "push_now" ? 1 : 0
              ),
              inboxReads: admin.firestore.FieldValue.increment(
                action === "inbox_only" ? 1 : 0
              ),
              totalReadLatencyMinutes:
                admin.firestore.FieldValue.increment(latencyMinutes),
              lastReadAt: admin.firestore.FieldValue.serverTimestamp(),
            },
          },
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
      },
      { merge: true }
    );
    transaction.set(
      input.notificationRef,
      {
        notificationAgent: {
          learning: {
            eventId: input.eventId,
            latencyMinutes,
            recordedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
        },
      },
      { merge: true }
    );
  });

  logger.info("Notification agent learned from a read", {
    uid: input.uid,
    notificationId: input.notificationRef.id,
    action,
    type: typeKey,
    latencyMinutes,
  });
}
