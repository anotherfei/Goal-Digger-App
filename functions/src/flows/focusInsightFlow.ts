// functions/src/flows/focusInsightFlow.ts
//
// Generates a post-session insight after the user completes (or stops) a
// focus timer. Rewards completed sessions with coins and an AI reflection.

import { z } from "genkit";
import { getAI, defaultModel } from "../ai";
import { parseModelJson } from "../json";

const FocusInsightInputSchema = z.object({
  taskTitle:       z.string(),
  goalTitle:       z.string(),
  durationMinutes: z.number().min(1),
  completed:       z.boolean(),
});

const FocusInsightOutputSchema = z.object({
  insight:      z.string(),
  coinsEarned:  z.number().default(0),
  badge:        z.string().default(""),
  nextStepHint: z.string().default(""),  // added to match Flutter FocusInsightResponse
});

export function defineFocusInsightFlow() {
  const ai = getAI();

  return ai.defineFlow(
    {
      name:         "focusInsight",
      inputSchema:  FocusInsightInputSchema,
      outputSchema: FocusInsightOutputSchema,
    },
    async (input) => {
      // Deterministic coin reward — not AI-controlled so it can't be gamed
      const coinsEarned = input.completed
        ? Math.min(50, Math.max(5, Math.round(input.durationMinutes / 2)))
        : 0;

      const badge =
        input.completed && input.durationMinutes >= 45
          ? "🏅 Deep Work"
          : input.completed && input.durationMinutes >= 25
          ? "⚡ Flow State"
          : input.completed
          ? "✅ Session Done"
          : "";

      const prompt = `
You are a focus coach in a productivity app. The user just ${
        input.completed ? "completed" : "stopped early"
      } a ${input.durationMinutes}-minute session.

Task: "${input.taskTitle}"
Goal: "${input.goalTitle}"
Completed: ${input.completed}
${input.completed ? `Coins earned: ${coinsEarned}` : ""}

Write ONE sentence (max 20 words) that:
- If completed: celebrates the win and connects it to the bigger goal
- If stopped early: is non-judgmental and motivates them to try again

Respond ONLY with valid JSON: { "insight": "..." }`.trim();

      try {
        const { text } = await ai.generate({
          model: defaultModel,
          prompt,
          config: {
            temperature: 0.6,
            maxOutputTokens: 80,
            responseMimeType: "application/json",
          },
        });

        const parsed = parseModelJson<{ insight: string }>(text);
        const insight = parsed.insight?.trim();

        if (insight) {
          const nextStepHint = input.completed
            ? `Keep the momentum — start your next task within 10 minutes.`
            : `When you're ready, try again with a shorter 10-minute session.`;
          return { insight, coinsEarned, badge, nextStepHint };
        }
      } catch (e) {
        // Fall through to static message
      }

      const staticInsight = input.completed
        ? `Great work — ${input.durationMinutes} focused minutes brings "${input.goalTitle}" closer to done.`
        : `Even a short session counts. Jump back in when you're ready.`;

      const staticNextStep = input.completed
        ? `Review what you just completed and pick the next action.`
        : `Take a short break, then try again with a smaller time block.`;

      return { insight: staticInsight, coinsEarned, badge, nextStepHint: staticNextStep };
    }
  );
}
