// lib/genkit/genkit_service.dart
//
// Single injectable service exposing all four AI flows.
// AuthService is injected from main.dart and passed into GenkitClient.

import '../firebase/auth/auth_service.dart';
import 'flows/goal_coach_flow.dart';
import 'genkit_client.dart';

export 'flows/goal_coach_flow.dart'
    show
        GoalCoachFlow,
        TaskGeneratorFlow,
        MoodAdvisorFlow,
        FocusInsightFlow,
        AgentPlannerFlow,
        AgentModifyFlow,
        AgentReassignFlow,
        GenkitFlowException;

export 'models/ai_models.dart';

class GenkitService {
  GenkitService({required AuthService authService}) {
    _client = GenkitClient(authService: authService);

    goalCoach = GoalCoachFlow(_client);
    taskGenerator = TaskGeneratorFlow(_client);
    moodAdvisor = MoodAdvisorFlow(_client);
    focusInsight = FocusInsightFlow(_client);
    agentPlanner = AgentPlannerFlow(_client);
    agentModify = AgentModifyFlow(_client);
    agentReassign = AgentReassignFlow(_client);
  }

  late final GenkitClient _client;

  late final GoalCoachFlow goalCoach;
  late final TaskGeneratorFlow taskGenerator;
  late final MoodAdvisorFlow moodAdvisor;
  late final FocusInsightFlow focusInsight;
  late final AgentPlannerFlow agentPlanner;
  late final AgentModifyFlow agentModify;
  late final AgentReassignFlow agentReassign;
}