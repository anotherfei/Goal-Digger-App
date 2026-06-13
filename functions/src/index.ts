// functions/src/index.ts
//
// Exports every Firebase Cloud Function for Goal Digger.
//
// Auth strategy:
//   • onCall functions  → Firebase verifies the ID token automatically.
//   • goalCoachStream   → onRequest (SSE), token verified manually via Admin SDK
//                         because onCall doesn't support streaming responses.
//
// Flow instances are created ONCE at module load time (not inside each request
// handler). Re-creating Genkit flows on every invocation is wasteful and can
// cause name-collision warnings in Genkit's flow registry.

import * as admin from "firebase-admin";
import { onCall, onRequest, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";

import { defineGoalCoachFlow }     from "./flows/goalCoachFlow";
import { defineTaskGeneratorFlow } from "./flows/taskGeneratorFlow";
import { defineMoodAdvisorFlow }   from "./flows/moodAdvisorFlow";
import { defineFocusInsightFlow }  from "./flows/focusInsightFlow";
import { getAI, defaultModel }     from "./ai";
import { runAgent }                from "./agent/runtime";
import { modificationAgent, type ModifiableTask } from "./agent/modification";
import {
  reassignmentAgent,
  type ReassignableTask,
  type ReassignGoalInfo,
  type ReassignmentTrigger,
} from "./agent/reassignment";
import {
  learnFromNotificationRead,
  runNotificationAgent,
} from "./notifications/notificationAgent";

import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";

// ── Initialise Admin SDK ──────────────────────────────────────────────────────
admin.initializeApp();

// ── Secret declaration ────────────────────────────────────────────────────────
const geminiApiKey = defineSecret("GEMINI_API_KEY");

const fnOptions = {
  region: "asia-east1",
  secrets: [geminiApiKey],
  timeoutSeconds: 60,
  memory: "256MiB" as const,
};


// Only allow authenticated Firebase users
const requireAuth = (auth: { uid?: string } | undefined) => {
  if (!auth?.uid) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }
};


// ── Define flows ONCE at module load ──────────────────────────────────────────
// Genkit registers flows by name internally. Calling defineFlow() on every
// request creates duplicate registrations and leaks memory. Define once here.
const goalCoachFlowFn     = defineGoalCoachFlow();
const taskGeneratorFlowFn = defineTaskGeneratorFlow();
const moodAdvisorFlowFn   = defineMoodAdvisorFlow();
const focusInsightFlowFn  = defineFocusInsightFlow();

// ── Callable functions (Flutter uses cloud_functions package) ─────────────────

export const goalCoach = onCall(fnOptions, async (req) => {
  requireAuth(req.auth);
  return await goalCoachFlowFn(req.data);
});

export const taskGenerator = onCall(fnOptions, async (req) => {
  requireAuth(req.auth);
  return await taskGeneratorFlowFn(req.data);
});

export const moodAdvisor = onCall(fnOptions, async (req) => {
  requireAuth(req.auth);
  return await moodAdvisorFlowFn(req.data);
});

export const focusInsight = onCall(fnOptions, async (req) => {
  requireAuth(req.auth);
  return await focusInsightFlowFn(req.data);
});

export const agentPlanner = onCall(fnOptions, async (req) => {
  requireAuth(req.auth);
  const goal = String(req.data?.goal ?? "").trim();
  if (!goal) {
    throw new HttpsError("invalid-argument", "goal is required.");
  }
  return await runAgent({
    userId: req.auth!.uid,
    goal,
    context: req.data?.context ?? {},
  });
});

// Task Modification Agent (§6.3): applies, clarifies, confirms, or rejects a
// user-requested change against the CURRENT draft plan.
export const agentModify = onCall(fnOptions, async (req) => {
  requireAuth(req.auth);
  const goal = String(req.data?.goal ?? "").trim();
  const request = String(req.data?.request ?? "").trim();
  if (!goal || !request) {
    throw new HttpsError("invalid-argument", "goal and request are required.");
  }
  const rawTasks = Array.isArray(req.data?.currentTasks) ? req.data.currentTasks : [];
  const currentTasks: ModifiableTask[] = rawTasks
    .filter((t: unknown): t is Record<string, unknown> => !!t && typeof t === "object")
    .map((t: Record<string, unknown>) => ({
      title: String(t.title ?? ""),
      durationMinutes: Number(t.durationMinutes ?? 20),
      load: (["light", "focus", "stretch"].includes(String(t.load))
        ? String(t.load)
        : "focus") as ModifiableTask["load"],
      dayOffset: Number(t.dayOffset ?? 0),
    }))
    .filter((t: ModifiableTask) => t.title.length > 0);

  return await modificationAgent({
    goal,
    request,
    currentTasks,
    context: req.data?.context ?? {},
    force: req.data?.force === true,
  });
});

// Task Reassignment Agent (§6.4): reacts to mood/routine/deadline changes and
// returns a validated set of reschedule recommendations.
export const agentReassign = onCall(fnOptions, async (req) => {
  requireAuth(req.auth);

  const validTriggers = new Set([
    "moodChanged",
    "routineAdded",
    "deadlineApproaching",
    "priorityChanged",
    "manual",
  ]);
  const trigger = String(req.data?.trigger ?? "manual");
  if (!validTriggers.has(trigger)) {
    throw new HttpsError("invalid-argument", `Unknown trigger "${trigger}".`);
  }

  const rawTasks = Array.isArray(req.data?.tasks) ? req.data.tasks : [];
  const tasks: ReassignableTask[] = rawTasks
    .filter((t: unknown): t is Record<string, unknown> => !!t && typeof t === "object")
    .map((t: Record<string, unknown>) => ({
      id: String(t.id ?? ""),
      goalId: String(t.goalId ?? ""),
      title: String(t.title ?? ""),
      durationMinutes: Number(t.durationMinutes ?? 20),
      load: String(t.load ?? "focus"),
      dayOffset: Number(t.dayOffset ?? 0),
      done: t.done === true,
    }))
    .filter((t: ReassignableTask) => t.id.length > 0 && t.title.length > 0);

  const rawGoals = Array.isArray(req.data?.goals) ? req.data.goals : [];
  const goals: ReassignGoalInfo[] = rawGoals
    .filter((g: unknown): g is Record<string, unknown> => !!g && typeof g === "object")
    .map((g: Record<string, unknown>) => ({
      id: String(g.id ?? ""),
      title: String(g.title ?? ""),
      importance: Math.min(5, Math.max(1, Number(g.importance ?? 3))),
      deadlineDays: Math.max(0, Number(g.deadlineDays ?? 14)),
    }))
    .filter((g: ReassignGoalInfo) => g.id.length > 0);

  const rawRoutines = Array.isArray(req.data?.routines) ? req.data.routines : [];
  const routines = rawRoutines
    .filter((r: unknown): r is Record<string, unknown> => !!r && typeof r === "object")
    .map((r: Record<string, unknown>) => ({
      title: String(r.title ?? ""),
      startsAt: String(r.startsAt ?? ""),
      repeat: String(r.repeat ?? ""),
    }))
    .filter((r: { title: string }) => r.title.length > 0);

  return await reassignmentAgent({
    userId: req.auth!.uid,
    trigger: trigger as ReassignmentTrigger,
    mood: req.data?.mood != null ? String(req.data.mood) : undefined,
    routines,
    tasks,
    goals,
    context: req.data?.context ?? {},
  });
});

// ── Streaming endpoint (SSE) ──────────────────────────────────────────────────
// onCall doesn't support streaming, so goalCoachStream is an onRequest function.
// The Flutter GenkitClient verifies the token manually for this endpoint.


export const goalCoachStream = onRequest(
  { ...fnOptions, cors: true },
  async (req, res) => {
    // 1. Verify Firebase ID token
    const authHeader = req.headers.authorization ?? "";
    if (!authHeader.startsWith("Bearer ")) {
      res.status(401).json({ error: "Missing Bearer token" });
      return;
    }
    try {
      await admin.auth().verifyIdToken(authHeader.slice(7));
    } catch {
      res.status(401).json({ error: "Invalid or expired token" });
      return;
    }

    // 2. Parse input
    const input = req.body as {
      userMessage: string;
      goalTitle: string;
      progressPercent: number;
      history?: { role: string; content: string }[];
    };

    // 3. Stream SSE
    res.setHeader("Content-Type", "text/event-stream");
    res.setHeader("Cache-Control", "no-cache");
    res.setHeader("X-Accel-Buffering", "no");

    try {
      const ai = getAI();
      const historyBlock = (input.history ?? [])
        .map((m) => `${m.role === "user" ? "User" : "Coach"}: ${m.content}`)
        .join("\n");

      const prompt = `
You are the Goal Digger AI coach — supportive, concise, and action-oriented.
Goal: "${input.goalTitle}" (${Math.round(input.progressPercent)}% complete).
${historyBlock ? `\n${historyBlock}\n` : ""}
User: ${input.userMessage}

Reply conversationally (1–3 sentences). Be warm and specific.`.trim();

      const { stream } = await ai.generateStream({
        model: defaultModel,
        prompt,
        config: { temperature: 0.7, maxOutputTokens: 512 },
      });

      for await (const chunk of stream) {
        const text = chunk.text;
        if (text) {
          res.write(`data: ${JSON.stringify({ chunk: text })}\n\n`);
        }
      }

      res.write("data: [DONE]\n\n");
    } catch (err) {
      res.write(`data: ${JSON.stringify({ error: String(err) })}\n\n`);
    } finally {
      res.end();
    }
  }
);

export const sendNotificationPush = onDocumentCreated(
  {
    ...fnOptions,
    document: "users/{uid}/notifications/{notificationId}",
  },
  async (event) => {
    const uid = String(event.params.uid);
    const notificationId = String(event.params.notificationId);
    const snapshot = event.data;
    if (!snapshot) return;

    await runNotificationAgent({
      uid,
      notificationId,
      eventId: event.id,
      notificationRef: snapshot.ref,
      data: snapshot.data(),
    });
  }
);

export const learnNotificationEngagement = onDocumentUpdated(
  {
    region: "asia-east1",
    timeoutSeconds: 30,
    memory: "256MiB",
    document: "users/{uid}/notifications/{notificationId}",
  },
  async (event) => {
    const before = event.data?.before;
    const after = event.data?.after;
    if (!before || !after) return;

    await learnFromNotificationRead({
      uid: String(event.params.uid),
      eventId: event.id,
      notificationRef: after.ref,
      before: before.data(),
      after: after.data(),
    });
  }
);
