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
  message:    z.string(),
  emoji:      z.string().default("✨"),      // emoji character for the UI (was missing)
  suggestion: z.string().default(""),        // renamed from suggestedAction to match Flutter
  intensity:  z.enum(["low", "medium", "high"]).default("medium"),
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
  "emoji": "a single emoji that matches the mood (e.g. 🔥 energized, 😴 tired, 😰 overwhelmed, 😊 okay)",
  "suggestion": "One concrete action they can do in the next 10 minutes",
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
            maxOutputTokens: 512,
            responseMimeType: "application/json",
            thinkingConfig: { thinkingBudget: 0 },
          },
        });

        const parsed = parseModelJson<{
          message: string;
          emoji: string;
          suggestion: string;
          intensity: string;
        }>(text);

        const validIntensities = new Set(["low", "medium", "high"]);
        return {
          message:    parsed.message?.trim()    || staticMoodMessage(input.mood),
          emoji:      parsed.emoji?.trim()      || moodEmoji(input.mood),
          suggestion: parsed.suggestion?.trim() || "",
          intensity:  validIntensities.has(parsed.intensity)
            ? (parsed.intensity as "low" | "medium" | "high")
            : "medium",
        };
      } catch (e) {
        return {
          message:    staticMoodMessage(input.mood),
          emoji:      moodEmoji(input.mood),
          suggestion: "",
          intensity:  "medium" as const,
        };
      }
    }
  );
}

function moodEmoji(mood: string): string {
  const lower = mood.toLowerCase();
  if (lower.includes("great") || lower.includes("energized")) return "🔥";
  if (lower.includes("tired") || lower.includes("stress"))     return "😴";
  if (lower.includes("overwhelm"))                             return "😰";
  return "✨";
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
