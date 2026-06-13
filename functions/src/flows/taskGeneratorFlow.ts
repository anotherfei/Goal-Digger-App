// functions/src/flows/taskGeneratorFlow.ts
//
// Generates a list of AI micro-tasks for a goal.
// Called when the user creates a new goal in the Flutter app.

import { z } from "genkit";
import { getAI, defaultModel } from "../ai";
import { evaluateGoal, goalGuardMessage } from "../agent/goal_guard";
import { parseModelJson } from "../json";

const TaskGeneratorInputSchema = z.object({
  goalTitle:    z.string(),
  category:     z.string().default("Study"),
  priority:     z.number().min(1).max(5).default(3),
  deadlineDays: z.number().min(1).default(14),
});

const GeneratedTaskSchema = z.object({
  title:           z.string(),
  durationMinutes: z.number(),
  load:            z.enum(["light", "focus", "stretch"]),
  dayOffset:       z.number(),
});

const TaskGeneratorOutputSchema = z.object({
  tasks:       z.array(GeneratedTaskSchema),
  explanation: z.string().default(""),  // added to match Flutter TaskGeneratorResponse
});

export type TaskGeneratorInput  = z.infer<typeof TaskGeneratorInputSchema>;
export type TaskGeneratorOutput = z.infer<typeof TaskGeneratorOutputSchema>;

export function defineTaskGeneratorFlow() {
  const ai = getAI();

  return ai.defineFlow(
    {
      name:         "taskGenerator",
      inputSchema:  TaskGeneratorInputSchema,
      outputSchema: TaskGeneratorOutputSchema,
    },
    async (input) => {
      const goalReview = await evaluateGoal(input.goalTitle);
      if (!goalReview.allowed) {
        return {
          tasks: [],
          explanation: goalGuardMessage(goalReview),
        };
      }

      const priorityLabel =
        input.priority >= 4 ? "high" : input.priority >= 2 ? "medium" : "low";

      const prompt = `
You are an expert productivity planner. Break this goal into focused micro-tasks. Decide how many the goal genuinely needs (use as few or as many as the real scope requires, up to 10) — do not pad to a fixed number.

Goal: "${input.goalTitle}"
Category: ${input.category}
Priority: ${priorityLabel} (${input.priority}/5)
Deadline: ${input.deadlineDays} days from now

Rules for each task:
- title: clear action phrase, max 10 words, starts with a verb
- Every task must be DOABLE work fully under the user's control — never an outcome target like "reach N subscribers/views/sales" or "get X result". Describe the work that produces the outcome (e.g. "Record and edit the first video", not "Reach 20 subscribers").
- durationMinutes: 10–60 (realistic, not aspirational)
- load: "light" (≤15 min, easy), "focus" (16–35 min, needs concentration), "stretch" (>35 min, demanding)
- dayOffset: which day to schedule it (0 = today, max = deadlineDays - 1)
- Schedule earlier tasks (dayOffset 0–2) as lighter tasks to build momentum

Respond ONLY with valid JSON:
{
  "tasks": [
    { "title": "...", "durationMinutes": 20, "load": "light", "dayOffset": 0 },
    ...
  ]
}`.trim();

      try {
        const { text } = await ai.generate({
          model: defaultModel,
          prompt,
          config: {
            temperature: 0.5,
            maxOutputTokens: 3072,
            responseMimeType: "application/json",
            thinkingConfig: { thinkingBudget: 512 },
          },
        });

        const parsed = parseModelJson<{ tasks: z.infer<typeof GeneratedTaskSchema>[] }>(text);

        const validLoads = new Set(["light", "focus", "stretch"]);
        const tasks = (parsed.tasks ?? [])
          .filter(
            (t) =>
              typeof t.title === "string" &&
              t.title.trim().length > 0 &&
              validLoads.has(t.load)
          )
          .map((t) => ({
            title:           t.title.trim(),
            durationMinutes: Math.min(90, Math.max(5, Number(t.durationMinutes))),
            load:            t.load as "light" | "focus" | "stretch",
            dayOffset:       Math.min(
              input.deadlineDays - 1,
              Math.max(0, Number(t.dayOffset))
            ),
          }))
          .slice(0, 12);

        if (tasks.length >= 2) return {
          tasks,
          explanation: `Generated ${tasks.length} micro-tasks for "${input.goalTitle}" using AI.`,
        };
      } catch (e) {
        console.error("[taskGeneratorFlow] AI generation failed:", e);
      }

      // Deterministic fallback
      return {
        tasks: [
          { title: `Define the goal outcome for ${input.goalTitle}`, durationMinutes: 10, load: "light"   as const, dayOffset: 0 },
          { title: "List blockers and open questions",                durationMinutes: 15, load: "light"   as const, dayOffset: 0 },
          { title: "Complete the main first deliverable",             durationMinutes: 40, load: "focus"   as const, dayOffset: 1 },
          { title: "Review progress and fix the weakest part",        durationMinutes: 25, load: "stretch" as const, dayOffset: 2 },
        ],
        explanation: "AI was unavailable — using a structured fallback plan.",
      };
    }
  );
}
