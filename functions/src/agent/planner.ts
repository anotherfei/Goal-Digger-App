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
}

export async function plannerAgent(input: PlannerInput) {
  const available = new Set(input.tools);
  const steps: AgentPlanStep[] = [];

  if (available.has("analyzeHabits")) {
    steps.push({
      title: "Analyze user objective and productivity signals",
      tool: "analyzeHabits",
      args: { goal: input.goal, memory: input.memory, context: input.context ?? {} },
    });
  }

  if (available.has("createMilestones")) {
    steps.push({
      title: "Generate milestone roadmap",
      tool: "createMilestones",
      args: { goal: input.goal, context: input.context ?? {} },
    });
  }

  if (available.has("scheduleTasks")) {
    steps.push({
      title: "Schedule deep work sessions",
      tool: "scheduleTasks",
      args: { goal: input.goal, context: input.context ?? {} },
    });
  }

  return {
    strategy: "multi-step-goal-planning",
    goal: input.goal,
    steps,
  };
}
