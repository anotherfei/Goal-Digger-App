/// goal_ai_assistant.dart
/// -----------------------
/// High-level AI features built on top of [GemmaService].
///
/// This class is the primary interface for all AI-powered features:
///   • generateTaskPlan  – break a goal into micro-tasks
///   • getMotivation     – personalised motivational message + tip
///   • reviewProgress    – coach-style progress review
///   • chat              – single-turn companion chat (streaming)
///   • suggestCommunityPost – auto-draft a community post
///
/// Folder: lib/services/ai/

import 'dart:convert';

import '../../models/models.dart';
import 'ai_models.dart';
import 'ai_prompts.dart';
import 'gemma_service.dart';

class GoalAiAssistant {
  GoalAiAssistant(this._gemma);

  final GemmaService _gemma;

  // ── Task plan generation ──────────────────────────────────────────────────

  /// Returns an [AiTaskPlan] with suggested [MicroTask]-like objects
  /// that can be converted to real [MicroTask]s by the caller.
  Future<AiTaskPlan> generateTaskPlan({
    required GoalProject goal,
    required DateTime today,
    int maxTasksPerDay = 3,
  }) async {
    final daysLeft = goal.deadline.difference(today).inDays.clamp(1, 90);

    final request = GemmaRequest.singleTurn(
      AiPrompts.taskPlan(
        goalTitle: goal.title,
        category: goal.category,
        importanceLevel: goal.importance,
        daysUntilDeadline: daysLeft,
        maxTasksPerDay: maxTasksPerDay,
      ),
      systemInstruction: AiPrompts.coreSystem,
      maxTokens: 1200,
      temperature: 0.4, // lower temperature for structured output
    );

    final response = await _gemma.generate(request);
    return _parseTaskPlan(response.text);
  }

  // ── Motivational message ──────────────────────────────────────────────────

  Future<AiMotivation> getMotivation({
    required String userName,
    required int streak,
    required List<GoalProject> goals,
    required int completedTasksToday,
    required String mood,
  }) async {
    final totalTasks =
        goals.fold<int>(0, (sum, g) => sum + g.tasks.length);
    final doneTasks =
        goals.fold<int>(0, (sum, g) => sum + g.tasks.where((t) => t.done).length);
    final progress = totalTasks == 0 ? 0.0 : doneTasks / totalTasks;

    final request = GemmaRequest.singleTurn(
      AiPrompts.motivation(
        userName: userName,
        streak: streak,
        overallProgress: progress,
        completedTasksToday: completedTasksToday,
        mood: mood,
      ),
      systemInstruction: AiPrompts.coreSystem,
      maxTokens: 400,
      temperature: 0.8,
    );

    final response = await _gemma.generate(request);
    return _parseMotivation(response.text);
  }

  // ── Progress review ───────────────────────────────────────────────────────

  Future<AiProgressReview> reviewProgress({
    required List<GoalProject> goals,
    required int streak,
  }) async {
    final goalMaps = goals
        .map((g) => {
              'title': g.title,
              'progress': g.progress,
              'deadline': _formatDate(g.deadline),
            })
        .toList();

    final totalDone = goals.fold<int>(
        0, (sum, g) => sum + g.tasks.where((t) => t.done).length);
    final totalPending = goals.fold<int>(
        0, (sum, g) => sum + g.tasks.where((t) => !t.done).length);

    final request = GemmaRequest.singleTurn(
      AiPrompts.progressReview(
        goals: goalMaps,
        totalTasksCompleted: totalDone,
        totalTasksPending: totalPending,
        streak: streak,
      ),
      systemInstruction: AiPrompts.coreSystem,
      maxTokens: 600,
      temperature: 0.5,
    );

    final response = await _gemma.generate(request);
    return _parseProgressReview(response.text);
  }

  // ── Companion chat (streaming) ────────────────────────────────────────────

  /// Returns a stream of tokens for a single-turn companion message.
  /// Append the yielded strings to a StringBuffer in your widget.
  Stream<String> chat({
    required String userMessage,
    required String userName,
    required String mood,
    required int streak,
    required int coins,
    required int petHappiness,
    required String petName,
  }) {
    final systemInstruction = AiPrompts.companionChat(
      userName: userName,
      mood: mood,
      streak: streak,
      coins: coins,
      petHappiness: petHappiness,
      petName: petName,
    );

    final request = GemmaRequest(
      messages: [GemmaMessage.user(userMessage)],
      systemInstruction: systemInstruction,
      maxTokens: 150,
      temperature: 0.9,
    );

    return _gemma.generateStream(request);
  }

  // ── Community post suggestion ─────────────────────────────────────────────

  Future<String> suggestCommunityPost({
    required String groupName,
    required GoalProject goal,
  }) async {
    final progress = (goal.progress * 100).round();
    final request = GemmaRequest.singleTurn(
      AiPrompts.communityPost(
        groupName: groupName,
        goalTitle: goal.title,
        progressPercent: progress,
      ),
      systemInstruction: AiPrompts.coreSystem,
      maxTokens: 200,
      temperature: 0.85,
    );

    final response = await _gemma.generate(request);
    return response.text.trim();
  }

  // ── JSON parsers ──────────────────────────────────────────────────────────

  AiTaskPlan _parseTaskPlan(String raw) {
    try {
      final json = jsonDecode(_cleanJson(raw)) as Map<String, dynamic>;
      final taskList = (json['tasks'] as List).cast<Map<String, dynamic>>();
      return AiTaskPlan(
        reasoning: json['reasoning'] as String? ?? '',
        tasks: taskList
            .map((t) => AiSuggestedTask(
                  title: t['title'] as String,
                  durationMinutes: (t['durationMinutes'] as num).toInt(),
                  load: t['load'] as String,
                  dayOffset: (t['dayOffset'] as num).toInt(),
                ))
            .toList(),
      );
    } catch (e) {
      throw FormatException('Failed to parse task plan from Gemma: $e\n$raw');
    }
  }

  AiMotivation _parseMotivation(String raw) {
    try {
      final json = jsonDecode(_cleanJson(raw)) as Map<String, dynamic>;
      return AiMotivation(
        message: json['message'] as String? ?? '',
        quote: json['quote'] as String? ?? '',
        tip: json['tip'] as String? ?? '',
      );
    } catch (e) {
      // Graceful fallback — show the raw text as the message.
      return AiMotivation(message: raw.trim(), quote: '', tip: '');
    }
  }

  AiProgressReview _parseProgressReview(String raw) {
    try {
      final json = jsonDecode(_cleanJson(raw)) as Map<String, dynamic>;
      return AiProgressReview(
        summary: json['summary'] as String? ?? '',
        strengths: List<String>.from(json['strengths'] as List? ?? []),
        improvements: List<String>.from(json['improvements'] as List? ?? []),
        nextFocus: json['nextFocus'] as String? ?? '',
      );
    } catch (e) {
      throw FormatException(
          'Failed to parse progress review from Gemma: $e\n$raw');
    }
  }

  /// Strips markdown code-fences that the model sometimes adds despite instructions.
  String _cleanJson(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('```')) {
      final start = trimmed.indexOf('{');
      final end = trimmed.lastIndexOf('}');
      if (start != -1 && end != -1) return trimmed.substring(start, end + 1);
    }
    return trimmed;
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
