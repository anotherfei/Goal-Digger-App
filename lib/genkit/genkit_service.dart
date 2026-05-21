// lib/genkit/genkit_service.dart
//
// Single injectable service exposing all four AI flows.
//
// No AuthService needed — GenkitClient reads the signed-in user directly
// from FirebaseAuth.instance (the cloud_functions package does the same
// for callable functions automatically).

import 'flows/goal_coach_flow.dart';
import 'genkit_client.dart';

export 'flows/goal_coach_flow.dart'
    show
        GoalCoachFlow,
        TaskGeneratorFlow,
        MoodAdvisorFlow,
        FocusInsightFlow,
        GenkitFlowException;
export 'models/ai_models.dart';

class GenkitService {
  GenkitService() {
    _client       = GenkitClient();
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
}
