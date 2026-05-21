// lib/genkit/flows/goal_coach_flow.dart
//
// Typed wrappers for every Firebase Function AI flow.
// Each class passes the Firebase Function name (from GenkitConfig) to
// GenkitClient, which calls it via the cloud_functions package.

import '../genkit_client.dart';
import '../genkit_config.dart';
import '../models/ai_models.dart';

// ── Goal Coach ────────────────────────────────────────────────────────────────

class GoalCoachFlow {
  const GoalCoachFlow(this._client);
  final GenkitClient _client;

  Future<GoalCoachResponse> ask(GoalCoachRequest request) async {
    final response = await _client.callFlow(
      GenkitConfig.fnGoalCoach,   // ← Firebase Function name
      request.toJson(),
    );
    if (!response.isSuccess) {
      throw GenkitFlowException(flow: 'goalCoach', message: response.error ?? 'Unknown error');
    }
    return GoalCoachResponse.fromJson(response.result!);
  }

  /// Streams partial tokens via the goalCoachStream onRequest SSE function.
  Stream<String> stream(GoalCoachRequest request) =>
      _client.streamFlow(GenkitConfig.fnGoalCoachStream, request.toJson());
}

// ── Task Generator ────────────────────────────────────────────────────────────

class TaskGeneratorFlow {
  const TaskGeneratorFlow(this._client);
  final GenkitClient _client;

  Future<TaskGeneratorResponse> generate(TaskGeneratorRequest request) async {
    final response = await _client.callFlow(
      GenkitConfig.fnTaskGenerator,
      request.toJson(),
    );
    if (!response.isSuccess) {
      throw GenkitFlowException(flow: 'taskGenerator', message: response.error ?? 'Unknown error');
    }
    return TaskGeneratorResponse.fromJson(response.result!);
  }
}

// ── Mood Advisor ──────────────────────────────────────────────────────────────

class MoodAdvisorFlow {
  const MoodAdvisorFlow(this._client);
  final GenkitClient _client;

  Future<MoodAdvisorResponse> advise(MoodAdvisorRequest request) async {
    final response = await _client.callFlow(
      GenkitConfig.fnMoodAdvisor,
      request.toJson(),
    );
    if (!response.isSuccess) {
      throw GenkitFlowException(flow: 'moodAdvisor', message: response.error ?? 'Unknown error');
    }
    return MoodAdvisorResponse.fromJson(response.result!);
  }
}

// ── Focus Insight ─────────────────────────────────────────────────────────────

class FocusInsightFlow {
  const FocusInsightFlow(this._client);
  final GenkitClient _client;

  Future<FocusInsightResponse> analyse(FocusInsightRequest request) async {
    final response = await _client.callFlow(
      GenkitConfig.fnFocusInsight,
      request.toJson(),
    );
    if (!response.isSuccess) {
      throw GenkitFlowException(flow: 'focusInsight', message: response.error ?? 'Unknown error');
    }
    return FocusInsightResponse.fromJson(response.result!);
  }
}

// ── Shared exception ──────────────────────────────────────────────────────────

class GenkitFlowException implements Exception {
  const GenkitFlowException({required this.flow, required this.message});
  final String flow;
  final String message;
  @override
  String toString() => 'GenkitFlowException[$flow]: $message';
}
