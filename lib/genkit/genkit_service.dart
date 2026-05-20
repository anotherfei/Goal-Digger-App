// ─────────────────────────────────────────────────────────────────────────────
// lib/genkit/genkit_service.dart
//
// Single injectable service that wires [GenkitClient] + all flows.
// Expose this through Provider so widgets can call:
//
//   context.read<GenkitService>().goalCoach.ask(...)
//   context.read<GenkitService>().taskGenerator.generate(...)
//   context.read<GenkitService>().moodAdvisor.advise(...)
//   context.read<GenkitService>().focusInsight.analyse(...)
//
// FIX: Previously only imported goal_coach_flow.dart, but instantiated
//      TaskGeneratorFlow, MoodAdvisorFlow, and FocusInsightFlow which are all
//      defined in that same file.  The missing explicit exports for those
//      classes meant downstream code couldn't reference them without knowing
//      which file they came from.  Now all four are explicitly re-exported.
// ─────────────────────────────────────────────────────────────────────────────

import '../firebase/auth/auth_service.dart';
import 'flows/goal_coach_flow.dart';
import 'genkit_client.dart';
import 'models/ai_models.dart';

// Re-export everything callers need so they only import genkit_service.dart
export 'flows/goal_coach_flow.dart'
    show
        GoalCoachFlow,
        TaskGeneratorFlow,
        MoodAdvisorFlow,
        FocusInsightFlow,
        GenkitFlowException;
export 'models/ai_models.dart';

class GenkitService {
  GenkitService({required AuthService authService}) {
    _client       = GenkitClient(authService: authService);
    goalCoach     = GoalCoachFlow(_client);
    taskGenerator = TaskGeneratorFlow(_client);
    moodAdvisor   = MoodAdvisorFlow(_client);
    focusInsight  = FocusInsightFlow(_client);
  }

  late final GenkitClient _client;
  late final GoalCoachFlow goalCoach;
  late final TaskGeneratorFlow taskGenerator;
  late final MoodAdvisorFlow moodAdvisor;
  late final FocusInsightFlow focusInsight;

  /// Expose the underlying client for any ad-hoc flow calls not covered
  /// by the typed wrappers (advanced use only).
  GenkitClient get rawClient => _client;
}
