// ─────────────────────────────────────────────────────────────────────────────
// lib/genkit/models/ai_models.dart
//
// Shared request / response value objects for every Genkit flow.
// Intentionally free of any Firebase or Flutter imports.
// ─────────────────────────────────────────────────────────────────────────────

// ── Generic flow envelope ─────────────────────────────────────────────────────

class FlowRequest {
  const FlowRequest({required this.data});
  final Map<String, dynamic> data;

  Map<String, dynamic> toJson() => {'data': data};
}

class FlowResponse {
  const FlowResponse({
    required this.result,
    this.error,
    this.usage,
  });

  final Map<String, dynamic>? result;
  final String? error;
  final TokenUsage? usage;

  bool get isSuccess => error == null && result != null;

  factory FlowResponse.fromJson(Map<String, dynamic> json) {
    final usage = json['usage'] != null
        ? TokenUsage.fromJson(json['usage'] as Map<String, dynamic>)
        : null;
    return FlowResponse(
      result: json['result'] as Map<String, dynamic>?,
      error: json['error'] as String?,
      usage: usage,
    );
  }
}

class TokenUsage {
  const TokenUsage({
    required this.promptTokens,
    required this.completionTokens,
  });

  final int promptTokens;
  final int completionTokens;
  int get totalTokens => promptTokens + completionTokens;

  factory TokenUsage.fromJson(Map<String, dynamic> json) => TokenUsage(
        promptTokens: (json['promptTokens'] as num?)?.toInt() ?? 0,
        completionTokens: (json['completionTokens'] as num?)?.toInt() ?? 0,
      );
}

// ── Goal Coach ────────────────────────────────────────────────────────────────

class GoalCoachRequest {
  const GoalCoachRequest({
    required this.userMessage,
    required this.goalTitle,
    required this.progressPercent,
    this.conversationHistory = const [],
  });

  final String userMessage;
  final String goalTitle;
  final double progressPercent;
  final List<ChatMessage> conversationHistory;

  Map<String, dynamic> toJson() => {
        'userMessage': userMessage,
        'goalTitle': goalTitle,
        'progressPercent': progressPercent,
        // Key must match the backend Zod schema field name exactly.
        'conversationHistory': conversationHistory.map((m) => m.toJson()).toList(),
      };
}

class GoalCoachResponse {
  const GoalCoachResponse({
    required this.reply,
    required this.suggestedActions,
    required this.motivationalScore,
  });

  final String reply;
  final List<String> suggestedActions;
  final int motivationalScore; // 1–10

  factory GoalCoachResponse.fromJson(Map<String, dynamic> json) =>
      GoalCoachResponse(
        reply: json['reply'] as String? ?? '',
        suggestedActions:
            (json['suggestedActions'] as List<dynamic>? ?? []).cast<String>(),
        motivationalScore: (json['motivationalScore'] as num?)?.toInt() ?? 7,
      );
}

// ── Task Generator ────────────────────────────────────────────────────────────

class TaskGeneratorRequest {
  const TaskGeneratorRequest({
    required this.goalTitle,
    required this.category,
    required this.deadlineDays,
    required this.priority,
    this.existingTaskTitles = const [],
  });

  final String goalTitle;
  final String category;
  final int deadlineDays;
  final int priority; // 1–5
  final List<String> existingTaskTitles;

  Map<String, dynamic> toJson() => {
        'goalTitle': goalTitle,
        'category': category,
        'deadlineDays': deadlineDays,
        'priority': priority,
        'existingTaskTitles': existingTaskTitles,
      };
}

class GeneratedTask {
  const GeneratedTask({
    required this.title,
    required this.durationMinutes,
    required this.load,
    required this.dayOffset,
  });

  final String title;
  final int durationMinutes;
  final String load; // 'light' | 'focus' | 'stretch'
  final int dayOffset; // days from today

  factory GeneratedTask.fromJson(Map<String, dynamic> json) => GeneratedTask(
        title: json['title'] as String,
        durationMinutes: (json['durationMinutes'] as num).toInt(),
        load: json['load'] as String? ?? 'focus',
        dayOffset: (json['dayOffset'] as num?)?.toInt() ?? 0,
      );
}

class TaskGeneratorResponse {
  const TaskGeneratorResponse({required this.tasks, required this.explanation});

  final List<GeneratedTask> tasks;
  final String explanation;

  factory TaskGeneratorResponse.fromJson(Map<String, dynamic> json) =>
      TaskGeneratorResponse(
        tasks: (json['tasks'] as List<dynamic>? ?? [])
            .map((t) => GeneratedTask.fromJson(t as Map<String, dynamic>))
            .toList(),
        explanation: json['explanation'] as String? ?? '',
      );
}

// ── Mood Advisor ─────────────────────────────────────────────────────────────

class MoodAdvisorRequest {
  const MoodAdvisorRequest({
    required this.mood,
    required this.completedToday,
    required this.totalToday,
    required this.streak,
  });

  final String mood;
  final int completedToday;
  final int totalToday;
  final int streak;

  Map<String, dynamic> toJson() => {
        'mood': mood,
        'completedToday': completedToday,
        'totalToday': totalToday,
        'streak': streak,
      };
}

class MoodAdvisorResponse {
  const MoodAdvisorResponse({
    required this.message,
    required this.emoji,
    required this.suggestion,
    this.intensity = 'medium',
  });

  final String message;
  final String emoji;
  final String suggestion;
  final String intensity; // 'low' | 'medium' | 'high'

  factory MoodAdvisorResponse.fromJson(Map<String, dynamic> json) =>
      MoodAdvisorResponse(
        message:   json['message']    as String? ?? '',
        emoji:     json['emoji']      as String? ?? '✨',
        suggestion: json['suggestion'] as String? ?? '',
        intensity:  json['intensity']  as String? ?? 'medium',
      );
}

// ── Focus Insight ─────────────────────────────────────────────────────────────

class FocusInsightRequest {
  const FocusInsightRequest({
    required this.taskTitle,
    required this.goalTitle,
    required this.durationMinutes,
    required this.completed,
  });

  final String taskTitle;
  final String goalTitle;
  final int durationMinutes;
  final bool completed;

  Map<String, dynamic> toJson() => {
        'taskTitle': taskTitle,
        'goalTitle': goalTitle,
        'durationMinutes': durationMinutes,
        'completed': completed,
      };
}

class FocusInsightResponse {
  const FocusInsightResponse({
    required this.insight,
    required this.nextStepHint,
    required this.coinsEarned,
    this.badge = '',
  });

  final String insight;
  final String nextStepHint;
  final int coinsEarned;
  final String badge; // e.g. "🏅 Deep Work" — now returned by backend

  factory FocusInsightResponse.fromJson(Map<String, dynamic> json) =>
      FocusInsightResponse(
        insight:      json['insight']      as String? ?? '',
        nextStepHint: json['nextStepHint'] as String? ?? '',
        coinsEarned:  (json['coinsEarned'] as num?)?.toInt() ?? 15,
        badge:        json['badge']        as String? ?? '',
      );
}

// ── Chat history helper ───────────────────────────────────────────────────────

class ChatMessage {
  const ChatMessage({required this.role, required this.content});

  final String role; // 'user' | 'model'
  final String content;

  Map<String, dynamic> toJson() => {'role': role, 'content': content};

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        role: json['role'] as String,
        content: json['content'] as String,
      );
}

// ── Agent Planner ────────────────────────────────────────────────────────────

class AgentPlannerRequest {
  const AgentPlannerRequest({required this.goal, this.context = const {}});

  final String goal;
  final Map<String, dynamic> context;

  Map<String, dynamic> toJson() => {
        'goal': goal,
        'context': context,
      };
}

class AgentPlannerResponse {
  const AgentPlannerResponse({
    required this.plan,
    required this.reflections,
    required this.memoryUpdated,
    this.goalGuardEvaluated = false,
    this.goalRejected = false,
    this.goalRejectionType,
    this.goalRejectionReason,
    this.goalRefinementPrompt,
    this.strategy,
    this.positiveGoal = true,
    this.suggestedDeadlineDays,
    this.deadlineSuggestionReason,
    this.milestones = const [],
    this.milestoneTasks = const [],
    this.milestoneNote,
    this.milestoneNeedsConfirmation = false,
    this.habitInsight,
    this.burnoutRisk,
    this.schedule = const {},
    this.degraded = false,
  });

  final Map<String, dynamic> plan;
  final List<Map<String, dynamic>> reflections;
  final bool memoryUpdated;

  /// True when the backend response included the goal_guard.ts verdict field.
  final bool goalGuardEvaluated;

  /// True when the backend refused to generate todos for this goal.
  final bool goalRejected;

  /// Why the goal was rejected ("unclear", "too_broad", "impossible", "harmful").
  final String? goalRejectionType;

  /// Human-readable reason explaining why no todos were generated.
  final String? goalRejectionReason;

  /// Prompt asking the user to sharpen or redefine the goal.
  final String? goalRefinementPrompt;

  /// One-line description of the planning approach the agent chose.
  final String? strategy;

  /// Positive goal filtering (§9.1): false when the goal was rejected for
  /// negative/destructive framing. [goalRejectionReason] explains why and
  /// [goalRefinementPrompt] asks the user to re-input the goal positively.
  final bool positiveGoal;

  /// When the agent judged the chosen deadline unrealistic for an ordinary
  /// person, the day count (from today) it recommends instead; null when the
  /// deadline is fine or the goal was rejected.
  final int? suggestedDeadlineDays;

  /// The agent's reasoning behind [suggestedDeadlineDays].
  final String? deadlineSuggestionReason;

  /// True when the agent proposed a deadline change for the user to accept
  /// or decline.
  bool get hasDeadlineSuggestion => suggestedDeadlineDays != null;

  /// Ready-to-use milestone titles produced by the createMilestones tool.
  /// Kept for backward compatibility; prefer [milestoneTasks] when present.
  final List<String> milestones;

  /// Fully AI-decided tasks from the Task Generation Agent — each carries its
  /// own duration, load, and day offset, so the client schedules them directly
  /// instead of inferring those values. Empty when the backend returned only
  /// titles (older builds or the milestone-titles fallback).
  final List<GeneratedTask> milestoneTasks;

  /// Feasibility note when the requested milestone count was scaled back or
  /// flagged as demanding (null when the request was honored as-is).
  final String? milestoneNote;

  /// True when [milestoneNote] is a yes/no question — the agent scaled an
  /// unrealistic request back and is asking the user to confirm the full amount.
  final bool milestoneNeedsConfirmation;

  /// AI productivity insight from the analyzeHabits tool, if it ran.
  final String? habitInsight;

  /// Burnout risk ("low" | "medium" | "high") detected by analyzeHabits.
  final String? burnoutRisk;

  /// Raw schedule payload from scheduleTasks (sessions, scheduleNote, …).
  final Map<String, dynamic> schedule;

  /// True when the agent fell back (planner/tool/reflection failures).
  final bool degraded;

  /// The first reflection condensed into a single user-facing line, or null.
  String? get primaryInsight {
    if (reflections.isEmpty) return null;
    final r = reflections.first;
    final insight = (r['insight'] ?? '').toString().trim();
    final recommendation = (r['recommendation'] ?? '').toString().trim();
    final parts = [insight, recommendation].where((s) => s.isNotEmpty);
    return parts.isEmpty ? null : parts.join(' ');
  }

  static Map<String, dynamic> _asStrMap(dynamic value) =>
      (value as Map<dynamic, dynamic>? ?? {})
          .map((key, v) => MapEntry(key.toString(), v));

  factory AgentPlannerResponse.fromJson(Map<String, dynamic> json) {
    final plan = _asStrMap(json['plan']);
    // Wire format: deadlineSuggestion: { suggestedDays: int, reason: string } | null
    final deadline = json['deadlineSuggestion'] is Map<dynamic, dynamic>
        ? _asStrMap(json['deadlineSuggestion'])
        : const <String, dynamic>{};
    final suggestedDays = (deadline['suggestedDays'] as num?)?.round();
    return AgentPlannerResponse(
      plan: plan,
      reflections: (json['reflections'] as List<dynamic>? ?? [])
          .whereType<Map<dynamic, dynamic>>()
          .map((entry) => _asStrMap(entry))
          .toList(),
      memoryUpdated: json['memoryUpdated'] as bool? ?? false,
      goalGuardEvaluated: json.containsKey('goalRejected'),
      goalRejected: json['goalRejected'] as bool? ?? false,
      goalRejectionType: json['goalRejectionType']?.toString(),
      goalRejectionReason: json['goalRejectionReason']?.toString(),
      goalRefinementPrompt: json['goalRefinementPrompt']?.toString(),
      strategy: (json['strategy'] ?? plan['strategy'])?.toString(),
      positiveGoal: json['positiveGoal'] as bool? ?? true,
      suggestedDeadlineDays:
          suggestedDays != null && suggestedDays >= 1 ? suggestedDays : null,
      deadlineSuggestionReason: deadline['reason']?.toString(),
      milestones: (json['milestones'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .where((s) => s.trim().isNotEmpty)
          .toList(),
      milestoneTasks: (json['milestoneTasks'] as List<dynamic>? ?? [])
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => GeneratedTask.fromJson(_asStrMap(e)))
          .where((t) => t.title.trim().isNotEmpty)
          .toList(),
      milestoneNote: json['milestoneNote']?.toString(),
      milestoneNeedsConfirmation:
          json['milestoneNeedsConfirmation'] as bool? ?? false,
      habitInsight: json['habitInsight']?.toString(),
      burnoutRisk: json['burnoutRisk']?.toString(),
      schedule: _asStrMap(json['schedule']),
      degraded: json['degraded'] as bool? ?? false,
    );
  }
}

// ── Task Modification Agent (§6.3) ───────────────────────────────────────────

class TaskModificationRequest {
  const TaskModificationRequest({
    required this.goal,
    required this.request,
    required this.currentTasks,
    this.context = const {},
    this.force = false,
  });

  final String goal;
  final String request;
  final List<GeneratedTask> currentTasks;
  final Map<String, dynamic> context;

  /// True when the user already answered "yes" to a confirmation question.
  final bool force;

  Map<String, dynamic> toJson() => {
        'goal': goal,
        'request': request,
        'currentTasks': currentTasks
            .map((t) => {
                  'title': t.title,
                  'durationMinutes': t.durationMinutes,
                  'load': t.load,
                  'dayOffset': t.dayOffset,
                })
            .toList(),
        'context': context,
        'force': force,
      };
}

class TaskModificationResponse {
  const TaskModificationResponse({
    required this.status,
    required this.tasks,
    required this.explanation,
    this.question,
    this.degraded = false,
  });

  /// 'applied' | 'clarify' | 'confirm' | 'rejected'
  final String status;

  /// The full revised plan when [status] == 'applied'; otherwise the
  /// unchanged current plan echoed back.
  final List<GeneratedTask> tasks;

  /// What the agent did or why it declined — always user-readable.
  final String explanation;

  /// Clarifying or yes/no confirmation question, when status asks one.
  final String? question;

  final bool degraded;

  bool get applied => status == 'applied';
  bool get needsConfirmation => status == 'confirm';
  bool get needsClarification => status == 'clarify';

  factory TaskModificationResponse.fromJson(Map<String, dynamic> json) =>
      TaskModificationResponse(
        status: json['status'] as String? ?? 'rejected',
        tasks: (json['tasks'] as List<dynamic>? ?? [])
            .whereType<Map<dynamic, dynamic>>()
            .map((t) => GeneratedTask.fromJson(
                t.map((k, v) => MapEntry(k.toString(), v))))
            .toList(),
        explanation: json['explanation'] as String? ?? '',
        question: json['question']?.toString(),
        degraded: json['degraded'] as bool? ?? false,
      );
}

// ── Task Reassignment Agent (§6.4) ───────────────────────────────────────────

class ReassignableTaskInfo {
  const ReassignableTaskInfo({
    required this.id,
    required this.goalId,
    required this.title,
    required this.durationMinutes,
    required this.load,
    required this.dayOffset,
    required this.done,
  });

  final String id;
  final String goalId;
  final String title;
  final int durationMinutes;
  final String load;
  final int dayOffset; // days from today (0 = today)
  final bool done;

  Map<String, dynamic> toJson() => {
        'id': id,
        'goalId': goalId,
        'title': title,
        'durationMinutes': durationMinutes,
        'load': load,
        'dayOffset': dayOffset,
        'done': done,
      };
}

class ReassignGoalInfo {
  const ReassignGoalInfo({
    required this.id,
    required this.title,
    required this.importance,
    required this.deadlineDays,
  });

  final String id;
  final String title;
  final int importance; // 1–5
  final int deadlineDays; // days from today until deadline

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'importance': importance,
        'deadlineDays': deadlineDays,
      };
}

class RoutineInfo {
  const RoutineInfo({
    required this.title,
    required this.startsAt,
    required this.repeat,
  });

  final String title;
  final String startsAt; // ISO timestamp or HH:mm
  final String repeat;

  Map<String, dynamic> toJson() => {
        'title': title,
        'startsAt': startsAt,
        'repeat': repeat,
      };
}

class TaskReassignmentRequest {
  const TaskReassignmentRequest({
    required this.trigger,
    required this.tasks,
    required this.goals,
    this.mood,
    this.routines = const [],
    this.context = const {},
  });

  /// 'moodChanged' | 'routineAdded' | 'deadlineApproaching' |
  /// 'priorityChanged' | 'manual'
  final String trigger;
  final List<ReassignableTaskInfo> tasks;
  final List<ReassignGoalInfo> goals;
  final String? mood;
  final List<RoutineInfo> routines;
  final Map<String, dynamic> context;

  Map<String, dynamic> toJson() => {
        'trigger': trigger,
        'tasks': tasks.map((t) => t.toJson()).toList(),
        'goals': goals.map((g) => g.toJson()).toList(),
        if (mood != null) 'mood': mood,
        'routines': routines.map((r) => r.toJson()).toList(),
        'context': context,
      };
}

class ReassignedTaskChange {
  const ReassignedTaskChange({
    required this.taskId,
    required this.goalId,
    required this.fromDayOffset,
    required this.toDayOffset,
    required this.reason,
  });

  final String taskId;
  final String goalId;
  final int fromDayOffset;
  final int toDayOffset;
  final String reason;

  factory ReassignedTaskChange.fromJson(Map<String, dynamic> json) =>
      ReassignedTaskChange(
        taskId: json['taskId']?.toString() ?? '',
        goalId: json['goalId']?.toString() ?? '',
        fromDayOffset: (json['fromDayOffset'] as num?)?.toInt() ?? 0,
        toDayOffset: (json['toDayOffset'] as num?)?.toInt() ?? 0,
        reason: json['reason'] as String? ?? '',
      );
}

class TaskReassignmentResponse {
  const TaskReassignmentResponse({
    required this.changed,
    required this.changes,
    required this.explanation,
    this.degraded = false,
  });

  final bool changed;
  final List<ReassignedTaskChange> changes;

  /// Why tasks were (or were not) moved — always user-readable.
  final String explanation;
  final bool degraded;

  factory TaskReassignmentResponse.fromJson(Map<String, dynamic> json) =>
      TaskReassignmentResponse(
        changed: json['changed'] as bool? ?? false,
        changes: (json['changes'] as List<dynamic>? ?? [])
            .whereType<Map<dynamic, dynamic>>()
            .map((c) => ReassignedTaskChange.fromJson(
                c.map((k, v) => MapEntry(k.toString(), v))))
            .toList(),
        explanation: json['explanation'] as String? ?? '',
        degraded: json['degraded'] as bool? ?? false,
      );
}
