import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

void main() {
  runApp(const GoalDiggerApp());
}

/* -------------------------------------------------------------------------- */
/* DESIGN TOKENS                                                              */
/* -------------------------------------------------------------------------- */

const Color gdBackground = Color(0xFFF7F8FC);
const Color gdSurface = Color(0xFFFFFFFF);
const Color gdInk = Color(0xFF263247);
const Color gdMuted = Color(0xFF5F6B7A); // readable but softer secondary text
const Color gdPrimary = Color(0xFF315C9D);
const Color gdPrimaryDark = Color(0xFF496DA8);
const Color gdPrimarySoft = Color(0xFFE8F0FE);
const Color gdAccent = Color(0xFFE66A6A);
const Color gdAccentSoft = Color(0xFFFFE4E6);
const Color gdWarning = Color(0xFFC2410C);
const Color gdError = Color(0xFFDC2626);
const Color gdErrorSoft = Color(0xFFFEE2E2);
const Color gdBorder = Color(0xFFE2E8F0); // soft modern border color
const Color gdBorderStrong = Color(0xFFCBD5E1); // stronger border color
const Color gdHint = Color(0xFF64748B); // hint text color
const Color gdGradientCareerFrom = Color(0xFF06B6D4); // career gradient start
const Color gdGradientCareerTo = Color(0xFF2563EB); // career gradient end
const Color gdGradientStudyFrom = Color(0xFFF59E0B); // study gradient start
const Color gdGradientStudyTo = Color(0xFFEC4899); // study gradient end
const Color gdGradientWellnessFrom = Color(0xFFFB7185); // wellness gradient start
const Color gdGradientWellnessTo = Color(0xFFF43F5E); // wellness gradient end
const Color gdGradientFinanceFrom = Color(0xFF10B981); // finance gradient start
const Color gdGradientFinanceTo = Color(0xFF059669); // finance gradient end
const Color gdGradientCreativeFrom = Color(0xFF8B5CF6); // creative gradient start
const Color gdGradientCreativeTo = Color(0xFFD946EF); // creative gradient end
const Color gdPetMintFrom = Color(0xFF22D3EE); // pet aqua gradient start
const Color gdPetMintTo = Color(0xFF2DD4BF); // pet mint gradient end
const Color gdPetAccent = Color(0xFFEAF2FF); // high-contrast soft text on dark blue
const Color gdOnDark = Color(0xFFFFFFFF); // readable foreground on dark surfaces
const Color gdOnDarkMuted = Color(0xFFF4F7FF); // readable secondary text on soft blue surfaces
const Color gdCardLight = Color(0xFFF8FAFC); // crisp light card background
const Color gdStarGold = Color(0xFFE9A63A); // energetic star rating gold color
const double gdTouchTarget = 52;

ThemeData buildGoalDiggerTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: gdPrimary,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: gdBackground,
    colorScheme: scheme.copyWith(
      primary: gdPrimary,
      onPrimary: Colors.white,
      secondary: gdAccent,
      onSecondary: Colors.white,
      tertiary: gdGradientCreativeFrom,
      surface: gdSurface,
      onSurface: gdInk,
      error: gdError,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: gdBackground,
      foregroundColor: gdInk,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: gdInk,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      height: 72,
      labelTextStyle: MaterialStatePropertyAll(
        TextStyle(fontWeight: FontWeight.w800, color: gdInk),
      ),
      iconTheme: MaterialStatePropertyAll(
        IconThemeData(color: gdMuted),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: gdInk,
        fontSize: 34,
        height: 1.05,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.2,
      ),
      headlineMedium: TextStyle(
        color: gdInk,
        fontSize: 26,
        height: 1.1,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.7,
      ),
      titleLarge: TextStyle(
        color: gdInk,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
      titleMedium: TextStyle(
        color: gdInk,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
      bodyLarge: TextStyle(color: gdInk, fontSize: 16, height: 1.45),
      bodyMedium: TextStyle(color: gdInk, fontSize: 14, height: 1.4),
      bodySmall: TextStyle(color: gdMuted, fontSize: 12, height: 1.35),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: gdPrimarySoft,
      selectedColor: gdPrimary,
      labelStyle: const TextStyle(color: gdInk, fontWeight: FontWeight.w800),
      secondaryLabelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide.none,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: gdSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: gdBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: gdPrimary, width: 2),
      ),
      labelStyle: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
      hintStyle: const TextStyle(color: gdHint),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, gdTouchTarget),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, gdTouchTarget),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        side: const BorderSide(color: gdBorderStrong),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    iconTheme: const IconThemeData(color: gdPrimary),
  );
}

/* -------------------------------------------------------------------------- */
/* MODELS                                                                     */
/* -------------------------------------------------------------------------- */

enum TaskLoad { light, focus, stretch }

extension TaskLoadX on TaskLoad {
  String get label {
    switch (this) {
      case TaskLoad.light:
        return 'Light';
      case TaskLoad.focus:
        return 'Focus';
      case TaskLoad.stretch:
        return 'Stretch';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskLoad.light:
        return Icons.spa_rounded;
      case TaskLoad.focus:
        return Icons.track_changes_rounded;
      case TaskLoad.stretch:
        return Icons.local_fire_department_rounded;
    }
  }
}

class MicroTask {
  MicroTask({
    required this.id,
    required this.goalId,
    required this.title,
    required this.durationMinutes,
    required this.load,
    required this.scheduledDate,
    this.done = false,
    this.points = 15,
  });

  final int id;
  final int goalId;
  final String title;
  final int durationMinutes;
  final TaskLoad load;
  DateTime scheduledDate;
  bool done;
  final int points;
}

class GoalProject {
  GoalProject({
    required this.id,
    required this.title,
    required this.importance,
    required this.category,
    required this.deadline,
    required this.from,
    required this.to,
    required this.tasks,
  });

  final int id;
  String title;
  int importance;
  String category;
  DateTime deadline;
  Color from;
  Color to;
  List<MicroTask> tasks;

  double get progress {
    if (tasks.isEmpty) return 0;
    return tasks.where((task) => task.done).length / tasks.length;
  }
}

class CommunityGroup {
  CommunityGroup({
    required this.name,
    required this.members,
    required this.tag,
    required this.description,
    this.similarity = 82,
    this.joined = false,
  });

  final String name;
  final int members;
  final String tag;
  final String description;
  final int similarity;
  bool joined;
}

enum RoutineRepeat { yearly, monthly, weekly, daily, custom }

extension RoutineRepeatX on RoutineRepeat {
  String get label {
    switch (this) {
      case RoutineRepeat.yearly:
        return 'Yearly';
      case RoutineRepeat.monthly:
        return 'Monthly';
      case RoutineRepeat.weekly:
        return 'Weekly';
      case RoutineRepeat.daily:
        return 'Daily';
      case RoutineRepeat.custom:
        return 'Custom';
    }
  }
}

class RoutineItem {
  RoutineItem({
    required this.title,
    required this.startsAt,
    required this.repeat,
  });

  final String title;
  final DateTime startsAt;
  final RoutineRepeat repeat;
}

class PetSkin {
  const PetSkin({
    required this.name,
    required this.from,
    required this.to,
    required this.accent,
  });

  final String name;
  final Color from;
  final Color to;
  final Color accent;
}

/* -------------------------------------------------------------------------- */
/* HELPERS                                                                    */
/* -------------------------------------------------------------------------- */

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime addDays(DateTime date, int days) {
  return dateOnly(date).add(Duration(days: days));
}

int daysBetween(DateTime from, DateTime to) {
  return dateOnly(to).difference(dateOnly(from)).inDays;
}

String two(int n) => n.toString().padLeft(2, '0');

const List<String> monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String shortDate(DateTime date) => '${monthNames[date.month - 1]} ${date.day}';

String longDate(DateTime date) {
  return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
}

String dateKey(DateTime date) {
  final d = dateOnly(date);
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}

List<GoalProject> seedGoals(DateTime today) {
  return [
    GoalProject(
      id: 1,
      title: 'Launch portfolio',
      importance: 5,
      category: 'Career',
      deadline: addDays(today, 7),
      from: gdGradientCareerFrom,
      to: gdGradientCareerTo,
      tasks: [
        MicroTask(
          id: 101,
          goalId: 1,
          title: 'Draft project outline',
          durationMinutes: 12,
          load: TaskLoad.focus,
          scheduledDate: today,
          done: true,
        ),
        MicroTask(
          id: 102,
          goalId: 1,
          title: 'Sketch homepage layout',
          durationMinutes: 15,
          load: TaskLoad.focus,
          scheduledDate: today,
        ),
        MicroTask(
          id: 103,
          goalId: 1,
          title: 'Write project descriptions',
          durationMinutes: 20,
          load: TaskLoad.stretch,
          scheduledDate: addDays(today, 1),
        ),
        MicroTask(
          id: 104,
          goalId: 1,
          title: 'Deploy first draft',
          durationMinutes: 20,
          load: TaskLoad.focus,
          scheduledDate: addDays(today, 3),
        ),
      ],
    ),
    GoalProject(
      id: 2,
      title: 'Exam prep',
      importance: 4,
      category: 'Study',
      deadline: addDays(today, 12),
      from: gdGradientStudyFrom,
      to: gdGradientStudyTo,
      tasks: [
        MicroTask(
          id: 201,
          goalId: 2,
          title: 'Review chapter notes',
          durationMinutes: 10,
          load: TaskLoad.light,
          scheduledDate: today,
        ),
        MicroTask(
          id: 202,
          goalId: 2,
          title: 'Solve 5 practice problems',
          durationMinutes: 25,
          load: TaskLoad.stretch,
          scheduledDate: addDays(today, 1),
        ),
        MicroTask(
          id: 203,
          goalId: 2,
          title: 'Make flashcards',
          durationMinutes: 15,
          load: TaskLoad.focus,
          scheduledDate: addDays(today, 2),
        ),
      ],
    ),
  ];
}

const List<String> categories = [
  'Study',
  'Career',
  'Wellness',
  'Finance',
  'Creative',
  'Other',
];

const PetSkin defaultPet = PetSkin(
  name: 'Mint',
  from: gdPetMintFrom,
  to: gdPetMintTo,
  accent: gdPetAccent,
);

/* -------------------------------------------------------------------------- */
/* ROOT APP                                                                   */
/* -------------------------------------------------------------------------- */

class GoalDiggerApp extends StatelessWidget {
  const GoalDiggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goal Digger',
      debugShowCheckedModeBanner: false,
      theme: buildGoalDiggerTheme(),
      home: const GoalDiggerRoot(),
    );
  }
}

class GoalDiggerRoot extends StatefulWidget {
  const GoalDiggerRoot({super.key});

  @override
  State<GoalDiggerRoot> createState() => _GoalDiggerRootState();
}

class _GoalDiggerRootState extends State<GoalDiggerRoot> {
  final DateTime today = dateOnly(DateTime.now());
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _communityController = TextEditingController();

  bool _onboarded = false;
  String _signedInWith = 'Guest';
  int _selectedIndex = 2;
  int _nextGoalId = 3;
  int _nextTaskId = 300;
  late List<GoalProject> _goals;
  late List<CommunityGroup> _communities;

  DateTime _newGoalDeadline = addDays(DateTime.now(), 14);
  int _newGoalPriority = 3;
  String _newGoalCategory = 'Study';

  bool _isProcessing = false;
  double _processingProgress = 0;
  Timer? _processingTimer;

  String _selectedMood = 'Okay';
  int _petHappiness = 62;
  int _coins = 140;
  int _streak = 7;
  final List<String> _friends = ['Maya Chen', 'Leo Tan', 'Ari Putra'];
  final List<String> _friendSuggestions = ['Nina Rahman', 'Jay Lim', 'Sofia Hart'];
  PetSkin _activePetSkin = defaultPet;
  String _activeAccessory = 'Cap';

  FocusSessionConfig? _activeFocusConfig;
  int _focusRemainingSeconds = 0;
  bool _focusPaused = false;
  Timer? _focusTimer;

  bool get _hasActiveFocus => _activeFocusConfig != null && _focusRemainingSeconds > 0;
  bool get _focusComplete => _activeFocusConfig != null && _focusRemainingSeconds <= 0;

  @override
  void initState() {
    super.initState();
    _goals = seedGoals(today);
    _communities = [
      CommunityGroup(
        name: 'Study Sprint Club',
        members: 89,
        tag: 'Exam prep',
        similarity: 94,
        description: 'Short daily sprints for students who want accountability.',
      ),
      CommunityGroup(
        name: 'Portfolio Builders',
        members: 142,
        tag: 'Career',
        similarity: 88,
        description: 'Share portfolio progress and get feedback from builders.',
      ),
      CommunityGroup(
        name: 'Calm Wellness Crew',
        members: 76,
        tag: 'Wellness',
        similarity: 81,
        description: 'Build low-pressure routines around sleep, movement, and reflection.',
      ),
    ];
  }

  @override
  void dispose() {
    _processingTimer?.cancel();
    _focusTimer?.cancel();
    _goalController.dispose();
    _communityController.dispose();
    super.dispose();
  }

  List<MicroTask> get _allTasks => _goals.expand((goal) => goal.tasks).toList();

  List<MicroTask> get _todayTasks => _allTasks
      .where((task) => dateOnly(task.scheduledDate) == today)
      .toList();

  GoalProject _goalForTask(MicroTask task) {
    return _goals.firstWhere((goal) => goal.id == task.goalId);
  }

  int get _todayCompleted => _todayTasks.where((task) => task.done).length;

  double get _todayProgress => _todayTasks.isEmpty ? 0 : _todayCompleted / _todayTasks.length;

  int get _remainingMinutes => _todayTasks
      .where((task) => !task.done)
      .fold(0, (sum, task) => sum + task.durationMinutes);

  String _formatFocusTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }

  void _completeOnboarding(String provider) {
    setState(() {
      _signedInWith = provider;
      _onboarded = true;
    });
    _showMessage('Welcome! You signed in with $provider.');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _showHelpfulError({
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.error_outline_rounded, color: gdError),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                onAction();
              },
              child: Text(actionLabel),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _newGoalDeadline,
      firstDate: today,
      lastDate: DateTime(today.year + 5),
    );
    if (picked != null) setState(() => _newGoalDeadline = picked);
  }

  void _createGoalWithProgress() {
    final title = _goalController.text.trim();
    if (title.isEmpty) {
      _showHelpfulError(
        title: 'Goal name is missing',
        message: 'Please write one clear goal first. Example: “Prepare for midterm” or “Build my portfolio”.',
        actionLabel: 'Write goal',
        onAction: () {},
      );
      return;
    }
    _openGoalBreakdownDialog(title);
  }

  Future<void> _openGoalBreakdownDialog(String title) async {
    final chatController = TextEditingController();
    var draftTitles = _generateTaskTitles(title).toList();
    final messages = <Map<String, dynamic>>[
      {
        'role': 'assistant',
        'text':
            "Great! Let\'s break down \"$title\" into actionable steps. I\'ve drafted ${draftTitles.length} micro-tasks below. If you want, ask me to make them easier, more detailed, or change the order.",
        'tasks': List<String>.from(draftTitles),
      },
    ];

    final result = await showDialog<List<String>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocalState) {
            Future<void> sendMessage() async {
              final request = chatController.text.trim();
              if (request.isEmpty) return;
              setLocalState(() {
                messages.add({'role': 'user', 'text': request});
                draftTitles = _refineTaskTitlesFromPrompt(draftTitles, request, title);
                messages.add({
                  'role': 'assistant',
                  'text':
                      "Absolutely — I refined the plan. Here\'s an updated version you can review before scheduling.",
                  'tasks': List<String>.from(draftTitles),
                });
                chatController.clear();
              });
            }

            Widget buildMessageBubble(Map<String, dynamic> message) {
              final isUser = message['role'] == 'user';
              final bubbleColor = isUser ? gdPrimary : const Color(0xFFF3F5F8);
              final textColor = isUser ? Colors.white : gdInk;
              final tasks = (message['tasks'] as List?)?.cast<String>();

              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 680),
                  margin: EdgeInsets.only(left: isUser ? 44 : 0, right: isUser ? 0 : 44),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(26),
                      topRight: const Radius.circular(26),
                      bottomLeft: Radius.circular(isUser ? 26 : 8),
                      bottomRight: Radius.circular(isUser ? 8 : 26),
                    ),
                    border: !isUser ? Border.all(color: gdBorder) : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser)
                        Row(
                          children: const [
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: gdPrimarySoft,
                              child: Icon(Icons.auto_awesome_rounded, size: 16, color: gdPrimary),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Assistant',
                              style: TextStyle(color: gdMuted, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      if (!isUser) const SizedBox(height: 10),
                      Text(
                        message['text'] as String,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          height: 1.55,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (tasks != null && tasks.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        for (var i = 0; i < tasks.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isUser ? Colors.white.withOpacity(0.14) : Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: isUser ? Colors.white24 : gdBorder,
                                    ),
                                  ),
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      color: isUser ? Colors.white : gdPrimary,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text(
                                      tasks[i],
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 15,
                                        height: 1.45,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              );
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 880,
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.86,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: gdSurface,
                    borderRadius: BorderRadius.circular(34),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 28,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'GOAL BREAKDOWN',
                                    style: TextStyle(
                                      color: Color(0xFF7C8AA5),
                                      fontSize: 13,
                                      letterSpacing: 3,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      color: gdInk,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F3F6),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: IconButton(
                                tooltip: 'Close',
                                onPressed: () => Navigator.pop(dialogContext),
                                icon: const Icon(Icons.close_rounded, color: gdMuted),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBFCFE),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: gdBorder),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: ListView.separated(
                              itemCount: messages.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) => buildMessageBubble(messages[index]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: chatController,
                                minLines: 1,
                                maxLines: 4,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => sendMessage(),
                                decoration: InputDecoration(
                                  hintText: 'Adjust the plan...',
                                  filled: true,
                                  fillColor: const Color(0xFFF7F5EF),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: const BorderSide(color: Color(0xFFE6DFD2)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: const BorderSide(color: gdPrimary, width: 1.6),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              height: 56,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: gdPrimary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                ),
                                onPressed: sendMessage,
                                child: const Text('Send'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(64),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            onPressed: () => Navigator.pop(dialogContext, List<String>.from(draftTitles)),
                            child: const Text('Looks good, finalize!'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    // Dispose after the dialog has fully unmounted.
    WidgetsBinding.instance.addPostFrameCallback((_) => chatController.dispose());
    if (result != null) {
      // Let Flutter finish removing the dialog route before rebuilding this page.
      // This prevents the framework `_dependents.isEmpty` assertion on finalize.
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      _finishCreateGoal(title, approvedTaskTitles: result);
    }
  }

  void _finishCreateGoal(String title, {List<String>? approvedTaskTitles}) {
    final goalId = _nextGoalId++;
    final colors = _categoryColors(_newGoalCategory);
    final steps = approvedTaskTitles == null
        ? _generateMicroTasks(title, goalId)
        : _generateMicroTasksFromTitles(approvedTaskTitles, goalId);
    setState(() {
      _goals.insert(
        0,
        GoalProject(
          id: goalId,
          title: title,
          importance: _newGoalPriority,
          category: _newGoalCategory,
          deadline: _newGoalDeadline,
          from: colors[0],
          to: colors[1],
          tasks: steps,
        ),
      );
      _isProcessing = false;
      _processingProgress = 0;
      _goalController.clear();
      _newGoalPriority = 3;
      _newGoalCategory = 'Study';
      _newGoalDeadline = addDays(today, 14);
    });
    _showMessage('Goal created. Your subtasks are scheduled.');
  }

  List<Color> _categoryColors(String category) {
    switch (category) {
      case 'Career': return [gdGradientCareerFrom, gdGradientCareerTo];
      case 'Wellness': return [gdGradientWellnessFrom, gdGradientWellnessTo];
      case 'Finance': return [gdGradientFinanceFrom, gdGradientFinanceTo];
      case 'Creative': return [gdGradientCreativeFrom, gdGradientCreativeTo];
      default: return [gdGradientStudyFrom, gdGradientStudyTo];
    }
  }

  List<String> _generateTaskTitles(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('exam') || lower.contains('midterm') || lower.contains('study')) {
      return ['List topics to review', 'Study the hardest topic for 20 minutes', 'Solve practice questions', 'Review mistakes and make flashcards'];
    } else if (lower.contains('portfolio') || lower.contains('project')) {
      return ['Define the project outcome', 'Create the first rough draft', 'Improve one visible section', 'Share for feedback'];
    }
    return ['Write the desired outcome', 'Break the goal into 3 milestones', 'Do the smallest first action', 'Review progress and adjust tomorrow'];
  }

  List<String> _refineTaskTitlesFromPrompt(List<String> currentTitles, String request, String goalTitle) {
    final lower = request.toLowerCase();
    List<String> updated = List<String>.from(currentTitles);

    final wantsSimpler = lower.contains('easy') ||
        lower.contains('easier') ||
        lower.contains('simple') ||
        lower.contains('smaller') ||
        lower.contains('busy');
    final wantsMoreDetail = lower.contains('detail') ||
        lower.contains('specific') ||
        lower.contains('clearer') ||
        lower.contains('more info');
    final wantsReorder = lower.contains('order') ||
        lower.contains('reorder') ||
        lower.contains('sequence');

    if (goalTitle.toLowerCase().contains('youtube')) {
      if (wantsSimpler) {
        return [
          'Pick one video idea for your first upload',
          'Write a short outline or talking points',
          'Record a simple first draft',
          'Upload it and note what to improve next',
        ];
      }
      if (wantsMoreDetail) {
        return [
          'Choose your niche and the topic for your first video',
          'Write your first script or recording outline',
          'Film the video and edit the best parts',
          'Publish it and review the response for your next upload',
        ];
      }
    }

    if (wantsSimpler) {
      updated = [
        'Define one small win for $goalTitle',
        'Work on the smallest part for 10 minutes',
        'Finish one visible improvement',
        'Review progress and set the next tiny step',
      ];
    } else if (wantsMoreDetail) {
      updated = [
        'Clarify the outcome and success metric',
        'Prepare the tools, files, or materials you need',
        'Complete the main work session',
        'Review results and plan the next follow-up action',
      ];
    } else if (wantsReorder && updated.length > 1) {
      final first = updated.removeAt(0);
      updated.insert(1, first);
    } else if (lower.contains('add')) {
      updated = List<String>.from(updated.take(3))
        ..add('Review progress and lock in the next step');
    } else {
      updated = [
        'Clarify the first concrete milestone',
        'Do the smallest useful action',
        'Improve one meaningful part',
        'Review the result and plan the next session',
      ];
    }

    return updated;
  }

  List<MicroTask> _generateMicroTasks(String title, int goalId) {
    return _generateMicroTasksFromTitles(_generateTaskTitles(title), goalId);
  }

  List<MicroTask> _generateMicroTasksFromTitles(List<String> taskTitles, int goalId) {
    return List.generate(taskTitles.length, (index) {
      return MicroTask(
        id: _nextTaskId++,
        goalId: goalId,
        title: taskTitles[index],
        durationMinutes: index == 0 ? 8 : 15 + index * 5,
        load: index == 0 ? TaskLoad.light : index == taskTitles.length - 1 ? TaskLoad.stretch : TaskLoad.focus,
        scheduledDate: addDays(today, index),
        points: 10 + index * 5,
      );
    });
  }

  void _toggleTask(MicroTask task) {
    setState(() {
      task.done = !task.done;
      if (task.done) {
        _coins += task.points;
        _petHappiness = min(100, _petHappiness + 8);
      } else {
        _coins = max(0, _coins - task.points);
        _petHappiness = max(0, _petHappiness - 8);
      }
    });
  }

  void _deleteGoal(GoalProject goal) {
    setState(() => _goals.removeWhere((item) => item.id == goal.id));
    _showMessage('Removed ${goal.title}.');
  }

  void _addCommunity() {
    final title = _communityController.text.trim();
    if (title.isEmpty) {
      _showHelpfulError(
        title: 'Community name is missing',
        message: 'Write a short community name first, then you can invite people later.',
        actionLabel: 'Try again',
        onAction: () {},
      );
      return;
    }
    setState(() {
      _communities.insert(0, CommunityGroup(
        name: title,
        members: 1,
        tag: 'Created by you',
        similarity: 100,
        joined: true,
        description: 'A new accountability group for people working on similar goals.',
      ));
      _communityController.clear();
    });
    _showMessage('Community created.');
  }

  void _joinCommunity(CommunityGroup group) {
    setState(() => group.joined = true);
    _showMessage('Joined ${group.name}.');
  }

  void _deleteCommunity(CommunityGroup group) {
    setState(() => _communities.remove(group));
    _showMessage('Removed ${group.name}.');
  }

  void _addFriend(String name) {
    if (_friends.contains(name)) return;
    setState(() => _friends.add(name));
    _showMessage('$name added as a friend.');
  }

  void _deleteFriend(String name) {
    setState(() => _friends.remove(name));
    _showMessage('Removed $name from friends.');
  }

  void _openPetChest() {
    if (_coins < 50) {
      _showHelpfulError(
        title: 'Not enough coins',
        message: 'A mystery chest costs 50 coins. Complete a few tasks first, then try again.',
        actionLabel: 'Got it',
        onAction: () {},
      );
      return;
    }
    final skins = [
      defaultPet,
      const PetSkin(name: 'Peach', from: Color(0xFFFFB4A2), to: Color(0xFFFFD6A5), accent: Color(0xFFFFF1E6)),
      const PetSkin(name: 'Lunar', from: Color(0xFF64748B), to: Color(0xFF1E293B), accent: Color(0xFFE2E8F0)),
    ];
    final accessories = ['Cap', 'Star badge', 'Tiny scarf', 'Focus glasses'];
    final skin = skins[Random().nextInt(skins.length)];
    final accessory = accessories[Random().nextInt(accessories.length)];
    setState(() {
      _coins -= 50;
      _activePetSkin = skin;
      _activeAccessory = accessory;
      _petHappiness = min(100, _petHappiness + 6);
    });
    _showMessage('Chest opened: ${skin.name} skin + $accessory unlocked!');
  }

  void _feedPet() {
    if (_coins < 10) {
      _showHelpfulError(
        title: 'Not enough coins',
        message: 'Complete one task first. Each completed task gives coins you can use for your companion.',
        actionLabel: 'Go to home',
        onAction: () => setState(() => _selectedIndex = 2),
      );
      return;
    }
    setState(() {
      _coins -= 10;
      _petHappiness = min(100, _petHappiness + 12);
    });
  }

  void _interactWithPet() {
    final reactions = [
      '${_activePetSkin.name} is cheering for you!',
      '${_activePetSkin.name} did a happy little bounce.',
      '${_activePetSkin.name} says: one tiny step counts!',
      '${_activePetSkin.name} feels closer to you.',
    ];
    setState(() => _petHappiness = min(100, _petHappiness + 2));
    _showMessage(reactions[Random().nextInt(reactions.length)]);
  }

  Future<void> _openFocusMode() async {
    if (_hasActiveFocus || _focusComplete) {
      _openActiveFocusDialog();
      return;
    }
    final unfinishedToday = _todayTasks.where((task) => !task.done).toList();
    final config = await showModalBottomSheet<FocusSessionConfig>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: gdSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => FocusSetupSheet(todayTasks: unfinishedToday),
    );
    if (!mounted || config == null) return;
    _startFocusSession(config);
  }

  void _startFocusSession(FocusSessionConfig config) {
    _focusTimer?.cancel();
    setState(() {
      _activeFocusConfig = config;
      _focusRemainingSeconds = config.durationMinutes * 60;
      _focusPaused = false;
    });
    _focusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_focusPaused) return;
      setState(() => _focusRemainingSeconds = max(0, _focusRemainingSeconds - 1));
      if (_focusRemainingSeconds == 0) timer.cancel();
    });
    _openActiveFocusDialog();
  }

  void _openActiveFocusDialog() {
    final config = _activeFocusConfig;
    if (config == null) return;
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.18),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FocusCountdownDialog(
          config: config,
          remainingSecondsProvider: () => _focusRemainingSeconds,
          pausedProvider: () => _focusPaused,
          onPauseToggle: _toggleFocusPause,
          onMinimize: () => Navigator.of(context).pop(),
          onStop: _stopFocusSession,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(opacity: curved, child: ScaleTransition(scale: Tween<double>(begin: 0.98, end: 1).animate(curved), child: child));
      },
    );
  }

  void _toggleFocusPause() => setState(() => _focusPaused = !_focusPaused);

  void _stopFocusSession() {
    _focusTimer?.cancel();
    setState(() {
      _activeFocusConfig = null;
      _focusRemainingSeconds = 0;
      _focusPaused = false;
    });
    Navigator.of(context, rootNavigator: true).maybePop();
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          backgroundColor: gdBackground,
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Profile'),
            leading: IconButton(
              tooltip: 'Close profile',
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              children: [
                AppCard(
                  color: gdSurface,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 36,
                              backgroundColor: gdPrimarySoft,
                              child: Icon(Icons.account_circle_rounded, size: 42, color: gdPrimary),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Goal Digger User', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: gdInk)),
                                  const SizedBox(height: 4),
                                  Text('Signed in with $_signedInWith', style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(children: [
                          Expanded(child: StatMiniCard(icon: Icons.paid_rounded, label: 'Coins', value: '$_coins')),
                          const SizedBox(width: 10),
                          Expanded(child: StatMiniCard(icon: Icons.local_fire_department_rounded, label: 'Streak', value: '$_streak days')),
                        ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: gdInk)),
                        SizedBox(height: 10),
                        ListTile(leading: Icon(Icons.mail_rounded), title: Text('Email / login method'), subtitle: Text('Manage account connection from settings.')),
                        ListTile(leading: Icon(Icons.shield_rounded), title: Text('Privacy'), subtitle: Text('Control what friends and communities can see.')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  color: gdPrimarySoft,
                  child: const Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'Friends are now managed from the Community page under the Friends tab.',
                      style: TextStyle(color: gdInk, fontWeight: FontWeight.w800, height: 1.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  Future<void> _editGoalDeadline(GoalProject goal) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: goal.deadline.isBefore(today) ? today : goal.deadline,
      firstDate: today,
      lastDate: DateTime(today.year + 5),
    );
    if (picked == null) return;
    setState(() => goal.deadline = picked);
    _showMessage('Deadline updated to ${shortDate(picked)}.');
  }

  Future<void> _editGoalPriority(GoalProject goal) async {
    var draftPriority = goal.importance;
    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          backgroundColor: gdSurface,
          title: const Text('Edit priority'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(goal.title, style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              PrioritySelector(
                value: draftPriority,
                onChanged: (value) => setLocalState(() => draftPriority = value),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, draftPriority), child: const Text('Save priority')),
          ],
        ),
      ),
    );
    if (result == null) return;
    setState(() => goal.importance = result);
    _showMessage('Priority updated.');
  }

  @override
  Widget build(BuildContext context) {
    if (!_onboarded) {
      return OnboardingScreen(
        onGoogle: () => _completeOnboarding('Google'),
        onLinkedIn: () => _completeOnboarding('LinkedIn'),
        onGuest: () => _completeOnboarding('Guest'),
      );
    }

    final pages = [
      _PlannerPage(
        goals: _goals,
        today: today,
        goalController: _goalController,
        deadline: _newGoalDeadline,
        priority: _newGoalPriority,
        category: _newGoalCategory,
        isProcessing: _isProcessing,
        processingProgress: _processingProgress,
        onDeadlinePick: _pickDeadline,
        onPriorityChanged: (value) => setState(() => _newGoalPriority = value),
        onCategoryChanged: (value) => setState(() => _newGoalCategory = value),
        onCreateGoal: _createGoalWithProgress,
        onDeleteGoal: _deleteGoal,
        onEditGoalDeadline: _editGoalDeadline,
        onEditGoalPriority: _editGoalPriority,
        onCreateFirstGoal: () => setState(() => _selectedIndex = 0),
      ),
      _CalendarPage(
        tasks: _allTasks,
        goalForTask: _goalForTask,
        today: today,
        onCreateGoal: () => setState(() => _selectedIndex = 0),
      ),
      _TasksPage(
        mood: _selectedMood,
        todayTasks: _todayTasks,
        todayProgress: _todayProgress,
        todayCompleted: _todayCompleted,
        todayTotal: _todayTasks.length,
        remainingMinutes: _remainingMinutes,
        goalForTask: _goalForTask,
        onMoodChanged: (value) => setState(() => _selectedMood = value),
        onToggleTask: _toggleTask,
        onCreateGoal: () => setState(() => _selectedIndex = 0),
      ),
      _CommunityPage(
        controller: _communityController,
        communities: _communities,
        friends: _friends,
        friendSuggestions: _friendSuggestions,
        streak: _streak,
        onAddCommunity: _addCommunity,
        onJoinCommunity: _joinCommunity,
        onDeleteCommunity: _deleteCommunity,
        onAddFriend: _addFriend,
        onDeleteFriend: _deleteFriend,
      ),
      _CompanionPage(
        coins: _coins,
        happiness: _petHappiness,
        pet: _activePetSkin,
        accessory: _activeAccessory,
        onFeed: _feedPet,
        onOpenChest: _openPetChest,
        onPetInteract: _interactWithPet,
      ),
    ];

    return ResponsiveGoalShell(
      selectedIndex: _selectedIndex,
      signedInWith: _signedInWith,
      pages: pages,
      onSelect: (index) => setState(() => _selectedIndex = index),
      onFocusMode: _openFocusMode,
      onProfile: _openProfile,
      onSettings: _openSettings,
      hasActiveFocus: _hasActiveFocus || _focusComplete,
      focusLabel: _activeFocusConfig == null ? null : (_focusComplete ? 'Done' : _formatFocusTime(_focusRemainingSeconds)),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* ONBOARDING / LANDING                                                       */
/* -------------------------------------------------------------------------- */

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({
    super.key,
    required this.onGoogle,
    required this.onLinkedIn,
    required this.onGuest,
  });

  final VoidCallback onGoogle;
  final VoidCallback onLinkedIn;
  final VoidCallback onGuest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const AmbientBackground(),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;
                final tutorial = const TutorialIntroPanel();
                final login = SimpleOnboardingCard(
                  onGoogle: onGoogle,
                  onLinkedIn: onLinkedIn,
                  onGuest: onGuest,
                );
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [Expanded(flex: 6, child: tutorial), const SizedBox(width: 24), Expanded(flex: 4, child: login)],
                            )
                          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [tutorial, const SizedBox(height: 18), login]),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TutorialIntroPanel extends StatelessWidget {
  const TutorialIntroPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      const _StepData(icon: Icons.login_rounded, title: '1. Log in or sign up', subtitle: 'Create an account first so goals, routines, coins, streaks, and friends can stay synced.'),
      const _StepData(icon: Icons.flag_rounded, title: '2. Add one goal', subtitle: 'Choose a category, priority, and deadline. You can chat with AI before subtasks are scheduled.'),
      const _StepData(icon: Icons.checklist_rounded, title: '3. Work from Home', subtitle: 'Finish today’s tasks, start Focus Mode, and earn coins for your companion.'),
      const _StepData(icon: Icons.groups_rounded, title: '4. Stay accountable', subtitle: 'Join recommended communities and manage friends from your profile.'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: gdPrimarySoft, borderRadius: BorderRadius.circular(999)),
                  child: const Text('Quick tutorial', style: TextStyle(color: gdPrimaryDark, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 18),
                Text('Welcome to Goal Digger', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 12),
                const Text('Here is how the app works before you enter: plan goals, review AI subtasks, schedule routines, focus without distractions, and grow with friends.', style: TextStyle(color: gdMuted, fontSize: 16, height: 1.5, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        ...steps.map((step) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: ListTile(
                  minVerticalPadding: 18,
                  leading: CircleAvatar(backgroundColor: gdPrimarySoft, child: Icon(step.icon, color: gdPrimary)),
                  title: Text(step.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(step.subtitle, style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w600)),
                ),
              ),
            )),
      ],
    );
  }
}

class SimpleOnboardingCard extends StatelessWidget {
  const SimpleOnboardingCard({
    super.key,
    required this.onGoogle,
    required this.onLinkedIn,
    required this.onGuest,
  });

  final VoidCallback onGoogle;
  final VoidCallback onLinkedIn;
  final VoidCallback onGuest;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Login or sign up', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text('Start with an account so your profile, friends, streaks, and routines are saved.', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            FilledButton.icon(onPressed: onGoogle, icon: const Icon(Icons.g_mobiledata_rounded, size: 30), label: const Text('Sign up with Google')),
            const SizedBox(height: 10),
            OutlinedButton.icon(onPressed: onLinkedIn, icon: const Icon(Icons.work_rounded), label: const Text('Continue with LinkedIn')),
            const SizedBox(height: 10),
            OutlinedButton.icon(onPressed: onGuest, icon: const Icon(Icons.person_outline_rounded), label: const Text('Preview as guest')),
            const Divider(height: 32),
            const HelpfulErrorBox(title: 'Tutorial first', message: 'The app now explains the main flow before users enter, then gives clear login/sign-up choices.', actionLabel: 'Got it', showAction: false),
          ],
        ),
      ),
    );
  }
}

class _StepData {
  const _StepData({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
}

/* -------------------------------------------------------------------------- */
/* FOCUS MODE                                                                 */
/* -------------------------------------------------------------------------- */

class FocusSessionConfig {
  const FocusSessionConfig({
    required this.task,
    required this.durationMinutes,
    required this.blockedApps,
    required this.blockUnrelatedApps,
  });

  final MicroTask? task;
  final int durationMinutes;
  final Set<String> blockedApps;
  final bool blockUnrelatedApps;

  String get title => task?.title ?? 'Custom focus session';

  String get blockingSummary {
    if (blockedApps.isEmpty) return 'No apps selected to block';
    if (blockUnrelatedApps && task != null) {
      return 'Blocking unrelated apps for this goal';
    }
    return 'Blocking selected apps';
  }
}

class FocusSetupSheet extends StatefulWidget {
  const FocusSetupSheet({super.key, required this.todayTasks});

  final List<MicroTask> todayTasks;

  @override
  State<FocusSetupSheet> createState() => _FocusSetupSheetState();
}

class _FocusSetupSheetState extends State<FocusSetupSheet> {
  static const List<int> _durationPresets = [15, 25, 45, 60];
  static const List<String> _appOptions = [
    'Instagram',
    'TikTok',
    'YouTube',
    'Games',
    'Shopping',
    'Messages',
    'Browser',
    'Music',
  ];

  final TextEditingController _customDurationController = TextEditingController(text: '30');

  MicroTask? _selectedTask;
  int _selectedDuration = 25;
  bool _useCustomDuration = false;
  bool _blockUnrelatedApps = true;
  late Set<String> _blockedApps;

  @override
  void initState() {
    super.initState();
    _selectedTask = widget.todayTasks.isEmpty ? null : widget.todayTasks.first;
    _selectedDuration = _selectedTask?.durationMinutes ?? 25;
    _blockedApps = _selectedTask == null
        ? {'Instagram', 'TikTok', 'YouTube'}
        : {'Instagram', 'TikTok', 'YouTube', 'Games'};
  }

  @override
  void dispose() {
    _customDurationController.dispose();
    super.dispose();
  }

  int? get _durationMinutes {
    if (!_useCustomDuration) return _selectedDuration;
    final value = int.tryParse(_customDurationController.text.trim());
    if (value == null || value <= 0) return null;
    return value.clamp(1, 240).toInt();
  }

  void _startFocus() {
    final duration = _durationMinutes;
    if (duration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid focus duration in minutes.')),
      );
      return;
    }

    Navigator.of(context).pop(
      FocusSessionConfig(
        task: _selectedTask,
        durationMinutes: duration,
        blockedApps: Set<String>.from(_blockedApps),
        blockUnrelatedApps: _selectedTask != null && _blockUnrelatedApps,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: ChipTheme(
        data: Theme.of(context).chipTheme.copyWith(
          backgroundColor: gdSurface,
          selectedColor: gdPrimary,
          labelStyle: const TextStyle(color: gdInk, fontWeight: FontWeight.w800),
          secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          side: const BorderSide(color: gdBorderStrong),
        ),
        child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: gdPrimarySoft,
                  child: Icon(Icons.track_changes_rounded, color: gdPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Focus mode', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      const Text(
                        'Choose a task, set a timer, and block distracting apps.',
                        style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('1. Choose today’s goal', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            AppCard(
              color: gdCardLight,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          selected: _selectedTask == null,
                          avatar: const Icon(Icons.edit_calendar_rounded, size: 18),
                          label: const Text('Custom focus'),
                          onSelected: (_) {
                            setState(() {
                              _selectedTask = null;
                              _blockUnrelatedApps = false;
                            });
                          },
                        ),
                        for (final task in widget.todayTasks)
                          ChoiceChip(
                            selected: identical(_selectedTask, task),
                            avatar: Icon(task.load.icon, size: 18),
                            label: Text('${task.title} · ${task.durationMinutes}m'),
                            onSelected: (_) {
                              setState(() {
                                _selectedTask = task;
                                _selectedDuration = task.durationMinutes;
                                _useCustomDuration = false;
                                _blockUnrelatedApps = true;
                              });
                            },
                          ),
                      ],
                    ),
                    if (widget.todayTasks.isEmpty) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'No unfinished goal is scheduled for today, so this will start a custom focus session.',
                        style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('2. Select duration', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            AppCard(
              color: gdCardLight,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_selectedTask != null)
                          ChoiceChip(
                            selected: !_useCustomDuration && _selectedDuration == _selectedTask!.durationMinutes,
                            avatar: const Icon(Icons.schedule_rounded, size: 18),
                            label: Text('Task time · ${_selectedTask!.durationMinutes}m'),
                            onSelected: (_) {
                              setState(() {
                                _useCustomDuration = false;
                                _selectedDuration = _selectedTask!.durationMinutes;
                              });
                            },
                          ),
                        for (final minutes in _durationPresets)
                          ChoiceChip(
                            selected: !_useCustomDuration && _selectedDuration == minutes,
                            label: Text('$minutes min'),
                            onSelected: (_) {
                              setState(() {
                                _useCustomDuration = false;
                                _selectedDuration = minutes;
                              });
                            },
                          ),
                        ChoiceChip(
                          selected: _useCustomDuration,
                          avatar: const Icon(Icons.tune_rounded, size: 18),
                          label: const Text('Custom'),
                          onSelected: (_) => setState(() => _useCustomDuration = true),
                        ),
                      ],
                    ),
                    if (_useCustomDuration) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _customDurationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Custom time',
                          hintText: 'Example: 30',
                          suffixText: 'minutes',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('3. Block distractions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            AppCard(
              color: gdCardLight,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedTask != null)
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _blockUnrelatedApps,
                        activeColor: gdPrimary,
                        title: const Text(
                          'Block apps unrelated to this goal',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: const Text(
                          'Goal Digger will use your selected list as the distraction blocklist during this session.',
                          style: TextStyle(color: gdMuted, fontWeight: FontWeight.w600),
                        ),
                        onChanged: (value) => setState(() => _blockUnrelatedApps = value),
                      )
                    else
                      const Text(
                        'Choose the apps you want to block during this custom session.',
                        style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
                      ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final app in _appOptions)
                          FilterChip(
                            selected: _blockedApps.contains(app),
                            label: Text(app),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _blockedApps.add(app);
                                } else {
                                  _blockedApps.remove(app);
                                }
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _startFocus,
                icon: const Icon(Icons.track_changes_rounded),
                label: const Text('Start focus session'),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class FocusCountdownDialog extends StatefulWidget {
  const FocusCountdownDialog({
    super.key,
    required this.config,
    required this.remainingSecondsProvider,
    required this.pausedProvider,
    required this.onPauseToggle,
    required this.onMinimize,
    required this.onStop,
  });

  final FocusSessionConfig config;
  final int Function() remainingSecondsProvider;
  final bool Function() pausedProvider;
  final VoidCallback onPauseToggle;
  final VoidCallback onMinimize;
  final VoidCallback onStop;

  @override
  State<FocusCountdownDialog> createState() => _FocusCountdownDialogState();
}

class _FocusCountdownDialogState extends State<FocusCountdownDialog> {
  Timer? _refreshTimer;

  int get _totalSeconds => widget.config.durationMinutes * 60;
  int get _remainingSeconds => widget.remainingSecondsProvider();
  bool get _paused => widget.pausedProvider();
  bool get _isComplete => _remainingSeconds <= 0;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds == 0 ? 1.0 : 1 - (_remainingSeconds / _totalSeconds);
    return Material(
      color: gdBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(backgroundColor: gdPrimarySoft, child: Icon(Icons.track_changes_rounded, color: gdPrimary)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_isComplete ? 'Focus complete' : 'Focus mode', style: Theme.of(context).textTheme.headlineMedium)),
                  IconButton.filledTonal(tooltip: 'Minimize without stopping', onPressed: widget.onMinimize, icon: const Icon(Icons.keyboard_arrow_down_rounded)),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        PetAvatar(pet: defaultPet, size: 112),
                        const SizedBox(height: 20),
                        Text(widget.config.title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(widget.config.blockingSummary, textAlign: TextAlign.center, style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 230,
                          height: 230,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox.expand(child: CircularProgressIndicator(value: progress.clamp(0.0, 1.0).toDouble(), strokeWidth: 14, backgroundColor: gdPrimarySoft, strokeCap: StrokeCap.round)),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_isComplete ? Icons.check_circle_rounded : _paused ? Icons.pause_circle_filled_rounded : Icons.track_changes_rounded, size: 34, color: gdPrimary),
                                  const SizedBox(height: 8),
                                  Text(_formatTime(_remainingSeconds), style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1.5, color: gdInk)),
                                  Text(_isComplete ? 'Nice work' : _paused ? 'Paused' : 'Running', style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        AppCard(
                          color: gdSurface,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(children: [Icon(Icons.block_rounded, size: 20), SizedBox(width: 8), Text('Blocked during focus', style: TextStyle(fontWeight: FontWeight.w900, color: gdInk))]),
                                const SizedBox(height: 10),
                                if (widget.config.blockedApps.isEmpty)
                                  const Text('No apps selected.', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700))
                                else
                                  Wrap(spacing: 8, runSpacing: 8, children: [for (final app in widget.config.blockedApps) Chip(backgroundColor: gdPrimarySoft, avatar: const Icon(Icons.lock_rounded, size: 16, color: gdPrimary), label: Text(app, style: const TextStyle(color: gdInk, fontWeight: FontWeight.w800)))]),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(child: OutlinedButton.icon(onPressed: _isComplete ? null : widget.onPauseToggle, icon: Icon(_paused ? Icons.play_arrow_rounded : Icons.pause_rounded), label: Text(_paused ? 'Resume' : 'Pause'))),
                  const SizedBox(width: 10),
                  Expanded(child: FilledButton.icon(onPressed: widget.onStop, icon: Icon(_isComplete ? Icons.check_circle_rounded : Icons.stop_rounded), label: Text(_isComplete ? 'Finish' : 'Stop session'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gdBackground,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Settings'),
        leading: IconButton(
          tooltip: 'Close settings',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          children: [
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('App preferences', style: TextStyle(color: gdInk, fontSize: 20, fontWeight: FontWeight.w900)),
                    SizedBox(height: 6),
                    Text('The whole app uses the same calm Goal Digger theme: soft background, white cards, readable slate text, and one primary blue for actions.', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700, height: 1.4)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    value: true,
                    onChanged: (_) {},
                    activeColor: gdPrimary,
                    title: const Text('Goal reminders', style: TextStyle(color: gdInk, fontWeight: FontWeight.w900)),
                    subtitle: const Text('Nudge me before scheduled tasks.', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: true,
                    onChanged: (_) {},
                    activeColor: gdPrimary,
                    title: const Text('Friend progress sharing', style: TextStyle(color: gdInk, fontWeight: FontWeight.w900)),
                    subtitle: const Text('Show my streak to approved friends.', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(
                children: const [
                  ListTile(
                    leading: CircleAvatar(backgroundColor: gdPrimarySoft, child: Icon(Icons.palette_rounded, color: gdPrimary)),
                    title: Text('Appearance', style: TextStyle(color: gdInk, fontWeight: FontWeight.w900)),
                    subtitle: Text('Readable colors and calm contrast enabled.', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: CircleAvatar(backgroundColor: gdPrimarySoft, child: Icon(Icons.notifications_active_rounded, color: gdPrimary)),
                    title: Text('Notifications', style: TextStyle(color: gdInk, fontWeight: FontWeight.w900)),
                    subtitle: Text('Focus, routine, friend, and streak notification controls.', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: CircleAvatar(backgroundColor: gdPrimarySoft, child: Icon(Icons.lock_rounded, color: gdPrimary)),
                    title: Text('Privacy and account', style: TextStyle(color: gdInk, fontWeight: FontWeight.w900)),
                    subtitle: Text('Manage login, visibility, and connected accounts.', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* RESPONSIVE NAVIGATION                                                      */
/* -------------------------------------------------------------------------- */

class ResponsiveGoalShell extends StatelessWidget {
  const ResponsiveGoalShell({
    super.key,
    required this.selectedIndex,
    required this.signedInWith,
    required this.pages,
    required this.onSelect,
    required this.onFocusMode,
    required this.onProfile,
    required this.onSettings,
    required this.hasActiveFocus,
    required this.focusLabel,
  });

  final int selectedIndex;
  final String signedInWith;
  final List<Widget> pages;
  final ValueChanged<int> onSelect;
  final VoidCallback onFocusMode;
  final VoidCallback onProfile;
  final VoidCallback onSettings;
  final bool hasActiveFocus;
  final String? focusLabel;

  static const labels = ['Goals', 'Calendar', 'Home', 'Social', 'Pet'];
  static const icons = [Icons.flag_rounded, Icons.calendar_month_rounded, Icons.home_rounded, Icons.groups_rounded, Icons.pets_rounded];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton.filledTonal(
            tooltip: 'Profile and friends',
            onPressed: onProfile,
            icon: const Icon(Icons.account_circle_rounded),
          ),
        ),
        centerTitle: true,
        title: const Text('Goal Digger'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton.filledTonal(
              tooltip: 'Settings',
              onPressed: onSettings,
              icon: const Icon(Icons.settings_rounded),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: SafeArea(top: false, bottom: false, child: pages[selectedIndex])),
          if (hasActiveFocus)
            Positioned(
              left: 22,
              right: 22,
              bottom: bottomInset + 126,
              child: AppCard(
                child: ListTile(
                  dense: true,
                  leading: const CircleAvatar(backgroundColor: gdPrimarySoft, child: Icon(Icons.track_changes_rounded, color: gdPrimary)),
                  title: const Text('Focus session running', style: TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text('Tap to reopen · ${focusLabel ?? ''}', style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
                  trailing: const Icon(Icons.open_in_full_rounded),
                  onTap: onFocusMode,
                ),
              ),
            ),
          Positioned(
            right: 22,
            bottom: bottomInset + (hasActiveFocus ? 220 : 124),
            child: FloatingActionButton.extended(
              tooltip: 'Focus mode',
              onPressed: onFocusMode,
              backgroundColor: gdPrimary,
              foregroundColor: Colors.white,
              elevation: 8,
              icon: const Icon(Icons.track_changes_rounded),
              label: const Text('Focus'),
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: bottomInset + 4,
            child: _GoalBottomNavigation(labels: labels, icons: icons, selectedIndex: selectedIndex, onSelect: onSelect),
          ),
        ],
      ),
    );
  }
}

class _GoalBottomNavigation extends StatelessWidget {
  const _GoalBottomNavigation({required this.labels, required this.icons, required this.selectedIndex, required this.onSelect});
  final List<String> labels;
  final List<IconData> icons;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Container(
              height: 88,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(color: gdSurface.withOpacity(0.96), borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 24, offset: const Offset(0, 12))], border: Border.all(color: gdBorder)),
              child: Row(children: [for (var i = 0; i < labels.length; i++) Expanded(child: _BottomNavItem(label: labels[i], icon: icons[i], selected: selectedIndex == i, highlighted: i == 2, onTap: () => onSelect(i)))]),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({required this.label, required this.icon, required this.selected, required this.highlighted, required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? gdOnDark : selected ? gdPrimary : gdMuted;
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: SizedBox(
        height: 70,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: highlighted ? 48 : 38,
            height: highlighted ? 48 : 38,
            decoration: BoxDecoration(color: highlighted ? gdPrimary : selected ? gdPrimarySoft : Colors.transparent, shape: BoxShape.circle, boxShadow: highlighted ? [BoxShadow(color: gdPrimary.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 6))] : null),
            child: Icon(icon, color: color, size: highlighted ? 28 : 23),
          ),
          const SizedBox(height: 4),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: highlighted ? gdPrimaryDark : selected ? gdPrimary : gdMuted, fontSize: 11, fontWeight: highlighted || selected ? FontWeight.w900 : FontWeight.w700)),
        ]),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* PAGES                                                                      */
/* -------------------------------------------------------------------------- */

class _PlannerPage extends StatelessWidget {
  const _PlannerPage({
    required this.goals,
    required this.today,
    required this.goalController,
    required this.deadline,
    required this.priority,
    required this.category,
    required this.isProcessing,
    required this.processingProgress,
    required this.onDeadlinePick,
    required this.onPriorityChanged,
    required this.onCategoryChanged,
    required this.onCreateGoal,
    required this.onDeleteGoal,
    required this.onEditGoalDeadline,
    required this.onEditGoalPriority,
    required this.onCreateFirstGoal,
  });

  final List<GoalProject> goals;
  final DateTime today;
  final TextEditingController goalController;
  final DateTime deadline;
  final int priority;
  final String category;
  final bool isProcessing;
  final double processingProgress;
  final VoidCallback onDeadlinePick;
  final ValueChanged<int> onPriorityChanged;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onCreateGoal;
  final ValueChanged<GoalProject> onDeleteGoal;
  final ValueChanged<GoalProject> onEditGoalDeadline;
  final ValueChanged<GoalProject> onEditGoalPriority;
  final VoidCallback onCreateFirstGoal;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 112),
        children: [
          AppCard(
            color: const Color(0xFFEAF1FF),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: const [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Create a goal', style: TextStyle(color: gdInk, fontSize: 26, height: 1.1, fontWeight: FontWeight.w900)),
                      SizedBox(height: 8),
                      Text('Pick a clear category, then review AI subtasks before they are scheduled.', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
                    ])),
                  ]),
                  const SizedBox(height: 18),
                  Theme(
                    data: Theme.of(context).copyWith(inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(fillColor: gdSurface)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(controller: goalController, textInputAction: TextInputAction.done, decoration: const InputDecoration(labelText: 'Goal', hintText: 'Example: Prepare for midterm'), onSubmitted: (_) => onCreateGoal()),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(style: OutlinedButton.styleFrom(backgroundColor: gdSurface), onPressed: onDeadlinePick, icon: const Icon(Icons.event_rounded), label: Text('Deadline: ${shortDate(deadline)}')),
                        const SizedBox(height: 14),
                        CategorySelector(selected: category, onChanged: onCategoryChanged),
                        const SizedBox(height: 12),
                        PrioritySelector(value: priority, onChanged: onPriorityChanged),
                        const SizedBox(height: 14),
                        FilledButton.icon(onPressed: isProcessing ? null : onCreateGoal, icon: const Icon(Icons.auto_awesome_rounded), label: const Text('Break down my goal')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isProcessing) ...[
            const SizedBox(height: 14),
            ProcessingProgressCard(progress: processingProgress, label: 'Creating your task plan'),
          ],
          const SizedBox(height: 22),
          SectionTitle(title: 'Active goals', trailing: '${goals.length}'),
          const SizedBox(height: 10),
          if (goals.isEmpty)
            EmptyStateCard(icon: Icons.flag_circle_rounded, title: 'No goals yet', message: 'Create your first project and Goal Digger will turn it into small, scheduled actions.', cta: 'Create your first project', onPressed: onCreateFirstGoal)
          else
            ...goals.map((goal) => GoalCard(
                  goal: goal,
                  today: today,
                  onDelete: () => onDeleteGoal(goal),
                  onEditDeadline: () => onEditGoalDeadline(goal),
                  onEditPriority: () => onEditGoalPriority(goal),
                )),
        ],
      ),
    );
  }
}

class _TasksPage extends StatelessWidget {
  const _TasksPage({
    required this.mood,
    required this.todayTasks,
    required this.todayProgress,
    required this.todayCompleted,
    required this.todayTotal,
    required this.remainingMinutes,
    required this.goalForTask,
    required this.onMoodChanged,
    required this.onToggleTask,
    required this.onCreateGoal,
  });

  final String mood;
  final List<MicroTask> todayTasks;
  final double todayProgress;
  final int todayCompleted;
  final int todayTotal;
  final int remainingMinutes;
  final GoalProject Function(MicroTask task) goalForTask;
  final ValueChanged<String> onMoodChanged;
  final ValueChanged<MicroTask> onToggleTask;
  final VoidCallback onCreateGoal;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 112),
        children: [
          MoodCheckPanel(
            selectedMood: mood,
            onMoodChanged: onMoodChanged,
          ),
          const SizedBox(height: 18),
          TodayProgressCard(
            progress: todayProgress,
            completed: todayCompleted,
            total: todayTotal,
            remainingMinutes: remainingMinutes,
          ),
          const SizedBox(height: 12),
          MoodAdjustmentNotice(mood: mood),
          const SizedBox(height: 18),
          SectionTitle(
            title: 'Goals for today',
            trailing: todayTasks.isEmpty ? null : '${todayTasks.length}',
          ),
          const SizedBox(height: 10),
          if (todayTasks.isEmpty)
            EmptyStateCard(
              icon: Icons.today_rounded,
              title: 'No goals scheduled today',
              message:
                  'Create a goal first. Goal Digger will automatically break it into scheduled actions for each day.',
              cta: 'Create goal',
              onPressed: onCreateGoal,
            )
          else
            ...todayTasks.map(
              (task) => TaskCard(
                task: task,
                goal: goalForTask(task),
                mood: mood,
                onToggle: () => onToggleTask(task),
              ),
            ),
        ],
      ),
    );
  }
}

class _CalendarPage extends StatefulWidget {
  const _CalendarPage({
    required this.tasks,
    required this.goalForTask,
    required this.today,
    required this.onCreateGoal,
  });

  final List<MicroTask> tasks;
  final GoalProject Function(MicroTask task) goalForTask;
  final DateTime today;
  final VoidCallback onCreateGoal;

  @override
  State<_CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<_CalendarPage> {
  late DateTime _visibleMonth;
  late DateTime _selectedDate;
  final TextEditingController _routineController = TextEditingController();
  final List<RoutineItem> _routines = [];
  DateTime _routineDate = DateTime.now();
  TimeOfDay _routineTime = const TimeOfDay(hour: 8, minute: 0);
  RoutineRepeat _routineRepeat = RoutineRepeat.daily;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(widget.today.year, widget.today.month);
    _selectedDate = widget.today;
    _routineDate = widget.today;
    _routines.addAll([
      RoutineItem(title: 'Morning goal review', startsAt: DateTime(widget.today.year, widget.today.month, widget.today.day, 8), repeat: RoutineRepeat.daily),
      RoutineItem(title: 'Evening reflection', startsAt: DateTime(widget.today.year, widget.today.month, widget.today.day, 20), repeat: RoutineRepeat.weekly),
    ]);
  }

  @override
  void dispose() {
    _routineController.dispose();
    super.dispose();
  }

  Future<void> _pickRoutineDate() async {
    final picked = await showDatePicker(context: context, initialDate: _routineDate, firstDate: DateTime(widget.today.year - 1), lastDate: DateTime(widget.today.year + 5));
    if (picked != null) setState(() => _routineDate = picked);
  }

  Future<void> _pickRoutineTime() async {
    final picked = await showTimePicker(context: context, initialTime: _routineTime);
    if (picked != null) setState(() => _routineTime = picked);
  }

  void _addRoutine() {
    final routine = _routineController.text.trim();
    if (routine.isEmpty) return;
    setState(() {
      _routines.add(RoutineItem(
        title: routine,
        startsAt: DateTime(_routineDate.year, _routineDate.month, _routineDate.day, _routineTime.hour, _routineTime.minute),
        repeat: _routineRepeat,
      ));
      _routineController.clear();
    });
  }

  void _viewAllRoutines() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoutinesListPage(routines: _routines)));
  }

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + offset);
      final daysInNewMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
      _selectedDate = DateTime(_visibleMonth.year, _visibleMonth.month, min(_selectedDate.day, daysInNewMonth));
    });
  }

  List<DateTime?> _buildMonthCells() {
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month);
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leadingEmptyCells = firstDay.weekday % 7;
    final cells = <DateTime?>[...List<DateTime?>.filled(leadingEmptyCells, null), for (var day = 1; day <= daysInMonth; day++) DateTime(_visibleMonth.year, _visibleMonth.month, day)];
    while (cells.length % 7 != 0) cells.add(null);
    return cells;
  }

  List<MicroTask> _tasksForDay(DateTime date) {
    final day = dateOnly(date);
    return widget.tasks.where((task) => dateOnly(task.scheduledDate) == day).toList()..sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
  }

  int _taskCountForDay(DateTime date) => _tasksForDay(date).length;

  @override
  Widget build(BuildContext context) {
    final monthTasks = widget.tasks.where((task) => task.scheduledDate.year == _visibleMonth.year && task.scheduledDate.month == _visibleMonth.month).toList();
    final completedThisMonth = monthTasks.where((task) => task.done).length;
    final selectedTasks = _tasksForDay(_selectedDate);

    return PageScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 112),
        children: [
          //const PageHero(icon: Icons.calendar_month_rounded, title: 'Calendar', subtitle: 'View scheduled goal tasks and add flexible routines. Tasks are view-only here.', compact: true),
          const SizedBox(height: 18),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(children: [
                Row(children: [
                  IconButton.filledTonal(onPressed: () => _changeMonth(-1), icon: const Icon(Icons.chevron_left_rounded)),
                  Expanded(child: Column(children: [Text('${monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 4), Text('${monthTasks.length} tasks · $completedThisMonth done', style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w800))])),
                  IconButton.filledTonal(onPressed: () => _changeMonth(1), icon: const Icon(Icons.chevron_right_rounded)),
                ]),
                const SizedBox(height: 16),
                const Row(children: [_WeekdayLabel('S'), _WeekdayLabel('M'), _WeekdayLabel('T'), _WeekdayLabel('W'), _WeekdayLabel('T'), _WeekdayLabel('F'), _WeekdayLabel('S')]),
                const SizedBox(height: 8),
                GridView.builder(
                  itemCount: _buildMonthCells().length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8),
                  itemBuilder: (context, index) {
                    final date = _buildMonthCells()[index];
                    if (date == null) return const SizedBox.shrink();
                    return _CalendarDayCell(date: date, taskCount: _taskCountForDay(date), completedCount: _tasksForDay(date).where((task) => task.done).length, selected: dateOnly(date) == dateOnly(_selectedDate), today: dateOnly(date) == widget.today, onTap: () => setState(() => _selectedDate = date));
                  },
                ),
              ]),
            ),
          ),
          const SizedBox(height: 18),
          AppCard(
            color: const Color(0xFFFFFBEB),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                CircleAvatar(backgroundColor: selectedTasks.isEmpty ? const Color(0xFFE2E8F0) : gdPrimarySoft, child: Icon(selectedTasks.isEmpty ? Icons.event_available_rounded : Icons.task_alt_rounded, color: selectedTasks.isEmpty ? gdMuted : gdPrimary)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(longDate(_selectedDate), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 3), Text(selectedTasks.isEmpty ? 'No goals scheduled on this date.' : '${selectedTasks.length} scheduled goal actions. Open Home to check them off.', style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w800))])),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          if (selectedTasks.isEmpty)
            EmptyStateCard(icon: Icons.event_available_rounded, title: 'No goals on this date', message: 'Pick another date with a dot, or create a new goal and Goal Digger will schedule it for you.', cta: 'Create goal', onPressed: widget.onCreateGoal)
          else
            ...selectedTasks.map((task) => _CalendarTaskDetailTile(task: task, goal: widget.goalForTask(task))),
          const SizedBox(height: 18),
          SectionTitle(title: 'Routines', trailing: '${_routines.length}'),
          const SizedBox(height: 10),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Add a routine', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 6),
                const Text('Choose the name, date, time, and repeat pattern yourself.', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                TextField(controller: _routineController, textInputAction: TextInputAction.done, decoration: const InputDecoration(labelText: 'Routine name', hintText: 'Example: 25-minute coding review'), onSubmitted: (_) => _addRoutine()),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  OutlinedButton.icon(onPressed: _pickRoutineDate, icon: const Icon(Icons.event_rounded), label: Text(longDate(_routineDate))),
                  OutlinedButton.icon(onPressed: _pickRoutineTime, icon: const Icon(Icons.schedule_rounded), label: Text(_routineTime.format(context))),
                  DropdownMenu<RoutineRepeat>(initialSelection: _routineRepeat, label: const Text('Repeat'), onSelected: (value) { if (value != null) setState(() => _routineRepeat = value); }, dropdownMenuEntries: [for (final repeat in RoutineRepeat.values) DropdownMenuEntry(value: repeat, label: repeat.label)]),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: FilledButton.icon(onPressed: _addRoutine, icon: const Icon(Icons.add_task_rounded), label: const Text('Add routine'))),
                  const SizedBox(width: 10),
                  Expanded(child: OutlinedButton.icon(onPressed: _viewAllRoutines, icon: const Icon(Icons.view_list_rounded), label: const Text('View routines'))),
                ]),
                const SizedBox(height: 12),
                for (final routine in _routines.take(3)) RoutineTile(routine: routine),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarTaskDetailTile extends StatelessWidget {
  const _CalendarTaskDetailTile({required this.task, required this.goal});
  final MicroTask task;
  final GoalProject goal;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        minVerticalPadding: 12,
        leading: CircleAvatar(backgroundColor: gdPrimarySoft, child: Icon(task.load.icon, color: gdPrimary)),
        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text('${goal.title} · ${shortDate(task.scheduledDate)} · ${task.durationMinutes} min · ${task.load.label}', style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
        trailing: const Chip(label: Text('View only')),
      ),
    );
  }
}

class RoutinesListPage extends StatelessWidget {
  const RoutinesListPage({super.key, required this.routines});
  final List<RoutineItem> routines;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All routines')),
      body: PageScaffold(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          children: routines.isEmpty
              ? [EmptyStateCard(icon: Icons.repeat_rounded, title: 'No routines yet', message: 'Add routines from Calendar first.', cta: 'Back to calendar', onPressed: () => Navigator.of(context).pop())]
              : [for (final routine in routines) RoutineTile(routine: routine)],
        ),
      ),
    );
  }
}

class RoutineTile extends StatelessWidget {
  const RoutineTile({super.key, required this.routine});
  final RoutineItem routine;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay(hour: routine.startsAt.hour, minute: routine.startsAt.minute).format(context);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: gdPrimarySoft, child: Icon(Icons.repeat_rounded, color: gdPrimary)),
        title: Text(routine.title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text('${longDate(routine.startsAt)} · $time · ${routine.repeat.label}', style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: gdMuted,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.date,
    required this.taskCount,
    required this.completedCount,
    required this.selected,
    required this.today,
    required this.onTap,
  });

  final DateTime date;
  final int taskCount;
  final int completedCount;
  final bool selected;
  final bool today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasTasks = taskCount > 0;
    final allDone = hasTasks && completedCount == taskCount;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: selected
              ? gdPrimary
              : hasTasks
                  ? gdPrimarySoft
                  : gdCardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: today
                ? gdWarning
                : selected
                    ? gdPrimary
                    : const Color(0xFFE2E8F0),
            width: today || selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                color: selected ? gdOnDark : gdInk,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            if (hasTasks)
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: selected
                      ? gdOnDark
                      : allDone
                          ? gdPrimary
                          : gdWarning,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 7),
          ],
        ),
      ),
    );
  }
}

class _CalendarStatCard extends StatelessWidget {
  const _CalendarStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: gdPrimarySoft,
              child: Icon(icon, color: gdPrimary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityPage extends StatefulWidget {
  const _CommunityPage({
    required this.controller,
    required this.communities,
    required this.friends,
    required this.friendSuggestions,
    required this.streak,
    required this.onAddCommunity,
    required this.onJoinCommunity,
    required this.onDeleteCommunity,
    required this.onAddFriend,
    required this.onDeleteFriend,
  });

  final TextEditingController controller;
  final List<CommunityGroup> communities;
  final List<String> friends;
  final List<String> friendSuggestions;
  final int streak;
  final VoidCallback onAddCommunity;
  final ValueChanged<CommunityGroup> onJoinCommunity;
  final ValueChanged<CommunityGroup> onDeleteCommunity;
  final ValueChanged<String> onAddFriend;
  final ValueChanged<String> onDeleteFriend;

  @override
  State<_CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<_CommunityPage> {
  int _tab = 0;
  final TextEditingController _friendSearchController = TextEditingController();
  final TextEditingController _communitySearchController = TextEditingController();

  @override
  void dispose() {
    _friendSearchController.dispose();
    _communitySearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 112),
        children: [
          // const PageHero(
          //   icon: Icons.groups_rounded,
          //   title: 'Social',
          //   subtitle: 'Manage accountability friends on the left tab and goal communities on the right tab.',
          // ),
          const SizedBox(height: 14),
          AppCard(
            color: gdCardLight,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(children: [
                Expanded(child: _SegmentButton(label: 'Friends', icon: Icons.person_add_alt_1_rounded, selected: _tab == 0, onTap: () => setState(() => _tab = 0))),
                Expanded(child: _SegmentButton(label: 'Communities', icon: Icons.groups_rounded, selected: _tab == 1, onTap: () => setState(() => _tab = 1))),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          if (_tab == 0) _buildFriendsTab(context) else _buildCommunitiesTab(context),
        ],
      ),
    );
  }

  Widget _buildFriendsTab(BuildContext context) {
    final leaderboard = <MapEntry<String, int>>[
      MapEntry('You', widget.streak),
      for (var i = 0; i < widget.friends.length; i++) MapEntry(widget.friends[i], max(2, widget.streak - i + 2)),
    ]..sort((a, b) => b.value.compareTo(a.value));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionTitle(title: 'Friend streak leaderboard'),
      const SizedBox(height: 10),
      AppCard(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            for (var i = 0; i < leaderboard.length; i++)
              ListTile(
                leading: CircleAvatar(backgroundColor: i == 0 ? gdAccentSoft : gdPrimarySoft, child: Text('#${i + 1}', style: const TextStyle(fontWeight: FontWeight.w900))),
                title: Text(leaderboard[i].key, style: const TextStyle(fontWeight: FontWeight.w900)),
                trailing: Chip(label: Text('${leaderboard[i].value} day streak')),
              ),
          ]),
        ),
      ),
      const SizedBox(height: 18),
      SectionTitle(title: 'My friend list', trailing: '${widget.friends.length}'),
      const SizedBox(height: 10),
      for (final friend in widget.friends)
        AppCard(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: gdPrimarySoft, child: Icon(Icons.person_rounded, color: gdPrimary)),
            title: Text(friend, style: const TextStyle(fontWeight: FontWeight.w900)),
            subtitle: const Text('Accountability friend · progress visible', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
            trailing: Wrap(spacing: 4, children: [
              IconButton.filledTonal(tooltip: 'Chat', onPressed: () => _showSimpleChat(context, friend, isCommunity: false), icon: const Icon(Icons.chat_bubble_rounded)),
              IconButton(tooltip: 'Delete friend', onPressed: () => widget.onDeleteFriend(friend), icon: const Icon(Icons.delete_outline_rounded, color: gdError)),
            ]),
          ),
        ),
      const SizedBox(height: 18),
      SectionTitle(title: 'Find friends'),
      const SizedBox(height: 10),
      TextField(controller: _friendSearchController, decoration: const InputDecoration(labelText: 'Search friend username', hintText: 'Example: @maya'), onSubmitted: (value) { if (value.trim().isNotEmpty) widget.onAddFriend(value.trim()); }),
      const SizedBox(height: 12),
      SectionTitle(title: 'Friend suggestions'),
      const SizedBox(height: 10),
      for (final name in widget.friendSuggestions.where((name) => !widget.friends.contains(name)))
        FriendSuggestionCard(name: name, match: 90 - widget.friendSuggestions.indexOf(name) * 6, onAdd: () => widget.onAddFriend(name)),
    ]);
  }

  Widget _buildCommunitiesTab(BuildContext context) {
    final joined = widget.communities.where((group) => group.joined).toList();
    final suggested = [...widget.communities]..sort((a, b) => b.similarity.compareTo(a.similarity));
    final leaderboard = [...widget.communities]..sort((a, b) => b.members.compareTo(a.members));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AppCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Create or join community', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: gdInk)),
            const SizedBox(height: 10),
            TextField(controller: widget.controller, decoration: const InputDecoration(labelText: 'Create a community', hintText: 'Example: Midterm study group'), onSubmitted: (_) => widget.onAddCommunity()),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: FilledButton.icon(onPressed: widget.onAddCommunity, icon: const Icon(Icons.add_rounded), label: const Text('Create'))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.login_rounded), label: const Text('Join with code'))),
            ]),
          ]),
        ),
      ),
      const SizedBox(height: 18),
      SectionTitle(title: 'Community streak leaderboard'),
      const SizedBox(height: 10),
      AppCard(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            for (var i = 0; i < min(3, leaderboard.length); i++)
              ListTile(
                leading: CircleAvatar(backgroundColor: gdPrimarySoft, child: Text('#${i + 1}', style: const TextStyle(fontWeight: FontWeight.w900))),
                title: Text(leaderboard[i].name, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('${leaderboard[i].members} members', style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
                trailing: Chip(label: Text('${leaderboard[i].similarity}% fit')),
              ),
          ]),
        ),
      ),
      const SizedBox(height: 18),
      SectionTitle(title: 'My community list', trailing: '${joined.length}'),
      const SizedBox(height: 10),
      if (joined.isEmpty)
        const HelpfulErrorBox(title: 'No joined communities yet', message: 'Join a suggested community below or create your own group.', actionLabel: 'Got it', showAction: false)
      else
        for (final group in joined)
          AppCard(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: gdPrimarySoft, child: Icon(Icons.groups_rounded, color: gdPrimary)),
              title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text('${group.members} members · ${group.tag}', style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
              trailing: Wrap(spacing: 4, children: [
                IconButton.filledTonal(tooltip: 'Chat', onPressed: () => _showSimpleChat(context, group.name, isCommunity: true), icon: const Icon(Icons.chat_bubble_rounded)),
                IconButton(tooltip: 'Delete community', onPressed: () => widget.onDeleteCommunity(group), icon: const Icon(Icons.delete_outline_rounded, color: gdError)),
              ]),
            ),
          ),
      const SizedBox(height: 18),
      SectionTitle(title: 'Find communities'),
      const SizedBox(height: 10),
      TextField(controller: _communitySearchController, decoration: const InputDecoration(labelText: 'Search communities', hintText: 'Example: design, fitness, exam'), onSubmitted: (_) {}),
      const SizedBox(height: 12),
      SectionTitle(title: 'Community suggestions'),
      const SizedBox(height: 10),
      ...suggested.map((group) => CommunityMatchCard(group: group, onJoin: () => widget.onJoinCommunity(group))),
    ]);
  }

  void _showSimpleChat(BuildContext context, String title, {required bool isCommunity}) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: gdSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isCommunity ? '$title chat' : 'Chat with $title', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            AppCard(color: gdCardLight, child: const Padding(padding: EdgeInsets.all(16), child: Text('Say hi, share your goal update, or ask for accountability.', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700)))),
            const SizedBox(height: 12),
            TextField(controller: controller, decoration: const InputDecoration(labelText: 'Message', hintText: 'Write a message...')),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.send_rounded), label: const Text('Send'))),
          ]),
        ),
      ),
    ).whenComplete(controller.dispose);
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({required this.label, required this.icon, required this.selected, required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(color: selected ? gdPrimary : Colors.transparent, borderRadius: BorderRadius.circular(18)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: selected ? Colors.white : gdMuted), const SizedBox(width: 8), Text(label, style: TextStyle(color: selected ? Colors.white : gdInk, fontWeight: FontWeight.w900))]),
      ),
    );
  }
}

class FriendSuggestionCard extends StatelessWidget {
  const FriendSuggestionCard({super.key, required this.name, required this.match, required this.onAdd});
  final String name;
  final int match;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: gdPrimarySoft, child: Icon(Icons.person_search_rounded, color: gdPrimary)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text('$match% similar goals · active this week', style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
        trailing: FilledButton(onPressed: onAdd, child: const Text('Add')),
      ),
    );
  }
}

class CommunityMatchCard extends StatelessWidget {
  const CommunityMatchCard({super.key, required this.group, required this.onJoin});
  final CommunityGroup group;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))), Chip(label: Text('${group.similarity}% match'))]),
          const SizedBox(height: 6),
          Text('${group.members} members · ${group.tag}', style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(group.description, style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: group.joined ? const OutlinedButton(onPressed: null, child: Text('Already joined')) : FilledButton.icon(onPressed: onJoin, icon: const Icon(Icons.group_add_rounded), label: const Text('Join community'))),
        ]),
      ),
    );
  }
}

class _CompanionPage extends StatefulWidget {
  const _CompanionPage({
    required this.coins,
    required this.happiness,
    required this.pet,
    required this.accessory,
    required this.onFeed,
    required this.onOpenChest,
    required this.onPetInteract,
  });

  final int coins;
  final int happiness;
  final PetSkin pet;
  final String accessory;
  final VoidCallback onFeed;
  final VoidCallback onOpenChest;
  final VoidCallback onPetInteract;

  @override
  State<_CompanionPage> createState() => _CompanionPageState();
}

class _CompanionPageState extends State<_CompanionPage> {
  String _selectedSkin = 'Mint';

  @override
  void didUpdateWidget(covariant _CompanionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selectedSkin = widget.pet.name;
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(18, 72, 18, 112),
            children: [
              // PageHero(
              //   icon: Icons.pets_rounded,
              //   title: 'Pet companion',
              //   subtitle: 'Care for your companion, unlock chest rewards, and keep the visual style calm and consistent.',
              // ),
              const SizedBox(height: 16),
              AppCard(
                color: const Color(0xFFEAF1FF),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'PET PREVIEW',
                          style: TextStyle(
                            color: gdPrimary,
                            letterSpacing: 3,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Center(
                        child: GestureDetector(
                          onTap: widget.onPetInteract,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: gdCardLight,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: gdBorder),
                                ),
                                child: PetAvatar(pet: widget.pet, size: 142),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: gdSurface,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: gdBorder),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  widget.accessory,
                                  style: const TextStyle(color: gdInk, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: gdCardLight,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: gdBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.favorite_rounded, color: gdAccent, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Happiness ${widget.happiness}%',
                                    style: const TextStyle(color: gdInk, fontWeight: FontWeight.w900),
                                  ),
                                ),
                                const Text(
                                  'Tap to cheer up',
                                  style: TextStyle(color: gdMuted, fontSize: 12, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: widget.happiness / 100,
                              minHeight: 10,
                              backgroundColor: gdPrimarySoft,
                              color: gdPrimary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(child: _SkinPill(label: 'Mint', selected: _selectedSkin == 'Mint', onTap: () => setState(() => _selectedSkin = 'Mint'))),
                          const SizedBox(width: 10),
                          Expanded(child: _SkinPill(label: 'Peach', selected: _selectedSkin == 'Peach', onTap: () => setState(() => _selectedSkin = 'Peach'))),
                          const SizedBox(width: 10),
                          Expanded(child: _SkinPill(label: 'Lunar', selected: _selectedSkin == 'Lunar', onTap: () => setState(() => _selectedSkin = 'Lunar'))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SectionTitle(title: 'Mystery chest', trailing: '50 coins'),
          const SizedBox(height: 10),
              AppCard(
                color: gdSurface,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: const [CircleAvatar(backgroundColor: gdPrimarySoft, child: Icon(Icons.inventory_2_rounded, color: gdPrimary)), SizedBox(width: 12), Expanded(child: Text('Open a chest for random pet skins or accessories.', style: TextStyle(color: gdInk, fontWeight: FontWeight.w900, fontSize: 16)))]),
                    const SizedBox(height: 14),
                    SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: widget.onOpenChest, icon: const Icon(Icons.auto_awesome_rounded), label: const Text('Open chest -50 coins'))),
                    const SizedBox(height: 10),
                    SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: widget.onFeed, icon: const Icon(Icons.restaurant_rounded), label: const Text('Feed companion -10 coins'))),
                  ]),
                ),
              ),
            ],
          ),
          Positioned(
            top: 14,
            left: 18,
            child: _FloatingWallet(coins: widget.coins),
          ),
        ],
      ),
    );
  }
}

class _FloatingWallet extends StatelessWidget {
  const _FloatingWallet({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: gdSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gdBorder),
        boxShadow: [
          BoxShadow(
            color: gdPrimary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(color: gdStarGold, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Text(
              'C',
              style: TextStyle(color: Color(0xFF5B3200), fontWeight: FontWeight.w900, fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Wallet',
                style: TextStyle(color: gdMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.6),
              ),
              Text(
                '$coins coins',
                style: const TextStyle(color: gdInk, fontSize: 13, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkinPill extends StatelessWidget {
  const _SkinPill({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: 62,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: selected ? const Color(0xFF071022) : Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: selected ? null : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)]),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : gdMuted, fontSize: 18, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* REUSABLE UI                                                                */
/* -------------------------------------------------------------------------- */

class PageScaffold extends StatelessWidget {
  const PageScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AmbientBackground(),
        child,
      ],
    );
  }
}

class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gdBackground,
                const Color(0xFFE0F2FE).withOpacity(0.7),
                const Color(0xFFFCE7F3).withOpacity(0.45),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.margin, this.color});

  final Widget child;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? gdSurface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class PageHero extends StatelessWidget {
  const PageHero({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: EdgeInsets.all(compact ? 0 : 20),
        child: Row(
          children: [
            CircleAvatar(
              radius: compact ? 22 : 28,
              backgroundColor: gdPrimarySoft,
              child: Icon(icon, color: gdPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  const _BenefitChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: gdPrimary, size: 18),
      label: Text(text),
      backgroundColor: gdPrimarySoft,
    );
  }
}

class MoodCheckPanel extends StatelessWidget {
  const MoodCheckPanel({
    super.key,
    required this.selectedMood,
    required this.onMoodChanged,
  });

  final String selectedMood;
  final ValueChanged<String> onMoodChanged;

  static const _moods = [
    _MoodOption(
      label: 'Tired',
      emoji: '😔',
      subtitle: 'Light wins only',
    ),
    _MoodOption(
      label: 'Okay',
      emoji: '🙄',
      subtitle: 'Balanced day',
    ),
    _MoodOption(
      label: 'Great',
      emoji: '😊',
      subtitle: 'Stretch tasks unlocked',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const spacing = 12.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [gdPrimaryDark, gdPrimary, gdGradientCreativeTo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gdPrimaryDark.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MOOD CHECK · REAL-TIME',
            style: TextStyle(
              color: gdOnDarkMuted,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: spacing),
          Row(
            children: [
              for (final mood in _moods)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: mood == _moods.last ? 0 : spacing,
                    ),
                    child: _MoodButton(
                      option: mood,
                      selected: selectedMood == mood.label,
                      onTap: () => onMoodChanged(mood.label),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodOption {
  const _MoodOption({
    required this.label,
    required this.emoji,
    required this.subtitle,
  });

  final String label;
  final String emoji;
  final String subtitle;
}

class _MoodButton extends StatelessWidget {
  const _MoodButton({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _MoodOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? gdSurface : gdOnDark.withOpacity(0.18),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? gdOnDark : gdOnDark.withOpacity(0.18),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(option.emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            Text(
              option.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? gdInk : gdOnDark,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              option.subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? gdMuted : gdOnDarkMuted,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProcessingProgressCard extends StatelessWidget {
  const ProcessingProgressCard({
    super.key,
    required this.progress,
    required this.label,
  });

  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0).toDouble();
    final percent = (safeProgress * 100).round();
    final secondsRemaining = max(0, ((1 - safeProgress) * 3).ceil());

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircularProgressBadge(
              progress: safeProgress,
              label: '$percent%',
              size: 82,
              strokeWidth: 8,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.hourglass_top_rounded),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(label, style: Theme.of(context).textTheme.titleMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    secondsRemaining == 0
                        ? 'Almost ready...'
                        : 'About $secondsRemaining seconds remaining',
                    style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TodayProgressCard extends StatelessWidget {
  const TodayProgressCard({
    super.key,
    required this.progress,
    required this.completed,
    required this.total,
    required this.remainingMinutes,
  });

  final double progress;
  final int completed;
  final int total;
  final int remainingMinutes;

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0).toDouble();
    final percent = (safeProgress * 100).round();

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircularProgressBadge(
              progress: safeProgress,
              label: '$percent%',
              size: 112,
              strokeWidth: 10,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$completed/$total done',
                    style: const TextStyle(
                      color: gdInk,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'About $remainingMinutes minutes left',
                    style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularProgressBadge extends StatelessWidget {
  const CircularProgressBadge({
    super.key,
    required this.progress,
    required this.label,
    this.size = 96,
    this.strokeWidth = 9,
  });

  final double progress;
  final String label;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0).toDouble();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: safeProgress,
              strokeWidth: strokeWidth,
              backgroundColor: const Color(0xFFE2E8F0),
              color: gdPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: gdPrimaryDark,
              fontSize: size >= 100 ? 22 : 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class HelpfulErrorBox extends StatelessWidget {
  const HelpfulErrorBox({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    this.onAction,
    this.showAction = true,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool showAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gdErrorSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gdError.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: gdError),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: gdError, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(message, style: const TextStyle(color: gdInk, height: 1.4)),
                if (showAction) ...[
                  const SizedBox(height: 8),
                  TextButton(onPressed: onAction, child: Text(actionLabel)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.cta,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String cta;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: gdPrimarySoft,
              child: Icon(icon, color: gdPrimary, size: 48),
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add_rounded),
              label: Text(cta),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: Theme.of(context).textTheme.headlineMedium)),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              color: gdMuted,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
      ],
    );
  }
}

class CategorySelector extends StatelessWidget {
  const CategorySelector({super.key, required this.selected, required this.onChanged});
  final String selected;
  final ValueChanged<String> onChanged;

  IconData _iconFor(String category) {
    switch (category) {
      case 'Career': return Icons.work_rounded;
      case 'Wellness': return Icons.favorite_rounded;
      case 'Finance': return Icons.savings_rounded;
      case 'Creative': return Icons.palette_rounded;
      case 'Study': return Icons.school_rounded;
      default: return Icons.more_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Category', style: TextStyle(color: gdInk, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final item in categories)
          Builder(builder: (context) {
            final isSelected = selected == item;
            return ChoiceChip(
              selected: isSelected,
              selectedColor: gdPrimary,
              backgroundColor: gdSurface,
              side: BorderSide(color: isSelected ? gdPrimary : gdBorderStrong),
              avatar: Icon(_iconFor(item), size: 18, color: isSelected ? Colors.white : gdPrimary),
              label: Text(item, style: TextStyle(color: isSelected ? Colors.white : gdInk, fontWeight: FontWeight.w900)),
              onSelected: (_) => onChanged(item),
            );
          }),
      ]),
    ]);
  }
}

class StatMiniCard extends StatelessWidget {
  const StatMiniCard({super.key, required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: gdCardLight,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: gdPrimary),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label, style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class PrioritySelector extends StatelessWidget {
  const PrioritySelector({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Priority',
          style: TextStyle(color: gdInk, fontWeight: FontWeight.w900),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: List.generate(5, (index) {
              final star = index + 1;
              return Expanded(
                child: IconButton(
                  tooltip: 'Priority $star',
                  onPressed: () => onChanged(star),
                  icon: Icon(
                    star <= value ? Icons.star_rounded : Icons.star_border_rounded,
                    color: star <= value ? gdStarGold : gdMuted.withOpacity(0.55),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.today,
    required this.onDelete,
    required this.onEditDeadline,
    required this.onEditPriority,
  });

  final GoalProject goal;
  final DateTime today;
  final VoidCallback onDelete;
  final VoidCallback onEditDeadline;
  final VoidCallback onEditPriority;

  void _showTaskDetail(BuildContext context, MicroTask task) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: gdSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              Text(goal.title, style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              AppCard(color: gdCardLight, child: ListTile(leading: Icon(task.load.icon), title: Text('${task.durationMinutes} minutes · ${task.load.label}', style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text('Scheduled on ${longDate(task.scheduledDate)}', style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700)))),
              const SizedBox(height: 12),
              Text(task.done ? 'Status: completed' : 'Status: not completed yet', style: const TextStyle(color: gdInk, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed = goal.tasks.where((task) => task.done).length;
    final daysLeft = daysBetween(today, goal.deadline);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 8, decoration: BoxDecoration(gradient: LinearGradient(colors: [goal.from.withOpacity(0.72), goal.to.withOpacity(0.72)]))),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Text(goal.title, style: Theme.of(context).textTheme.titleLarge)),
              Chip(backgroundColor: gdPrimarySoft, label: Text(goal.category, style: const TextStyle(color: gdPrimary, fontWeight: FontWeight.w900))),
              IconButton(tooltip: 'Remove goal', onPressed: onDelete, icon: const Icon(Icons.close_rounded, color: gdError)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              CircularProgressBadge(progress: goal.progress, label: '${(goal.progress * 100).round()}%', size: 72, strokeWidth: 7),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$completed/${goal.tasks.length} tasks done', style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Row(children: [Icon(daysLeft <= 2 ? Icons.warning_amber_rounded : Icons.event_rounded, size: 18, color: daysLeft <= 2 ? gdWarning : gdPrimary), const SizedBox(width: 4), Text(daysLeft < 0 ? 'Overdue' : '$daysLeft days left', style: TextStyle(color: daysLeft <= 2 ? gdWarning : gdMuted, fontWeight: FontWeight.w900))]),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.star_rounded, size: 18, color: gdStarGold),
                  const SizedBox(width: 4),
                  Text('Priority ${goal.importance}/5', style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w900)),
                ]),
              ])),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              OutlinedButton.icon(
                onPressed: onEditDeadline,
                icon: const Icon(Icons.event_rounded, size: 18),
                label: const Text('Edit deadline'),
              ),
              OutlinedButton.icon(
                onPressed: onEditPriority,
                icon: const Icon(Icons.star_rounded, size: 18),
                label: const Text('Edit priority'),
              ),
            ]),
            const Divider(height: 26),
            const Text('Subtasks', style: TextStyle(color: gdInk, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (var i = 0; i < goal.tasks.length; i++)
                ActionChip(
                  avatar: Icon(goal.tasks[i].load.icon, size: 18, color: gdPrimary),
                  label: Text('Step ${i + 1}', style: const TextStyle(color: gdInk, fontWeight: FontWeight.w900)),
                  backgroundColor: goal.tasks[i].done ? gdPrimarySoft : const Color(0xFFF1F5F9),
                  side: const BorderSide(color: gdBorder),
                  onPressed: () => _showTaskDetail(context, goal.tasks[i]),
                ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class MoodAdjustmentNotice extends StatelessWidget {
  const MoodAdjustmentNotice({super.key, required this.mood});

  final String mood;

  @override
  Widget build(BuildContext context) {
    final icon = mood == 'Tired'
        ? Icons.spa_rounded
        : mood == 'Great'
            ? Icons.local_fire_department_rounded
            : Icons.tune_rounded;
    final title = mood == 'Tired'
        ? 'Tasks softened for low energy'
        : mood == 'Great'
            ? 'Stretch mode is available today'
            : 'Balanced task plan';
    final message = mood == 'Tired'
        ? 'Goal Digger shortens today’s actions and turns heavy tasks into smaller first steps.'
        : mood == 'Great'
            ? 'Goal Digger keeps the plan ambitious and suggests deeper work where it fits.'
            : 'Goal Digger keeps today’s tasks at their normal size.';

    return AppCard(
      color: mood == 'Tired'
          ? const Color(0xFFF0FDF4)
          : mood == 'Great'
              ? const Color(0xFFFFF7ED)
              : gdCardLight,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: gdSurface,
              child: Icon(icon, color: gdPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: gdInk)),
                  const SizedBox(height: 3),
                  Text(
                    message,
                    style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.goal,
    required this.mood,
    required this.onToggle,
  });

  final MicroTask task;
  final GoalProject goal;
  final String mood;
  final VoidCallback onToggle;

  String get _adjustedTitle {
    if (mood == 'Tired') {
      if (task.load == TaskLoad.stretch) return 'Tiny version: ${task.title}';
      if (task.durationMinutes > 15) return 'Start only: ${task.title}';
      return task.title;
    }
    if (mood == 'Great' && task.load != TaskLoad.light) {
      return 'Deep work: ${task.title}';
    }
    return task.title;
  }

  int get _adjustedMinutes {
    if (mood == 'Tired') return min(task.durationMinutes, task.load == TaskLoad.stretch ? 12 : 15);
    if (mood == 'Great' && task.load == TaskLoad.stretch) return task.durationMinutes + 10;
    return task.durationMinutes;
  }

  String get _moodTip {
    if (mood == 'Tired') {
      return task.load == TaskLoad.stretch
          ? 'Mood adjusted: do only the smallest useful part. You can finish the rest later.'
          : 'Mood adjusted: keep this light and stop after the first clear win.';
    }
    if (mood == 'Great') {
      return task.load == TaskLoad.light
          ? 'Warm-up task. Finish this quickly, then move to a deeper step.'
          : 'Mood adjusted: good energy today, so this can become a focused stretch block.';
    }
    return task.load == TaskLoad.light
        ? 'Start here when energy is low. This task is intentionally small.'
        : task.load == TaskLoad.focus
            ? 'Block distractions and work on this single step first.'
            : 'This is a higher-effort step. Do it when you have enough time.';
  }

  Color get _moodChipColor {
    if (mood == 'Tired') return const Color(0xFFDCFCE7);
    if (mood == 'Great') return const Color(0xFFFFEDD5);
    return gdPrimarySoft;
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(value: task.done, onChanged: (_) => onToggle()),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _adjustedTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            decoration: task.done ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        if (mood != 'Okay')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: _moodChipColor,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: gdBorder),
                            ),
                            child: Text(
                              mood == 'Tired' ? 'Adjusted lighter' : 'Stretch option',
                              style: const TextStyle(
                                color: gdInk,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${goal.title} · ${shortDate(task.scheduledDate)} · $_adjustedMinutes min · ${task.load.label}',
                      style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(task.load.icon, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _moodTip,
                            style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Chip(label: Text('+${task.points}')),
            ],
          ),
        ),
      ),
    );
  }
}

class PetAvatar extends StatelessWidget {
  const PetAvatar({super.key, required this.pet, this.size = 72});

  final PetSkin pet;
  final double size;

  @override
  Widget build(BuildContext context) {
    final eye = size * 0.08;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [pet.from, pet.to],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: pet.to.withOpacity(0.34),
            blurRadius: size * 0.22,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * 0.23,
            child: Container(
              width: size * 0.45,
              height: size * 0.17,
              decoration: BoxDecoration(
                color: pet.accent.withOpacity(0.85),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            top: size * 0.43,
            left: size * 0.31,
            child: CircleAvatar(radius: eye, backgroundColor: Colors.white),
          ),
          Positioned(
            top: size * 0.43,
            right: size * 0.31,
            child: CircleAvatar(radius: eye, backgroundColor: Colors.white),
          ),
          Positioned(
            bottom: size * 0.27,
            child: Container(
              width: size * 0.22,
              height: size * 0.08,
              decoration: BoxDecoration(
                color: gdSurface.withOpacity(0.94),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RewardTile extends StatelessWidget {
  const RewardTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.price,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int price;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        minVerticalPadding: 14,
        leading: CircleAvatar(
          backgroundColor: gdPrimarySoft,
          child: Icon(icon, color: gdPrimary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle, style: const TextStyle(color: gdMuted)),
        trailing: Chip(
          avatar: const Icon(Icons.monetization_on_rounded, size: 18),
          label: Text('$price'),
        ),
      ),
    );
  }
}
