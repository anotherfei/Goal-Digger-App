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

    // Deterministic heuristic used ONLY as the offline fallback for burnout risk.
    const completionRate = totalToday > 0 ? completedToday / totalToday : 1;
    const heuristicBurnoutRisk: "low" | "medium" | "high" =
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

    // AI assesses burnout risk AND writes the insight in one call — the risk is
    // a judgement call (mood + completion + streak + deadline pressure), not a
    // fixed threshold. Falls back to the heuristic if the model is unavailable.
    let burnoutRisk: "low" | "medium" | "high" = heuristicBurnoutRisk;
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

Assess this user's burnout risk right now from ALL of the signals above (mood, completion rate, streak, and deadline pressure together — not any single number). Then write exactly ONE sentence (max 25 words) naming their strongest pattern AND their biggest risk, concrete and specific to the goal.

Respond ONLY with valid JSON: { "burnoutRisk": "low" | "medium" | "high", "insight": "..." }`.trim();

      const { text } = await ai.generate({
        model: defaultModel,
        prompt,
        config: {
          temperature: 0.4,
          maxOutputTokens: 512,
          responseMimeType: "application/json",
          thinkingConfig: { thinkingBudget: 256 },
        },
      });

      const parsed = parseModelJson<{
        burnoutRisk?: string;
        insight?: string;
      }>(text);
      if (
        parsed.burnoutRisk === "low" ||
        parsed.burnoutRisk === "medium" ||
        parsed.burnoutRisk === "high"
      ) {
        burnoutRisk = parsed.burnoutRisk;
      }
      if (parsed.insight?.trim()) {
        productivityInsight = parsed.insight.trim();
      }
    } catch (e) {
      console.error("[analyzeHabits] LLM call failed, using static:", e);
    }

    if (!productivityInsight) {
      // Deterministic fallback insight (model unavailable or returned no text).
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
