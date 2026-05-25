interface ReflectionInput {
  goal: string;
  plan: { strategy?: string };
  executionResults: unknown[];
  memory: Record<string, unknown>;
}

export async function reflectionAgent(input: ReflectionInput) {
  const completedTools = input.executionResults.length;
  return [
    {
      type: "agent-summary",
      insight: `Created a ${input.plan.strategy ?? "goal"} plan for ${input.goal}.`,
      recommendation:
        completedTools >= 3
          ? "Use the generated milestones and schedule as the first draft."
          : "Review the plan because not every planning tool returned a result.",
      memoryKeysUsed: Object.keys(input.memory),
    },
  ];
}
