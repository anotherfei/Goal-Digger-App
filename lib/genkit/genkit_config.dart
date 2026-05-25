// lib/genkit/genkit_config.dart
//
// Configuration for Goal Digger's AI integration via Firebase Functions.
//
// No secrets, no URLs needed in Flutter — the cloud_functions package
// resolves function URLs automatically from your Firebase project config.
// The only thing to configure is the region if you deployed outside .

class GenkitConfig {
  GenkitConfig._();

  // ── Firebase Function names ───────────────────────────────────────────────
  // Must exactly match the export names in functions/src/index.ts
  static const String fnGoalCoach     = "goalCoach";
  static const String fnTaskGenerator = "taskGenerator";
  static const String fnMoodAdvisor   = "moodAdvisor";
  static const String fnFocusInsight  = "focusInsight";
  static const String fnAgentPlanner  = "agentPlanner";
  // onRequest SSE streaming endpoint (goalCoachStream in index.ts)
  static const String fnGoalCoachStream = "goalCoachStream";

  // ── Region ────────────────────────────────────────────────────────────────
  // Change this if you deploy to a different region.
  static const String region = "asia-east1";

  // ── Timeouts ──────────────────────────────────────────────────────────────
  static const Duration callTimeout   = Duration(seconds: 60);
  static const Duration streamTimeout = Duration(seconds: 120);
}
