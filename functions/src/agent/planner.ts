// functions/src/agent/planner.ts
//
// AI-powered planner agent.
// Uses Gemini to reason about the goal, available tools, and user memory,
// then produces a structured multi-step plan.
// Falls back to a deterministic static plan if the AI call fails.

import { getAI, defaultModel } from "../ai";
import { parseModelJson } from "../json";

interface PlannerInput {
  goal: string;
  memory: Record<string, unknown>;
  tools: string[];
  context?: Record<string, unknown>;
}

interface AgentPlanStep {
  title: string;
  tool: string;
  args: Record<string, unknown>;
  reasoning: string;
}

export interface AgentPlan {
  strategy: string;
  goal: string;
  steps: AgentPlanStep[];
}

export async function plannerAgent(input: PlannerInput): Promise<AgentPlan> {
  const ai = getAI();

  const memoryContext =
    Object.keys(input.memory).length > 0
      ? `User memory summary: ${JSON.stringify(input.memory)}`
      : "No prior user memory available.";

  const contextNote =
    input.context && Object.keys(input.context).length > 0
      ? `Current session context: ${JSON.stringify(input.context)}`
      : "";

  // Tool schema descriptions for the LLM
  const toolDescriptions = `
Available tools (use only the names listed):
- analyzeHabits: Analyze user productivity patterns and burnout risk from memory + context. Args: { goal, memory, context }
- createMilestones: Generate an adaptive milestone roadmap for the goal using AI. The number and granularity of milestones scale with the goal's duration/deadline and any user special request. Args: { goal, context } where context may carry { deadline, startDate, durationDays, specialRequest }.
- scheduleTasks: Calculate an optimal session schedule based on deadline. Args: { context }
`.trim();

  const prompt = `
You are an AI agent planner for a productivity app. Reason about the user's goal and decide which tools to call and how.

Goal: "${input.goal}"
${memoryContext}
${contextNote}

${toolDescriptions}

Instructions:
1. Think about what this goal requires: does it need habit analysis? clear milestones? a schedule?
2. Select the tools that are most useful. Not every tool needs to be called for every goal.
3. For short/simple goals (≤3 days), skip scheduleTasks or make it minimal.
4. For complex goals, use all three tools in order: analyzeHabits → createMilestones → scheduleTasks.
5. When calling createMilestones, pass the session context through as args.context (deadline/durationDays/specialRequest) so the roadmap adapts to the available time and any user request.

Respond ONLY with valid JSON — no commentary:
{
  "strategy": "one sentence describing your planning approach for THIS specific goal",
  "steps": [
    {
      "title": "Human-readable step title",
      "tool": "toolName",
      "args": { "key": "value" },
      "reasoning": "Why this tool is useful for this specific goal"
    }
  ]
}`.trim();

  try {
    const { text } = await ai.generate({
      model: defaultModel,
      prompt,
      config: {
        temperature: 0.3,
        maxOutputTokens: 1024,
        responseMimeType: "application/json",
        // gemini-2.5-flash is a thinking model; thinking tokens would eat the
        // output budget and truncate the JSON. Disable it for structured output.
        thinkingConfig: { thinkingBudget: 0 },
      },
    });

    const parsed = parseModelJson<{ strategy: string; steps: AgentPlanStep[] }>(text);

    // Guard: only keep steps whose tool names actually exist
    const available = new Set(input.tools);
    const validSteps = (parsed.steps ?? []).filter(
      (step) => typeof step.tool === "string" && available.has(step.tool)
    );

    return {
      strategy: parsed.strategy?.trim() || "multi-step-goal-planning",
      goal: input.goal,
      steps: validSteps,
    };
  } catch (e) {
    // AI unavailable — fall back to deterministic plan
    console.error("[agent/planner] LLM call failed, using static plan:", e);
    return staticFallbackPlan(input);
  }
}

function staticFallbackPlan(input: PlannerInput): AgentPlan {
  const available = new Set(input.tools);
  const steps: AgentPlanStep[] = [];

  if (available.has("analyzeHabits")) {
    steps.push({
      title: "Analyze productivity signals",
      tool: "analyzeHabits",
      args: { goal: input.goal, memory: input.memory, context: input.context ?? {} },
      reasoning: "Identify burnout risk and optimal work hours before planning",
    });
  }
  if (available.has("createMilestones")) {
    steps.push({
      title: "Generate milestone roadmap",
      tool: "createMilestones",
      args: { goal: input.goal, context: input.context ?? {} },
      reasoning: "Break the goal into trackable, sequenced milestones sized to the deadline",
    });
  }
  if (available.has("scheduleTasks")) {
    steps.push({
      title: "Schedule deep work sessions",
      tool: "scheduleTasks",
      args: { context: input.context ?? {} },
      reasoning: "Distribute work sessions across the available deadline window",
    });
  }

  return { strategy: "multi-step-goal-planning", goal: input.goal, steps };
}
