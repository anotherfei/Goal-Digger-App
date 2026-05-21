// functions/src/flows/moodAdvisorFlow.ts

import { z } from "genkit";
import { getAI, defaultModel } from "../ai";

const inputSchema = z.object({
  mood:           z.string(),
  completedToday: z.number().int(),
  totalToday:     z.number().int(),
  streak:         z.number().int(),
});

const outputSchema = z.object({
  message:    z.string(),
  emoji:      z.string(),
  suggestion: z.string(),
});

export function defineMoodAdvisorFlow() {
  const ai = getAI();

  return ai.defineFlow(
    { name: "moodAdvisor", inputSchema, outputSchema },
    async (input) => {
      const pct = input.totalToday > 0
        ? Math.round((input.completedToday / input.totalToday) * 100)
        : 0;
      const streakNote = input.streak > 0
        ? ` They're on a ${input.streak}-day streak — acknowledge it warmly.`
        : "";
      const progressNote = input.totalToday > 0
        ? `${pct}% of tasks done today (${input.completedToday}/${input.totalToday}).`
        : "No tasks scheduled today.";

      const prompt = `
A Goal Digger user's mood: "${input.mood}". Daily progress: ${progressNote}${streakNote}

Write a short (1–2 sentences) warm personalised message — never generic.
Give one concrete actionable suggestion for the rest of their day.
Choose an emoji matching the mood.

Respond ONLY with valid JSON:
{ "message": "...", "emoji": "🌟", "suggestion": "..." }`.trim();

      const { text } = await ai.generate({
        model: defaultModel,
        prompt,
        config: { temperature: 0.8, maxOutputTokens: 256, responseMimeType: "application/json" },
      });

      const parsed = JSON.parse(text) as z.infer<typeof outputSchema>;
      return {
        message:    parsed.message    ?? "",
        emoji:      parsed.emoji      ?? "✨",
        suggestion: parsed.suggestion ?? "",
      };
    }
  );
}
