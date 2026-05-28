// functions/src/flows/moodAdvisorFlow.ts
//
// Returns a personalised mood-based productivity recommendation.
// Triggered when the user updates their mood on the Tasks page.

import { z } from "genkit";
import { getAI, defaultModel } from "../ai";
import { parseModelJson } from "../json";

const MoodAdvisorInputSchema = z.object({
  mood:            z.string(),
  completedToday:  z.number().min(0).default(0),
  totalToday:      z.number().min(0).default(0),
  streak:          z.number().min(0).default(0),
});

const MoodAdvisorOutputSchema = z.object({
  message:         z.string(),
  suggestedAction: z.string().default(""),
  intensity:       z.enum(["low", "medium", "high"]).default("medium"),
});

export function defineMoodAdvisorFlow() {
  const ai = getAI();

  return ai.defineFlow(
    {
      name:         "moodAdvisor",
      inputSchema:  MoodAdvisorInputSchema,
      outputSchema: MoodAdvisorOutputSchema,
    },
    async (input) => {
      const remaining = Math.max(0, input.totalToday - input.completedToday);
      const completionRate =
        input.totalToday > 0
          ? Math.round((input.completedToday / input.totalToday) * 100)
          : 100;

      const prompt = `
You are a productivity coach in a goal-tracking app.

User status:
- Current mood: "${input.mood}"
- Tasks done today: ${input.completedToday}/${input.totalToday} (${completionRate}%)
- Tasks remaining: ${remaining}
- Current streak: ${input.streak} days

Generate a mood-aware productivity recommendation. Be direct and specific — not vague.

Respond ONLY with valid JSON:
{
  "message": "1–2 sentence personalised advice based on their mood and task status",
  "suggestedAction": "One concrete action they can do in the next 10 minutes",
  "intensity": "low | medium | high (how hard they should push given their mood)"
}

Mood guidance:
- Energized/Great → push for a stretch task
- Okay/Neutral → steady focus session on priority tasks
- Tired/Stressed → light wins only, protect the streak
- Overwhelmed → pick ONE task and ignore the rest today`.trim();

      try {
        const { text } = await ai.generate({
          model: defaultModel,
          prompt,
          config: {
            temperature: 0.6,
            maxOutputTokens: 200,
            responseMimeType: "application/json",
          },
        });

        const parsed = parseModelJson<{
          message: string;
          suggestedAction: string;
          intensity: string;
        }>(text);

        const validIntensities = new Set(["low", "medium", "high"]);
        return {
          message:         parsed.message?.trim()         || staticMoodMessage(input.mood),
          suggestedAction: parsed.suggestedAction?.trim() || "",
          intensity:       validIntensities.has(parsed.intensity)
            ? (parsed.intensity as "low" | "medium" | "high")
            : "medium",
        };
      } catch (e) {
        return {
          message:         staticMoodMessage(input.mood),
          suggestedAction: "",
          intensity:       "medium" as const,
        };
      }
    }
  );
}

function staticMoodMessage(mood: string): string {
  const lower = mood.toLowerCase();
  if (lower.includes("great") || lower.includes("energized")) {
    return "You're in top form — tackle your most challenging task now while the energy lasts.";
  }
  if (lower.includes("tired") || lower.includes("stress")) {
    return "Energy is low — pick one small win and protect your streak with minimal effort.";
  }
  if (lower.includes("overwhelm")) {
    return "Feeling overwhelmed is a signal to simplify. Pick ONE task and ignore everything else today.";
  }
  return "Steady mood — a focused 20-minute work session will make meaningful progress today.";
}
