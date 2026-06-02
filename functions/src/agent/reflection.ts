// functions/src/agent/reflection.ts
//
// AI-powered reflection agent.
// After the planner executes its tool steps, this agent reviews the
// collected results and produces sharp, personalised insights.
// Falls back to a deterministic summary if the AI call fails.

import { getAI, defaultModel } from "../ai";
import { parseModelJson } from "../json";

interface ReflectionInput {
  goal: string;
  plan: { strategy?: string; steps?: unknown[]; goal?: string };
  executionResults: unknown[];
  memory: Record<string, unknown>;
}

export interface Reflection {
  type: string;
  insight: string;
  recommendation: string;
  memoryKeysUsed: string[];
}

export async function reflectionAgent(
  input: ReflectionInput
): Promise<Reflection[]> {
  const ai = getAI();
  const memoryKeys = Object.keys(input.memory);

  // Build a concise summary of what the tools returned
  const resultsSummary =
    input.executionResults.length > 0
      ? JSON.stringify(input.executionResults.slice(0, 3), null, 0)
      : "No tool results were produced.";

  const planSummary = `strategy="${input.plan.strategy ?? "unknown"}", steps=${
    Array.isArray(input.plan.steps) ? input.plan.steps.length : 0
  }`;

  const prompt = `
You are an AI reflection agent for a productivity app. Analyse this completed planning session and produce 1–2 sharp, actionable insights for the user.

Goal: "${input.goal}"
Agent plan: ${planSummary}
Tool results: ${resultsSummary}
User memory keys: ${memoryKeys.length > 0 ? memoryKeys.join(", ") : "none"}

Rules:
- Be specific to the goal — avoid generic advice.
- Focus on the single most important first action the user should take RIGHT NOW.
- If milestones were generated, reference the first one directly.
- If burnout risk was detected, address it explicitly.
- Keep each insight ≤2 sentences and each recommendation ≤1 sentence.

Respond ONLY with valid JSON:
{
  "reflections": [
    {
      "type": "agent-summary",
      "insight": "Specific, goal-relevant observation about the plan or situation",
      "recommendation": "The one most important action to take right now"
    }
  ]
}`.trim();

  try {
    const { text } = await ai.generate({
      model: defaultModel,
      prompt,
      config: {
        temperature: 0.55,
        maxOutputTokens: 512,
        responseMimeType: "application/json",
        thinkingConfig: { thinkingBudget: 0 },
      },
    });

    const parsed = parseModelJson<{
      reflections: Array<{ type: string; insight: string; recommendation: string }>;
    }>(text);

    const reflections = (parsed.reflections ?? [])
      .filter((r) => r.insight?.trim() && r.recommendation?.trim())
      .map((r) => ({
        type: r.type?.trim() || "agent-summary",
        insight: r.insight.trim(),
        recommendation: r.recommendation.trim(),
        memoryKeysUsed: memoryKeys,
      }));

    if (reflections.length > 0) return reflections;
    // If the model returned an empty array, fall through to static fallback
    console.warn("[agent/reflection] model returned no reflections, using static");
  } catch (e) {
    console.error("[agent/reflection] LLM call failed, using static:", e);
  }

  return staticFallback(input, memoryKeys);
}

function staticFallback(
  input: ReflectionInput,
  memoryKeys: string[]
): Reflection[] {
  const stepsCompleted = input.executionResults.length;
  const allToolsRan =
    Array.isArray(input.plan.steps) &&
    stepsCompleted >= input.plan.steps.length;

  return [
    {
      type: "agent-summary",
      insight: allToolsRan
        ? `The agent completed all ${stepsCompleted} planning step(s) for "${input.goal}". Your milestones and schedule are ready to review.`
        : `The agent completed ${stepsCompleted} of ${
            Array.isArray(input.plan.steps) ? input.plan.steps.length : "?"
          } steps. Some tools did not return results — review the plan before starting.`,
      recommendation: allToolsRan
        ? "Start with milestone 1 — commit to the first visible action today."
        : "Check the generated tasks and fill any gaps before your first work session.",
      memoryKeysUsed: memoryKeys,
    },
  ];
}
