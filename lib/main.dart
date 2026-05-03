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

const Color gdBackground = Color(0xFFF4EFE6);
const Color gdSurface = Color(0xFFFFF4E3);
const Color gdInk = Color(0xFF10201F);
const Color gdMuted = Color(0xFF334155); // stronger secondary text for readability
const Color gdPrimary = Color(0xFF0B5F59);
const Color gdPrimaryDark = Color(0xFF073B38);
const Color gdPrimarySoft = Color(0xFFC7EEE8);
const Color gdWarning = Color(0xFFB45309);
const Color gdError = Color(0xFFB42318);
const Color gdErrorSoft = Color(0xFFFFF1F0);
const Color gdBorder = Color(0xFFE5E7EB); // light border color
const Color gdBorderStrong = Color(0xFFD1D5DB); // stronger border color
const Color gdHint = Color(0xFF6B7280); // hint text color
const Color gdGradientCareerFrom = Color(0xFF14B8A6); // career gradient start
const Color gdGradientCareerTo = Color(0xFF0EA5E9); // career gradient end
const Color gdGradientStudyFrom = Color(0xFFF59E0B); // study gradient start
const Color gdGradientStudyTo = Color(0xFFEF4444); // study gradient end
const Color gdGradientWellnessFrom = Color(0xFFFB7185); // wellness gradient start
const Color gdGradientWellnessTo = Color(0xFFE11D48); // wellness gradient end
const Color gdGradientFinanceFrom = Color(0xFF22C55E); // finance gradient start
const Color gdGradientFinanceTo = Color(0xFF15803D); // finance gradient end
const Color gdGradientCreativeFrom = Color(0xFFA78BFA); // creative gradient start
const Color gdGradientCreativeTo = Color(0xFF7C3AED); // creative gradient end
const Color gdPetMintFrom = Color(0xFF7DD3FC); // pet mint gradient start
const Color gdPetMintTo = Color(0xFF34D399); // pet mint gradient end
const Color gdPetAccent = Color(0xFFEFFFFB); // high-contrast soft text on dark teal
const Color gdOnDark = Color(0xFFFFFEF8); // readable foreground on dark surfaces
const Color gdOnDarkMuted = Color(0xFFD8FFF7); // readable secondary text on dark surfaces
const Color gdCardLight = Color(0xFFFFFBF2); // warm light card background
const Color gdStarGold = Color(0xFFFBBF24); // star rating gold color
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
      labelStyle: const TextStyle(fontWeight: FontWeight.w800),
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
  });

  final String name;
  final int members;
  final String tag;
  final String description;
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

  @override
  void initState() {
    super.initState();
    _goals = seedGoals(today);
    _communities = [
      CommunityGroup(
        name: 'Study Sprint Club',
        members: 89,
        tag: 'Exam prep',
        description: 'Short daily sprints for students who want accountability.',
      ),
      CommunityGroup(
        name: 'Portfolio Builders',
        members: 142,
        tag: 'Career',
        description: 'Share portfolio progress and get feedback from builders.',
      ),
    ];
  }

  @override
  void dispose() {
    _processingTimer?.cancel();
    _goalController.dispose();
    _communityController.dispose();
    super.dispose();
  }

  List<MicroTask> get _allTasks {
    return _goals.expand((goal) => goal.tasks).toList();
  }

  List<MicroTask> get _todayTasks {
    return _allTasks
        .where((task) => dateOnly(task.scheduledDate) == today)
        .toList();
  }


  GoalProject _goalForTask(MicroTask task) {
    return _goals.firstWhere((goal) => goal.id == task.goalId);
  }

  int get _todayCompleted => _todayTasks.where((task) => task.done).length;

  double get _todayProgress {
    if (_todayTasks.isEmpty) return 0;
    return _todayCompleted / _todayTasks.length;
  }

  int get _remainingMinutes {
    return _todayTasks
        .where((task) => !task.done)
        .fold(0, (sum, task) => sum + task.durationMinutes);
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
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
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
    if (picked != null) {
      setState(() => _newGoalDeadline = picked);
    }
  }

  void _createGoalWithProgress() {
    final title = _goalController.text.trim();
    if (title.isEmpty) {
      _showHelpfulError(
        title: 'Goal name is missing',
        message:
            'Please write one clear goal first. Example: “Prepare for midterm” or “Build my portfolio”.',
        actionLabel: 'Write goal',
        onAction: () => FocusScope.of(context).requestFocus(FocusNode()),
      );
      return;
    }

    _processingTimer?.cancel();
    setState(() {
      _isProcessing = true;
      _processingProgress = 0;
    });

    _processingTimer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
      if (!mounted) return;
      setState(() {
        _processingProgress = min(1, _processingProgress + 0.17);
      });
      if (_processingProgress >= 1) {
        timer.cancel();
        _finishCreateGoal(title);
      }
    });
  }

  void _finishCreateGoal(String title) {
    final goalId = _nextGoalId++;
    final Color from;
    final Color to;
    switch (_newGoalCategory) {
      case 'Career':
        from = gdGradientCareerFrom;
        to = gdGradientCareerTo;
        break;
      case 'Wellness':
        from = gdGradientWellnessFrom;
        to = gdGradientWellnessTo;
        break;
      case 'Finance':
        from = gdGradientFinanceFrom;
        to = gdGradientFinanceTo;
        break;
      case 'Creative':
        from = gdGradientCreativeFrom;
        to = gdGradientCreativeTo;
        break;
      default:
        from = gdGradientStudyFrom;
        to = gdGradientStudyTo;
    }

    final steps = _generateMicroTasks(title, goalId);
    setState(() {
      _goals.insert(
        0,
        GoalProject(
          id: goalId,
          title: title,
          importance: _newGoalPriority,
          category: _newGoalCategory,
          deadline: _newGoalDeadline,
          from: from,
          to: to,
          tasks: steps,
        ),
      );
      _isProcessing = false;
      _processingProgress = 0;
      _goalController.clear();
      _newGoalPriority = 3;
      _newGoalCategory = 'Study';
      _newGoalDeadline = addDays(today, 14);
      _selectedIndex = 2;
    });
    _showMessage('Goal created. Your first tasks are ready on Home.');
  }

  List<MicroTask> _generateMicroTasks(String title, int goalId) {
    final lower = title.toLowerCase();
    final List<String> taskTitles;
    if (lower.contains('exam') || lower.contains('midterm') || lower.contains('study')) {
      taskTitles = [
        'List topics to review',
        'Study the hardest topic for 20 minutes',
        'Solve practice questions',
        'Review mistakes and make flashcards',
      ];
    } else if (lower.contains('portfolio') || lower.contains('project')) {
      taskTitles = [
        'Define the project outcome',
        'Create the first rough draft',
        'Improve one visible section',
        'Share for feedback',
      ];
    } else {
      taskTitles = [
        'Write the desired outcome',
        'Break the goal into 3 milestones',
        'Do the smallest first action',
        'Review progress and adjust tomorrow',
      ];
    }

    return List.generate(taskTitles.length, (index) {
      return MicroTask(
        id: _nextTaskId++,
        goalId: goalId,
        title: taskTitles[index],
        durationMinutes: index == 0 ? 8 : 15 + index * 5,
        load: index == 0
            ? TaskLoad.light
            : index == taskTitles.length - 1
                ? TaskLoad.stretch
                : TaskLoad.focus,
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
      _communities.insert(
        0,
        CommunityGroup(
          name: title,
          members: 1,
          tag: 'Created by you',
          description: 'A new accountability group for people working on similar goals.',
        ),
      );
      _communityController.clear();
    });
    _showMessage('Community created.');
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

  Future<void> _openFocusMode() async {
    final unfinishedToday = _todayTasks.where((task) => !task.done).toList();

    final config = await showModalBottomSheet<FocusSessionConfig>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: gdSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return FocusSetupSheet(todayTasks: unfinishedToday);
      },
    );

    if (!mounted || config == null) return;
    _openFocusCountdown(config);
  }

  void _openFocusCountdown(FocusSessionConfig config) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.24),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FocusCountdownDialog(config: config);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
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
        onCreateFirstGoal: () => setState(() => _selectedIndex = 0),
      ),
      _CalendarPage(
        tasks: _allTasks,
        goalForTask: _goalForTask,
        today: today,
        onToggleTask: _toggleTask,
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
        onAddCommunity: _addCommunity,
      ),
      _CompanionPage(
        coins: _coins,
        happiness: _petHappiness,
        onFeed: _feedPet,
      ),
    ];

    return ResponsiveGoalShell(
      selectedIndex: _selectedIndex,
      signedInWith: _signedInWith,
      pages: pages,
      onSelect: (index) => setState(() => _selectedIndex = index),
      onFocusMode: _openFocusMode,
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
                final heroColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DirectValueHero(onPrimaryCta: onGuest),
                    const SizedBox(height: 18),
                    const HowItWorksSimple(),
                  ],
                );
                final signInCard = SimpleOnboardingCard(
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
                              children: [
                                Expanded(flex: 6, child: heroColumn),
                                const SizedBox(width: 24),
                                Expanded(flex: 4, child: signInCard),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                heroColumn,
                                const SizedBox(height: 18),
                                signInCard,
                              ],
                            ),
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

class DirectValueHero extends StatelessWidget {
  const DirectValueHero({super.key, required this.onPrimaryCta});

  final VoidCallback onPrimaryCta;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: gdPrimarySoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'AI goal planner + daily action coach',
                style: TextStyle(
                  color: gdPrimaryDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Turn big goals into today’s next step.',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 14),
            const Text(
              'Goal Digger breaks a goal into small tasks, schedules them by deadline and energy, and shows clear progress so you always know what to do next.',
              style: TextStyle(
                color: gdMuted,
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _BenefitChip(icon: Icons.account_tree_rounded, text: 'Micro-tasks'),
                _BenefitChip(icon: Icons.calendar_month_rounded, text: 'Auto schedule'),
                _BenefitChip(icon: Icons.trending_up_rounded, text: 'Progress nudges'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onPrimaryCta,
                icon: const Icon(Icons.rocket_launch_rounded),
                label: const Text('Start with my first goal'),
              ),
            ),
          ],
        ),
      ),
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
            Text('Start in one step', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'No long account setup. Sign in quickly, then add details only when they are needed.',
              style: TextStyle(color: gdMuted, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onGoogle,
              icon: const Icon(Icons.g_mobiledata_rounded, size: 30),
              label: const Text('Continue with Google'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onLinkedIn,
              icon: const Icon(Icons.work_rounded),
              label: const Text('Continue with LinkedIn'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onGuest,
              child: const Text('Continue without account'),
            ),
            const Divider(height: 32),
            const HelpfulErrorBox(
              title: 'Prototype note',
              message:
                  'These social buttons are ready for Firebase Auth, Supabase Auth, or your preferred login provider.',
              actionLabel: 'Got it',
              showAction: false,
            ),
          ],
        ),
      ),
    );
  }
}

class HowItWorksSimple extends StatelessWidget {
  const HowItWorksSimple({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      const _StepData(
        icon: Icons.flag_rounded,
        title: 'Tell us your goal',
        subtitle: 'Write the outcome and choose a deadline. That is enough to start.',
      ),
      const _StepData(
        icon: Icons.account_tree_rounded,
        title: 'Get tiny tasks',
        subtitle: 'Goal Digger turns the goal into clear actions you can finish today.',
      ),
      const _StepData(
        icon: Icons.trending_up_rounded,
        title: 'Track progress calmly',
        subtitle: 'See what is done, what is next, and how much time remains.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How it works', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        ...steps.map((step) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: ListTile(
                  minVerticalPadding: 18,
                  leading: CircleAvatar(
                    backgroundColor: gdPrimarySoft,
                    child: Icon(step.icon, color: gdPrimary),
                  ),
                  title: Text(
                    step.title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    step.subtitle,
                    style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

class _StepData {
  const _StepData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

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
                        activeThumbColor: gdPrimary,
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
    );
  }
}

class FocusCountdownDialog extends StatefulWidget {
  const FocusCountdownDialog({super.key, required this.config});

  final FocusSessionConfig config;

  @override
  State<FocusCountdownDialog> createState() => _FocusCountdownDialogState();
}

class _FocusCountdownDialogState extends State<FocusCountdownDialog> {
  late int _remainingSeconds;
  Timer? _timer;

  int get _totalSeconds => widget.config.durationMinutes * 60;
  bool get _isComplete => _remainingSeconds <= 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _totalSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _remainingSeconds = max(0, _remainingSeconds - 1);
      });
      if (_remainingSeconds == 0) timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
                  const CircleAvatar(
                    backgroundColor: gdPrimarySoft,
                    child: Icon(Icons.track_changes_rounded, color: gdPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isComplete ? 'Focus complete' : 'Focus mode',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Minimize focus timer',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PetAvatar(pet: defaultPet, size: 120),
                        const SizedBox(height: 22),
                        Text(
                          widget.config.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.config.blockingSummary,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: 230,
                          height: 230,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox.expand(
                                child: CircularProgressIndicator(
                                  value: progress.clamp(0.0, 1.0).toDouble(),
                                  strokeWidth: 14,
                                  backgroundColor: gdPrimarySoft,
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isComplete ? Icons.check_circle_rounded : Icons.track_changes_rounded,
                                    size: 34,
                                    color: gdPrimary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatTime(_remainingSeconds),
                                    style: const TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1.5,
                                      color: gdInk,
                                    ),
                                  ),
                                  Text(
                                    _isComplete ? 'Nice work' : 'Stay locked in',
                                    style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        AppCard(
                          color: gdSurface.withValues(alpha: 0.94),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.block_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Blocked during focus',
                                      style: TextStyle(fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (widget.config.blockedApps.isEmpty)
                                  const Text(
                                    'No apps selected.',
                                    style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
                                  )
                                else
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      for (final app in widget.config.blockedApps)
                                        Chip(
                                          avatar: const Icon(Icons.lock_rounded, size: 16),
                                          label: Text(app),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: _isComplete
                    ? FilledButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('Finish session'),
                      )
                    : OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        label: const Text('End focus session'),
                      ),
              ),
            ],
          ),
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
  });

  final int selectedIndex;
  final String signedInWith;
  final List<Widget> pages;
  final ValueChanged<int> onSelect;
  final VoidCallback onFocusMode;

  static const labels = ['Goals', 'Calendar', 'Home', 'Community', 'Pet'];
  static const icons = [
    Icons.flag_rounded,
    Icons.calendar_month_rounded,
    Icons.home_rounded,
    Icons.groups_rounded,
    Icons.pets_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Goal Digger'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              avatar: const Icon(Icons.verified_user_rounded, size: 18),
              label: Text(signedInWith),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              top: false,
              bottom: false,
              child: pages[selectedIndex],
            ),
          ),
          Positioned(
            right: 22,
            bottom: bottomInset + 124,
            child: FloatingActionButton(
              tooltip: 'Focus mode',
              onPressed: onFocusMode,
              backgroundColor: gdPrimary,
              foregroundColor: Colors.white,
              elevation: 8,
              child: const Icon(Icons.track_changes_rounded),
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: bottomInset + 4,
            child: _GoalBottomNavigation(
              labels: labels,
              icons: icons,
              selectedIndex: selectedIndex,
              onSelect: onSelect,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalBottomNavigation extends StatelessWidget {
  const _GoalBottomNavigation({
    required this.labels,
    required this.icons,
    required this.selectedIndex,
    required this.onSelect,
  });

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
            color: Colors.transparent,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Container(
              height: 88,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(
                color: gdSurface.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.13),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: gdOnDark.withValues(alpha: 0.55),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < labels.length; i++)
                    Expanded(
                      child: _BottomNavItem(
                        label: labels[i],
                        icon: icons[i],
                        selected: selectedIndex == i,
                        highlighted: i == 2,
                        onTap: () => onSelect(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.highlighted,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = highlighted
        ? gdOnDark
        : selected
            ? gdPrimary
            : gdMuted;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: SizedBox(
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: highlighted ? 48 : 38,
              height: highlighted ? 48 : 38,
              decoration: BoxDecoration(
                color: highlighted
                    ? gdPrimary
                    : selected
                        ? gdPrimarySoft
                        : Colors.transparent,
                shape: BoxShape.circle,
                border: highlighted && !selected
                    ? Border.all(color: gdPrimaryDark.withValues(alpha: 0.2), width: 2)
                    : null,
                boxShadow: highlighted
                    ? [
                        BoxShadow(
                          color: gdPrimary.withValues(alpha: 0.34),
                          blurRadius: 14,
                          offset: const Offset(0, 7),
                        ),
                      ]
                    : null,
              ),
              child: Icon(icon, color: color, size: highlighted ? 28 : 23),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: highlighted
                    ? gdPrimaryDark
                    : selected
                        ? gdPrimary
                        : gdMuted,
                fontSize: 11,
                fontWeight: highlighted || selected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
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
  final VoidCallback onCreateFirstGoal;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 112),
        children: [
          AppCard(
            color: gdPrimaryDark,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What goal do you want to make progress on?',
                              style: TextStyle(
                                color: gdOnDark,
                                fontSize: 26,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add one goal. Goal Digger will break it into small, scheduled steps.',
                              style: TextStyle(
                                color: gdOnDarkMuted,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      PetAvatar(pet: defaultPet, size: 76),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
                            fillColor: gdSurface,
                          ),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: goalController,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'Goal',
                            hintText: 'Example: Prepare for midterm',
                          ),
                          onSubmitted: (_) => onCreateGoal(),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: gdSurface,
                              ),
                              onPressed: onDeadlinePick,
                              icon: const Icon(Icons.event_rounded),
                              label: Text('Deadline: ${shortDate(deadline)}'),
                            ),
                            DropdownMenu<String>(
                              initialSelection: category,
                              label: const Text('Category'),
                              onSelected: (value) {
                                if (value != null) onCategoryChanged(value);
                              },
                              dropdownMenuEntries: [
                                for (final item in categories)
                                  DropdownMenuEntry(value: item, label: item),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        PrioritySelector(value: priority, onChanged: onPriorityChanged),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: isProcessing ? null : onCreateGoal,
                            icon: const Icon(Icons.auto_awesome_rounded),
                            label: const Text('Break down my goal'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isProcessing) ...[
            const SizedBox(height: 14),
            ProcessingProgressCard(
              progress: processingProgress,
              label: 'Creating your task plan',
            ),
          ],
          const SizedBox(height: 22),
          const HowItWorksSimple(),
          const SizedBox(height: 22),
          SectionTitle(title: 'Active goals', trailing: '${goals.length}'),
          const SizedBox(height: 10),
          if (goals.isEmpty)
            EmptyStateCard(
              icon: Icons.flag_circle_rounded,
              title: 'No goals yet',
              message:
                  'Create your first project and Goal Digger will turn it into small, scheduled actions.',
              cta: 'Create your first project',
              onPressed: onCreateFirstGoal,
            )
          else
            ...goals.map(
              (goal) => GoalCard(
                goal: goal,
                today: today,
                onDelete: () => onDeleteGoal(goal),
              ),
            ),
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
    required this.onToggleTask,
    required this.onCreateGoal,
  });

  final List<MicroTask> tasks;
  final GoalProject Function(MicroTask task) goalForTask;
  final DateTime today;
  final ValueChanged<MicroTask> onToggleTask;
  final VoidCallback onCreateGoal;

  @override
  State<_CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<_CalendarPage> {
  late DateTime _visibleMonth;
  late DateTime _selectedDate;
  final TextEditingController _routineController = TextEditingController();
  final List<String> _routines = ['Morning goal review', 'Evening reflection'];

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(widget.today.year, widget.today.month);
    _selectedDate = widget.today;
  }

  @override
  void dispose() {
    _routineController.dispose();
    super.dispose();
  }

  void _addRoutine() {
    final routine = _routineController.text.trim();
    if (routine.isEmpty) return;
    setState(() {
      _routines.add(routine);
      _routineController.clear();
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + offset);
      final daysInNewMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
      _selectedDate = DateTime(
        _visibleMonth.year,
        _visibleMonth.month,
        min(_selectedDate.day, daysInNewMonth),
      );
    });
  }

  List<DateTime?> _buildMonthCells() {
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month);
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leadingEmptyCells = firstDay.weekday % 7; // Sunday = 0, Monday = 1.
    final cells = <DateTime?>[
      ...List<DateTime?>.filled(leadingEmptyCells, null),
      for (var day = 1; day <= daysInMonth; day++)
        DateTime(_visibleMonth.year, _visibleMonth.month, day),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }

  List<MicroTask> _tasksForDay(DateTime date) {
    final day = dateOnly(date);
    final dayTasks = widget.tasks
        .where((task) => dateOnly(task.scheduledDate) == day)
        .toList()
      ..sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
    return dayTasks;
  }

  int _taskCountForDay(DateTime date) => _tasksForDay(date).length;

  @override
  Widget build(BuildContext context) {
    final monthTasks = widget.tasks
        .where(
          (task) =>
              task.scheduledDate.year == _visibleMonth.year &&
              task.scheduledDate.month == _visibleMonth.month,
        )
        .toList();
    final completedThisMonth = monthTasks.where((task) => task.done).length;
    final selectedTasks = _tasksForDay(_selectedDate);

    return PageScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 112),
        children: [
          const PageHero(
            icon: Icons.calendar_month_rounded,
            title: 'Calendar',
            subtitle:
                'See your goal tasks inside a month view. Open Home when you want to work on today’s goals.',
          ),
          const SizedBox(height: 18),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => _changeMonth(-1),
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${monthTasks.length} tasks · $completedThisMonth done',
                              style: const TextStyle(
                                color: gdMuted,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () => _changeMonth(1),
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      _WeekdayLabel('S'),
                      _WeekdayLabel('M'),
                      _WeekdayLabel('T'),
                      _WeekdayLabel('W'),
                      _WeekdayLabel('T'),
                      _WeekdayLabel('F'),
                      _WeekdayLabel('S'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    itemCount: _buildMonthCells().length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final date = _buildMonthCells()[index];
                      if (date == null) return const SizedBox.shrink();
                      final taskCount = _taskCountForDay(date);
                      return _CalendarDayCell(
                        date: date,
                        taskCount: taskCount,
                        completedCount: _tasksForDay(date).where((task) => task.done).length,
                        selected: dateOnly(date) == dateOnly(_selectedDate),
                        today: dateOnly(date) == widget.today,
                        onTap: () => setState(() => _selectedDate = date),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          AppCard(
            color: const Color(0xFFFFF4DF),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: selectedTasks.isEmpty ? const Color(0xFFE5E7EB) : gdPrimarySoft,
                    child: Icon(
                      selectedTasks.isEmpty ? Icons.event_available_rounded : Icons.task_alt_rounded,
                      color: selectedTasks.isEmpty ? gdMuted : gdPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          longDate(_selectedDate),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          selectedTasks.isEmpty
                              ? 'No goals scheduled on this date.'
                              : '${selectedTasks.length} scheduled goal actions on this date.',
                          style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (selectedTasks.isEmpty)
            EmptyStateCard(
              icon: Icons.event_available_rounded,
              title: 'No goals on this date',
              message: 'Pick another date with a dot, or create a new goal and Goal Digger will schedule it for you.',
              cta: 'Create goal',
              onPressed: widget.onCreateGoal,
            )
          else
            ...selectedTasks.map(
              (task) => _CalendarTaskDetailTile(
                task: task,
                goal: widget.goalForTask(task),
                onToggle: () => widget.onToggleTask(task),
              ),
            ),
          const SizedBox(height: 18),
          SectionTitle(title: 'Routines', trailing: '${_routines.length}'),
          const SizedBox(height: 10),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add a routine below the calendar',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Use routines for repeated habits like morning review, study blocks, or bedtime planning.',
                    style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _routineController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Routine name',
                      hintText: 'Example: 25-minute coding review',
                    ),
                    onSubmitted: (_) => _addRoutine(),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _addRoutine,
                      icon: const Icon(Icons.add_task_rounded),
                      label: const Text('Add routine'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final routine in _routines)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: gdPrimarySoft,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.repeat_rounded, size: 20, color: gdPrimary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              routine,
                              style: const TextStyle(fontWeight: FontWeight.w900, color: gdInk),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarTaskDetailTile extends StatelessWidget {
  const _CalendarTaskDetailTile({
    required this.task,
    required this.goal,
    required this.onToggle,
  });

  final MicroTask task;
  final GoalProject goal;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        minVerticalPadding: 12,
        leading: Checkbox(value: task.done, onChanged: (_) => onToggle()),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            decoration: task.done ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          '${goal.title} · ${task.durationMinutes} min · ${task.load.label}',
          style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
        ),
        trailing: CircleAvatar(
          backgroundColor: task.done ? gdPrimary : gdPrimarySoft,
          child: Icon(
            task.done ? Icons.check_rounded : task.load.icon,
            color: task.done ? gdSurface : gdPrimary,
            size: 20,
          ),
        ),
        onTap: onToggle,
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
                    : const Color(0xFFE5E7EB),
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

class _CommunityPage extends StatelessWidget {
  const _CommunityPage({
    required this.controller,
    required this.communities,
    required this.onAddCommunity,
  });

  final TextEditingController controller;
  final List<CommunityGroup> communities;
  final VoidCallback onAddCommunity;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 112),
        children: [
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PageHero(
                    icon: Icons.groups_rounded,
                    title: 'Find accountability',
                    subtitle:
                        'Join or create a group so progress feels social instead of lonely.',
                    compact: true,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Create a community',
                      hintText: 'Example: Midterm study group',
                    ),
                    onSubmitted: (_) => onAddCommunity(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onAddCommunity,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Create community'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          SectionTitle(title: 'Suggested groups', trailing: '${communities.length}'),
          const SizedBox(height: 10),
          if (communities.isEmpty)
            EmptyStateCard(
              icon: Icons.groups_2_rounded,
              title: 'No communities yet',
              message:
                  'Create your first group and invite people working toward similar goals.',
              cta: 'Create group',
              onPressed: onAddCommunity,
            )
          else
            ...communities.map(
              (group) => AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  minVerticalPadding: 16,
                  leading: const CircleAvatar(
                    backgroundColor: gdPrimarySoft,
                    child: Icon(Icons.groups_rounded, color: gdPrimary),
                  ),
                  title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(
                    '${group.members} members · ${group.tag}\n${group.description}',
                    style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w600),
                  ),
                  isThreeLine: true,
                  trailing: OutlinedButton(
                    onPressed: () {},
                    child: const Text('View'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CompanionPage extends StatelessWidget {
  const _CompanionPage({
    required this.coins,
    required this.happiness,
    required this.onFeed,
  });

  final int coins;
  final int happiness;
  final VoidCallback onFeed;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 112),
        children: [
          AppCard(
            color: gdPrimaryDark,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  PetAvatar(pet: defaultPet, size: 120),
                  const SizedBox(height: 16),
                  const Text(
                    'Your companion grows when you finish tasks.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: gdOnDark,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: happiness / 100,
                    minHeight: 10,
                    backgroundColor: Colors.white24,
                    color: const Color(0xFF5EEAD4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Happiness $happiness% · $coins coins',
                    style: const TextStyle(color: gdOnDarkMuted, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onFeed,
                      icon: const Icon(Icons.restaurant_rounded),
                      label: const Text('Feed companion -10 coins'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          SectionTitle(title: 'Rewards shop', trailing: 'Material icons'),
          const SizedBox(height: 10),
          const RewardTile(
            icon: Icons.lightbulb_rounded,
            title: 'Focus Lamp',
            subtitle: 'A clean, consistent Material icon style.',
            price: 80,
          ),
          const RewardTile(
            icon: Icons.bed_rounded,
            title: 'Cloud Bed',
            subtitle: 'Consistent iconography improves visual polish.',
            price: 120,
          ),
          const RewardTile(
            icon: Icons.backpack_rounded,
            title: 'Tiny Backpack',
            subtitle: 'No mixed emoji/icon libraries in dashboard cards.',
            price: 110,
          ),
        ],
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
                const Color(0xFFE0F2FE).withValues(alpha: 0.7),
                const Color(0xFFFCE7F3).withValues(alpha: 0.45),
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
            color: Colors.black.withValues(alpha: 0.06),
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
          colors: [gdPrimaryDark, gdPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gdPrimaryDark.withValues(alpha: 0.18),
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
          color: selected ? gdSurface : gdOnDark.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? gdOnDark : gdOnDark.withValues(alpha: 0.18),
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
              backgroundColor: const Color(0xFFE5E7EB),
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
        border: Border.all(color: gdError.withValues(alpha: 0.35)),
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
          style: TextStyle(color: gdOnDark, fontWeight: FontWeight.w900),
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
                    color: star <= value ? gdStarGold : gdOnDarkMuted.withValues(alpha: 0.72),
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
  });

  final GoalProject goal;
  final DateTime today;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final completed = goal.tasks.where((task) => task.done).length;
    final daysLeft = daysBetween(today, goal.deadline);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [goal.from, goal.to]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(goal.title, style: Theme.of(context).textTheme.titleLarge),
                    ),
                    Chip(label: Text(goal.category)),
                    IconButton(
                      tooltip: 'Remove goal',
                      onPressed: onDelete,
                      icon: const Icon(Icons.close_rounded, color: gdError),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    CircularProgressBadge(
                      progress: goal.progress,
                      label: '${(goal.progress * 100).round()}%',
                      size: 72,
                      strokeWidth: 7,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$completed/${goal.tasks.length} tasks done',
                            style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                daysLeft <= 2 ? Icons.warning_amber_rounded : Icons.event_rounded,
                                size: 18,
                                color: daysLeft <= 2 ? gdWarning : gdPrimary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                daysLeft < 0 ? 'Overdue' : '$daysLeft days left',
                                style: TextStyle(
                                  color: daysLeft <= 2 ? gdWarning : gdMuted,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 26),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final task in goal.tasks)
                      Chip(
                        avatar: Icon(task.load.icon, size: 18),
                        label: Text(task.title),
                        backgroundColor: task.done ? gdPrimarySoft : const Color(0xFFF3F4F6),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.goal,
    required this.onToggle,
  });

  final MicroTask task;
  final GoalProject goal;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final tip = task.load == TaskLoad.light
        ? 'Start here when energy is low. This task is intentionally small.'
        : task.load == TaskLoad.focus
            ? 'Block distractions and work on this single step first.'
            : 'This is a higher-effort step. Do it when you have enough time.';

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
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        decoration: task.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${goal.title} · ${shortDate(task.scheduledDate)} · ${task.durationMinutes} min · ${task.load.label}',
                      style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(task.load.icon, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            tip,
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
            color: pet.to.withValues(alpha: 0.34),
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
                color: pet.accent.withValues(alpha: 0.85),
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
                color: gdSurface.withValues(alpha: 0.94),
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
