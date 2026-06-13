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
  | "negative"
  | "harmful";

// Deadline feasibility (architecture §9.2): when the user's chosen deadline
// is unrealistic for an ordinary person, the guard proposes a better one.
// The goal itself stays ALLOWED — the client explains the reasoning and asks
// the user to agree (adjust the deadline) or decline (keep it as chosen).
export interface DeadlineSuggestion {
  suggestedDays: number;
  reason: string;
}

export interface GoalGuardResult {
  allowed: boolean;
  type: GoalRejectionType | null;
  reason: string | null;
  refinementPrompt: string | null;
  // Positive goal filtering (architecture §9.1): false when the goal was
  // rejected because it is negatively framed (avoidance, self-criticism,
  // destructiveness). The client should explain why and ask the user to
  // re-input the goal in positive, constructive language.
  positiveGoal: boolean;
  // Non-null only for allowed goals whose deadline is clearly unrealistic.
  deadlineSuggestion: DeadlineSuggestion | null;
}

type ModelGoalGuardResult = Partial<{
  allowed: boolean;
  type: string | null;
  reason: string | null;
  refinementPrompt: string | null;
  deadlineFeasible: boolean;
  suggestedDeadlineDays: number | null;
  deadlineReason: string | null;
}>;

const REJECTION_TYPES = new Set<GoalRejectionType>([
  "unclear",
  "too_broad",
  "impossible",
  "negative",
  "harmful",
]);

function rejection(
  type: GoalRejectionType,
  reason: string,
  refinementPrompt: string
): GoalGuardResult {
  return {
    allowed: false,
    type,
    reason,
    refinementPrompt,
    // §9.1: only negativity-related rejections mean the goal failed the
    // positive-goal filter; unclear/too-broad goals may still be positive.
    positiveGoal: type !== "negative" && type !== "harmful",
    deadlineSuggestion: null,
  };
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
    case "negative":
      return "I can't plan this goal as written because it is framed negatively — it focuses on what to avoid or stop instead of a positive outcome to work toward.";
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
    case "negative":
      return "Please re-enter the goal as a positive outcome you want to achieve (e.g. \"Pass my exams with confident preparation\" instead of \"stop failing my exams\").";
    case "impossible":
      return "Please redefine it into an achievable version with a realistic finish line and timeframe.";
    case "too_broad":
      return "Please sharpen it with a measurable result, a smaller scope, and a timeframe.";
    case "unclear":
    default:
      return "Please rewrite it as a specific real-world outcome with clear scope and a success condition.";
  }
}

// Accept the model's deadline verdict only when it is a meaningfully
// different, sane day count — otherwise treat the deadline as feasible.
function normalizeDeadlineSuggestion(
  raw: ModelGoalGuardResult,
  currentDeadlineDays: number | null
): DeadlineSuggestion | null {
  if (raw.deadlineFeasible !== false) return null;
  const suggested = Math.round(Number(raw.suggestedDeadlineDays));
  if (!Number.isFinite(suggested) || suggested < 1 || suggested > 730) {
    return null;
  }
  if (currentDeadlineDays !== null && suggested === currentDeadlineDays) {
    return null;
  }
  const reason = cleanText(raw.deadlineReason);
  if (!reason) return null;
  return { suggestedDays: suggested, reason };
}

function normalizeGuardResult(
  raw: ModelGoalGuardResult,
  currentDeadlineDays: number | null
): GoalGuardResult {
  if (raw.allowed === true) {
    return {
      allowed: true,
      type: null,
      reason: null,
      refinementPrompt: null,
      positiveGoal: true,
      deadlineSuggestion: normalizeDeadlineSuggestion(raw, currentDeadlineDays),
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

  const deadlineDaysRaw = Number(context?.deadlineDays);
  const deadlineDays =
    Number.isFinite(deadlineDaysRaw) && deadlineDaysRaw >= 1
      ? Math.round(deadlineDaysRaw)
      : null;

  const prompt = `
You are goal_guard.ts, the first gate for a productivity planning app.

Your job is to decide whether the app may generate a task breakdown for the user's goal, and whether the user's chosen deadline is realistic. Do not generate tasks, milestones, plans, advice, or instructions.

Reject the goal with allowed=false when it is:
- ambiguous, unclear, vague, missing a concrete outcome, or too broad to schedule (type "unclear" or "too_broad");
- impossible or unrealistic as written for a human in the real world (type "impossible");
- phrased negatively, self-critically, or as avoidance — focused on what to stop, quit, or avoid rather than a positive outcome to work toward, e.g. "stop failing my exams", "quit being lazy" (type "negative");
- destructive, harmful, illegal, violent, exploitative, harassing, or lacks a constructive positive outcome (type "harmful");
- centered on sexual pursuit of random, unknown, unspecified, or non-consenting people, or otherwise cannot be framed as a respectful and safe real-world productivity goal (type "harmful").

If rejected, explain briefly why the app cannot break it down and ask the user to re-enter the goal until it is achievable and constructive. For type "negative", the reason must say specifically what makes the framing negative, and the refinementPrompt must ask the user to re-input the goal as a positive outcome (you may include one example reframing of THEIR goal inside the refinementPrompt). Do not soften harmful goals into operational steps.

Deadline feasibility (only for allowed goals):
The context field "deadlineDays" is how many days from today the user wants this goal reached. The context also includes the goal's "category", "priority" (1-5), and "existingDailyMinutes" — minutes already booked by the user's existing tasks for each day from today up to the deadline (max 30 entries). Judge whether an ordinary person, working on this goal alongside normal daily life, can realistically reach it in that time. A sustainable day holds roughly 90-120 minutes of goal work INCLUDING what is already booked.
- The deadline is unrealistic when the timeframe is far too short for the work involved (e.g. "become a fluent speaker" in 7 days), OR when existingDailyMinutes shows the days before the deadline are already so full (near or above ~90-120 min/day) that there is no room left for this new goal's tasks.
- If unrealistic for either reason, set deadlineFeasible=false, propose a realistic suggestedDeadlineDays (integer days from today, far enough out to leave real free capacity), and write deadlineReason: 1-2 sentences explaining concretely why the current deadline does not work (mention the already-full schedule when that is the cause) and why the suggested one does. Do NOT reject the goal for its deadline — deadline problems are a suggestion, not a rejection.
- If the deadline is plausible (even if ambitious), or no deadlineDays is given, set deadlineFeasible=true and leave suggestedDeadlineDays and deadlineReason null. Only flag clear mismatches; do not nitpick workable deadlines.

Return ONLY valid JSON using exactly this shape:
{
  "allowed": boolean,
  "type": "unclear" | "too_broad" | "impossible" | "negative" | "harmful" | null,
  "reason": string | null,
  "refinementPrompt": string | null,
  "deadlineFeasible": boolean,
  "suggestedDeadlineDays": number | null,
  "deadlineReason": string | null
}

For allowed=true, type, reason, and refinementPrompt must be null.
For allowed=false, choose the single best type, provide reason and refinementPrompt, and set deadlineFeasible=true with null deadline fields.

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

    return normalizeGuardResult(
      parseModelJson<ModelGoalGuardResult>(text),
      deadlineDays
    );
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
