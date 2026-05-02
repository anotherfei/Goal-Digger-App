import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const GoalDiggerApp());
}

class GoalDiggerApp extends StatelessWidget {
  const GoalDiggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goal Digger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F1E8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF14B8A6),
          brightness: Brightness.light,
        ),
        fontFamily: 'Arial',
      ),
      home: const GoalDiggerHome(),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                   MODELS                                   */
/* -------------------------------------------------------------------------- */

enum TaskLoad { light, focus, stretch }

extension TaskLoadLabel on TaskLoad {
  String get label {
    switch (this) {
      case TaskLoad.light:
        return 'light';
      case TaskLoad.focus:
        return 'focus';
      case TaskLoad.stretch:
        return 'stretch';
    }
  }
}

class MicroTask {
  int id;
  String title;
  int goalId;
  String duration;
  TaskLoad load;
  bool done;
  int points;
  DateTime scheduledDate;

  MicroTask({
    required this.id,
    required this.title,
    required this.goalId,
    required this.duration,
    required this.load,
    required this.done,
    required this.points,
    required this.scheduledDate,
  });

  int get minutes {
    final match = RegExp(r'\d+').firstMatch(duration);
    return int.tryParse(match?.group(0) ?? '10') ?? 10;
  }
}

class Goal {
  int id;
  String title;
  int importance;
  String category;
  DateTime deadline;
  Color from;
  Color to;
  List<MicroTask> subtasks;

  Goal({
    required this.id,
    required this.title,
    required this.importance,
    required this.category,
    required this.deadline,
    required this.from,
    required this.to,
    required this.subtasks,
  });
}

class Routine {
  int id;
  String title;
  String time;
  String frequency;

  Routine({
    required this.id,
    required this.title,
    required this.time,
    required this.frequency,
  });
}

class FriendInfo {
  String name;
  String status;
  Color color;

  FriendInfo({
    required this.name,
    required this.status,
    required this.color,
  });
}

class FriendSuggestion {
  String name;
  int? compatibility;
  String avatar;

  FriendSuggestion({
    required this.name,
    required this.compatibility,
    required this.avatar,
  });
}

class CommunityInfo {
  String name;
  int members;
  String tag;
  String creator;
  String created;
  String about;

  CommunityInfo({
    required this.name,
    required this.members,
    required this.tag,
    required this.creator,
    required this.created,
    required this.about,
  });
}

class PetSkin {
  String id;
  String name;
  Color from;
  Color to;
  Color accent;

  PetSkin({
    required this.id,
    required this.name,
    required this.from,
    required this.to,
    required this.accent,
  });
}

class FocusApp {
  String name;
  String icon;
  bool allowed;

  FocusApp({
    required this.name,
    required this.icon,
    required this.allowed,
  });
}

class ShopItem {
  String name;
  int price;
  String note;
  String image;
  String type;

  ShopItem({
    required this.name,
    required this.price,
    required this.note,
    required this.image,
    required this.type,
  });
}

/* -------------------------------------------------------------------------- */
/*                                  HELPERS                                   */
/* -------------------------------------------------------------------------- */

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime addDays(DateTime d, int days) {
  return dateOnly(d).add(Duration(days: days));
}

int daysBetween(DateTime from, DateTime to) {
  return dateOnly(to).difference(dateOnly(from)).inDays;
}

String two(int n) => n.toString().padLeft(2, '0');

const monthNames = [
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

String shortDate(DateTime d) => '${monthNames[d.month - 1]} ${d.day}';

String longDate(DateTime d) {
  return '${monthNames[d.month - 1]} ${d.day}, ${d.year}';
}

/* -------------------------------------------------------------------------- */
/*                                  SEED DATA                                 */
/* -------------------------------------------------------------------------- */

final categories = [
  'Career',
  'Study',
  'Work',
  'Wellness',
  'Hobby',
  'Creative',
  'Family',
  'Finance',
  'Other',
];

List<Goal> seedGoals() {
  return [
    Goal(
      id: 1,
      title: 'Launch portfolio',
      importance: 5,
      category: 'Career',
      deadline: DateTime(2026, 4, 22),
      from: const Color(0xFF2DD4BF),
      to: const Color(0xFF10B981),
      subtasks: [
        MicroTask(
          id: 101,
          title: 'Draft project outline',
          goalId: 1,
          duration: '12 min',
          load: TaskLoad.focus,
          done: false,
          points: 20,
          scheduledDate: DateTime(2026, 4, 15),
        ),
        MicroTask(
          id: 102,
          title: 'Sketch homepage layout',
          goalId: 1,
          duration: '15 min',
          load: TaskLoad.focus,
          done: false,
          points: 20,
          scheduledDate: DateTime(2026, 4, 16),
        ),
        MicroTask(
          id: 103,
          title: 'Write project descriptions',
          goalId: 1,
          duration: '20 min',
          load: TaskLoad.stretch,
          done: false,
          points: 25,
          scheduledDate: DateTime(2026, 4, 17),
        ),
        MicroTask(
          id: 104,
          title: 'Choose color palette',
          goalId: 1,
          duration: '8 min',
          load: TaskLoad.light,
          done: false,
          points: 10,
          scheduledDate: DateTime(2026, 4, 18),
        ),
        MicroTask(
          id: 105,
          title: 'Build hero section',
          goalId: 1,
          duration: '25 min',
          load: TaskLoad.stretch,
          done: false,
          points: 30,
          scheduledDate: DateTime(2026, 4, 19),
        ),
        MicroTask(
          id: 106,
          title: 'Deploy first draft',
          goalId: 1,
          duration: '20 min',
          load: TaskLoad.focus,
          done: false,
          points: 25,
          scheduledDate: DateTime(2026, 4, 21),
        ),
      ],
    ),
    Goal(
      id: 2,
      title: 'Exam prep',
      importance: 4,
      category: 'Study',
      deadline: DateTime(2026, 4, 28),
      from: const Color(0xFFFBBF24),
      to: const Color(0xFFF97316),
      subtasks: [
        MicroTask(
          id: 201,
          title: 'Review chapter 3 notes',
          goalId: 2,
          duration: '8 min',
          load: TaskLoad.light,
          done: true,
          points: 10,
          scheduledDate: DateTime(2026, 4, 14),
        ),
        MicroTask(
          id: 202,
          title: 'Solve 5 practice problems',
          goalId: 2,
          duration: '15 min',
          load: TaskLoad.focus,
          done: false,
          points: 20,
          scheduledDate: DateTime(2026, 4, 15),
        ),
        MicroTask(
          id: 203,
          title: 'Make flashcards (chapter 4)',
          goalId: 2,
          duration: '12 min',
          load: TaskLoad.focus,
          done: false,
          points: 15,
          scheduledDate: DateTime(2026, 4, 17),
        ),
        MicroTask(
          id: 204,
          title: 'Mock exam timed',
          goalId: 2,
          duration: '30 min',
          load: TaskLoad.stretch,
          done: false,
          points: 35,
          scheduledDate: DateTime(2026, 4, 20),
        ),
        MicroTask(
          id: 205,
          title: 'Review weak topics',
          goalId: 2,
          duration: '15 min',
          load: TaskLoad.focus,
          done: false,
          points: 20,
          scheduledDate: DateTime(2026, 4, 24),
        ),
      ],
    ),
    Goal(
      id: 3,
      title: 'Team comms',
      importance: 2,
      category: 'Work',
      deadline: DateTime(2026, 4, 30),
      from: const Color(0xFFA78BFA),
      to: const Color(0xFF8B5CF6),
      subtasks: [
        MicroTask(
          id: 301,
          title: 'Send weekly update',
          goalId: 3,
          duration: '5 min',
          load: TaskLoad.light,
          done: false,
          points: 10,
          scheduledDate: DateTime(2026, 4, 15),
        ),
        MicroTask(
          id: 302,
          title: 'Reply to pending DMs',
          goalId: 3,
          duration: '10 min',
          load: TaskLoad.light,
          done: false,
          points: 10,
          scheduledDate: DateTime(2026, 4, 18),
        ),
        MicroTask(
          id: 303,
          title: 'Schedule sync meeting',
          goalId: 3,
          duration: '5 min',
          load: TaskLoad.light,
          done: false,
          points: 10,
          scheduledDate: DateTime(2026, 4, 22),
        ),
      ],
    ),
    Goal(
      id: 4,
      title: 'Build consistency',
      importance: 3,
      category: 'Wellness',
      deadline: DateTime(2026, 5, 5),
      from: const Color(0xFFFB7185),
      to: const Color(0xFFEC4899),
      subtasks: [
        MicroTask(
          id: 401,
          title: 'Choose next practice problem',
          goalId: 4,
          duration: '10 min',
          load: TaskLoad.stretch,
          done: false,
          points: 15,
          scheduledDate: DateTime(2026, 4, 15),
        ),
        MicroTask(
          id: 402,
          title: 'Journal 3 wins',
          goalId: 4,
          duration: '5 min',
          load: TaskLoad.light,
          done: false,
          points: 10,
          scheduledDate: DateTime(2026, 4, 16),
        ),
        MicroTask(
          id: 403,
          title: 'Reflect on the week',
          goalId: 4,
          duration: '10 min',
          load: TaskLoad.light,
          done: false,
          points: 10,
          scheduledDate: DateTime(2026, 4, 21),
        ),
        MicroTask(
          id: 404,
          title: 'Plan May routine',
          goalId: 4,
          duration: '15 min',
          load: TaskLoad.focus,
          done: false,
          points: 20,
          scheduledDate: DateTime(2026, 5, 2),
        ),
      ],
    ),
  ];
}

final taskStartTips = <String, String>{
  'Draft project outline':
      "Open a blank doc. Write: problem, audience, 3 projects, contact. Don't aim for perfect — just capture the core idea.",
  'Sketch homepage layout':
      "Use paper or a whiteboard. Draw 3 boxes: hero, about, projects. You're deciding order, not designing yet.",
  'Write project descriptions':
      'For each project write: 1 sentence what it does, 1 sentence why it matters.',
  'Choose color palette':
      "Go to coolors.co, hit spacebar 5 times, and pick one. Don't overthink it.",
  'Build hero section':
      'Copy a hero section you like. Replace the text and image. Start ugly, refine later.',
  'Deploy first draft':
      'Use Vercel, Netlify, or GitHub Pages. Ship imperfect.',
  'Solve 5 practice problems':
      "Pick problems you're 70% confident about. Write the solution before checking.",
  'Make flashcards (chapter 4)':
      'One concept per card. Use questions on front, answers on back.',
  'Mock exam timed':
      'Set a timer for 30 min. Close everything else. If stuck, skip and return.',
  'Review weak topics':
      'Look at your last test errors. Re-read only those sections.',
  'Send weekly update':
      "Template: Here's what I did, here's what's next, here's where I need help.",
  'Reply to pending DMs':
      'Batch reply from oldest to newest. Keep each reply under 3 sentences.',
  'Schedule sync meeting':
      "Send 2 time options. Don't over-negotiate.",
  'Choose next practice problem':
      "Pick one that scares you a little. Set a 10-min attempt limit.",
  'Journal 3 wins':
      "Write 3 things you did today. 'I showed up' counts.",
  'Reflect on the week':
      "Answer: What worked? What didn't? What will I try differently?",
};

final routinesSeed = [
  Routine(id: 1, title: 'Morning stretch', time: '07:00', frequency: 'Daily'),
  Routine(id: 2, title: 'Drink water', time: '07:15', frequency: 'Daily'),
  Routine(id: 3, title: 'Read 10 pages', time: '21:00', frequency: 'Weekly'),
];

final friendsSeed = [
  FriendInfo(
    name: 'Sam',
    status: 'Finished 3 tiny wins',
    color: const Color(0xFF38BDF8),
  ),
  FriendInfo(
    name: 'Lee',
    status: 'Needs a gentle nudge',
    color: const Color(0xFFFBBF24),
  ),
  FriendInfo(
    name: 'Zoe',
    status: 'Planning tomorrow',
    color: const Color(0xFFA78BFA),
  ),
];

final friendSuggestionsSeed = [
  FriendSuggestion(name: 'Alex K.', compatibility: 90, avatar: 'AK'),
  FriendSuggestion(name: 'Mira S.', compatibility: 72, avatar: 'MS'),
  FriendSuggestion(name: 'Dev P.', compatibility: 56, avatar: 'DP'),
  FriendSuggestion(name: 'Luna R.', compatibility: 23, avatar: 'LR'),
  FriendSuggestion(name: 'New User', compatibility: null, avatar: '??'),
];

final communitiesSeed = [
  CommunityInfo(
    name: 'Portfolio Builders',
    members: 142,
    tag: 'They build portfolios like you',
    creator: 'Maya Chen',
    created: 'Apr 2026',
    about: 'Portfolio builders sharing weekly reviews and design feedback.',
  ),
  CommunityInfo(
    name: 'Study Sprint Club',
    members: 89,
    tag: 'Exam prep community',
    creator: 'Dr. Noor',
    created: 'Mar 2026',
    about: 'Focused study sprints for students preparing for exams.',
  ),
  CommunityInfo(
    name: 'Consistency Crew',
    members: 234,
    tag: 'Looking for habit trackers',
    creator: 'Ari Reed',
    created: 'Feb 2026',
    about: 'Gentle accountability for daily routines and tiny wins.',
  ),
  CommunityInfo(
    name: 'Creative Side Hustle',
    members: 67,
    tag: 'Needs designers & writers',
    creator: 'Zoe Park',
    created: 'Apr 2026',
    about: 'Creative workers building side projects after school or work.',
  ),
];

final petSkins = [
  PetSkin(
    id: 'mint',
    name: 'Mint',
    from: const Color(0xFF7DD3FC),
    to: const Color(0xFF34D399),
    accent: const Color(0xFFD1FAE5),
  ),
  PetSkin(
    id: 'peach',
    name: 'Peach',
    from: const Color(0xFFFDBA74),
    to: const Color(0xFFFB7185),
    accent: const Color(0xFFFFEDD5),
  ),
  PetSkin(
    id: 'lunar',
    name: 'Lunar',
    from: const Color(0xFFA78BFA),
    to: const Color(0xFF475569),
    accent: const Color(0xFFEDE9FE),
  ),
];

final shopItems = [
  ShopItem(
    name: 'Cloud Bed',
    price: 120,
    note: 'Rest bonus',
    image: '☁️',
    type: 'Furniture',
  ),
  ShopItem(
    name: 'Focus Lamp',
    price: 80,
    note: 'Deep work glow',
    image: '💡',
    type: 'Room',
  ),
  ShopItem(
    name: 'Trail Cape',
    price: 150,
    note: 'Streak style',
    image: '🧣',
    type: 'Costume',
  ),
  ShopItem(
    name: 'Star Hat',
    price: 95,
    note: 'Motivation charm',
    image: '⭐',
    type: 'Costume',
  ),
  ShopItem(
    name: 'Tiny Backpack',
    price: 110,
    note: 'Adventure gear',
    image: '🎒',
    type: 'Costume',
  ),
  ShopItem(
    name: 'Snack Bowl',
    price: 70,
    note: 'Happy pet boost',
    image: '🥣',
    type: 'Food',
  ),
];

final focusAppsSeed = [
  FocusApp(name: 'Notes', icon: '📝', allowed: true),
  FocusApp(name: 'Music', icon: '🎵', allowed: true),
  FocusApp(name: 'Browser', icon: '🌐', allowed: false),
  FocusApp(name: 'Messages', icon: '💬', allowed: false),
  FocusApp(name: 'Calculator', icon: '🧮', allowed: true),
  FocusApp(name: 'Social', icon: '📱', allowed: false),
];

const moodMode = {
  'great': 'high',
  'okay': 'steady',
  'tired': 'low',
};

const adaptiveMessages = {
  'low':
      "Low energy detected. I'm prioritizing only your most important goals and shrinking each task to ≤8 min.",
  'steady':
      'Steady energy. Balanced mix: 1 stretch task + light wins from your top-priority goals.',
  'high':
      "High energy! I'm front-loading stretch tasks from your highest-importance goals.",
};

/* -------------------------------------------------------------------------- */
/*                                  MAIN PAGE                                 */
/* -------------------------------------------------------------------------- */

class GoalDiggerHome extends StatefulWidget {
  const GoalDiggerHome({super.key});

  @override
  State<GoalDiggerHome> createState() => _GoalDiggerHomeState();
}

class _GoalDiggerHomeState extends State<GoalDiggerHome> {
  final DateTime today = dateOnly(DateTime.now());

  int tabIndex = 0;

  late List<Goal> goals;
  late List<int> todayTaskIds;

  String energyMode = 'steady';
  String mood = 'okay';
  String adaptiveMessage = adaptiveMessages['steady']!;

  String selectedPetId = 'mint';
  int petHunger = 35;
  int petCoins = 430;

  late List<FocusApp> focusApps;

  int focusSeconds = 0;
  int focusDurationSeconds = 1500;
  bool focusRunning = false;
  Timer? focusTimer;
  String customFocusMinutes = '';
  int? selectedFocusTaskId;

  String newGoalTitle = 'Become a YouTuber';
  int newGoalImportance = 3;
  String newGoalCategory = 'Hobby';
  late DateTime newGoalDeadline;

  late List<Routine> routines;
  bool showAddRoutine = false;
  String newRoutineName = '';
  String newRoutineTime = '08:00';
  String newRoutineFrequency = 'Daily';
  String newRoutineCustom = '';

  late DateTime selectedDay;
  late int viewYear;
  late int viewMonth;

  late List<FriendInfo> myFriends;
  late List<FriendSuggestion> friendSuggestions;
  late List<CommunityInfo> myCommunities;
  late List<CommunityInfo> communitySuggestions;
  String joinGroupInput = '';

  int? expandedTaskId;

  @override
  void initState() {
    super.initState();

    goals = seedGoals();
    newGoalDeadline = addDays(today, 14);

    routines = routinesSeed
        .map(
          (r) => Routine(
            id: r.id,
            title: r.title,
            time: r.time,
            frequency: r.frequency,
          ),
        )
        .toList();

    focusApps = focusAppsSeed
        .map(
          (a) => FocusApp(name: a.name, icon: a.icon, allowed: a.allowed),
        )
        .toList();

    myFriends = friendsSeed
        .map(
          (f) => FriendInfo(name: f.name, status: f.status, color: f.color),
        )
        .toList();

    friendSuggestions = friendSuggestionsSeed
        .map(
          (f) => FriendSuggestion(
            name: f.name,
            compatibility: f.compatibility,
            avatar: f.avatar,
          ),
        )
        .toList();

    myCommunities = [communitiesSeed.first];

    communitySuggestions = communitiesSeed
        .where((c) => c.name != communitiesSeed.first.name)
        .map(
          (c) => CommunityInfo(
            name: c.name,
            members: c.members,
            tag: c.tag,
            creator: c.creator,
            created: c.created,
            about: c.about,
          ),
        )
        .toList();

    selectedDay = today;
    viewYear = today.year;
    viewMonth = today.month;

    todayTaskIds = suggestedTasks(goals, energyMode).map((t) => t.id).toList();
  }

  @override
  void dispose() {
    focusTimer?.cancel();
    super.dispose();
  }

  PetSkin get activePet {
    return petSkins.firstWhere(
      (p) => p.id == selectedPetId,
      orElse: () => petSkins.first,
    );
  }

  List<MicroTask> get allTasks {
    return goals.expand((g) => g.subtasks).toList();
  }

  List<MicroTask> get todayTasks {
    return todayTaskIds
        .map((id) => findTask(id))
        .whereType<MicroTask>()
        .toList();
  }

  int get todayCompleted => todayTasks.where((t) => t.done).length;

  int get todayCompletion {
    if (todayTasks.isEmpty) return 100;
    return ((todayCompleted / todayTasks.length) * 100).round();
  }

  int get earnedPoints {
    return todayTasks.where((t) => t.done).fold(0, (sum, t) => sum + t.points);
  }

  MicroTask? findTask(int id, [List<Goal>? source]) {
    final list = source ?? goals;
    for (final goal in list) {
      for (final task in goal.subtasks) {
        if (task.id == id) return task;
      }
    }
    return null;
  }

  Goal? findGoal(int id, [List<Goal>? source]) {
    final list = source ?? goals;
    for (final goal in list) {
      if (goal.id == id) return goal;
    }
    return null;
  }

  double scoreTask(MicroTask task, Goal goal, String mode) {
    final daysToDeadline = max(1, daysBetween(today, goal.deadline));
    final daysToTask = daysBetween(today, task.scheduledDate);

    final dateBonus = daysToTask == 0
        ? 5.0
        : daysToTask < 0
            ? 3.0
            : max(0, 4 - daysToTask).toDouble();

    double loadBonus;
    if (mode == 'low') {
      loadBonus = task.load == TaskLoad.light
          ? 4
          : task.load == TaskLoad.focus
              ? 1
              : -3;
    } else if (mode == 'high') {
      loadBonus = task.load == TaskLoad.stretch
          ? 4
          : task.load == TaskLoad.focus
              ? 2
              : 1;
    } else {
      loadBonus = 2;
    }

    return goal.importance * 2 + 10 / daysToDeadline + dateBonus + loadBonus;
  }

  List<MicroTask> suggestedTasks(List<Goal> sourceGoals, String mode) {
    final incomplete = sourceGoals
        .expand((goal) => goal.subtasks.where((task) => !task.done))
        .toList();

    final limit = mode == 'low'
        ? 2
        : mode == 'steady'
            ? 4
            : 5;

    incomplete.sort((a, b) {
      final goalA = findGoal(a.goalId, sourceGoals)!;
      final goalB = findGoal(b.goalId, sourceGoals)!;
      return scoreTask(b, goalB, mode).compareTo(scoreTask(a, goalA, mode));
    });

    return incomplete.take(limit).toList();
  }

  void reseedTodayTasks(String mode, [List<Goal>? source]) {
    final src = source ?? goals;
    final doneAlready = todayTaskIds.where((id) {
      final task = findTask(id, src);
      return task?.done == true;
    }).toList();

    final suggestions = suggestedTasks(src, mode);

    final next = [...doneAlready];
    for (final task in suggestions) {
      if (!next.contains(task.id)) next.add(task.id);
    }

    todayTaskIds = next;
  }

  void toggleTask(int taskId) {
    setState(() {
      final task = findTask(taskId);
      if (task == null) return;

      if (task.done) {
        petHunger = max(0, petHunger - 15);
        petCoins = max(0, petCoins - task.points);
      } else {
        petHunger = min(100, petHunger + 15);
        petCoins += task.points;
      }

      task.done = !task.done;
    });
  }

  void selectMood(String nextMood) {
    setState(() {
      final requestedMode = moodMode[nextMood] ?? 'steady';

      final urgentUndoneCount = goals
          .where((g) => daysBetween(today, g.deadline) <= 1)
          .fold<int>(
            0,
            (sum, g) => sum + g.subtasks.where((t) => !t.done).length,
          );

      final finalMode =
          requestedMode == 'low' && urgentUndoneCount > 2 ? 'steady' : requestedMode;

      mood = nextMood;
      energyMode = finalMode;

      adaptiveMessage = requestedMode == 'low' && urgentUndoneCount > 2
          ? 'I hear that energy is low, but a deadline is very close. I kept the urgent tasks and made the approach gentler instead of removing them.'
          : adaptiveMessages[finalMode]!;

      reseedTodayTasks(finalMode);
    });
  }

  void addGoal() {
    if (newGoalTitle.trim().isEmpty) return;

    setState(() {
      final lower = newGoalTitle.trim().toLowerCase();

      final titles = lower == 'become a youtuber'
          ? [
              'Write first script',
              'Film pilot video',
              'Edit and add effects',
              'Review and publish',
            ]
          : [
              'Research the topic',
              'Create a plan outline',
              'Execute first step',
              'Review and iterate',
            ];

      final nextId = goals.map((g) => g.id).fold(0, max) + 1;

      final goal = Goal(
        id: nextId,
        title: newGoalTitle.trim(),
        importance: newGoalImportance,
        category: newGoalCategory,
        deadline: newGoalDeadline,
        from: const Color(0xFF22D3EE),
        to: const Color(0xFF3B82F6),
        subtasks: titles.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;

          return MicroTask(
            id: nextId * 100 + index,
            title: title,
            goalId: nextId,
            duration: '10 min',
            load: index == titles.length - 1 ? TaskLoad.stretch : TaskLoad.focus,
            done: false,
            points: 15,
            scheduledDate: addDays(today, index + 1),
          );
        }).toList(),
      );

      goals = [...goals, goal];
      reseedTodayTasks(energyMode, goals);
      newGoalTitle = '';
    });

    showMessage('Goal broken into micro-tasks and scheduled.');
  }

  void removeGoal(int goalId) {
    setState(() {
      final removed = goals.firstWhere((g) => g.id == goalId);
      final removedTaskIds = removed.subtasks.map((t) => t.id).toSet();

      goals = goals.where((g) => g.id != goalId).toList();
      todayTaskIds = todayTaskIds.where((id) => !removedTaskIds.contains(id)).toList();
    });
  }

  void swapTask(int oldTaskId) {
    setState(() {
      final blocked = todayTaskIds.toSet();
      final candidates = allTasks.where((t) {
        return !t.done && !blocked.contains(t.id) && t.id != oldTaskId;
      }).toList();

      if (candidates.isEmpty) return;

      candidates.sort((a, b) {
        final ga = findGoal(a.goalId)!;
        final gb = findGoal(b.goalId)!;
        return scoreTask(b, gb, energyMode).compareTo(scoreTask(a, ga, energyMode));
      });

      final replacement = candidates.first;
      todayTaskIds = todayTaskIds
          .map((id) => id == oldTaskId ? replacement.id : id)
          .toList();
    });
  }

  void addMoreTask() {
    setState(() {
      final blocked = todayTaskIds.toSet();
      final candidates = allTasks.where((t) => !t.done && !blocked.contains(t.id)).toList();

      if (candidates.isEmpty) return;

      candidates.sort((a, b) {
        final ga = findGoal(a.goalId)!;
        final gb = findGoal(b.goalId)!;
        return scoreTask(b, gb, energyMode).compareTo(scoreTask(a, ga, energyMode));
      });

      todayTaskIds.add(candidates.first.id);
    });
  }

  void feedPet() {
    setState(() {
      if (earnedPoints >= 10 && petHunger < 100) {
        petHunger = min(100, petHunger + 20);
        petCoins = max(0, petCoins - 10);
      }
    });
  }

  void startFocus() {
    setState(() {
      final custom = int.tryParse(customFocusMinutes.trim());

      if (custom != null && custom > 0) {
        focusDurationSeconds = custom * 60;
      } else if (selectedFocusTaskId != null) {
        final task = findTask(selectedFocusTaskId!);
        if (task != null) focusDurationSeconds = task.minutes * 60;
      }

      focusSeconds = 0;
      focusRunning = true;
    });

    focusTimer?.cancel();
    focusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        if (focusSeconds >= focusDurationSeconds - 1) {
          focusSeconds = focusDurationSeconds;
          focusRunning = false;
          timer.cancel();
          showMessage('Focus session complete.');
        } else {
          focusSeconds += 1;
        }
      });
    });
  }

  void stopFocus() {
    focusTimer?.cancel();
    setState(() {
      focusRunning = false;
      focusSeconds = 0;
    });
  }

  void addRoutine() {
    final title = newRoutineName.trim();
    if (title.isEmpty) return;

    setState(() {
      final frequency =
          newRoutineFrequency == 'Custom' && newRoutineCustom.trim().isNotEmpty
              ? newRoutineCustom.trim()
              : newRoutineFrequency;

      final nextId = routines.map((r) => r.id).fold(0, max) + 1;

      routines.add(
        Routine(
          id: nextId,
          title: title,
          time: newRoutineTime,
          frequency: frequency,
        ),
      );

      newRoutineName = '';
      newRoutineCustom = '';
      showAddRoutine = false;
    });
  }

  void addFriend(FriendSuggestion suggestion) {
    setState(() {
      if (!myFriends.any((f) => f.name == suggestion.name)) {
        myFriends.add(
          FriendInfo(
            name: suggestion.name,
            status: '${suggestion.compatibility ?? 0}% match',
            color: const Color(0xFF34D399),
          ),
        );
      }

      friendSuggestions.removeWhere((f) => f.name == suggestion.name);
    });
  }

  void joinCommunity(CommunityInfo community) {
    setState(() {
      if (!myCommunities.any((c) => c.name == community.name)) {
        myCommunities.add(community);
      }

      communitySuggestions.removeWhere((c) => c.name == community.name);
    });
  }

  void createCommunity() {
    final title = joinGroupInput.trim();
    if (title.isEmpty) return;

    setState(() {
      myCommunities.add(
        CommunityInfo(
          name: title,
          members: 1,
          tag: 'Created by you',
          creator: 'Ari Reed',
          created: 'Today',
          about: 'A new community for shared goals and gentle accountability.',
        ),
      );

      joinGroupInput = '';
    });
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> pickDate(DateTime initial, ValueChanged<DateTime> onPick) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2032),
    );

    if (picked != null) {
      setState(() => onPick(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (focusRunning) return buildFocusRunningScreen();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const AmbientBackground(),
            Column(
              children: [
                buildHeader(),
                Expanded(
                  child: IndexedStack(
                    index: tabIndex,
                    children: [
                      buildPlannerTab(),
                      buildTasksTab(),
                      buildCalendarTab(),
                      buildCommunityTab(),
                      buildCompanionTab(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tabIndex,
        onDestinationSelected: (index) => setState(() => tabIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_awesome),
            label: 'Planner',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_2),
            label: 'Community',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets),
            label: 'Companion',
          ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF0F172A),
            child: Text(
              'AR',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Goal Digger',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                  ),
                ),
                Text(
                  'Productivity Companion',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: () => showMessage('Settings placeholder'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
    );
  }

  /* ------------------------------------------------------------------------ */
  /*                                PLANNER TAB                               */
  /* ------------------------------------------------------------------------ */

  Widget buildPlannerTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        HeroCard(
          pet: activePet,
          title: 'Goal Deconstructor',
          subtitle: 'Turn a big goal into tiny, scheduled, less-scary steps.',
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Goal',
                  hintText: 'Become a YouTuber',
                  filled: true,
                ),
                controller: TextEditingController(text: newGoalTitle)
                  ..selection = TextSelection.collapsed(
                    offset: newGoalTitle.length,
                  ),
                onChanged: (value) => newGoalTitle = value,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: newGoalCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  filled: true,
                ),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => newGoalCategory = value);
                },
              ),
              const SizedBox(height: 12),
              buildStarSelector(
                value: newGoalImportance,
                onChanged: (v) => setState(() => newGoalImportance = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => pickDate(
                        newGoalDeadline,
                        (date) => newGoalDeadline = date,
                      ),
                      icon: const Icon(Icons.event),
                      label: Text('Deadline: ${longDate(newGoalDeadline)}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    onPressed: () => setState(
                      () => newGoalDeadline = addDays(newGoalDeadline, -1),
                    ),
                    icon: const Icon(Icons.remove),
                  ),
                  IconButton.outlined(
                    onPressed: () => setState(
                      () => newGoalDeadline = addDays(newGoalDeadline, 1),
                    ),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: addGoal,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Break down & schedule'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionTitle(
          title: 'My goals',
          trailing: '${goals.length} active',
        ),
        const SizedBox(height: 10),
        ...goals.map(buildGoalCard),
      ],
    );
  }

  Widget buildGoalCard(Goal goal) {
    final done = goal.subtasks.where((t) => t.done).length;
    final double progress = goal.subtasks.isEmpty ? 0.0 : done / goal.subtasks.length;
    final daysLeft = daysBetween(today, goal.deadline);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientBar(from: goal.from, to: goal.to),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(goal.category),
                      backgroundColor: goal.from.withOpacity(0.18),
                    ),
                    IconButton(
                      onPressed: () => removeGoal(goal.id),
                      icon: const Icon(Icons.close),
                      color: Colors.redAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.black.withOpacity(0.06),
                  valueColor: AlwaysStoppedAnimation(goal.from),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(999),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '$done/${goal.subtasks.length} · ${(progress * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${daysLeft}d',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: daysLeft <= 3
                            ? Colors.red
                            : daysLeft <= 7
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                buildStarSelector(
                  value: goal.importance,
                  onChanged: (v) {
                    setState(() {
                      goal.importance = v;
                      reseedTodayTasks(energyMode);
                    });
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => pickDate(
                          goal.deadline,
                          (date) {
                            goal.deadline = date;
                            reseedTodayTasks(energyMode);
                          },
                        ),
                        icon: const Icon(Icons.event),
                        label: Text(longDate(goal.deadline)),
                      ),
                    ),
                    IconButton.outlined(
                      onPressed: () {
                        setState(() {
                          goal.deadline = addDays(goal.deadline, -1);
                          reseedTodayTasks(energyMode);
                        });
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    IconButton.outlined(
                      onPressed: () {
                        setState(() {
                          goal.deadline = addDays(goal.deadline, 1);
                          reseedTodayTasks(energyMode);
                        });
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: goal.subtasks.map((task) {
                    return FilterChip(
                      selected: task.done,
                      label: Text(task.title),
                      onSelected: (_) => toggleTask(task.id),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /* ------------------------------------------------------------------------ */
  /*                                 TASK TAB                                 */
  /* ------------------------------------------------------------------------ */

  Widget buildTasksTab() {
    final incomplete = todayTasks.where((t) => !t.done).toList();
    final selectedStillValid =
        incomplete.any((t) => t.id == selectedFocusTaskId) ? selectedFocusTaskId : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        HeroCard(
          pet: activePet,
          title: 'Focus Buddy',
          subtitle: 'Tap a task to see how to start. Your list adapts to your energy.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How are you today?',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  moodChip('great', '🚀 Great', 'Stretch tasks unlocked'),
                  moodChip('okay', '🙂 Okay', 'Balanced day'),
                  moodChip('tired', '🪫 Tired', 'Light wins only'),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                adaptiveMessage,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              LinearProgressIndicator(
                value: todayCompletion / 100,
                minHeight: 10,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(height: 8),
              Text(
                '$todayCompleted/${todayTasks.length} complete · $earnedPoints pts earned',
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SectionTitle(
          title: 'Today',
          trailing: energyMode.toUpperCase(),
        ),
        const SizedBox(height: 10),
        ...todayTasks.map(buildTaskCard),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: addMoreTask,
                icon: const Icon(Icons.add),
                label: const Text('Add more'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: feedPet,
                icon: const Icon(Icons.restaurant),
                label: const Text('Feed pet'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        SectionTitle(title: 'Focus session', trailing: 'Timer'),
        const SizedBox(height: 10),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  value: selectedStillValid,
                  decoration: const InputDecoration(
                    labelText: 'Working on',
                    filled: true,
                  ),
                  items: incomplete.map((task) {
                    return DropdownMenuItem(
                      value: task.id,
                      child: Text(task.title),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedFocusTaskId = value),
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Custom minutes',
                    hintText: 'Optional',
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => customFocusMinutes = value,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [5, 10, 15, 25, 30].map((min) {
                    return ChoiceChip(
                      selected: focusDurationSeconds == min * 60,
                      label: Text('$min min'),
                      onSelected: (_) {
                        setState(() {
                          focusDurationSeconds = min * 60;
                          customFocusMinutes = '';
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: startFocus,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start focus'),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Allowed apps',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: focusApps.map((app) {
                    return FilterChip(
                      selected: app.allowed,
                      avatar: Text(app.icon),
                      label: Text(app.name),
                      onSelected: (value) {
                        setState(() => app.allowed = value);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget moodChip(String key, String title, String helper) {
    return ChoiceChip(
      selected: mood == key,
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          Text(
            helper,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
      onSelected: (_) => selectMood(key),
    );
  }

  Widget buildTaskCard(MicroTask task) {
    final goal = findGoal(task.goalId)!;
    final expanded = expandedTaskId == task.id;
    final tip = taskStartTips[task.title] ??
        'Focus on starting, not finishing. Set a timer and begin with the smallest possible step.';

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          setState(() => expandedTaskId = expanded ? null : task.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    value: task.done,
                    onChanged: (_) => toggleTask(task.id),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            decoration:
                                task.done ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        Text(
                          '${goal.title} · ${task.duration} · ${task.load.label} · +${task.points}',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => swapTask(task.id),
                    icon: const Icon(Icons.swap_horiz),
                  ),
                ],
              ),
              if (expanded) ...[
                const Divider(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    tip,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFocusRunningScreen() {
    final remaining = max(0, focusDurationSeconds - focusSeconds);
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;
    final task = selectedFocusTaskId == null ? null : findTask(selectedFocusTaskId!);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SafeArea(
        child: Stack(
          children: [
            const AmbientBackground(dark: true),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PetAvatar(pet: activePet, size: 132),
                    const SizedBox(height: 24),
                    const Text(
                      'FOCUS SESSION',
                      style: TextStyle(
                        color: Colors.white54,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${two(minutes)}:${two(seconds)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 82,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppCard(
                      color: Colors.white.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            const Text(
                              'Working on',
                              style: TextStyle(
                                color: Colors.white54,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              task?.title ?? 'Open focus block',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Stay with one task. You can do anything after the bell.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white60,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.tonalIcon(
                      onPressed: stopFocus,
                      icon: const Icon(Icons.close),
                      label: const Text('End session'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ------------------------------------------------------------------------ */
  /*                               CALENDAR TAB                               */
  /* ------------------------------------------------------------------------ */

  Widget buildCalendarTab() {
    final daysInMonth = DateUtils.getDaysInMonth(viewYear, viewMonth);
    final first = DateTime(viewYear, viewMonth, 1);
    final leading = first.weekday % 7;

    final selectedTasks = allTasks
        .where((t) => dateOnly(t.scheduledDate) == dateOnly(selectedDay))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        HeroCard(
          pet: activePet,
          title: 'Calendar',
          subtitle: 'See micro-tasks and routines by day.',
          child: Row(
            children: [
              IconButton.outlined(
                onPressed: () {
                  setState(() {
                    viewMonth--;
                    if (viewMonth < 1) {
                      viewMonth = 12;
                      viewYear--;
                    }
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${monthNames[viewMonth - 1]} $viewYear',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              IconButton.outlined(
                onPressed: () {
                  setState(() {
                    viewMonth++;
                    if (viewMonth > 12) {
                      viewMonth = 1;
                      viewYear++;
                    }
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leading + daysInMonth,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                if (index < leading) return const SizedBox.shrink();

                final day = index - leading + 1;
                final date = DateTime(viewYear, viewMonth, day);
                final hasTask = allTasks.any(
                  (t) => dateOnly(t.scheduledDate) == dateOnly(date),
                );
                final selected = dateOnly(date) == dateOnly(selectedDay);

                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => setState(() => selectedDay = date),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF0F172A)
                          : hasTask
                              ? const Color(0xFF14B8A6).withOpacity(0.12)
                              : Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 18),
        SectionTitle(title: longDate(selectedDay), trailing: 'Day plan'),
        const SizedBox(height: 10),
        if (selectedTasks.isEmpty)
          const AppCard(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No micro-tasks scheduled for this day.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          )
        else
          ...selectedTasks.map(buildTaskCard),
        const SizedBox(height: 18),
        SectionTitle(title: 'Routines', trailing: '${routines.length}'),
        const SizedBox(height: 10),
        ...routines.map((routine) {
          return AppCard(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(Icons.repeat),
              title: Text(
                routine.title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text('${routine.time} · ${routine.frequency}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  setState(() => routines.removeWhere((r) => r.id == routine.id));
                },
              ),
            ),
          );
        }),
        if (showAddRoutine)
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Routine name',
                      filled: true,
                    ),
                    onChanged: (v) => newRoutineName = v,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      hintText: '08:00',
                      filled: true,
                    ),
                    onChanged: (v) => newRoutineTime = v,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: newRoutineFrequency,
                    decoration: const InputDecoration(
                      labelText: 'Frequency',
                      filled: true,
                    ),
                    items: ['Daily', 'Weekly', 'Weekdays', 'Custom']
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => newRoutineFrequency = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: addRoutine,
                    child: const Text('Add routine'),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => setState(() => showAddRoutine = !showAddRoutine),
          icon: Icon(showAddRoutine ? Icons.close : Icons.add),
          label: Text(showAddRoutine ? 'Cancel' : 'Add routine'),
        ),
      ],
    );
  }

  /* ------------------------------------------------------------------------ */
  /*                              COMMUNITY TAB                               */
  /* ------------------------------------------------------------------------ */

  Widget buildCommunityTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        HeroCard(
          pet: activePet,
          title: 'Community',
          subtitle: 'Friends, groups, and gentle accountability.',
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Create a community',
              hintText: 'e.g. Flutter Builders',
              filled: true,
              suffixIcon: IconButton(
                onPressed: createCommunity,
                icon: const Icon(Icons.add),
              ),
            ),
            onChanged: (v) => joinGroupInput = v,
          ),
        ),
        const SizedBox(height: 18),
        SectionTitle(title: 'My friends', trailing: '${myFriends.length}'),
        const SizedBox(height: 10),
        ...myFriends.map((friend) {
          return AppCard(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: friend.color),
              title: Text(
                friend.name,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(friend.status),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() => myFriends.removeWhere((f) => f.name == friend.name));
                },
              ),
            ),
          );
        }),
        const SizedBox(height: 18),
        SectionTitle(title: 'Friend suggestions', trailing: 'Match'),
        const SizedBox(height: 10),
        ...friendSuggestions.map((suggestion) {
          return AppCard(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(child: Text(suggestion.avatar)),
              title: Text(
                suggestion.name,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text('${suggestion.compatibility ?? 0}% match'),
              trailing: FilledButton(
                onPressed: () => addFriend(suggestion),
                child: const Text('Add'),
              ),
            ),
          );
        }),
        const SizedBox(height: 18),
        SectionTitle(title: 'My communities', trailing: '${myCommunities.length}'),
        const SizedBox(height: 10),
        ...myCommunities.map(buildCommunityCard),
        const SizedBox(height: 18),
        SectionTitle(title: 'Discover', trailing: 'Groups'),
        const SizedBox(height: 10),
        ...communitySuggestions.map((community) {
          return buildCommunityCard(
            community,
            action: FilledButton(
              onPressed: () => joinCommunity(community),
              child: const Text('Join'),
            ),
          );
        }),
      ],
    );
  }

  Widget buildCommunityCard(CommunityInfo community, {Widget? action}) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              community.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${community.members} members · ${community.tag}',
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              community.about,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'By ${community.creator} · ${community.created}',
                  style: const TextStyle(
                    color: Colors.black45,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (action != null)
                  action
                else
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      setState(() {
                        myCommunities.removeWhere((c) => c.name == community.name);
                      });
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /* ------------------------------------------------------------------------ */
  /*                              COMPANION TAB                               */
  /* ------------------------------------------------------------------------ */

  Widget buildCompanionTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        HeroCard(
          pet: activePet,
          title: '${activePet.name} Companion',
          subtitle: 'Earn coins by completing micro-tasks. Spend coins on pet items.',
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.local_fire_department),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: petHunger / 100,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$petHunger%',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    avatar: const Icon(Icons.monetization_on),
                    label: Text('$petCoins coins'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: feedPet,
                    icon: const Icon(Icons.restaurant),
                    label: const Text('Feed -10'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SectionTitle(title: 'Choose pet', trailing: selectedPetId),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: petSkins.map((pet) {
            final selected = pet.id == selectedPetId;

            return InkWell(
              onTap: () => setState(() => selectedPetId = pet.id),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 120,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    PetAvatar(pet: pet, size: 64),
                    const SizedBox(height: 8),
                    Text(
                      pet.name,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 22),
        SectionTitle(title: 'Pet shop', trailing: 'Rewards'),
        const SizedBox(height: 10),
        ...shopItems.map((item) {
          return AppCard(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Text(
                item.image,
                style: const TextStyle(fontSize: 28),
              ),
              title: Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text('${item.type} · ${item.note}'),
              trailing: FilledButton.tonal(
                onPressed: () {
                  if (petCoins >= item.price) {
                    setState(() => petCoins -= item.price);
                    showMessage('Purchased ${item.name}.');
                  } else {
                    showMessage('Not enough coins.');
                  }
                },
                child: Text('${item.price}'),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget buildStarSelector({
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: [
        const Text(
          'Priority',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: List.generate(5, (index) {
              final star = index + 1;
              return Expanded(
                child: IconButton(
                  onPressed: () => onChanged(star),
                  icon: Icon(
                    star <= value ? Icons.star : Icons.star_border,
                    color: star <= value ? Colors.amber : Colors.black26,
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

/* -------------------------------------------------------------------------- */
/*                              PRESENTATION WIDGETS                          */
/* -------------------------------------------------------------------------- */

class AmbientBackground extends StatelessWidget {
  final bool dark;

  const AmbientBackground({
    super.key,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? [
                      const Color(0xFF020617),
                      const Color(0xFF0F172A),
                    ]
                  : [
                      const Color(0xFFF7F1E8),
                      const Color(0xFFE0F2FE).withOpacity(0.6),
                      const Color(0xFFFCE7F3).withOpacity(0.5),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}

class HeroCard extends StatelessWidget {
  final PetSkin pet;
  final String title;
  final String subtitle;
  final Widget child;

  const HeroCard({
    super.key,
    required this.pet,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: const Color(0xFF0F172A),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                PetAvatar(pet: pet, size: 72),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: const InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.margin,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
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

class GradientBar extends StatelessWidget {
  final Color from;
  final Color to;

  const GradientBar({
    super.key,
    required this.from,
    required this.to,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [from, to]),
      ),
    );
  }
}

class PetAvatar extends StatelessWidget {
  final PetSkin pet;
  final double size;

  const PetAvatar({
    super.key,
    required this.pet,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    final eye = size * 0.09;

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
            color: pet.to.withOpacity(0.35),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * 0.24,
            child: Container(
              width: size * 0.48,
              height: size * 0.18,
              decoration: BoxDecoration(
                color: pet.accent.withOpacity(0.85),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            top: size * 0.42,
            left: size * 0.32,
            child: CircleAvatar(radius: eye, backgroundColor: Colors.white),
          ),
          Positioned(
            top: size * 0.42,
            right: size * 0.32,
            child: CircleAvatar(radius: eye, backgroundColor: Colors.white),
          ),
          Positioned(
            bottom: size * 0.28,
            child: Container(
              width: size * 0.22,
              height: size * 0.08,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;

  const SectionTitle({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              color: Colors.black45,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
      ],
    );
  }
}