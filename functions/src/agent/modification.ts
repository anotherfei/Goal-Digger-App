// functions/src/agent/modification.ts
//
// Task Modification Agent (architecture §6.3).
//
// Handles direct user requests to modify an already-generated task plan.
// Unlike re-running the planner, this agent sees the CURRENT draft and the
// user's change request side-by-side, so adjustments are incremental and
// previous edits aren't lost.
//
// Decision rules implemented here:
//   §9.2 feasibility check — is the change realistic for the schedule/deadline?
//   §9.3 clarification rule — ambiguous request → ask a question, change nothing
//   §9.4 confirmation rule — plausible but risky → explain concern, wait for yes
//   §9.5 deadline rule      — never move work past the deadline window
//
// The model decides WHICH verdict applies; deterministic post-validation
// enforces the hard limits regardless of what the model returns.

import { getAI, defaultModel } from "../ai";
import { parseModelJson } from "../json";

export interface ModifiableTask {
  title: string;
  durationMinutes: number;
  load: "light" | "focus" | "stretch";
  dayOffset: number;
}

export interface ModificationInput {
  goal: string;
  request: string;
  currentTasks: ModifiableTask[];
  // Session context: deadlineDays, mood, streak, completedToday, totalToday…
  context?: Record<string, unknown>;
  // True when the user already answered "yes" to a §9.4 confirmation question.
  force?: boolean;
}

export type ModificationStatus =
  | "applied"   // change was sensible → tasks contains the revised plan
  | "clarify"   // request ambiguous → question asks what they meant (§9.3)
  | "confirm"   // plausible but risky → question asks for a yes/no (§9.4)
  | "rejected"; // infeasible/contradictory → explanation says why (§9.2/§9.5)

export interface ModificationResult {
  status: ModificationStatus;
  tasks: ModifiableTask[];
  explanation: string;
  question: string | null;
  degraded: boolean;
}

const VALID_LOADS = new Set(["light", "focus", "stretch"]);
const MAX_TASKS = 30;

// Realistic per-day workload ceiling (minutes) used for the risk check.
function dailyCapacityMinutes(mood: string): number {
  const m = mood.toLowerCase();
  if (m.includes("overwhelm")) return 30;
  if (m.includes("tired") || m.includes("stress")) return 45;
  if (m.includes("great") || m.includes("energi")) return 150;
  return 90;
}

function sanitizeTasks(
  raw: unknown,
  deadlineDays: number
): ModifiableTask[] {
  if (!Array.isArray(raw)) return [];
  return raw
    .filter(
      (t): t is Record<string, unknown> =>
        !!t && typeof t === "object" && typeof (t as { title?: unknown }).title === "string"
    )
    .map((t) => ({
      title: String(t.title).trim(),
      durationMinutes: Math.min(90, Math.max(5, Math.round(Number(t.durationMinutes ?? 20)))),
      load: (VALID_LOADS.has(String(t.load)) ? String(t.load) : "focus") as ModifiableTask["load"],
      // §9.5 deadline rule: a task can never land outside the deadline window.
      dayOffset: Math.min(
        Math.max(1, deadlineDays) - 1,
        Math.max(0, Math.round(Number(t.dayOffset ?? 0)))
      ),
    }))
    .filter((t) => t.title.length > 0)
    .slice(0, MAX_TASKS);
}

function unavailableResult(input: ModificationInput): ModificationResult {
  return {
    status: "rejected",
    tasks: input.currentTasks,
    explanation:
      "The AI modifier is unavailable right now, so I can't safely apply that change. The current plan is unchanged.",
    question: null,
    degraded: true,
  };
}

export async function modificationAgent(
  input: ModificationInput
): Promise<ModificationResult> {
  const request = input.request.trim();
  if (request.length === 0) {
    return {
      status: "clarify",
      tasks: input.currentTasks,
      explanation: "I didn't catch a change request.",
      question: "What would you like me to change about the plan?",
      degraded: false,
    };
  }

  const ctx = input.context ?? {};
  const deadlineDays = Math.max(1, Number(ctx.deadlineDays ?? 14));
  const mood = String(ctx.mood ?? "okay");
  const capacity = dailyCapacityMinutes(mood);

  const taskLines = input.currentTasks
    .map(
      (t, i) =>
        `${i + 1}. "${t.title}" — ${t.durationMinutes} min, ${t.load}, day ${t.dayOffset + 1}`
    )
    .join("\n");

  const prompt = `
You are the Task Modification Agent in a productivity app. The user has a draft task plan and is asking for a change. Decide whether the change makes sense, then respond with ONE of four verdicts.

Goal: "${input.goal}"
Deadline: ${deadlineDays} day(s) from today (day 1 = today, day ${deadlineDays} = last day).
User's current mood: ${mood} (realistic capacity ≈ ${capacity} focused minutes per day).
${input.force ? "The user has ALREADY CONFIRMED they want this change even though it is demanding — apply it.\n" : ""}
Current plan:
${taskLines || "(no tasks yet)"}

User request: "${request}"

Verdicts:
- "applied": the request is clear and realistic. Return the FULL revised task list (modified, added, removed, or reordered as requested). Keep tasks the user didn't ask to change. Each task: title (≤10 words, starts with a verb), durationMinutes (5–90), load ("light" ≤15 min easy, "focus" 16–35 min, "stretch" >35 min demanding), dayOffset (0-based day index, 0 = today, max ${deadlineDays - 1}).
- "clarify": the request is ambiguous or contradictory — you genuinely can't tell what to change. Ask ONE short question. Do not change tasks.
- "confirm": the request is possible but risky — it would exceed a normal person's daily capacity (~${capacity} min/day right now), crowd everything near the deadline, or undermine the goal. Briefly explain the concern, ask a yes/no question, and do NOT change tasks yet.
- "rejected": the request is impossible within the deadline, beyond ordinary human capability, or works against the goal itself. Explain why in a personalised, non-judgmental way and suggest what would work instead. Do not change tasks.

Never schedule work past day ${deadlineDays}. Never produce more than ${MAX_TASKS} tasks.
Every task title must be DOABLE work fully under the user's control — never an outcome target like "reach N subscribers/views/sales"; describe the work that produces the outcome instead.

Respond ONLY with valid JSON:
{
  "status": "applied" | "clarify" | "confirm" | "rejected",
  "tasks": [ { "title": "...", "durationMinutes": 20, "load": "focus", "dayOffset": 0 } ],
  "explanation": "1–2 sentences explaining what you did or why not",
  "question": "the clarifying or yes/no question, or null"
}
For "applied", tasks is the full revised plan. For every other status, tasks must be [].`.trim();

  try {
    const ai = getAI();
    const { text } = await ai.generate({
      model: defaultModel,
      prompt,
      config: {
        temperature: 0.35,
        maxOutputTokens: 3072,
        responseMimeType: "application/json",
        thinkingConfig: { thinkingBudget: 512 },
      },
    });

    const parsed = parseModelJson<{
      status?: string;
      tasks?: unknown;
      explanation?: string;
      question?: string | null;
    }>(text);

    const status = String(parsed.status ?? "").trim() as ModificationStatus;
    const explanation = String(parsed.explanation ?? "").trim();
    const question =
      typeof parsed.question === "string" && parsed.question.trim().length > 0
        ? parsed.question.trim()
        : null;

    if (status === "applied") {
      const tasks = sanitizeTasks(parsed.tasks, deadlineDays);
      if (tasks.length === 0) {
        // Model claimed success but returned nothing usable — keep the plan.
        return {
          status: "rejected",
          tasks: input.currentTasks,
          explanation:
            explanation ||
            "I couldn't produce a valid revision for that request, so the plan is unchanged.",
          question: null,
          degraded: true,
        };
      }
      return {
        status: "applied",
        tasks,
        explanation: explanation || "Done — I updated the plan as requested.",
        question: null,
        degraded: false,
      };
    }

    if (status === "clarify" || status === "confirm") {
      return {
        status,
        tasks: input.currentTasks,
        explanation:
          explanation ||
          (status === "confirm"
            ? "That change looks demanding for your current capacity."
            : "I need a bit more detail before changing the plan."),
        question:
          question ??
          (status === "confirm"
            ? "Are you sure you want to go ahead? (yes / no)"
            : "Could you describe the change more specifically?"),
        degraded: false,
      };
    }

    if (status === "rejected") {
      return {
        status: "rejected",
        tasks: input.currentTasks,
        explanation:
          explanation ||
          "That change isn't realistic within the current deadline, so the plan is unchanged.",
        question: null,
        degraded: false,
      };
    }

    console.warn(`[agent/modification] Unknown status "${status}" from model`);
    return unavailableResult(input);
  } catch (e) {
    console.error("[agent/modification] LLM call failed:", e);
    return unavailableResult(input);
  }
}
