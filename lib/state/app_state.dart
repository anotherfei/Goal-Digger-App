import 'package:flutter/material.dart';
import '../models/sub_task.dart';
import '../models/goal_item.dart';
import '../models/pet_look.dart';

enum NavTab { task, calendar, planner, community, companion }
enum Energy { low, steady, high }
enum Mood { great, okay, tired }

class CommunityUser {
  final String name;
  final int? compatibility;
  final String avatar;
  const CommunityUser({required this.name, this.compatibility, required this.avatar});
}

class FocusApp {
  final String name;
  final String icon;
  bool allowed;
  FocusApp({required this.name, required this.icon, required this.allowed});
}

class Reminder {
  final int id;
  final String title;
  final String time;
  final int? taskId;
  Reminder({required this.id, required this.title, required this.time, this.taskId});
}

class AppState extends ChangeNotifier {
  static const int todayDay = 15;

  // ── Navigation ──
  NavTab _activeTab = NavTab.planner;
  NavTab get activeTab => _activeTab;
  void setActiveTab(NavTab tab) {
    _activeTab = tab;
    notifyListeners();
  }

  // ── Goals (with subtasks) ──
  late List<GoalItem> _goals = [
    GoalItem(
      id: 1, title: 'Launch portfolio', importance: 5, deadlineDay: 22,
      startColor: const Color(0xFF2DD4BF), endColor: const Color(0xFF10B981),
      subtasks: [
        SubTask(id: 101, title: 'Draft project outline', goalId: 1, duration: '12 min', load: TaskLoad.focus, points: 20, scheduledDay: 15),
        SubTask(id: 102, title: 'Sketch homepage layout', goalId: 1, duration: '15 min', load: TaskLoad.focus, points: 20, scheduledDay: 16),
        SubTask(id: 103, title: 'Write project descriptions', goalId: 1, duration: '20 min', load: TaskLoad.stretch, points: 25, scheduledDay: 17),
        SubTask(id: 104, title: 'Choose color palette', goalId: 1, duration: '8 min', load: TaskLoad.light, points: 10, scheduledDay: 18),
        SubTask(id: 105, title: 'Build hero section', goalId: 1, duration: '25 min', load: TaskLoad.stretch, points: 30, scheduledDay: 19),
        SubTask(id: 106, title: 'Deploy first draft', goalId: 1, duration: '20 min', load: TaskLoad.focus, points: 25, scheduledDay: 21),
      ],
    ),
    GoalItem(
      id: 2, title: 'Exam prep', importance: 4, deadlineDay: 28,
      startColor: const Color(0xFFFBBF24), endColor: const Color(0xFFF97316),
      subtasks: [
        SubTask(id: 201, title: 'Review chapter 3 notes', goalId: 2, duration: '8 min', load: TaskLoad.light, done: true, points: 10, scheduledDay: 14),
        SubTask(id: 202, title: 'Solve 5 practice problems', goalId: 2, duration: '15 min', load: TaskLoad.focus, points: 20, scheduledDay: 15),
        SubTask(id: 203, title: 'Make flashcards (chapter 4)', goalId: 2, duration: '12 min', load: TaskLoad.focus, points: 15, scheduledDay: 17),
        SubTask(id: 204, title: 'Mock exam timed', goalId: 2, duration: '30 min', load: TaskLoad.stretch, points: 35, scheduledDay: 20),
        SubTask(id: 205, title: 'Review weak topics', goalId: 2, duration: '15 min', load: TaskLoad.focus, points: 20, scheduledDay: 24),
      ],
    ),
    GoalItem(
      id: 3, title: 'Team comms', importance: 2, deadlineDay: 30,
      startColor: const Color(0xFFA78BFA), endColor: const Color(0xFF8B5CF6),
      subtasks: [
        SubTask(id: 301, title: 'Send weekly update', goalId: 3, duration: '5 min', load: TaskLoad.light, points: 10, scheduledDay: 15),
        SubTask(id: 302, title: 'Reply to pending DMs', goalId: 3, duration: '10 min', load: TaskLoad.light, points: 10, scheduledDay: 18),
        SubTask(id: 303, title: 'Schedule sync meeting', goalId: 3, duration: '5 min', load: TaskLoad.light, points: 10, scheduledDay: 22),
      ],
    ),
    GoalItem(
      id: 4, title: 'Build consistency', importance: 3, deadlineDay: 30,
      startColor: const Color(0xFFFB7185), endColor: const Color(0xFFEC4899),
      subtasks: [
        SubTask(id: 401, title: 'Choose next practice problem', goalId: 4, duration: '10 min', load: TaskLoad.stretch, points: 15, scheduledDay: 15),
        SubTask(id: 402, title: 'Journal 3 wins', goalId: 4, duration: '5 min', load: TaskLoad.light, points: 10, scheduledDay: 16),
        SubTask(id: 403, title: 'Reflect on the week', goalId: 4, duration: '10 min', load: TaskLoad.light, points: 10, scheduledDay: 21),
      ],
    ),
  ];

  List<GoalItem> get goals => _goals;
  List<SubTask> get allSubtasks => _goals.expand((g) => g.subtasks).toList();

  // ── Mood / Energy ──
  Mood _mood = Mood.okay;
  Mood get mood => _mood;
  Energy _energy = Energy.steady;
  Energy get energy => _energy;

  static const Map<Mood, Energy> _moodToEnergy = {
    Mood.great: Energy.high,
    Mood.okay: Energy.steady,
    Mood.tired: Energy.low,
  };

  static const Map<Energy, String> energyCopy = {
    Energy.low: "Low energy detected. I'm prioritizing only your most important goals and shrinking each task to ≤8 min.",
    Energy.steady: "Steady energy. Balanced mix: 1 stretch task + light wins from your top-priority goals.",
    Energy.high: "High energy! I'm front-loading stretch tasks from your highest-importance goals.",
  };

  String get adaptiveMessage => energyCopy[_energy]!;

  void setMood(Mood m) {
    _mood = m;
    _energy = _moodToEnergy[m]!;
    _recomputeSuggestions();
    notifyListeners();
  }

  void setEnergy(Energy e) {
    _energy = e;
    _recomputeSuggestions();
    notifyListeners();
  }

  // ── Today's task ids (computed by ATS) ──
  List<int> _todayTaskIds = [];
  List<int> get todayTaskIds => _todayTaskIds;

  List<SubTask> get todayTasks {
    final all = allSubtasks;
    return _todayTaskIds
        .map((id) => all.where((s) => s.id == id).firstOrNull)
        .whereType<SubTask>()
        .toList();
  }

  int get todayCompletedCount => todayTasks.where((t) => t.done).length;
  int get todayCompletionPercent {
    final t = todayTasks;
    if (t.isEmpty) return 100;
    return ((todayCompletedCount / t.length) * 100).round();
  }

  int get earnedPointsToday => todayTasks.where((t) => t.done).fold(0, (s, t) => s + t.points);

  AppState() {
    _recomputeSuggestions();
  }

  // ── ATS Engine ──
  List<SubTask> _computeAdaptiveSuggestions(List<GoalItem> goals, Energy energy, int day) {
    final allSubs = goals.expand((g) => g.subtasks.where((s) => !s.done)).toList();
    if (allSubs.isEmpty) return [];

    final slots = energy == Energy.low ? 2 : energy == Energy.steady ? 4 : 5;

    final scored = allSubs.map((s) {
      final goal = goals.firstWhere((g) => g.id == s.goalId);
      final daysUntilDeadline = (goal.deadlineDay - day).clamp(1, 999).toInt();
      final urgency = 10.0 / daysUntilDeadline;
      final importance = goal.importance * 2.0;
      final dayMatch = s.scheduledDay == day ? 5.0 : s.scheduledDay < day ? 3.0 : (4 - (s.scheduledDay - day)).clamp(0, 4).toDouble();
      final energyMatch = energy == Energy.low
          ? (s.load == TaskLoad.light ? 4.0 : s.load == TaskLoad.focus ? 1.0 : -3.0)
          : energy == Energy.high
              ? (s.load == TaskLoad.stretch ? 4.0 : s.load == TaskLoad.focus ? 2.0 : 1.0)
              : 2.0;
      return MapEntry(s, importance + urgency + dayMatch + energyMatch);
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.take(slots).map((e) => e.key).toList();
  }

  SubTask? _findReplacementTask(List<GoalItem> goals, Energy energy, int day, List<int> currentIds, int excludeId) {
    final allSubs = goals.expand((g) => g.subtasks.where((s) => !s.done && !currentIds.contains(s.id) && s.id != excludeId)).toList();
    if (allSubs.isEmpty) return null;

    final scored = allSubs.map((s) {
      final goal = goals.firstWhere((g) => g.id == s.goalId);
      final daysUntilDeadline = (goal.deadlineDay - day).clamp(1, 999).toInt();
      final urgency = 10.0 / daysUntilDeadline;
      final importance = goal.importance * 2.0;
      final energyMatch = energy == Energy.low
          ? (s.load == TaskLoad.light ? 4.0 : s.load == TaskLoad.focus ? 1.0 : -3.0)
          : energy == Energy.high
              ? (s.load == TaskLoad.stretch ? 4.0 : s.load == TaskLoad.focus ? 2.0 : 1.0)
              : 2.0;
      return MapEntry(s, importance + urgency + energyMatch);
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.first.key;
  }

  void _recomputeSuggestions() {
    final newTasks = _computeAdaptiveSuggestions(_goals, _energy, todayDay);
    final all = allSubtasks;
    // Keep already-completed ones at the top
    final completedKept = _todayTaskIds.where((id) {
      final t = all.where((s) => s.id == id).firstOrNull;
      return t != null && t.done;
    }).toList();
    final merged = List<int>.from(completedKept);
    for (final t in newTasks) {
      if (!merged.contains(t.id)) merged.add(t.id);
    }
    _todayTaskIds = merged;
  }

  // ── Task interactions ──
  void toggleTask(int id) {
    for (final g in _goals) {
      for (final s in g.subtasks) {
        if (s.id == id) {
          final wasDone = s.done;
          s.done = !wasDone;
          if (!wasDone) {
            _petHunger = (_petHunger + 15).clamp(0, 100);
            _petCoins += s.points;
          } else {
            _petHunger = (_petHunger - 15).clamp(0, 100);
            _petCoins = (_petCoins - s.points).clamp(0, 99999);
          }
          notifyListeners();
          return;
        }
      }
    }
  }

  void replaceTodayTask(int taskId) {
    final replacement = _findReplacementTask(_goals, _energy, todayDay, _todayTaskIds, taskId);
    if (replacement == null) return;
    _todayTaskIds = _todayTaskIds.map((id) => id == taskId ? replacement.id : id).toList();
    notifyListeners();
  }

  bool get hasMoreAvailableTasks {
    final inToday = _todayTaskIds.toSet();
    return allSubtasks.any((s) => !s.done && !inToday.contains(s.id));
  }

  void addAnotherTask() {
    final replacement = _findReplacementTask(_goals, _energy, todayDay, _todayTaskIds, -1);
    if (replacement == null) return;
    _todayTaskIds = [..._todayTaskIds, replacement.id];
    notifyListeners();
  }

  // ── Goal updates ──
  void updateGoalImportance(int goalId, int importance) {
    final g = _goals.where((g) => g.id == goalId).firstOrNull;
    if (g != null) {
      g.importance = importance;
      _recomputeSuggestions();
      notifyListeners();
    }
  }

  void updateGoalDeadline(int goalId, int day) {
    final g = _goals.where((g) => g.id == goalId).firstOrNull;
    if (g != null) {
      g.deadlineDay = day;
      _recomputeSuggestions();
      notifyListeners();
    }
  }

  // ── Goal Deconstructor ──
  String _deconGoalInput = 'Become a YouTuber';
  int _deconGoalImportance = 3;
  int _deconGoalDeadline = 28;
  bool _showGoalDeconstructor = false;
  String get deconGoalInput => _deconGoalInput;
  int get deconGoalImportance => _deconGoalImportance;
  int get deconGoalDeadline => _deconGoalDeadline;
  bool get showGoalDeconstructor => _showGoalDeconstructor;

  void setDeconGoalInput(String v) { _deconGoalInput = v; notifyListeners(); }
  void setDeconGoalImportance(int v) { _deconGoalImportance = v; notifyListeners(); }
  void setDeconGoalDeadline(int v) { _deconGoalDeadline = v; notifyListeners(); }
  void toggleGoalDeconstructor() { _showGoalDeconstructor = !_showGoalDeconstructor; notifyListeners(); }

  void deconstructGoal() {
    final subMap = <String, List<String>>{
      'become a youtuber': ['Write first script', 'Film pilot video', 'Edit and add effects', 'Review and publish'],
    };
    final key = _deconGoalInput.toLowerCase();
    final subs = subMap[key] ?? ['Research the topic', 'Create a plan outline', 'Execute first step', 'Review and iterate'];
    final newId = _goals.map((g) => g.id).reduce((a, b) => a > b ? a : b) + 1;
    _goals.add(GoalItem(
      id: newId,
      title: _deconGoalInput,
      importance: _deconGoalImportance,
      deadlineDay: _deconGoalDeadline,
      startColor: const Color(0xFF22D3EE),
      endColor: const Color(0xFF3B82F6),
      subtasks: subs.asMap().entries.map((e) => SubTask(
        id: newId * 100 + e.key,
        title: e.value,
        goalId: newId,
        duration: '10 min',
        load: e.key == subs.length - 1 ? TaskLoad.stretch : TaskLoad.focus,
        points: 15,
        scheduledDay: (todayDay + e.key + 1).clamp(1, 30),
      )).toList(),
    ));
    _recomputeSuggestions();
    notifyListeners();
  }

  // ── Calendar selected day ──
  int _selectedDay = todayDay;
  int get selectedDay => _selectedDay;
  void setSelectedDay(int day) { _selectedDay = day; notifyListeners(); }

  // ── Companion ──
  String _selectedPetId = 'mint';
  String get selectedPetId => _selectedPetId;
  PetLook get activePet => petLooks.firstWhere((p) => p.id == _selectedPetId, orElse: () => petLooks.first);
  void setSelectedPet(String id) { _selectedPetId = id; notifyListeners(); }

  int _petHunger = 35;
  int get petHunger => _petHunger;
  int _petCoins = 430;
  int get petCoins => _petCoins;

  void feedPet() {
    if (earnedPointsToday >= 10 && _petHunger < 100) {
      _petHunger = (_petHunger + 20).clamp(0, 100);
      _petCoins = (_petCoins - 10).clamp(0, 99999);
      notifyListeners();
    }
  }

  // ── Focus Mode ──
  bool _showFocusMode = false;
  bool get showFocusMode => _showFocusMode;
  void toggleFocusMode() { _showFocusMode = !_showFocusMode; notifyListeners(); }

  List<FocusApp> _focusApps = [
    FocusApp(name: 'Notes', icon: '📝', allowed: true),
    FocusApp(name: 'Music', icon: '🎵', allowed: true),
    FocusApp(name: 'Browser', icon: '🌐', allowed: false),
    FocusApp(name: 'Messages', icon: '💬', allowed: false),
    FocusApp(name: 'Calculator', icon: '🔢', allowed: true),
    FocusApp(name: 'Social', icon: '📱', allowed: false),
  ];
  List<FocusApp> get focusApps => _focusApps;

  void toggleFocusApp(String name) {
    final idx = _focusApps.indexWhere((a) => a.name == name);
    if (idx != -1) {
      _focusApps[idx].allowed = !_focusApps[idx].allowed;
      notifyListeners();
    }
  }

  int _focusDuration = 25 * 60;
  int get focusDuration => _focusDuration;
  void setFocusDuration(int s) { _focusDuration = s; notifyListeners(); }

  // ── Global Reminder ──
  Reminder? _activeReminder;
  Reminder? get activeReminder => _activeReminder;
  void showReminder(Reminder r) { _activeReminder = r; notifyListeners(); }
  void dismissReminder() { _activeReminder = null; notifyListeners(); }

  // ── Community users ──
  static const List<CommunityUser> communityUsers = [
    CommunityUser(name: 'Alex K.', compatibility: 90, avatar: 'AK'),
    CommunityUser(name: 'Mira S.', compatibility: 72, avatar: 'MS'),
    CommunityUser(name: 'Dev P.', compatibility: 56, avatar: 'DP'),
    CommunityUser(name: 'Luna R.', compatibility: 23, avatar: 'LR'),
    CommunityUser(name: 'New User', compatibility: null, avatar: '??'),
  ];
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
