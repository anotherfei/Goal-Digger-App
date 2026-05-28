// functions/src/agent/runtime.ts
//
// Agentic runtime — orchestrates the full plan→execute→reflect loop.
//
// Flow:
//   1. Load user memory from Firestore
//   2. plannerAgent  → Gemini reasons about which tools to use (LLM-driven)
//   3. toolRegistry  → execute each chosen tool (some are AI-enriched)
//   4. reflectionAgent → Gemini generates personalised insights
//   5. Persist insights back to Firestore memory
//
// All steps are wrapped in try-catch so a single tool failure never
// aborts the entire session — partial results are always returned.

import * as admin from "firebase-admin";
import { plannerAgent } from "./planner";
import { reflectionAgent } from "./reflection";
import { toolRegistry } from "./tools/registry";

interface AgentRunInput {
  userId: string;
  goal: string;
  context?: Record<string, unknown>;
}

interface AgentRunResult {
  plan: Record<string, unknown>;
  executionResults: unknown[];
  reflections: unknown[];
  memorySnapshot: Record<string, unknown>;
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

// ── Main runtime ──────────────────────────────────────────────────────────────

export async function runAgent(input: AgentRunInput): Promise<AgentRunResult> {
  const { userId, goal, context = {} } = input;

  console.log(`[agent/runtime] Starting agent for uid=${userId}, goal="${goal}"`);

  // Step 1: Load user memory
  const memory = await loadMemory(userId);

  // Step 2: AI planner decides which tools to invoke
  const availableTools = toolRegistry.map((tool) => tool.name);
  let plan = { strategy: "multi-step-goal-planning", goal, steps: [] as unknown[] };

  try {
    plan = await plannerAgent({ goal, memory, tools: availableTools, context });
    console.log(
      `[agent/runtime] Plan: strategy="${plan.strategy}", steps=${plan.steps.length}`
    );
  } catch (e) {
    console.error("[agent/runtime] plannerAgent failed:", e);
    // Proceed with empty plan — reflection will still run
  }

  // Step 3: Execute each planned tool step
  const executionResults: unknown[] = [];

  for (const step of plan.steps as Array<{
    tool: string;
    args: Record<string, unknown>;
    title: string;
  }>) {
    const tool = toolRegistry.find((t) => t.name === step.tool);
    if (!tool) {
      console.warn(`[agent/runtime] Unknown tool "${step.tool}" — skipping`);
      continue;
    }

    try {
      console.log(`[agent/runtime] Executing tool: ${step.tool}`);
      const result = await tool.execute(step.args);
      executionResults.push({ tool: step.tool, title: step.title, result });
    } catch (e) {
      console.error(`[agent/runtime] Tool "${step.tool}" failed:`, e);
      executionResults.push({
        tool: step.tool,
        title: step.title,
        error: String(e),
      });
    }
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
    reflections = [
      {
        type: "agent-summary",
        insight: `Agent completed ${executionResults.length} tool(s) for "${goal}".`,
        recommendation: "Review the plan and start with the first milestone.",
        memoryKeysUsed: Object.keys(memory),
      },
    ];
  }

  // Step 5: Persist insights and update memory for future sessions
  const memoryUpdates: Record<string, unknown> = {
    lastGoal: goal,
    lastAgentRun: new Date().toISOString(),
    totalAgentRuns: ((memory.totalAgentRuns as number) ?? 0) + 1,
    reflectionCount:
      ((memory.reflectionCount as number) ?? 0) + reflections.length,
  };

  // Merge schedule info into memory if scheduleTasks ran successfully
  const scheduleResult = executionResults.find(
    (r) =>
      (r as { tool: string; error?: string }).tool === "scheduleTasks" &&
      !(r as { error?: string }).error
  ) as { result?: { recommendedDailyMinutes?: number } } | undefined;

  if (scheduleResult?.result?.recommendedDailyMinutes) {
    memoryUpdates.recommendedDailyMinutes =
      scheduleResult.result.recommendedDailyMinutes;
  }

  await saveMemory(userId, memoryUpdates);

  return {
    plan: plan as unknown as Record<string, unknown>,
    executionResults,
    reflections,
    memorySnapshot: { ...memory, ...memoryUpdates },
  };
}
