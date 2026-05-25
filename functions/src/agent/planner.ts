
export async function plannerAgent(input: any) {
  return {
    strategy: "multi-step-goal-planning",
    steps: [
      {
        title: "Analyze user objective",
        tool: "analyzeHabits",
        args: {},
      },
      {
        title: "Generate milestone roadmap",
        tool: "createMilestones",
        args: {},
      },
      {
        title: "Schedule deep work sessions",
        tool: "scheduleTasks",
        args: {},
      },
    ],
  };
}
