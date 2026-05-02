import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const GoalDiggerApp());
}

/* -------------------------------------------------------------------------- */
/* DESIGN TOKENS                                                              */
/* -------------------------------------------------------------------------- */

const Color gdBackground = Color(0xFFF7F1E8);
const Color gdSurface = Color(0xFFFFFFFF);
const Color gdInk = Color(0xFF10201F);
const Color gdMuted = Color(0xFF4B5563); // darker than black54 for readability
const Color gdPrimary = Color(0xFF0F766E);
const Color gdPrimaryDark = Color(0xFF134E4A);
const Color gdPrimarySoft = Color(0xFFE0F2F1);
const Color gdWarning = Color(0xFFB45309);
const Color gdError = Color(0xFFB42318);
const Color gdErrorSoft = Color(0xFFFFF1F0);
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
        TextStyle(fontWeight: FontWeight.w800),
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
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: gdPrimary, width: 2),
      ),
      labelStyle: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
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
        side: const BorderSide(color: Color(0xFFD1D5DB)),
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
        return Icons.center_focus_strong_rounded;
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
      from: const Color(0xFF14B8A6),
      to: const Color(0xFF0EA5E9),
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
      from: const Color(0xFFF59E0B),
      to: const Color(0xFFEF4444),
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
  from: Color(0xFF7DD3FC),
  to: Color(0xFF34D399),
  accent: Color(0xFFD1FAE5),
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
  int _selectedIndex = 0;
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

  String _taskFilter = 'All';
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

  List<MicroTask> get _visibleTasks {
    final list = [..._allTasks];
    switch (_taskFilter) {
      case 'Today':
        return list.where((task) => dateOnly(task.scheduledDate) == today).toList();
      case 'High priority':
        return list.where((task) => _goalForTask(task).importance >= 4).toList();
      case 'Low energy':
        return list.where((task) => task.load == TaskLoad.light).toList();
      case 'Overdue':
        return list
            .where((task) => !task.done && task.scheduledDate.isBefore(today))
            .toList();
      case 'Completed':
        return list.where((task) => task.done).toList();
      default:
        return list;
    }
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
        from = const Color(0xFF06B6D4);
        to = const Color(0xFF2563EB);
        break;
      case 'Wellness':
        from = const Color(0xFFFB7185);
        to = const Color(0xFFE11D48);
        break;
      case 'Finance':
        from = const Color(0xFF22C55E);
        to = const Color(0xFF15803D);
        break;
      case 'Creative':
        from = const Color(0xFFA78BFA);
        to = const Color(0xFF7C3AED);
        break;
      default:
        from = const Color(0xFF14B8A6);
        to = const Color(0xFF0F766E);
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
      _selectedIndex = 1;
    });
    _showMessage('Goal created. Your first tasks are ready.');
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
        actionLabel: 'Go to tasks',
        onAction: () => setState(() => _selectedIndex = 1),
      );
      return;
    }
    setState(() {
      _coins -= 10;
      _petHappiness = min(100, _petHappiness + 12);
    });
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
      _TasksPage(
        filter: _taskFilter,
        visibleTasks: _visibleTasks,
        todayProgress: _todayProgress,
        todayCompleted: _todayCompleted,
        todayTotal: _todayTasks.length,
        remainingMinutes: _remainingMinutes,
        goalForTask: _goalForTask,
        onFilterChanged: (value) => setState(() => _taskFilter = value),
        onToggleTask: _toggleTask,
        onCreateGoal: () => setState(() => _selectedIndex = 0),
      ),
      _CalendarPage(
        tasks: _allTasks,
        goalForTask: _goalForTask,
        today: today,
        onToggleTask: _toggleTask,
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
/* RESPONSIVE NAVIGATION                                                      */
/* -------------------------------------------------------------------------- */

class ResponsiveGoalShell extends StatelessWidget {
  const ResponsiveGoalShell({
    super.key,
    required this.selectedIndex,
    required this.signedInWith,
    required this.pages,
    required this.onSelect,
  });

  final int selectedIndex;
  final String signedInWith;
  final List<Widget> pages;
  final ValueChanged<int> onSelect;

  static const labels = ['Planner', 'Tasks', 'Calendar', 'Community', 'Pet'];
  static const icons = [
    Icons.auto_awesome_rounded,
    Icons.check_circle_rounded,
    Icons.calendar_month_rounded,
    Icons.groups_rounded,
    Icons.pets_rounded,
  ];

  static const selectedIcons = [
    Icons.auto_awesome,
    Icons.check_circle,
    Icons.calendar_month,
    Icons.groups,
    Icons.pets,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SafeArea(
        top: false,
        child: pages[selectedIndex],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onSelect,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            for (var i = 0; i < labels.length; i++)
              NavigationDestination(
                icon: Icon(icons[i]),
                selectedIcon: Icon(selectedIcons[i]),
                label: labels[i],
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
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
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
                                color: Colors.white,
                                fontSize: 26,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add one goal. Goal Digger will break it into small, scheduled steps.',
                              style: TextStyle(
                                color: Color(0xFFD1FAE5),
                                fontWeight: FontWeight.w700,
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
                            fillColor: Colors.white,
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
                                backgroundColor: Colors.white,
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
    required this.filter,
    required this.visibleTasks,
    required this.todayProgress,
    required this.todayCompleted,
    required this.todayTotal,
    required this.remainingMinutes,
    required this.goalForTask,
    required this.onFilterChanged,
    required this.onToggleTask,
    required this.onCreateGoal,
  });

  final String filter;
  final List<MicroTask> visibleTasks;
  final double todayProgress;
  final int todayCompleted;
  final int todayTotal;
  final int remainingMinutes;
  final GoalProject Function(MicroTask task) goalForTask;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<MicroTask> onToggleTask;
  final VoidCallback onCreateGoal;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        children: [
          TodayProgressCard(
            progress: todayProgress,
            completed: todayCompleted,
            total: todayTotal,
            remainingMinutes: remainingMinutes,
          ),
          const SizedBox(height: 18),
          SectionTitle(title: 'Tasks', trailing: filter),
          const SizedBox(height: 10),
          VisibleFilterBar(selected: filter, onChanged: onFilterChanged),
          const SizedBox(height: 14),
          if (visibleTasks.isEmpty)
            EmptyStateCard(
              icon: Icons.check_circle_outline_rounded,
              title: 'No tasks found',
              message:
                  'Try another filter, or create a new goal to generate fresh micro-tasks.',
              cta: 'Create goal',
              onPressed: onCreateGoal,
            )
          else
            ...visibleTasks.map(
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

class _CalendarPage extends StatelessWidget {
  const _CalendarPage({
    required this.tasks,
    required this.goalForTask,
    required this.today,
    required this.onToggleTask,
  });

  final List<MicroTask> tasks;
  final GoalProject Function(MicroTask task) goalForTask;
  final DateTime today;
  final ValueChanged<MicroTask> onToggleTask;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<MicroTask>>{};
    for (final task in tasks) {
      grouped.putIfAbsent(dateKey(task.scheduledDate), () => []).add(task);
    }
    final keys = grouped.keys.toList()..sort();

    return PageScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        children: [
          const PageHero(
            icon: Icons.calendar_month_rounded,
            title: 'Schedule',
            subtitle:
                'Tasks are grouped by date so users can see what is coming next without digging through menus.',
          ),
          const SizedBox(height: 18),
          if (keys.isEmpty)
            EmptyStateCard(
              icon: Icons.event_busy_rounded,
              title: 'No scheduled tasks',
              message: 'Create a goal first, then your generated steps will appear here.',
              cta: 'Go to planner',
              onPressed: () {},
            )
          else
            ...keys.map((key) {
              final groupTasks = grouped[key]!;
              final date = groupTasks.first.scheduledDate;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(
                    title: dateOnly(date) == today ? 'Today' : longDate(date),
                    trailing: '${groupTasks.length} tasks',
                  ),
                  const SizedBox(height: 10),
                  ...groupTasks.map(
                    (task) => TaskCard(
                      task: task,
                      goal: goalForTask(task),
                      onToggle: () => onToggleTask(task),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }),
        ],
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
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
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
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
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
                      color: Colors.white,
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
                    style: const TextStyle(color: Color(0xFFD1FAE5), fontWeight: FontWeight.w900),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.hourglass_top_rounded),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(label, style: Theme.of(context).textTheme.titleMedium),
                ),
                Text('$percent%', style: const TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: safeProgress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(999),
            ),
            const SizedBox(height: 10),
            Text(
              secondsRemaining == 0
                  ? 'Almost ready...'
                  : 'About $secondsRemaining seconds remaining',
              style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
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
    final percent = (progress * 100).round();
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: gdPrimarySoft,
                  child: Icon(Icons.trending_up_rounded, color: gdPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Today’s progress',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0).toDouble(),
              minHeight: 12,
              borderRadius: BorderRadius.circular(999),
            ),
            const SizedBox(height: 10),
            Text(
              '$completed/$total done · $percent% complete · about $remainingMinutes minutes left',
              style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class VisibleFilterBar extends StatelessWidget {
  const VisibleFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const filters = ['All', 'Today', 'High priority', 'Low energy', 'Overdue', 'Completed'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in filters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: selected == filter,
                onSelected: (_) => onChanged(filter),
                showCheckmark: false,
                avatar: Icon(_filterIcon(filter), size: 18),
              ),
            ),
        ],
      ),
    );
  }

  IconData _filterIcon(String filter) {
    switch (filter) {
      case 'Today':
        return Icons.today_rounded;
      case 'High priority':
        return Icons.priority_high_rounded;
      case 'Low energy':
        return Icons.spa_rounded;
      case 'Overdue':
        return Icons.warning_amber_rounded;
      case 'Completed':
        return Icons.done_all_rounded;
      default:
        return Icons.filter_alt_rounded;
    }
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
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
                    color: star <= value ? const Color(0xFFFBBF24) : Colors.white60,
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
                LinearProgressIndicator(
                  value: goal.progress.clamp(0.0, 1.0).toDouble(),
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(999),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '$completed/${goal.tasks.length} tasks done',
                      style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
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
                color: Colors.white.withOpacity(0.92),
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
