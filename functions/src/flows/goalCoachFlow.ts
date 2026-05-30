// functions/src/flows/goalCoachFlow.ts
//
// Defines the goal coach conversational AI flow.
// The Flutter app calls this via the `goalCoach` Cloud Function.

import { z } from "genkit";
import { getAI, defaultModel } from "../ai";

const ChatMessageSchema = z.object({
  role: z.enum(["user", "model"]),
  content: z.string(),
});

const GoalCoachInputSchema = z.object({
  userMessage:          z.string(),
  goalTitle:            z.string(),
  progressPercent:      z.number().min(0).max(100).default(0),
  conversationHistory:  z.array(ChatMessageSchema).default([]),
});

const GoalCoachOutputSchema = z.object({
  reply:             z.string(),
  suggestedActions:  z.array(z.string()).default([]),
  encouragement:     z.string().default(""),
  // motivationalScore added so the Flutter model (which reads this field) works correctly.
  motivationalScore: z.number().min(1).max(10).default(7),
});

export type GoalCoachInput  = z.infer<typeof GoalCoachInputSchema>;
export type GoalCoachOutput = z.infer<typeof GoalCoachOutputSchema>;

export function defineGoalCoachFlow() {
  const ai = getAI();

  return ai.defineFlow(
    {
      name:         "goalCoach",
      inputSchema:  GoalCoachInputSchema,
      outputSchema: GoalCoachOutputSchema,
    },
    async (input) => {
      const historyBlock = input.conversationHistory
        .map((m) => `${m.role === "user" ? "User" : "Coach"}: ${m.content}`)
        .join("\n");

      const prompt = `
You are the Goal Digger AI coach — warm, concise, and relentlessly action-oriented.
The user's goal is: "${input.goalTitle}" (${Math.round(input.progressPercent)}% complete).

${historyBlock ? `Conversation so far:\n${historyBlock}\n` : ""}
User says: ${input.userMessage}

Respond with a JSON object:
{
  "reply": "1–3 sentence response. Be specific to the goal. Never generic.",
  "suggestedActions": ["concrete next task 1", "concrete next task 2"],
  "encouragement": "One short motivational line (max 12 words) tied to their goal",
  "motivationalScore": 8
}

Rules:
- suggestedActions should be specific micro-tasks the user can act on today.
- If the user asks to change/adjust tasks, put the revised task titles in suggestedActions.
- Reply must feel like a real human coach, not a chatbot.
- motivationalScore is 1–10: how encouraging the tone is (10 = very uplifting).
- Respond ONLY with valid JSON — no markdown fences.`.trim();

      try {
        const { text } = await ai.generate({
          model: defaultModel,
          prompt,
          config: {
            temperature: 0.65,
            maxOutputTokens: 512,
            responseMimeType: "application/json",
          },
        });

        // Strip potential markdown fences from response
        const cleaned = text
          .trim()
          .replace(/^```(?:json)?\s*/i, "")
          .replace(/\s*```\s*$/i, "")
          .trim();

        const parsed = JSON.parse(cleaned);

        return {
          reply:             String(parsed.reply ?? "").trim(),
          suggestedActions:  Array.isArray(parsed.suggestedActions)
            ? parsed.suggestedActions.map(String).filter(Boolean)
            : [],
          encouragement:     String(parsed.encouragement ?? "").trim(),
          motivationalScore: typeof parsed.motivationalScore === "number"
            ? Math.min(10, Math.max(1, Math.round(parsed.motivationalScore)))
            : 7,
        };
      } catch (e) {
        // Graceful degradation — the Flutter app handles this gracefully
        return {
          reply:             "I couldn't reach the AI right now. Check your network and try again.",
          suggestedActions:  [],
          encouragement:     "",
          motivationalScore: 7,
        };
      }
    }
  );
}
