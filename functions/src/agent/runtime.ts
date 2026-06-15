// functions/src/agent/runtime.ts
//
// Agentic runtime — orchestrates the full plan→execute→reflect loop.
//
// Flow:
//   1. Load user memory from Firestore
//   2. plannerAgent  → Gemini reasons about WHICH tools to use (LLM-driven)
//   3. runtime       → executes the chosen tools with TRUSTED args, chaining
//                      results between dependent tools (analyzeHabits feeds
//                      scheduleTasks). Independent tools run in parallel.
//   4. reflectionAgent → Gemini generates personalised insights
//   5. Persist insights + learned preferences back to Firestore memory
//
// Design notes (why this differs from a naive forward pass):
//   • The planner only SELECTS tools. The runtime owns the actual tool args so
//     a model that fails to transcribe numeric context can't corrupt execution.
//   • Tool results flow downstream: the burnout risk computed by analyzeHabits
//     is injected into scheduleTasks so adaptive scheduling actually fires.
//   • A `degraded` flag is returned so the client can tell a real agentic
//     result from a fully fallen-back one.

import * as admin from "firebase-admin";
import {
  evaluateGoal,
  goalGuardMessage,
  type DeadlineSuggestion,
  type GoalGuardResult,
} from "./goal_guard";
import { plannerAgent } from "./planner";
import { reflectionAgent } from "./reflection";
import { toolRegistry } from "./tools/registry";
import type { MilestoneTask } from "./tools/tool_create_milestones";

interface AgentRunInput {
  userId: string;
  goal: string;
  context?: Record<string, unknown>;
}

interface ExecutionRecord {
  tool: string;
  title: string;
  result?: unknown;
  error?: string;
}

interface HabitAnalysis {
  burnoutRisk?: "low" | "medium" | "high";
  strongestHours?: string[];
  productivityInsight?: string;
}

interface ScheduleResult {
  recommendedDailyMinutes?: number;
  scheduleNote?: string;
  totalSessions?: number;
  sessions?: unknown[];
}

interface MilestonesResult {
  milestones?: string[];
  tasks?: MilestoneTask[];
  feasibilityNote?: string | null;
  requestedCount?: number | null;
  needsConfirmation?: boolean;
}

interface AgentRunResult {
  strategy: string;
  plan: Record<string, unknown>;
  executionResults: ExecutionRecord[];
  reflections: unknown[];
  goalRejected: boolean;
  goalRejectionType: string | null;
  goalRejectionReason: string | null;
  goalRefinementPrompt: string | null;
  // Positive goal filtering (§9.1): false when the goal was rejected for
  // negative/destructive framing — the client should show the rejection
  // reason and ask the user to re-input a positively framed goal.
  positiveGoal: boolean;
  // Deadline feasibility: non-null when the goal is allowed but its deadline
  // is unrealistic. The client shows the reason and asks the user whether to
  // adopt the suggested deadline (agree → adjust, decline → keep as-is).
  deadlineSuggestion: DeadlineSuggestion | null;
  // Structured, ready-to-consume outputs (the client reads these directly):
  milestones: string[];
  // Fully AI-decided tasks (title + duration + load + day). The client uses
  // these directly instead of inferring durations/loads/days itself.
  milestoneTasks: MilestoneTask[];
  milestoneNote: string | null;
  milestoneNeedsConfirmation: boolean;
  habitInsight: string | null;
  burnoutRisk: string | null;
  schedule: ScheduleResult | null;
  memorySnapshot: Record<string, unknown>;
  memoryUpdated: boolean;
  degraded: boolean;
}

// ── Firestore memory helpers ──────────────────────────────────────────────────

async function loadMemory(userId: string): Promise<Record<string, unknown>> {
  try {
    const db = admin.firestore();
    const snap = await db.collection("agent_memory").doc(userId).get();
    return snap.exists ? (snap.data() as Record<string, unknown>) : {};
  } catch (e) {
    console.error(`[agent/runtime] loadMemory failed for uid=${userId}:`, e);
    return {};
  }
}

async function saveMemory(
  userId: string,
  updates: Record<string, unknown>
): Promise<void> {
  try {
    const db = admin.firestore();
    await db
      .collection("agent_memory")
      .doc(userId)
      .set(updates, { merge: true });
  } catch (e) {
    console.error(`[agent/runtime] saveMemory failed for uid=${userId}:`, e);
    // Non-fatal — session still returns results to the client
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/** Parse the leading hour from a "HH:MM" string (e.g. "09:00" → 9). */
function parseStartHour(hours?: string[]): number | undefined {
  if (!hours || hours.length === 0) return undefined;
  const match = /^(\d{1,2})/.exec(String(hours[0]).trim());
  return match ? Number(match[1]) : undefined;
}

function rejectedGoalResult(
  goal: string,
  context: Record<string, unknown>,
  review: GoalGuardResult
): AgentRunResult {
  const message = goalGuardMessage(review);
  return {
    strategy: "goal-refinement-required",
    plan: {
      strategy: "goal-refinement-required",
      goal,
      context,
      rejectionType: review.type,
      rejectionReason: review.reason,
      refinementPrompt: review.refinementPrompt,
    },
    executionResults: [],
    reflections: [
      {
        type: "goal-refinement-required",
        insight: review.reason ?? message,
        recommendation:
          review.refinementPrompt ??
          "Please rewrite the goal into a clear, constructive, achievable outcome.",
        memoryKeysUsed: [],
      },
    ],
    goalRejected: true,
    goalRejectionType: review.type,
    goalRejectionReason: review.reason,
    goalRefinementPrompt: review.refinementPrompt,
    positiveGoal: review.positiveGoal,
    deadlineSuggestion: null,
    milestones: [],
    milestoneTasks: [],
    milestoneNote: message,
    milestoneNeedsConfirmation: false,
    habitInsight: null,
    burnoutRisk: null,
    schedule: null,
    memorySnapshot: {},
    memoryUpdated: false,
    degraded: false,
  };
}

// ── Main runtime ──────────────────────────────────────────────────────────────

export async function runAgent(input: AgentRunInput): Promise<AgentRunResult> {
  const { userId, goal, context = {} } = input;

  console.log(`[agent/runtime] Starting agent for uid=${userId}, goal="${goal}"`);

  // §9.1 positive goal filtering happens inside the guard: negatively framed
  // goals are rejected with a reason and a prompt to re-input the goal.
  const goalReview = await evaluateGoal(goal, context);
  if (!goalReview.allowed) {
    console.log(
      `[agent/runtime] Refusing goal before planning: ${goalReview.type}`
    );
    return rejectedGoalResult(goal, context, goalReview);
  }

  // Step 1: Load user memory
  const memory = await loadMemory(userId);

  // Step 2: AI planner decides which tools to invoke
  const availableTools = toolRegistry.map((tool) => tool.name);
  let plan = { strategy: "multi-step-goal-planning", goal, steps: [] as Array<{
    tool: string;
    args: Record<string, unknown>;
    title: string;
  }> };
  let degraded = false;

  try {
    plan = (await plannerAgent({
      goal,
      memory,
      tools: availableTools,
      context,
    })) as typeof plan;
    console.log(
      `[agent/runtime] Plan: strategy="${plan.strategy}", steps=${plan.steps.length}`
    );
  } catch (e) {
    console.error("[agent/runtime] plannerAgent failed:", e);
    degraded = true;
  }

  // Which tools did the planner select? (Titles preserved for nicer output.)
  const selected = new Set(plan.steps.map((s) => s.tool));
  const titleFor = new Map(plan.steps.map((s) => [s.tool, s.title]));

  // If the planner produced nothing usable, run the full default toolset so the
  // agent still delivers value — but flag the session as degraded.
  if (selected.size === 0) {
    degraded = true;
    for (const t of availableTools) selected.add(t);
  }

  // Step 3: Execute tools with TRUSTED args and result chaining.
  const executionResults: ExecutionRecord[] = [];

  const exec = async (
    toolName: string,
    args: Record<string, unknown>,
    fallbackTitle: string
  ): Promise<unknown | null> => {
    const tool = toolRegistry.find((t) => t.name === toolName);
    if (!tool) {
      console.warn(`[agent/runtime] Unknown tool "${toolName}" — skipping`);
      return null;
    }
    const title = titleFor.get(toolName) ?? fallbackTitle;
    try {
      console.log(`[agent/runtime] Executing tool: ${toolName}`);
      const result = await tool.execute(args);
      executionResults.push({ tool: toolName, title, result });
      return result;
    } catch (e) {
      console.error(`[agent/runtime] Tool "${toolName}" failed:`, e);
      degraded = true;
      executionResults.push({ tool: toolName, title, error: String(e) });
      return null;
    }
  };

  // Phase 1 — independent tools run in parallel (analysis + milestones).
  // Results are captured from Promise.all (not via closure assignment) so the
  // types stay precise and don't get narrowed to `never`.
  const [habitRes, milestoneRes] = await Promise.all([
    selected.has("analyzeHabits")
      ? exec("analyzeHabits", { goal, memory, context }, "Analyze productivity signals")
      : Promise.resolve(null),
    selected.has("createMilestones")
      ? exec("createMilestones", { goal, context }, "Generate milestone roadmap")
      : Promise.resolve(null),
  ]);
  const habitAnalysis = habitRes as HabitAnalysis | null;
  const milestonesResult = milestoneRes as MilestonesResult | null;

  // Phase 2 — scheduleTasks, ENRICHED with what analyzeHabits learned.
  // This is the chaining the original code was missing: burnout risk and
  // preferred hours flow from analysis into the schedule so the adaptive
  // (burnout-aware) scheduling path actually fires.
  let scheduleResult: ScheduleResult | null = null;
  if (selected.has("scheduleTasks")) {
    const analysis: HabitAnalysis = habitAnalysis ?? {};
    const enrichedContext: Record<string, unknown> = {
      ...context,
      burnoutRisk:
        analysis.burnoutRisk ?? (context.burnoutRisk as string) ?? "low",
      preferredStartHour:
        parseStartHour(analysis.strongestHours) ??
        (context.preferredStartHour as number) ??
        (memory.preferredStartHour as number),
    };
    scheduleResult = (await exec(
      "scheduleTasks",
      { context: enrichedContext },
      "Schedule deep work sessions"
    )) as ScheduleResult | null;
  }

  // Step 4: AI reflection — synthesises insights from results
  let reflections: unknown[] = [];
  try {
    reflections = await reflectionAgent({
      goal,
      plan,
      executionResults,
      memory,
    });
    console.log(`[agent/runtime] Reflections generated: ${reflections.length}`);
  } catch (e) {
    console.error("[agent/runtime] reflectionAgent failed:", e);
    degraded = true;
    reflections = [
      {
        type: "agent-summary",
        insight: `Agent completed ${executionResults.length} tool(s) for "${goal}".`,
        recommendation: "Review the plan and start with the first milestone.",
        memoryKeysUsed: Object.keys(memory),
      },
    ];
  }

  // Step 5: Persist insights AND learned preferences (closing the memory loop).
  const analysis: HabitAnalysis = habitAnalysis ?? {};
  const schedule: ScheduleResult = scheduleResult ?? {};

  const memoryUpdates: Record<string, unknown> = {
    lastGoal: goal,
    lastAgentRun: new Date().toISOString(),
    totalAgentRuns: ((memory.totalAgentRuns as number) ?? 0) + 1,
    reflectionCount:
      ((memory.reflectionCount as number) ?? 0) + reflections.length,
  };

  if (schedule.recommendedDailyMinutes) {
    memoryUpdates.recommendedDailyMinutes = schedule.recommendedDailyMinutes;
  }
  // Previously read by analyzeHabits but never written — now we learn them.
  if (analysis.strongestHours && analysis.strongestHours.length > 0) {
    memoryUpdates.preferredWorkHours = analysis.strongestHours;
    const startHour = parseStartHour(analysis.strongestHours);
    if (startHour !== undefined) memoryUpdates.preferredStartHour = startHour;
  }
  if (analysis.burnoutRisk) {
    memoryUpdates.lastBurnoutRisk = analysis.burnoutRisk;
  }

  await saveMemory(userId, memoryUpdates);

  const milestoneTasks = Array.isArray(milestonesResult?.tasks)
    ? (milestonesResult!.tasks as MilestoneTask[])
    : [];
  const milestones = Array.isArray(milestonesResult?.milestones)
    ? (milestonesResult!.milestones as string[])
    : milestoneTasks.map((t) => t.title);

  return {
    strategy: plan.strategy,
    plan: plan as unknown as Record<string, unknown>,
    executionResults,
    reflections,
    goalRejected: false,
    goalRejectionType: null,
    goalRejectionReason: null,
    goalRefinementPrompt: null,
    positiveGoal: true,
    deadlineSuggestion: goalReview.deadlineSuggestion,
    milestones,
    milestoneTasks,
    milestoneNote: milestonesResult?.feasibilityNote ?? null,
    milestoneNeedsConfirmation: milestonesResult?.needsConfirmation ?? false,
    habitInsight: analysis.productivityInsight ?? null,
    burnoutRisk: analysis.burnoutRisk ?? null,
    schedule: scheduleResult,
    memorySnapshot: { ...memory, ...memoryUpdates },
    memoryUpdated: true,
    degraded,
  };
}
