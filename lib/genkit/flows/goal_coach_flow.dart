// ─────────────────────────────────────────────────────────────────────────────
// lib/genkit/flows/goal_coach_flow.dart
//
// Typed wrapper around the `goalCoach` Genkit flow.
// Provides streaming and single-shot coaching conversations.
// ─────────────────────────────────────────────────────────────────────────────

import '../genkit_client.dart';
import '../genkit_config.dart';
import '../models/ai_models.dart';

class GoalCoachFlow {
  const GoalCoachFlow(this._client);

  final GenkitClient _client;

  // ── Single response ───────────────────────────────────────────────────────────

  Future<GoalCoachResponse> ask(GoalCoachRequest request) async {
    final response = await _client.callFlow(
      GenkitConfig.flowGoalCoach,
      request.toJson(),
    );

    if (!response.isSuccess) {
      throw GenkitFlowException(
        flow: 'goalCoach',
        message: response.error ?? 'Unknown error',
      );
    }

    return GoalCoachResponse.fromJson(response.result!);
  }

  // ── Streaming response ────────────────────────────────────────────────────────

  /// Streams partial reply tokens for live typing animation in the UI.
  Stream<String> stream(GoalCoachRequest request) =>
      _client.streamFlow(GenkitConfig.flowGoalCoach, request.toJson());
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/genkit/flows/task_generator_flow.dart
// ─────────────────────────────────────────────────────────────────────────────

class TaskGeneratorFlow {
  const TaskGeneratorFlow(this._client);

  final GenkitClient _client;

  /// Generates a breakdown of [MicroTask]-compatible tasks for a goal.
  Future<TaskGeneratorResponse> generate(TaskGeneratorRequest request) async {
    final response = await _client.callFlow(
      GenkitConfig.flowTaskGen,
      request.toJson(),
    );

    if (!response.isSuccess) {
      throw GenkitFlowException(
        flow: 'taskGenerator',
        message: response.error ?? 'Unknown error',
      );
    }

    return TaskGeneratorResponse.fromJson(response.result!);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/genkit/flows/mood_advisor_flow.dart
// ─────────────────────────────────────────────────────────────────────────────

class MoodAdvisorFlow {
  const MoodAdvisorFlow(this._client);

  final GenkitClient _client;

  Future<MoodAdvisorResponse> advise(MoodAdvisorRequest request) async {
    final response = await _client.callFlow(
      GenkitConfig.flowMoodAdvisor,
      request.toJson(),
    );

    if (!response.isSuccess) {
      throw GenkitFlowException(
        flow: 'moodAdvisor',
        message: response.error ?? 'Unknown error',
      );
    }

    return MoodAdvisorResponse.fromJson(response.result!);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/genkit/flows/focus_insight_flow.dart
// ─────────────────────────────────────────────────────────────────────────────

class FocusInsightFlow {
  const FocusInsightFlow(this._client);

  final GenkitClient _client;

  Future<FocusInsightResponse> analyse(FocusInsightRequest request) async {
    final response = await _client.callFlow(
      GenkitConfig.flowFocusInsight,
      request.toJson(),
    );

    if (!response.isSuccess) {
      throw GenkitFlowException(
        flow: 'focusInsight',
        message: response.error ?? 'Unknown error',
      );
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
