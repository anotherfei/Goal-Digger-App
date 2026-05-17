/// ai_models.dart
/// ---------------
/// Data classes used throughout the AI service layer.
///
/// Folder: lib/services/ai/

enum GemmaRole { user, model }

// ─── Message ──────────────────────────────────────────────────────────────────

class GemmaMessage {
  const GemmaMessage({required this.role, required this.content});

  final GemmaRole role;
  final String content;

  /// Convenience constructors.
  factory GemmaMessage.user(String text) =>
      GemmaMessage(role: GemmaRole.user, content: text);

  factory GemmaMessage.model(String text) =>
      GemmaMessage(role: GemmaRole.model, content: text);
}

// ─── Request ──────────────────────────────────────────────────────────────────

class GemmaRequest {
  const GemmaRequest({
    required this.messages,
    this.systemInstruction,
    this.maxTokens,
    this.temperature,
    this.safetySettings,
  });

  final List<GemmaMessage> messages;
  final String? systemInstruction;
  final int? maxTokens;
  final double? temperature;

  /// Vertex AI safety settings list, e.g.:
  /// [{'category': 'HARM_CATEGORY_DANGEROUS_CONTENT', 'threshold': 'BLOCK_NONE'}]
  final List<Map<String, String>>? safetySettings;

  /// Single-turn convenience constructor.
  factory GemmaRequest.singleTurn(
    String userMessage, {
    String? systemInstruction,
    int? maxTokens,
    double? temperature,
  }) {
    return GemmaRequest(
      messages: [GemmaMessage.user(userMessage)],
      systemInstruction: systemInstruction,
      maxTokens: maxTokens,
      temperature: temperature,
    );
  }
}

// ─── Response ─────────────────────────────────────────────────────────────────

class GemmaResponse {
  const GemmaResponse({
    required this.text,
    required this.finishReason,
    this.inputTokenCount,
    this.outputTokenCount,
  });

  final String text;
  final String finishReason;   // 'STOP' | 'MAX_TOKENS' | 'SAFETY' | …
  final int? inputTokenCount;
  final int? outputTokenCount;

  factory GemmaResponse.fromVertexJson(Map<String, dynamic> json) {
    final candidates =
        (json['candidates'] as List?)?.cast<Map<String, dynamic>>();
    final candidate = candidates?.first ?? {};

    final parts = (candidate['content']?['parts'] as List?)?.cast<Map>();
    final text = (parts ?? [])
        .map((p) => p['text'] as String? ?? '')
        .join();

    final usage =
        json['usageMetadata'] as Map<String, dynamic>?;

    return GemmaResponse(
      text: text,
      finishReason: candidate['finishReason'] as String? ?? 'UNKNOWN',
      inputTokenCount: usage?['promptTokenCount'] as int?,
      outputTokenCount: usage?['candidatesTokenCount'] as int?,
    );
  }

  bool get isComplete => finishReason == 'STOP';
  bool get wasTruncated => finishReason == 'MAX_TOKENS';
  bool get wasBlocked => finishReason == 'SAFETY';
}

// ─── Structured AI responses (Goal Digger–specific) ───────────────────────────

/// Returned by GoalAiAssistant.generateTaskPlan.
class AiTaskPlan {
  const AiTaskPlan({
    required this.tasks,
    required this.reasoning,
  });

  final List<AiSuggestedTask> tasks;
  final String reasoning;
}

class AiSuggestedTask {
  const AiSuggestedTask({
    required this.title,
    required this.durationMinutes,
    required this.load,
    required this.dayOffset,  // 0 = today, 1 = tomorrow, …
  });

  final String title;
  final int durationMinutes;
  final String load;   // 'light' | 'focus' | 'stretch'
  final int dayOffset;
}

/// Returned by GoalAiAssistant.getMotivation.
class AiMotivation {
  const AiMotivation({
    required this.message,
    required this.quote,
    required this.tip,
  });

  final String message;   // personalised motivational paragraph
  final String quote;     // short inspirational quote
  final String tip;       // one concrete actionable tip for today
}

/// Returned by GoalAiAssistant.reviewProgress.
class AiProgressReview {
  const AiProgressReview({
    required this.summary,
    required this.strengths,
    required this.improvements,
    required this.nextFocus,
  });

  final String summary;
  final List<String> strengths;
  final List<String> improvements;
  final String nextFocus;
}
