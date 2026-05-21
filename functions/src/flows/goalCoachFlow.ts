// functions/src/flows/goalCoachFlow.ts

import { z } from "genkit";
import { getAI, defaultModel } from "../ai";

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
Then list 1–3 specific suggested actions (short imperative phrases).
Score your motivational impact 1–10.

Respond ONLY with valid JSON:
{
  "reply": "...",
  "suggestedActions": ["...", "..."],
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

      const parsed = JSON.parse(text) as GoalCoachOutput;
      return {
        reply:             parsed.reply             ?? "",
        suggestedActions:  parsed.suggestedActions  ?? [],
        motivationalScore: parsed.motivationalScore ?? 7,
      };
    }
  );
}
