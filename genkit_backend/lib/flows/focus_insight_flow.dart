// ─────────────────────────────────────────────────────────────────────────────
// genkit_backend/lib/flows/focus_insight_flow.dart
//
// FIX: Extracted from task_generator_flow.dart — this function was previously
//      in that file but main.dart tried to import it from this non-existent
//      file, causing a compile error.
//
// Genkit flow: focusInsight
// Called after a Pomodoro/focus session ends.
// Returns an encouraging insight, a next-step hint, and a coin reward.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';

GenkitFlow registerFocusInsightFlow(Genkit ai) {
  return ai.defineFlow(
    name: 'focusInsight',
    inputSchema: z.object({
      'taskTitle':       z.string(),
      'goalTitle':       z.string(),
      'durationMinutes': z.number().int(),
      'completed':       z.boolean(),
    }),
    outputSchema: z.object({
      'insight':      z.string(),
      'nextStepHint': z.string(),
      'coinsEarned':  z.number().int(),
    }),
    fn: (input) async {
      final taskTitle = input['taskTitle'] as String;
      final goalTitle = input['goalTitle'] as String;
      final duration  = (input['durationMinutes'] as num).toInt();
      final completed = input['completed'] as bool;

      // ENHANCE: Coin range is calculated here and passed as a hint, so the
      // model can suggest an appropriate value rather than always picking
      // exactly coinBase.  The backend still owns the final value.
      final coinBase  = completed
          ? (duration * 0.8).round()
          : (duration * 0.4).round();
      final coinMin   = (coinBase - 5).clamp(1, 9999);
      final coinMax   = coinBase + 10;
      final status    = completed ? 'fully completed' : 'partially completed';

      final prompt = '''
A Goal Digger user just $status a focus session.
Task: "$taskTitle"  |  Goal: "$goalTitle"  |  Duration: $duration minutes.

Write:
1. "insight": A brief, specific, encouraging observation about this session (1 sentence).
   Reference the task or goal by name — don't be generic.
2. "nextStepHint": A concrete hint for what to do next to keep momentum (1 sentence).
3. "coinsEarned": Integer coin reward between $coinMin and $coinMax.
   Completed sessions earn more. Longer sessions earn more within the range.

Respond ONLY with valid JSON:
{
  "insight": "...",
  "nextStepHint": "...",
  "coinsEarned": $coinBase
}
''';

      final response = await ai.generate(
        model: googleGenAI('gemma-4-it'),
        prompt: prompt,
        config: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 256,
          responseMimeType: 'application/json',
        ),
      );

      final parsed = response.outputAsMap();

      // Guard coin value to stay within the intended range
      final rawCoins = (parsed['coinsEarned'] as num?)?.toInt() ?? coinBase;
      final coinsEarned = rawCoins.clamp(coinMin, coinMax);

      return {
        'insight':      parsed['insight']      ?? '',
        'nextStepHint': parsed['nextStepHint'] ?? '',
        'coinsEarned':  coinsEarned,
      };
    },
  );
}
