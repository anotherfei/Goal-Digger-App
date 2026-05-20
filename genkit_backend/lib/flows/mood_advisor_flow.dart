// ─────────────────────────────────────────────────────────────────────────────
// genkit_backend/lib/flows/mood_advisor_flow.dart
//
// FIX: Extracted from task_generator_flow.dart — this function was previously
//      in that file but main.dart tried to import it from this non-existent
//      file, causing a compile error.
//
// Genkit flow: moodAdvisor
// Returns a short personalised message + suggestion based on the user's mood
// and daily task progress.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';

GenkitFlow registerMoodAdvisorFlow(Genkit ai) {
  return ai.defineFlow(
    name: 'moodAdvisor',
    inputSchema: z.object({
      'mood':           z.string(),
      'completedToday': z.number().int(),
      'totalToday':     z.number().int(),
      'streak':         z.number().int(),
    }),
    outputSchema: z.object({
      'message':    z.string(),
      'emoji':      z.string(),
      'suggestion': z.string(),
    }),
    fn: (input) async {
      final mood   = input['mood'] as String;
      final done   = (input['completedToday'] as num).toInt();
      final total  = (input['totalToday'] as num).toInt();
      final streak = (input['streak'] as num).toInt();

      // Compute context string to guide the tone
      final streakNote = streak > 0
          ? ' They are on a $streak-day streak — acknowledge this warmly.'
          : '';
      final progressNote = total > 0
          ? '${((done / total) * 100).round()}% of their tasks done today ($done/$total).'
          : 'No tasks scheduled today.';

      final prompt = '''
A Goal Digger user says their current mood is "$mood".
Daily progress: $progressNote$streakNote

Write a short (1–2 sentences), warm, personalised message acknowledging
their mood and daily progress — never preachy or generic.
Then give one concrete, actionable suggestion for the rest of their day.
Choose an appropriate emoji that matches the mood.

Respond ONLY with valid JSON:
{
  "message": "...",
  "emoji": "🌟",
  "suggestion": "..."
}
''';

      final response = await ai.generate(
        model: googleGenAI('gemma-4-it'),
        prompt: prompt,
        config: GenerationConfig(
          temperature: 0.8,
          maxOutputTokens: 256,
          responseMimeType: 'application/json',
        ),
      );

      final parsed = response.outputAsMap();
      return {
        'message':    parsed['message']    ?? '',
        'emoji':      parsed['emoji']      ?? '✨',
        'suggestion': parsed['suggestion'] ?? '',
      };
    },
  );
}
