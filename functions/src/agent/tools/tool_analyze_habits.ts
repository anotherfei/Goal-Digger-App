interface AnalyzeHabitsArgs {
  goal?: string;
  memory?: Record<string, unknown>;
  context?: Record<string, unknown>;
}

export const analyzeHabitsTool = {
  name: "analyzeHabits",
  description: "Analyzes productivity and behavioral trends.",
  async execute(args: AnalyzeHabitsArgs) {
    const completedToday = Number(args.context?.completedToday ?? 0);
    const totalToday = Number(args.context?.totalToday ?? 0);
    const load = totalToday > 0 ? completedToday / totalToday : 0;
    return {
      burnoutRisk: load < 0.25 && totalToday >= 4 ? "medium" : "low",
      strongestHours: args.memory?.preferredWorkHours ?? ["08:00", "11:00"],
      goal: args.goal ?? "",
    };
  },
};
