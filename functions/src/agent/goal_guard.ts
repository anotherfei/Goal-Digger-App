// functions/src/agent/goal_guard.ts
//
// Shared AI preflight guard for user goals. The planner and task generator
// should only create todos after this classifier says the goal is suitable.

import { getAI, defaultModel } from "../ai";
import { parseModelJson } from "../json";

export type GoalRejectionType =
  | "unclear"
  | "too_broad"
  | "impossible"
  | "harmful";

export interface GoalGuardResult {
  allowed: boolean;
  type: GoalRejectionType | null;
  reason: string | null;
  refinementPrompt: string | null;
}

type ModelGoalGuardResult = Partial<{
  allowed: boolean;
  type: string | null;
  reason: string | null;
  refinementPrompt: string | null;
}>;

const REJECTION_TYPES = new Set<GoalRejectionType>([
  "unclear",
  "too_broad",
  "impossible",
  "harmful",
]);

function rejection(
  type: GoalRejectionType,
  reason: string,
  refinementPrompt: string
): GoalGuardResult {
  return { allowed: false, type, reason, refinementPrompt };
}

function cleanText(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const cleaned = value.trim();
  return cleaned.length > 0 ? cleaned : null;
}

function defaultReason(type: GoalRejectionType): string {
  switch (type) {
    case "harmful":
      return "I can't create todos for this goal because it could cause harm, break laws, or produce a destructive outcome.";
    case "impossible":
      return "I can't plan this as written because it is not realistically achievable by a person in the real world.";
    case "too_broad":
      return "I can't break this into useful todos yet because the goal is too broad and has no clear finish line.";
    case "unclear":
    default:
      return "I can't break this into todos yet because the goal is unclear or missing a concrete outcome.";
  }
}

function defaultPrompt(type: GoalRejectionType): string {
  switch (type) {
    case "harmful":
      return "Please redefine this as a constructive, respectful, and achievable goal with a positive real-world outcome.";
    case "impossible":
      return "Please redefine it into an achievable version with a realistic finish line and timeframe.";
    case "too_broad":
      return "Please sharpen it with a measurable result, a smaller scope, and a timeframe.";
    case "unclear":
    default:
      return "Please rewrite it as a specific real-world outcome with clear scope and a success condition.";
  }
}

function normalizeGuardResult(raw: ModelGoalGuardResult): GoalGuardResult {
  if (raw.allowed === true) {
    return {
      allowed: true,
      type: null,
      reason: null,
      refinementPrompt: null,
    };
  }

  const type = REJECTION_TYPES.has(raw.type as GoalRejectionType)
    ? (raw.type as GoalRejectionType)
    : "unclear";

  return rejection(
    type,
    cleanText(raw.reason) ?? defaultReason(type),
    cleanText(raw.refinementPrompt) ?? defaultPrompt(type)
  );
}

function blockedWhenGuardUnavailable(): GoalGuardResult {
  return rejection(
    "unclear",
    "I can't verify this goal right now, so I won't generate todos for it.",
    "Please try again, or rewrite it as a clear, constructive, achievable real-world outcome."
  );
}

function contextForPrompt(context?: Record<string, unknown>): string {
  if (!context || Object.keys(context).length === 0) return "{}";
  try {
    return JSON.stringify(context).slice(0, 2000);
  } catch {
    return "{}";
  }
}

export async function evaluateGoal(
  goal: string,
  context?: Record<string, unknown>
): Promise<GoalGuardResult> {
  const trimmed = goal.trim();
  if (trimmed.length === 0) {
    return rejection(
      "unclear",
      "I can't break this into todos yet because the goal is blank.",
      defaultPrompt("unclear")
    );
  }

  const prompt = `
You are goal_guard.ts, the first gate for a productivity planning app.

Your only job is to decide whether the app may generate a task breakdown for the user's goal. Do not generate tasks, milestones, plans, advice, or instructions.

Reject the goal with allowed=false when it is:
- ambiguous, unclear, vague, missing a concrete outcome, or too broad to schedule;
- impossible or unrealistic as written for a human in the real world;
- destructive, harmful, illegal, violent, exploitative, harassing, or lacks a constructive positive outcome;
- centered on sexual pursuit of random, unknown, unspecified, or non-consenting people, or otherwise cannot be framed as a respectful and safe real-world productivity goal.

If rejected, explain briefly why the app cannot break it down and ask the user to sharpen or redefine the goal until it is achievable and constructive. Do not soften harmful goals into operational steps.

Return ONLY valid JSON using exactly this shape:
{
  "allowed": boolean,
  "type": "unclear" | "too_broad" | "impossible" | "harmful" | null,
  "reason": string | null,
  "refinementPrompt": string | null
}

For allowed=true, type, reason, and refinementPrompt must be null.
For allowed=false, choose the single best type and provide reason and refinementPrompt.

Goal: ${JSON.stringify(trimmed)}
Context: ${contextForPrompt(context)}
`.trim();

  try {
    const ai = getAI();
    const { text } = await ai.generate({
      model: defaultModel,
      prompt,
      config: {
        temperature: 0,
        maxOutputTokens: 700,
        responseMimeType: "application/json",
        thinkingConfig: { thinkingBudget: 0 },
      },
    });

    return normalizeGuardResult(parseModelJson<ModelGoalGuardResult>(text));
  } catch (e) {
    console.error("[goal_guard] AI goal evaluation failed:", e);
    return blockedWhenGuardUnavailable();
  }
}

export function goalGuardMessage(result: GoalGuardResult): string {
  const parts = [result.reason, result.refinementPrompt].filter(
    (part): part is string => typeof part === "string" && part.trim().length > 0
  );
  return parts.join("\n\n");
}
