// functions/src/agent/tools/tool_schedule_tasks.ts
//
// Calculates an optimal session schedule distributed across the deadline window.
// Pure logic — no AI call needed here; the schedule math is deterministic.
// The AI coach (goalCoachFlow) can later refine the schedule narratively.

interface ScheduleTasksArgs {
  context?: Record<string, unknown>;
}

interface SessionSlot {
  day: number;
  startTime: string;
  durationMinutes: number;
  label: string;
}

interface ScheduleResult {
  sessions: SessionSlot[];
  totalSessions: number;
  recommendedDailyMinutes: number;
  scheduleNote: string;
}

export const scheduleTasksTool = {
  name: "scheduleTasks",
  description:
    "Calculates an optimised session schedule spread across the available deadline window.",

  execute(args: ScheduleTasksArgs): ScheduleResult {
    const deadlineDays = Math.max(1, Number(args.context?.deadlineDays ?? 7));
    const totalMinutes = Number(args.context?.estimatedMinutes ?? 120);
    const preferredStartHour = Number(args.context?.preferredStartHour ?? 9);
    const burnoutRisk = String(args.context?.burnoutRisk ?? "low");

    // Respect burnout risk: give lighter daily loads under medium/high risk
    const maxDailyMinutes =
      burnoutRisk === "high" ? 20 : burnoutRisk === "medium" ? 35 : 60;

    const sessionsNeeded = Math.ceil(totalMinutes / maxDailyMinutes);
    // Spread sessions across deadline window, leaving the last 10% as buffer
    const workDays = Math.max(1, Math.floor(deadlineDays * 0.9));
    const sessionSpacing = Math.max(1, Math.floor(workDays / sessionsNeeded));

    const sessions: SessionSlot[] = [];

    for (let i = 0; i < sessionsNeeded; i++) {
      const day = Math.min(i * sessionSpacing + 1, workDays);
      const minutesForSession = Math.min(
        maxDailyMinutes,
        totalMinutes - i * maxDailyMinutes
      );
      if (minutesForSession <= 0) break;

      // Alternate morning / afternoon to avoid fatigue
      const hour =
        i % 2 === 0 ? preferredStartHour : Math.min(preferredStartHour + 4, 16);
      const startTime = `${String(hour).padStart(2, "0")}:00`;

      sessions.push({
        day,
        startTime,
        durationMinutes: minutesForSession,
        label: `Session ${i + 1}: ${minutesForSession} min at ${startTime}`,
      });
    }

    const recommendedDailyMinutes = Math.ceil(totalMinutes / Math.max(1, workDays));

    let scheduleNote: string;
    if (burnoutRisk === "high") {
      scheduleNote =
        "Burnout risk is high — sessions are capped at 20 min. Prioritise rest between sessions.";
    } else if (burnoutRisk === "medium") {
      scheduleNote =
        "Moderate load detected — sessions are capped at 35 min to protect your streak.";
    } else if (deadlineDays <= 3) {
      scheduleNote =
        "Tight deadline — sessions are compressed. Focus only on the highest-impact tasks.";
    } else {
      scheduleNote = `${sessions.length} sessions spread across ${workDays} days. Adjust timing in the Calendar tab.`;
    }

    return {
      sessions,
      totalSessions: sessions.length,
      recommendedDailyMinutes,
      scheduleNote,
    };
  },
};
