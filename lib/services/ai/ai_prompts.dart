/// ai_prompts.dart
/// ----------------
/// Centralised prompt templates for every Gemma 4 feature in Goal Digger.
/// Keeping prompts here (not scattered across the codebase) makes them easy
/// to tune without touching feature code.
///
/// Folder: lib/services/ai/

class AiPrompts {
  AiPrompts._(); // static-only class

  // ── System instructions ───────────────────────────────────────────────────

  static const String coreSystem = '''
You are Goal Digger's AI companion — an expert productivity coach and motivator.
You are empathetic, concise, and data-driven. You speak in a friendly but
professional tone. Never be preachy. Always give actionable advice.
When returning structured JSON, output ONLY the JSON object — no markdown fences,
no preamble, no explanation outside the JSON.
''';

  // ── Task planning ─────────────────────────────────────────────────────────

  /// Prompt to break a goal into micro-tasks spread over [days] days.
  static String taskPlan({
    required String goalTitle,
    required String category,
    required int importanceLevel, // 1-5
    required int daysUntilDeadline,
    required int maxTasksPerDay,
  }) =>
      '''
Generate a micro-task plan for the following goal.

Goal: "$goalTitle"
Category: $category
Importance: $importanceLevel / 5
Days until deadline: $daysUntilDeadline
Max tasks per day: $maxTasksPerDay

Rules:
- Each task must be completable in 10–30 minutes.
- Spread tasks evenly across the $daysUntilDeadline days (day_offset 0 to ${daysUntilDeadline - 1}).
- Assign a load level: "light" (≤12 min), "focus" (13–20 min), "stretch" (21–30 min).
- Tasks should build on each other logically.
- Generate between 4 and ${daysUntilDeadline * maxTasksPerDay} tasks total.

Return a JSON object exactly like this:
{
  "reasoning": "<one sentence explaining your plan>",
  "tasks": [
    {
      "title": "<task title>",
      "durationMinutes": <number>,
      "load": "<light|focus|stretch>",
      "dayOffset": <number 0..${daysUntilDeadline - 1}>
    }
  ]
}
''';

  // ── Motivation ────────────────────────────────────────────────────────────

  static String motivation({
    required String userName,
    required int streak,
    required double overallProgress, // 0.0 – 1.0
    required int completedTasksToday,
    required String mood,
  }) =>
      '''
Generate a personalised motivational message for $userName.

Context:
- Current mood: $mood
- Day streak: $streak days
- Overall goal progress: ${(overallProgress * 100).toStringAsFixed(0)}%
- Tasks completed today: $completedTasksToday

Return a JSON object exactly like this:
{
  "message": "<personalised 2-3 sentence motivational message>",
  "quote":   "<short inspiring quote, max 20 words>",
  "tip":     "<one concrete, specific action they can do in the next 30 minutes>"
}
''';

  // ── Progress review ───────────────────────────────────────────────────────

  static String progressReview({
    required List<Map<String, dynamic>> goals,
    required int totalTasksCompleted,
    required int totalTasksPending,
    required int streak,
  }) {
    final goalSummaries = goals
        .map((g) =>
            '- "${g['title']}" (${(g['progress'] * 100).toStringAsFixed(0)}% done, deadline: ${g['deadline']})')
        .join('\n');
    return '''
Analyse the user's goal progress and provide a coach-style review.

Goals:
$goalSummaries

Overall stats:
- Tasks completed: $totalTasksCompleted
- Tasks pending:   $totalTasksPending
- Current streak:  $streak days

Return a JSON object exactly like this:
{
  "summary":      "<2-3 sentence overall assessment>",
  "strengths":    ["<strength 1>", "<strength 2>"],
  "improvements": ["<improvement area 1>", "<improvement area 2>"],
  "nextFocus":    "<the single most important thing to do next>"
}
''';
  }

  // ── Chat companion ────────────────────────────────────────────────────────

  static String companionChat({
    required String userName,
    required String mood,
    required int streak,
    required int coins,
    required int petHappiness,
    required String petName,
  }) =>
      '''
You are $petName, the user's virtual productivity companion in the Goal Digger app.
You are playful, warm, and encouraging. You know the user's name is $userName.

Current state:
- Mood: $mood
- Streak: $streak days
- Coins: $coins
- Your happiness: $petHappiness / 100

Reply in character as $petName. Keep your reply under 60 words.
You may add one emoji. Do NOT add JSON — just plain text.
''';

  // ── Community post suggestions ────────────────────────────────────────────

  static String communityPost({
    required String groupName,
    required String goalTitle,
    required int progressPercent,
  }) =>
      '''
Write an encouraging community post for the group "$groupName".
The user just made progress on their goal "$goalTitle" ($progressPercent% complete).
Post should be 2-3 sentences, conversational, and motivate others.
Return plain text only — no JSON, no markdown.
''';
}
