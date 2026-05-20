// ─────────────────────────────────────────────────────────────────────────────
// genkit_backend/lib/flows/goal_coach_flow.dart
//
// Genkit flow: goalCoach
// Multi-turn AI coaching conversation using Gemma 4 (cloud).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';

GenkitFlow registerGoalCoachFlow(Genkit ai) {
  return ai.defineFlow(
    name: 'goalCoach',
    inputSchema: z.object({
      'userMessage':    z.string(),
      'goalTitle':      z.string(),
      'progressPercent': z.number(),
      'history': z.array(z.object({
        'role':    z.string(),
        'content': z.string(),
      })).optional(),
    }),
    outputSchema: z.object({
      'reply':             z.string(),
      'suggestedActions':  z.array(z.string()),
      'motivationalScore': z.number().int(),
    }),
    fn: (input) async {
      final userMessage     = input['userMessage'] as String;
      final goalTitle       = input['goalTitle'] as String;
      final progress        = (input['progressPercent'] as num).toDouble();
      final history         = (input['history'] as List<dynamic>? ?? []);

      // Build message history for multi-turn context
      final messages = <Message>[
        Message.system('''
You are the Goal Digger AI coach — supportive, concise, and action-oriented.
You help users break big goals into achievable tasks and stay motivated.
Current goal: "$goalTitle" (${(progress * 100).round()}% complete).
Reply in the same language as the user message.
Keep responses short (2–4 sentences) unless asked for detail.
After your reply, provide:
  - suggestedActions: 2–3 short action bullets the user could take right now
  - motivationalScore: integer 1–10 reflecting how motivated the user seems
Respond ONLY with valid JSON: { "reply": "...", "suggestedActions": [...], "motivationalScore": N }
'''),
        // Inject conversation history
        for (final msg in history)
          if ((msg as Map)['role'] == 'user')
            Message.user((msg)['content'] as String)
          else
            Message.model((msg)['content'] as String),
        // Current user message
        Message.user(userMessage),
      ];

      final response = await ai.generate(
        model: googleGenAI('gemma-4-it'),
        messages: messages,
        config: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 512,
          responseMimeType: 'application/json',
        ),
      );

      final parsed = response.outputAsMap();
      return {
        'reply':             parsed['reply'] ?? '',
        'suggestedActions':  parsed['suggestedActions'] ?? [],
        'motivationalScore': parsed['motivationalScore'] ?? 7,
      };
    },
  );
}
