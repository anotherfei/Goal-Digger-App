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
  });

  final Map<String, dynamic> plan;
  final List<Map<String, dynamic>> reflections;
  final bool memoryUpdated;

  factory AgentPlannerResponse.fromJson(Map<String, dynamic> json) {
    return AgentPlannerResponse(
      plan: (json['plan'] as Map<dynamic, dynamic>? ?? {})
          .map((key, value) => MapEntry(key.toString(), value)),
      reflections: (json['reflections'] as List<dynamic>? ?? [])
          .whereType<Map<dynamic, dynamic>>()
          .map((entry) => entry.map((key, value) => MapEntry(key.toString(), value)))
          .toList(),
      memoryUpdated: json['memoryUpdated'] as bool? ?? false,
    );
  }
}
