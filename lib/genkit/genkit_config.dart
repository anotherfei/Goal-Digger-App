// ─────────────────────────────────────────────────────────────────────────────
// lib/genkit/genkit_config.dart
//
// Central configuration for all Genkit / Gemma 4 AI integration.
// All env values are read from compile-time defines so no secrets land in
// the Flutter asset bundle.
//
// Compile with:
//   flutter run --dart-define=GENKIT_BASE_URL=https://YOUR_CLOUD_RUN_URL
//               --dart-define=GENKIT_API_KEY=your_key   # optional if using Firebase Auth
// ─────────────────────────────────────────────────────────────────────────────

class GenkitConfig {
  GenkitConfig._();

  // ── Backend URL ───────────────────────────────────────────────────────────────
  // URL of the deployed Genkit Dart backend (Cloud Run or Cloud Functions).
  // Change the default to your real Cloud Run URL after deployment.
  static const String baseUrl = String.fromEnvironment(
    'GENKIT_BASE_URL',
    defaultValue: 'http://localhost:3400', // local dev default
  );

  // ── API key (optional – prefer Firebase ID tokens) ────────────────────────────
  static const String apiKey = String.fromEnvironment(
    'GENKIT_API_KEY',
    defaultValue: '',
  );

  // ── Gemma 4 model identifier ──────────────────────────────────────────────────
  // Gemma 4 on Google AI Studio / Vertex AI.
  // Adjust to the exact model string when Google releases Gemma 4:
  //   Google AI Studio:  'gemma-4-it'
  //   Vertex AI:         'google/gemma-4-27b-it'
  static const String gemma4ModelId = String.fromEnvironment(
    'GEMMA4_MODEL_ID',
    defaultValue: 'gemma-4-it',
  );

  // ── Flow endpoints ────────────────────────────────────────────────────────────
  // Each maps to a Genkit flow registered on the backend.
  static const String flowGoalCoach    = '/flow/goalCoach';
  static const String flowTaskGen      = '/flow/taskGenerator';
  static const String flowMoodAdvisor  = '/flow/moodAdvisor';
  static const String flowFocusInsight = '/flow/focusInsight';

  // ── Request tuning ────────────────────────────────────────────────────────────
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int maxRetries          = 2;
  static const int maxTokens           = 1024;

  // ── Prompt system template ────────────────────────────────────────────────────
  static const String systemPrompt = '''
You are the Goal Digger AI coach — supportive, concise, and action-oriented.
You help users break big goals into small achievable tasks, stay motivated,
and reflect on their progress. Always reply in the same language the user
writes in. Keep responses short and encouraging unless asked for detail.
''';
}
