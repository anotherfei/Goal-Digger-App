// functions/src/flows/focusInsightFlow.ts

import { z } from "genkit";
import { getAI, defaultModel } from "../ai";

const inputSchema = z.object({
  taskTitle:       z.string(),
  goalTitle:       z.string(),
  durationMinutes: z.number().int(),
  completed:       z.boolean(),
});

const outputSchema = z.object({
  insight:      z.string(),
  nextStepHint: z.string(),
  coinsEarned:  z.number().int(),
});

export function defineFocusInsightFlow() {
  const ai = getAI();

  return ai.defineFlow(
    { name: "focusInsight", inputSchema, outputSchema },
    async (input) => {
      const status   = input.completed ? "fully completed" : "partially completed";
      const coinBase = input.completed
        ? Math.round(input.durationMinutes * 0.8)
        : Math.round(input.durationMinutes * 0.4);
      const coinMin  = Math.max(1, coinBase - 5);
      const coinMax  = coinBase + 10;

      const prompt = `
A Goal Digger user just ${status} a focus session.
Task: "${input.taskTitle}" | Goal: "${input.goalTitle}" | Duration: ${input.durationMinutes} min.

Write:
1. "insight": Specific encouraging observation (1 sentence, name the task/goal).
2. "nextStepHint": Concrete hint to maintain momentum (1 sentence).
3. "coinsEarned": Integer between ${coinMin} and ${coinMax}. More for completed + longer sessions.

Respond ONLY with valid JSON:
{ "insight": "...", "nextStepHint": "...", "coinsEarned": ${coinBase} }`.trim();

      const { text } = await ai.generate({
        model: defaultModel,
        prompt,
        config: { temperature: 0.7, maxOutputTokens: 256, responseMimeType: "application/json" },
      });

      const parsed = JSON.parse(text) as z.infer<typeof outputSchema>;
      const coins  = Math.min(coinMax, Math.max(coinMin, parsed.coinsEarned ?? coinBase));
      return {
        insight:      parsed.insight      ?? "",
        nextStepHint: parsed.nextStepHint ?? "",
        coinsEarned:  coins,
      };
    }
  );
}
