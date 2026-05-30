// functions/src/agent/tools/tool_create_milestones.ts
//
// Generates a 3-step milestone roadmap using Gemini.
// Each milestone represents a visible, completable chunk of progress.

import { getAI, defaultModel } from "../../ai";
import { parseModelJson } from "../../json";

interface CreateMilestonesArgs {
  goal?: string;
}

interface MilestoneResult {
  milestones: string[];
}

export const createMilestonesTool = {
  name: "createMilestones",
  description:
    "Generates a 3-step AI milestone roadmap for a goal. Each milestone is a concrete, achievable outcome.",

  async execute(args: CreateMilestonesArgs): Promise<MilestoneResult> {
    const goal = String(args.goal ?? "the goal").trim();

    try {
      const ai = getAI();
      const prompt = `
Create exactly 3 clear, ordered milestones for this goal: "${goal}".

Rules:
- Each milestone must describe a VISIBLE, CONCRETE outcome (not a vague activity).
- Milestones should be completable in 1–3 days each.
- Use plain language. Start each with an action verb.
- Do NOT number them — just write the milestone text.

Example for "Build a personal portfolio website":
["Design and publish a one-page layout with your name and bio", "Add 3 real project case studies with screenshots", "Share the live URL with 5 people and collect feedback"]

Respond ONLY with valid JSON: { "milestones": ["...", "...", "..."] }`.trim();

      const { text } = await ai.generate({
        model: defaultModel,
        prompt,
        config: {
          temperature: 0.5,
          maxOutputTokens: 512,
          responseMimeType: "application/json",
          thinkingConfig: { thinkingBudget: 0 },
        },
      });

      const parsed = parseModelJson<{ milestones: string[] }>(text);
      const cleaned = (parsed.milestones ?? [])
        .map((m: string) => m.trim())
        .filter((m: string) => m.length > 0)
        .slice(0, 3);

      if (cleaned.length >= 2) {
        return { milestones: cleaned };
      }
      // Not enough milestones from AI — fall through to static
      console.warn("[createMilestones] AI returned <2 milestones, using static");
    } catch (e) {
      console.error("[createMilestones] LLM call failed, using static:", e);
    }

    // Deterministic fallback milestones
    return {
      milestones: [
        `Define what "done" looks like for ${goal} and list the 3 biggest blockers`,
        `Complete the first working version or first visible deliverable`,
        `Review the result, fix the weakest part, and share it or submit it`,
      ],
    };
  },
};
