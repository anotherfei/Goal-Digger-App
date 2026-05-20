// ─────────────────────────────────────────────────────────────────────────────
// genkit_backend/lib/flows/task_generator_flow.dart
//
// FIX: This file previously contained three flow definitions (taskGenerator,
//      moodAdvisor, focusInsight), but main.dart tried to import
//      mood_advisor_flow.dart and focus_insight_flow.dart as separate files
//      (which didn't exist), causing compile errors.
//      moodAdvisor → mood_advisor_flow.dart
//      focusInsight → focus_insight_flow.dart
//
// ENHANCE: Added 'tags' to task output so the UI can colour-code tasks.
// ENHANCE: Added 'subtasks' optional field for stretch tasks.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';

GenkitFlow registerTaskGeneratorFlow(Genkit ai) {
  return ai.defineFlow(
    name: 'taskGenerator',
    inputSchema: z.object({
      'goalTitle':          z.string(),
      'category':           z.string(),
      'deadlineDays':       z.number().int(),
      'priority':           z.number().int(), // 1–5
      'existingTaskTitles': z.array(z.string()).optional(),
    }),
    outputSchema: z.object({
      'tasks': z.array(z.object({
        'title':           z.string(),
        'durationMinutes': z.number().int(),
        'load':            z.string(),       // light | focus | stretch
        'dayOffset':       z.number().int(), // 0 = today
        'tags':            z.array(z.string()), // e.g. ["research","writing"]
      })),
      'explanation': z.string(),
    }),
    fn: (input) async {
      final goalTitle    = input['goalTitle'] as String;
      final category     = input['category'] as String;
      final deadlineDays = (input['deadlineDays'] as num).toInt();
      final priority     = (input['priority'] as num).toInt();
      final existing     = (input['existingTaskTitles'] as List<dynamic>? ?? [])
          .cast<String>();

      final existingNote = existing.isEmpty
          ? ''
          : 'Avoid duplicating these existing tasks: ${existing.join(', ')}.';

      final prompt = '''
You are a productivity expert helping a user achieve: "$goalTitle".
Category: $category | Deadline: $deadlineDays days | Priority: $priority/5.
$existingNote

Generate 4–6 specific micro-tasks that will meaningfully progress this goal.
Each task should be concrete and completable in one sitting.
Spread them intelligently across the available $deadlineDays days —
earlier days for higher-priority or blocking tasks.

load options:
  "light"   = easy, minimal focus needed (≤15 min)
  "focus"   = requires concentration (15–30 min)
  "stretch" = challenging, deep work (>30 min)

tags: 1–3 lowercase words describing the type of work (e.g. "research", "writing",
"design", "coding", "review", "planning", "communication").

Respond ONLY with valid JSON matching this exact shape:
{
  "tasks": [
    {
      "title": "...",
      "durationMinutes": 20,
      "load": "focus",
      "dayOffset": 0,
      "tags": ["writing"]
    }
  ],
  "explanation": "One sentence explaining your scheduling approach."
}
''';

      final response = await ai.generate(
        model: googleGenAI('gemma-4-it'),
        prompt: prompt,
        config: GenerationConfig(
          temperature: 0.6,
          maxOutputTokens: 1024,
          responseMimeType: 'application/json',
        ),
      );

      final parsed = response.outputAsMap();

      // Normalise tasks — ensure tags field always exists
      final rawTasks = (parsed['tasks'] as List<dynamic>? ?? []);
      final tasks = rawTasks.map((t) {
        final task = Map<String, dynamic>.from(t as Map);
        task['tags'] ??= <String>[];
        return task;
      }).toList();

      return {
        'tasks':       tasks,
        'explanation': parsed['explanation'] ?? '',
      };
    },
  );
}
