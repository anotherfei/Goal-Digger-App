// functions/src/flows/taskGeneratorFlow.ts

import { z } from "genkit";
import { getAI, defaultModel } from "../ai";
import { parseModelJson } from "../json";

const inputSchema = z.object({
  goalTitle:          z.string(),
  category:           z.string(),
  deadlineDays:       z.number().int(),
  priority:           z.number().int(),
  existingTaskTitles: z.array(z.string()).optional(),
});

const taskSchema = z.object({
  title:           z.string(),
  durationMinutes: z.number().int(),
  load:            z.string(), // light | focus | stretch
  dayOffset:       z.number().int(),
  tags:            z.array(z.string()),
});

const outputSchema = z.object({
  tasks:       z.array(taskSchema),
  explanation: z.string(),
});

export type TaskGeneratorInput  = z.infer<typeof inputSchema>;
export type TaskGeneratorOutput = z.infer<typeof outputSchema>;

export function defineTaskGeneratorFlow() {
  const ai = getAI();

  return ai.defineFlow(
    { name: "taskGenerator", inputSchema, outputSchema },
    async (input) => {
      const existing = input.existingTaskTitles ?? [];
      const existingNote = existing.length
        ? `Avoid duplicating these existing tasks: ${existing.join(", ")}.`
        : "";

      const prompt = `
You are a productivity expert helping a user achieve: "${input.goalTitle}".
Category: ${input.category} | Deadline: ${input.deadlineDays} days | Priority: ${input.priority}/5.
${existingNote}

Generate 4–6 specific micro-tasks. Each must be completable in one sitting.
Spread them across the available days — earlier days for blocking tasks.

load: "light" ≤15 min · "focus" 15–30 min · "stretch" >30 min
tags: 1–3 lowercase words, e.g. "research", "writing", "design", "coding".

Respond ONLY with valid JSON:
{
  "tasks": [
    { "title": "...", "durationMinutes": 20, "load": "focus", "dayOffset": 0, "tags": ["writing"] }
  ],
  "explanation": "One sentence explaining your scheduling approach."
}`.trim();

      const { text } = await ai.generate({
        model: defaultModel,
        prompt,
        config: { temperature: 0.6, maxOutputTokens: 1024, responseMimeType: "application/json" },
      });

      const parsed = parseModelJson<TaskGeneratorOutput>(text);
      const tasks = (parsed.tasks ?? []).map((t) => ({ ...t, tags: t.tags ?? [] }));
      return { tasks, explanation: parsed.explanation ?? "" };
    }
  );
}
