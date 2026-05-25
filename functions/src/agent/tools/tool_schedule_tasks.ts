interface ScheduleTasksArgs {
  context?: Record<string, unknown>;
}

export const scheduleTasksTool = {
  name: "scheduleTasks",
  description: "Schedules tasks into available time blocks.",
  async execute(args: ScheduleTasksArgs) {
    const deadlineDays = Number(args.context?.deadlineDays ?? 7);
    const sessionsCreated = Math.max(3, Math.min(6, Math.ceil(deadlineDays / 2)));
    return {
      scheduled: true,
      sessionsCreated,
      cadence: deadlineDays <= 3 ? "daily" : "every-other-day",
    };
  },
};
