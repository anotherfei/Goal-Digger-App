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
