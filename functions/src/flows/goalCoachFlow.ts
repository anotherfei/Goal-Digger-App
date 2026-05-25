// functions/src/flows/goalCoachFlow.ts

import { z } from "genkit";
import { getAI, defaultModel } from "../ai";
import { parseModelJson } from "../json";

const inputSchema = z.object({
  userMessage:     z.string(),
  goalTitle:       z.string(),
  progressPercent: z.number(),
  history: z.array(
    z.object({ role: z.string(), content: z.string() })
  ).optional(),
});

const outputSchema = z.object({
  reply:              z.string(),
  suggestedActions:   z.array(z.string()),
  motivationalScore:  z.number().int(),
});

export type GoalCoachInput  = z.infer<typeof inputSchema>;
export type GoalCoachOutput = z.infer<typeof outputSchema>;

export function defineGoalCoachFlow() {
  const ai = getAI();

  return ai.defineFlow(
    { name: "goalCoach", inputSchema, outputSchema },
    async (input) => {
      const historyBlock = (input.history ?? [])
        .map((m) => `${m.role === "user" ? "User" : "Coach"}: ${m.content}`)
        .join("\n");

      const prompt = `
You are the Goal Digger AI coach — supportive, concise, and action-oriented.
The user is working on: "${input.goalTitle}" (${Math.round(input.progressPercent)}% complete).

${historyBlock ? `Conversation so far:\n${historyBlock}\n` : ""}
User: ${input.userMessage}

Reply as the coach (1–3 sentences max unless detail is explicitly requested).
If the user asks to adjust the plan, return a complete revised micro-task list in suggestedActions, not just extra tips. Keep it to 4–6 short imperative tasks.
If no plan change is needed, return the current best 4–6 tasks in suggestedActions.
Score your motivational impact 1–10.

Respond ONLY with valid JSON:
{
  "reply": "...",
  "suggestedActions": ["Complete task 1", "Complete task 2", "Complete task 3", "Complete task 4"],
  "motivationalScore": 8
}`.trim();

      const { text } = await ai.generate({
        model: defaultModel,
        prompt,
        config: {
          temperature: 0.7,
          maxOutputTokens: 512,
          responseMimeType: "application/json",
        },
      });

      const parsed = parseModelJson<GoalCoachOutput>(text);
      return {
        reply:             parsed.reply             ?? "",
        suggestedActions:  parsed.suggestedActions  ?? [],
        motivationalScore: parsed.motivationalScore ?? 7,
      };
    }
  );
}
