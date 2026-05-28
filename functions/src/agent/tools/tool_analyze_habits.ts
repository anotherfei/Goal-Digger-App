// functions/src/agent/tools/tool_analyze_habits.ts
//
// Analyzes user productivity patterns. Uses AI to produce a targeted
// one-sentence insight based on task completion rate, mood, and streak.

import { getAI, defaultModel } from "../../ai";
import { parseModelJson } from "../../json";

interface AnalyzeHabitsArgs {
  goal?: string;
  memory?: Record<string, unknown>;
  context?: Record<string, unknown>;
}

interface HabitAnalysis {
  burnoutRisk: "low" | "medium" | "high";
  strongestHours: string[];
  goal: string;
  productivityInsight: string;
}

export const analyzeHabitsTool = {
  name: "analyzeHabits",
  description:
    "Analyzes user productivity patterns, burnout risk, and optimal work hours. Returns an AI-generated insight.",

  async execute(args: AnalyzeHabitsArgs): Promise<HabitAnalysis> {
    const completedToday = Number(args.context?.completedToday ?? 0);
    const totalToday = Number(args.context?.totalToday ?? 0);
    const mood = String(args.context?.mood ?? "okay");
    const streak = Number(args.context?.streak ?? 0);
    const deadlineDays = Number(args.context?.deadlineDays ?? 14);
    const goal = String(args.goal ?? "general productivity");

    // Derive heuristic signals
    const completionRate = totalToday > 0 ? completedToday / totalToday : 1;
    const burnoutRisk: "low" | "medium" | "high" =
      completionRate < 0.25 && totalToday >= 4
        ? "high"
        : completionRate < 0.5 && totalToday >= 6
        ? "medium"
        : "low";

    const preferredHours = (args.memory?.preferredWorkHours as string[]) ?? [
      "09:00",
      "11:00",
      "15:00",
    ];
    const strongestHours = preferredHours.slice(0, 3);

    // AI-generated productivity insight
    let productivityInsight = "";
    try {
      const ai = getAI();
      const prompt = `
Productivity snapshot:
- Goal: "${goal}"
- Tasks completed today: ${completedToday}/${totalToday}
- Mood: ${mood}
- Day streak: ${streak}
- Days until deadline: ${deadlineDays}
- Burnout risk: ${burnoutRisk}

Write exactly ONE sentence (max 25 words) that identifies this user's strongest pattern AND their biggest risk right now. Be concrete and specific to the goal.

Respond ONLY with valid JSON: { "insight": "..." }`.trim();

      const { text } = await ai.generate({
        model: defaultModel,
        prompt,
        config: {
          temperature: 0.45,
          maxOutputTokens: 80,
          responseMimeType: "application/json",
        },
      });

      const parsed = parseModelJson<{ insight: string }>(text);
      if (parsed.insight?.trim()) {
        productivityInsight = parsed.insight.trim();
      }
    } catch {
      // Deterministic fallback
      if (burnoutRisk === "high") {
        productivityInsight = `Task completion is critically low (${completedToday}/${totalToday}) — reduce today's load and protect your streak.`;
      } else if (burnoutRisk === "medium") {
        productivityInsight = `Momentum is slipping with ${completedToday}/${totalToday} tasks done — focus on 1–2 high-priority items now.`;
      } else if (streak >= 7) {
        productivityInsight = `Strong ${streak}-day streak — maintain it by completing at least one task before ${strongestHours[0]}.`;
      } else {
        productivityInsight = `Productivity looks healthy — keep the current rhythm to close out "${goal}" on time.`;
      }
    }

    return { burnoutRisk, strongestHours, goal, productivityInsight };
  },
};
