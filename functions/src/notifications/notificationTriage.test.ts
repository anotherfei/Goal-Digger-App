import assert from "node:assert/strict";
import test from "node:test";

import {
  applyDecisionPolicy,
  fallbackNotificationDecision,
  NotificationCandidate,
  NotificationUserContext,
  notificationContextFromProfile,
  pushBlockReason,
} from "./notificationTriage";

const baseCandidate: NotificationCandidate = {
  title: "A useful update",
  body: "There is something to review.",
  type: "community",
  delivery: "inApp",
  sourceId: "source-1",
  important: false,
  payload: {},
};

const baseContext: NotificationUserContext = {
  selectedMood: "Okay",
  streak: 4,
  systemNotificationsEnabled: true,
  notificationSettings: {},
};

test("legacy goalReminders setting takes precedence over nested settings", () => {
  const context = notificationContextFromProfile({
    goalReminders: false,
    notificationSettings: { systemNotificationsEnabled: true },
  });

  assert.equal(context.systemNotificationsEnabled, false);
});

test("system notification opt-out blocks an otherwise approved push", () => {
  const decision = applyDecisionPolicy(
    baseCandidate,
    { ...baseContext, systemNotificationsEnabled: false },
    {
      important: true,
      shouldPush: true,
      score: 88,
      reason: "Time-sensitive.",
      source: "ai",
    }
  );

  assert.equal(decision.important, true);
  assert.equal(decision.shouldPush, false);
  assert.match(decision.reason, /system notifications are disabled/);
});

test("type-specific settings block delivery", () => {
  const candidate = { ...baseCandidate, type: "streakSaver" };
  const context = {
    ...baseContext,
    notificationSettings: { streakSaverEnabled: false },
  };

  assert.equal(pushBlockReason(candidate, context), "streakSaverEnabled is disabled");
});

test("critical types remain important even when AI rates them low", () => {
  const decision = applyDecisionPolicy(
    { ...baseCandidate, type: "deadlineWarning" },
    baseContext,
    {
      important: false,
      shouldPush: true,
      score: 20,
      reason: "Low confidence.",
      source: "ai",
    }
  );

  assert.equal(decision.important, true);
  assert.equal(decision.score, 70);
});

test("fallback preserves delivery while respecting explicit suppression", () => {
  const decision = fallbackNotificationDecision(
    {
      ...baseCandidate,
      type: "important",
      important: true,
      payload: { suppressPush: true },
    },
    baseContext
  );

  assert.equal(decision.important, true);
  assert.equal(decision.shouldPush, false);
});

test("duplicate notifications stay in the inbox", () => {
  const decision = applyDecisionPolicy(
    baseCandidate,
    baseContext,
    {
      important: false,
      shouldPush: true,
      score: 60,
      reason: "Useful update.",
      source: "ai",
    },
    {
      duplicate: true,
      recentPushCount: 0,
      typeDecisionCount: 0,
      typeReadCount: 0,
    }
  );

  assert.equal(decision.action, "inbox_only");
  assert.match(decision.reason, /equivalent recent notification/);
});

test("push budget holds non-important notifications", () => {
  const decision = applyDecisionPolicy(
    baseCandidate,
    baseContext,
    {
      important: false,
      shouldPush: true,
      score: 65,
      reason: "Worth seeing.",
      source: "ai",
    },
    {
      duplicate: false,
      recentPushCount: 3,
      typeDecisionCount: 0,
      typeReadCount: 0,
    }
  );

  assert.equal(decision.action, "inbox_only");
  assert.match(decision.reason, /hourly push budget/);
});

test("protected social content cannot be rewritten by the model", () => {
  const candidate = {
    ...baseCandidate,
    type: "chat",
    title: "Farrel",
    body: "Can we focus at 7?",
  };
  const decision = applyDecisionPolicy(candidate, baseContext, {
    important: false,
    shouldPush: true,
    score: 62,
    reason: "Direct message.",
    source: "ai",
    tone: "urgent",
    pushTitle: "Invented urgent title",
    pushBody: "Invented message",
  });

  assert.equal(decision.pushTitle, candidate.title);
  assert.equal(decision.pushBody, candidate.body);
  assert.equal(decision.tone, "preserve");
});

test("low learned engagement holds low-scoring notifications", () => {
  const decision = applyDecisionPolicy(
    baseCandidate,
    baseContext,
    {
      important: false,
      shouldPush: true,
      score: 50,
      reason: "General update.",
      source: "ai",
    },
    {
      duplicate: false,
      recentPushCount: 0,
      typeDecisionCount: 10,
      typeReadCount: 1,
    }
  );

  assert.equal(decision.action, "inbox_only");
  assert.match(decision.reason, /learned engagement/);
});
