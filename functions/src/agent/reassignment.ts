// functions/src/agent/reassignment.ts
//
// Task Reassignment Agent (architecture §6.4, request flow §8).
//
// Reacts to context changes AFTER a plan exists — mood shifts, new routines,
// approaching deadlines, priority changes — and decides whether tasks should
// be rescheduled, swapped, or kept as-is.
//
// Hard rules enforced deterministically (the model proposes, this code disposes):
//   §9.5 deadline rule    — a task is never moved past its goal's deadline
//   §3.4 capability rule  — a day's total load never exceeds a realistic
//                           per-day capacity derived from the user's mood
//   §9.6 importance rule  — when proposals conflict, higher-importance goals
//                           win the better slots; their tasks are applied first
//
// If Gemini is unavailable, a deterministic fallback still protects the user:
// under a low mood it pushes the lightest low-importance tasks of an
// overloaded today to the next feasible day.

import * as admin from "firebase-admin";
import { getAI, defaultModel } from "../ai";
import { parseModelJson } from "../json";

export interface ReassignableTask {
  id: string;
  goalId: string;
  title: string;
  durationMinutes: number;
  load: string; // "light" | "focus" | "stretch"
  dayOffset: number; // days from today (0 = today)
  done: boolean;
}

export interface ReassignGoalInfo {
  id: string;
  title: string;
  importance: number; // 1–5 (5 = most important)
  deadlineDays: number; // days from today until the goal's deadline
}

export type ReassignmentTrigger =
  | "moodChanged"
  | "routineAdded"
  | "deadlineApproaching"
  | "priorityChanged"
  | "manual";

export interface ReassignmentInput {
  userId: string;
  trigger: ReassignmentTrigger;
  mood?: string;
  routines?: Array<{ title: string; startsAt: string; repeat: string }>;
  tasks: ReassignableTask[];
  goals: ReassignGoalInfo[];
  context?: Record<string, unknown>;
}

export interface TaskChange {
  taskId: string;
  goalId: string;
  fromDayOffset: number;
  toDayOffset: number;
  reason: string;
}

export interface ReassignmentResult {
  changed: boolean;
  changes: TaskChange[];
  explanation: string;
  degraded: boolean;
}

// Horizon we let the model think about; nothing is ever scheduled beyond it.
const MAX_HORIZON_DAYS = 60;

/** Realistic per-day workload ceiling in minutes, mood-aware for today and
 *  near-term days, settling to a steady baseline further out. */
export function capacityForDay(mood: string, dayOffset: number): number {
  const m = mood.toLowerCase();
  const todayCap = m.includes("overwhelm")
    ? 30
    : m.includes("tired") || m.includes("stress")
    ? 45
    : m.includes("great") || m.includes("energi")
    ? 150
    : 90;
  // Mood is a today-signal; assume gradual recovery to the 120-min baseline.
  if (dayOffset <= 0) return todayCap;
  if (dayOffset === 1) return Math.max(todayCap, 90);
  return 120;
}

interface ProposedChange {
  taskId: string;
  toDayOffset: number;
  reason: string;
}

/** Applies proposals in §9.6 importance order while enforcing §9.5 and §3.4.
 *  Returns only the changes that survived validation. */
export function validateProposals(
  proposals: ProposedChange[],
  tasks: ReassignableTask[],
  goals: ReassignGoalInfo[],
  mood: string
): TaskChange[] {
  const taskById = new Map(tasks.map((t) => [t.id, t]));
  const goalById = new Map(goals.map((g) => [g.id, g]));

  // Current minutes already booked per day (pending tasks only).
  const dayLoad = new Map<number, number>();
  for (const t of tasks) {
    if (t.done) continue;
    dayLoad.set(t.dayOffset, (dayLoad.get(t.dayOffset) ?? 0) + t.durationMinutes);
  }

  // §9.6 importance rule: apply changes for important goals first so they
  // claim capacity in the better slots before low-priority work does.
  const ordered = [...proposals].sort((a, b) => {
    const ga = goalById.get(taskById.get(a.taskId)?.goalId ?? "")?.importance ?? 3;
    const gb = goalById.get(taskById.get(b.taskId)?.goalId ?? "")?.importance ?? 3;
    return gb - ga;
  });

  const accepted: TaskChange[] = [];
  const seen = new Set<string>();

  for (const p of ordered) {
    if (seen.has(p.taskId)) continue; // one move per task per run
    const task = taskById.get(p.taskId);
    if (!task || task.done) continue;

    const goal = goalById.get(task.goalId);
    const to = Math.round(Number(p.toDayOffset));
    if (!Number.isFinite(to) || to < 0 || to === task.dayOffset) continue;

    // §9.5 deadline rule: never move work to or past the deadline day.
    const lastFeasibleDay = goal
      ? Math.max(0, Math.min(goal.deadlineDays - 1, MAX_HORIZON_DAYS))
      : MAX_HORIZON_DAYS;
    if (to > lastFeasibleDay) continue;

    // §3.4 capability rule: the destination day must stay under capacity.
    const destLoad = (dayLoad.get(to) ?? 0) + task.durationMinutes;
    if (destLoad > capacityForDay(mood, to)) continue;

    dayLoad.set(to, destLoad);
    dayLoad.set(task.dayOffset, (dayLoad.get(task.dayOffset) ?? 0) - task.durationMinutes);
    seen.add(p.taskId);
    accepted.push({
      taskId: task.id,
      goalId: task.goalId,
      fromDayOffset: task.dayOffset,
      toDayOffset: to,
      reason: String(p.reason ?? "").trim() || "Rebalanced for your current capacity.",
    });
  }

  return accepted;
}

/** No-AI fallback, bidirectional like the model path:
 *  - today over capacity → push the lightest, lowest-importance tasks to the
 *    next feasible day;
 *  - today has clear spare capacity → pull the most important near-term tasks
 *    back into today (how the schedule recovers after a low-mood day). */
function heuristicFallback(input: ReassignmentInput): TaskChange[] {
  const mood = input.mood ?? "okay";
  const cap = capacityForDay(mood, 0);
  const goalById = new Map(input.goals.map((g) => [g.id, g]));

  const todayPending = input.tasks.filter((t) => !t.done && t.dayOffset === 0);
  const todayLoad = todayPending.reduce((s, t) => s + t.durationMinutes, 0);

  const proposals: ProposedChange[] = [];

  if (todayLoad > cap) {
    // Move least-important, lightest tasks first; keep important work today.
    const movable = [...todayPending].sort((a, b) => {
      const ia = goalById.get(a.goalId)?.importance ?? 3;
      const ib = goalById.get(b.goalId)?.importance ?? 3;
      if (ia !== ib) return ia - ib;
      return a.durationMinutes - b.durationMinutes;
    });

    let load = todayLoad;
    for (const t of movable) {
      if (load <= cap) break;
      proposals.push({
        taskId: t.id,
        toDayOffset: 1,
        reason: `Moved to tomorrow to keep today under ${cap} minutes while your mood is "${mood}".`,
      });
      load -= t.durationMinutes;
    }
  } else if (cap - todayLoad >= 30) {
    // Spare room today — pull upcoming work in, most important goals first,
    // earliest-scheduled first. validateProposals re-checks capacity.
    const upcoming = input.tasks
      .filter((t) => !t.done && t.dayOffset > 0 && t.dayOffset <= 7)
      .sort((a, b) => {
        const ia = goalById.get(a.goalId)?.importance ?? 3;
        const ib = goalById.get(b.goalId)?.importance ?? 3;
        if (ia !== ib) return ib - ia;
        return a.dayOffset - b.dayOffset;
      });

    let load = todayLoad;
    for (const t of upcoming) {
      if (load + t.durationMinutes > cap) continue;
      proposals.push({
        taskId: t.id,
        toDayOffset: 0,
        reason: `Pulled forward to today — your mood is "${mood}" and you have capacity to spare.`,
      });
      load += t.durationMinutes;
    }
  }

  return validateProposals(proposals, input.tasks, input.goals, mood);
}

async function recordReassignmentMemory(
  input: ReassignmentInput,
  changes: TaskChange[]
): Promise<void> {
  try {
    const db = admin.firestore();
    const updates: Record<string, unknown> = {
      lastReassignmentTrigger: input.trigger,
      lastReassignmentAt: new Date().toISOString(),
      lastReassignmentChanges: changes.length,
    };
    if (input.mood) {
      updates.lastMood = input.mood;
      // Mood history (architecture §10): keep a rolling window of recent moods.
      updates.moodHistory = admin.firestore.FieldValue.arrayUnion({
        mood: input.mood,
        at: new Date().toISOString(),
      });
    }
    await db.collection("agent_memory").doc(input.userId).set(updates, { merge: true });
  } catch (e) {
    console.error("[agent/reassignment] memory write failed:", e);
  }
}

/** Previous mood from agent memory (§10) — lets the agent see the direction
 *  of a mood change ("Tired" → "Great" means capacity OPENED UP). */
async function loadPreviousMood(userId: string): Promise<string | null> {
  try {
    const snap = await admin
      .firestore()
      .collection("agent_memory")
      .doc(userId)
      .get();
    const last = snap.data()?.lastMood;
    return typeof last === "string" && last.trim().length > 0 ? last : null;
  } catch (e) {
    console.error("[agent/reassignment] loadPreviousMood failed:", e);
    return null;
  }
}

export async function reassignmentAgent(
  input: ReassignmentInput
): Promise<ReassignmentResult> {
  const mood = input.mood ?? "okay";
  const pending = input.tasks.filter((t) => !t.done);

  if (pending.length === 0) {
    return {
      changed: false,
      changes: [],
      explanation: "No pending tasks to reassign.",
      degraded: false,
    };
  }

  const goalLines = input.goals
    .map(
      (g) =>
        `- goalId=${g.id} "${g.title}" — importance ${g.importance}/5, deadline in ${g.deadlineDays} day(s)`
    )
    .join("\n");

  const taskLines = pending
    .map(
      (t) =>
        `- taskId=${t.id} (goalId=${t.goalId}) "${t.title}" — ${t.durationMinutes} min, ${t.load}, scheduled day ${t.dayOffset} (0 = today)`
    )
    .join("\n");

  const routineLines = (input.routines ?? [])
    .map((r) => `- "${r.title}" at ${r.startsAt} (${r.repeat})`)
    .join("\n");

  const capToday = capacityForDay(mood, 0);
  const previousMood =
    input.trigger === "moodChanged" ? await loadPreviousMood(input.userId) : null;
  const todayLoad = pending
    .filter((t) => t.dayOffset === 0)
    .reduce((s, t) => s + t.durationMinutes, 0);

  const moodShiftLine =
    previousMood && previousMood.toLowerCase() !== mood.toLowerCase()
      ? `The user's mood just shifted from "${previousMood}" (capacity ≈ ${capacityForDay(previousMood, 0)} min) to "${mood}" — earlier reassignments may have been made for the OLD capacity, so rebalance for the new one.`
      : "";

  const prompt = `
You are the Task Reassignment Agent in a productivity app. The user's context just changed and you must decide whether scheduled tasks should be rescheduled, swapped, or left alone.

Trigger: ${input.trigger}
Current mood: "${mood}" → realistic capacity today ≈ ${capToday} minutes; tomorrow ≈ ${capacityForDay(mood, 1)} minutes; later days ≈ 120 minutes.
Today currently holds ${todayLoad} minute(s) of pending tasks.
${moodShiftLine}

Goals:
${goalLines || "- (none)"}

Pending tasks (day 0 = today):
${taskLines}

${routineLines ? `User routines (fixed commitments — avoid stacking heavy task days on busy routine days):\n${routineLines}\n` : ""}
Rules:
1. NEVER move a task to a day on or after its goal's deadline. If the deadline is close, prefer keeping tasks where they are over risking the deadline.
2. NEVER let any single day's total task minutes exceed the capacity figures above.
3. Higher-importance goals (4–5) keep today's and the earliest slots; move lower-importance work first.
4. Rebalance in BOTH directions:
   - Today over capacity → push the lowest-importance, lightest tasks to later feasible days.
   - Today clearly UNDER capacity (e.g. mood improved, or tasks were pushed away under an earlier low mood) → pull the most important upcoming tasks back INTO today (toDayOffset 0) until today's capacity is well used. Recovering the schedule matters as much as protecting it.
5. Move as FEW tasks as needed to reach a balanced schedule. Only change nothing when today's load already sits comfortably near capacity.
6. Every change needs a short reason the user will read.

Respond ONLY with valid JSON:
{
  "changes": [ { "taskId": "...", "toDayOffset": 1, "reason": "..." } ],
  "explanation": "1–2 sentences telling the user what you changed and why — or why nothing needed to change"
}
If no change is needed, return "changes": [] with an explanation.`.trim();

  let changes: TaskChange[] = [];
  let explanation = "";
  let degraded = false;

  try {
    const ai = getAI();
    const { text } = await ai.generate({
      model: defaultModel,
      prompt,
      config: {
        temperature: 0.3,
        maxOutputTokens: 2560,
        responseMimeType: "application/json",
        thinkingConfig: { thinkingBudget: 512 },
      },
    });

    const parsed = parseModelJson<{
      changes?: Array<{ taskId?: string; toDayOffset?: number; reason?: string }>;
      explanation?: string;
    }>(text);

    const proposals: ProposedChange[] = (parsed.changes ?? [])
      .filter((c) => typeof c.taskId === "string")
      .map((c) => ({
        taskId: String(c.taskId),
        toDayOffset: Number(c.toDayOffset),
        reason: String(c.reason ?? ""),
      }));

    changes = validateProposals(proposals, input.tasks, input.goals, mood);
    explanation = String(parsed.explanation ?? "").trim();

    const droppedCount = proposals.length - changes.length;
    if (droppedCount > 0) {
      console.log(
        `[agent/reassignment] Dropped ${droppedCount} proposal(s) that violated deadline/capacity rules`
      );
    }
  } catch (e) {
    console.error("[agent/reassignment] LLM call failed, using heuristic:", e);
    degraded = true;
    changes = heuristicFallback(input);
    if (changes.length === 0) {
      explanation =
        "Your current schedule already fits your capacity, so I left it unchanged.";
    } else if (changes.every((c) => c.toDayOffset === 0)) {
      explanation = `Your mood is "${mood}", so I pulled ${changes.length} task(s) forward into today to use your extra capacity.`;
    } else {
      explanation = `Your mood is "${mood}", so I lightened today by moving ${changes.length} lower-priority task(s) to tomorrow.`;
    }
  }

  if (!explanation) {
    explanation =
      changes.length > 0
        ? `I rescheduled ${changes.length} task(s) to match your current capacity while keeping every deadline safe.`
        : "Your schedule still fits your capacity and deadlines, so nothing needed to move.";
  }

  await recordReassignmentMemory(input, changes);

  return { changed: changes.length > 0, changes, explanation, degraded };
}
