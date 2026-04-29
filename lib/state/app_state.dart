import 'dart:math';
import 'package:flutter/material.dart';
import '../models/sub_task.dart';
import '../models/goal_item.dart';
import '../models/pet_look.dart';
import '../models/routine.dart';
import '../models/community_models.dart';

enum NavTab { task, calendar, home, community, shop }
enum Energy { low, steady, high }
enum Mood { great, okay, tired }

class ChatMsg {
  final String role; // 'ai' | 'user'
  final String text;
  ChatMsg({required this.role, required this.text});
}

class AppUser {
  final String name;
  final String email;
  final String joined;
  AppUser({required this.name, required this.email, required this.joined});
}

class FocusApp {
  final String name;
  final String icon;
  bool allowed;
  FocusApp({required this.name, required this.icon, required this.allowed});
}

class ReminderData {
  final int id;
  final String title;
  final String time;
  final int? taskId;
  ReminderData({required this.id, required this.title, required this.time, this.taskId});
}

final today = DateTime(2026, 4, 15);

class AppState extends ChangeNotifier {
  // ── Navigation ──
  NavTab _tab = NavTab.home;
  NavTab get tab => _tab;
  void setTab(NavTab t) { _tab = t; notifyListeners(); }

  // ── Goals ──
  late List<GoalItem> _goals = _starterGoals();
  List<GoalItem> get goals => _goals;
  List<SubTask> get allSubtasks => _goals.expand((g) => g.subtasks).toList();

  // ── Pet ──
  String _petId = 'mint';
  String get petId => _petId;
  PetLook get activePet => petLooks.firstWhere((p) => p.id == _petId, orElse: () => petLooks.first);
  void setPetId(String id) { _petId = id; notifyListeners(); }

  int _petHunger = 35;
  int get petHunger => _petHunger;
  int _coins = 430;
  int get coins => _coins;

  // ── Mood / Energy ──
  Mood _mood = Mood.okay;
  Mood get mood => _mood;
  Energy _energy = Energy.steady;
  Energy get energy => _energy;
  String _adaptiveText = 'Steady energy. Balanced mix for important goals.';
  String get adaptiveText => _adaptiveText;

  static const Map<Mood, Energy> _moodEnergy = {Mood.great: Energy.high, Mood.okay: Energy.steady, Mood.tired: Energy.low};
  static const Map<Energy, String> _energyCopy = {
    Energy.low: "Low energy. Prioritizing light wins from top goals.",
    Energy.steady: "Steady energy. Balanced mix: stretch + light wins.",
    Energy.high: "High energy! Front-loading stretch tasks from top goals.",
  };

  void setMood(Mood m) {
    final requested = _moodEnergy[m]!;
    final urgentLoad = _goals.where((g) => g.deadline.difference(today).inDays <= 1).fold(0, (s, g) => s + g.subtasks.where((t) => !t.done).length);
    final effective = requested == Energy.low && urgentLoad > 2 ? Energy.steady : requested;
    _mood = m;
    _energy = effective;
    _adaptiveText = (requested == Energy.low && urgentLoad > 2)
        ? "Low energy, but a deadline is very close. I kept urgent tasks and made the approach gentler."
        : _energyCopy[effective]!;
    _recompute();
    notifyListeners();
  }

  // ── Today task ids (ATS) ──
  List<int> _todayIds = [];
  List<int> get todayIds => _todayIds;
  List<SubTask> get todayTasks => _todayIds.map((id) => allSubtasks.where((t) => t.id == id).firstOrNull).whereType<SubTask>().toList();
  int get todayDone => todayTasks.where((t) => t.done).length;
  int get todayPercent => todayTasks.isEmpty ? 100 : ((todayDone / todayTasks.length) * 100).round();
  int get earnedToday => todayTasks.where((t) => t.done).fold(0, (s, t) => s + t.points);
  bool get hasMoreTasks => allSubtasks.any((s) => !s.done && !_todayIds.contains(s.id));

  AppState() { _recompute(); }

  double _score(SubTask s, GoalItem g, Energy e) {
    final dl = max(1, g.deadline.difference(today).inDays);
    final dd = s.scheduledDate.difference(today).inDays;
    final dayMatch = dd == 0 ? 5.0 : dd < 0 ? 3.0 : max(0, 4 - dd).toDouble();
    final energyMatch = e == Energy.low ? (s.load == TaskLoad.light ? 4.0 : s.load == TaskLoad.focus ? 1.0 : -3.0)
        : e == Energy.high ? (s.load == TaskLoad.stretch ? 4.0 : s.load == TaskLoad.focus ? 2.0 : 1.0) : 2.0;
    return g.importance * 2.0 + 10.0 / dl + dayMatch + energyMatch;
  }

  void _recompute() {
    final undone = allSubtasks.where((s) => !s.done).toList();
    if (undone.isEmpty) { _todayIds = []; return; }
    final slots = _energy == Energy.low ? 2 : _energy == Energy.steady ? 4 : 5;
    final scored = undone.map((s) {
      final g = _goals.firstWhere((g) => g.id == s.goalId);
      return MapEntry(s, _score(s, g, _energy));
    }).toList()..sort((a, b) => b.value.compareTo(a.value));
    final fresh = scored.take(slots).map((e) => e.key.id).toList();
    final kept = _todayIds.where((id) => allSubtasks.where((s) => s.id == id).firstOrNull?.done == true).toList();
    final merged = [...kept];
    for (final id in fresh) { if (!merged.contains(id)) merged.add(id); }
    _todayIds = merged;
  }

  SubTask? _findReplacement(int excludeId) {
    final pool = allSubtasks.where((s) => !s.done && !_todayIds.contains(s.id) && s.id != excludeId).toList();
    if (pool.isEmpty) return null;
    final scored = pool.map((s) {
      final g = _goals.firstWhere((g) => g.id == s.goalId);
      return MapEntry(s, _score(s, g, _energy));
    }).toList()..sort((a, b) => b.value.compareTo(a.value));
    return scored.first.key;
  }

  void toggleTask(int id) {
    for (final g in _goals) {
      for (final s in g.subtasks) {
        if (s.id == id) {
          if (!s.done) { _petHunger = (_petHunger + 15).clamp(0, 100); _coins += s.points; }
          else { _petHunger = (_petHunger - 15).clamp(0, 100); _coins = max(0, _coins - s.points); }
          s.done = !s.done;
          notifyListeners();
          return;
        }
      }
    }
  }

  void swapTask(int taskId) {
    final r = _findReplacement(taskId);
    if (r == null) return;
    _todayIds = _todayIds.map((id) => id == taskId ? r.id : id).toList();
    notifyListeners();
  }

  void addMoreTask() {
    final r = _findReplacement(-1);
    if (r == null) return;
    _todayIds = [..._todayIds, r.id];
    notifyListeners();
  }

  void feedPet() {
    if (earnedToday >= 10 && _petHunger < 100) {
      _petHunger = (_petHunger + 20).clamp(0, 100);
      _coins = max(0, _coins - 10);
      notifyListeners();
    }
  }

  // ── Goal CRUD ──
  void updateGoalImportance(int id, int v) {
    _goals.firstWhere((g) => g.id == id).importance = v;
    _recompute(); notifyListeners();
  }
  void updateGoalCategory(int id, String c) {
    _goals.firstWhere((g) => g.id == id).category = c;
    notifyListeners();
  }
  void updateGoalDeadline(int id, DateTime d) {
    _goals.firstWhere((g) => g.id == id).deadline = d;
    _recompute(); notifyListeners();
  }
  void removeGoal(int id) {
    _todayIds = _todayIds.where((tid) => !(_goals.firstWhere((g) => g.id == id).subtasks.any((s) => s.id == tid))).toList();
    _goals = _goals.where((g) => g.id != id).toList();
    notifyListeners();
  }

  // ── Goal Deconstructor ──
  String deconTitle = 'Become a YouTuber';
  String deconCategory = 'Hobby';
  int deconImportance = 3;
  DateTime deconDeadline = today.add(const Duration(days: 14));

  void deconstructGoal() {
    final map = <String, List<String>>{'become a youtuber': ['Write first script', 'Film pilot video', 'Edit and add effects', 'Review and publish']};
    final subs = map[deconTitle.toLowerCase()] ?? ['Research the topic', 'Create a plan outline', 'Execute first step', 'Review and iterate'];
    final newId = _goals.map((g) => g.id).reduce(max) + 1;
    _goals.add(GoalItem(
      id: newId, title: deconTitle, importance: deconImportance, category: deconCategory,
      deadline: deconDeadline, startColor: const Color(0xFF22D3EE), endColor: const Color(0xFF3B82F6),
      subtasks: subs.asMap().entries.map((e) => SubTask(
        id: newId * 100 + e.key, goalId: newId, title: e.value, duration: '10 min',
        load: e.key == subs.length - 1 ? TaskLoad.stretch : TaskLoad.focus,
        points: 15, scheduledDate: today.add(Duration(days: e.key + 1)),
      )).toList(),
    ));
    _breakdownChat = BreakdownChat(goal: deconTitle, messages: [
      ChatMsg(role: 'ai', text: 'Great! I drafted ${subs.length} steps:\n${subs.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}\n\nDoes this look right? Tell me what to adjust.'),
    ]);
    deconTitle = '';
    _recompute();
    notifyListeners();
  }

  // ── Breakdown Chat ──
  BreakdownChat? _breakdownChat;
  BreakdownChat? get breakdownChat => _breakdownChat;
  void sendChatMsg(String msg) {
    _breakdownChat?.messages.add(ChatMsg(role: 'user', text: msg));
    _breakdownChat?.messages.add(ChatMsg(role: 'ai', text: 'Noted. I refined the breakdown. Anything else before we finalize?'));
    notifyListeners();
  }
  void closeChat() { _breakdownChat = null; notifyListeners(); }

  // ── Routines ──
  List<Routine> routines = [
    Routine(id: 1, title: 'Morning stretch', time: '07:00', frequency: 'Daily'),
    Routine(id: 2, title: 'Drink water', time: '07:15', frequency: 'Daily'),
    Routine(id: 3, title: 'Read 10 pages', time: '21:00', frequency: 'Weekly'),
  ];
  void addRoutine(Routine r) { routines.add(r); notifyListeners(); }
  void removeRoutine(int id) { routines.removeWhere((r) => r.id == id); notifyListeners(); }

  List<Routine> routinesForDate(DateTime date) {
    return routines.where((r) {
      if (r.frequency == 'Daily') return true;
      if (r.frequency == 'Weekly') return date.weekday == today.weekday;
      if (r.frequency == 'Monthly') return date.day == today.day;
      if (r.frequency == 'Once') return date.year == today.year && date.month == today.month && date.day == today.day;
      return (date.difference(today).inDays.abs() % 3) == 0;
    }).toList();
  }

  // ── Calendar ──
  int viewYear = today.year;
  int viewMonth = today.month - 1; // 0-indexed for consistency
  void navigateMonth(int delta) {
    viewMonth += delta;
    while (viewMonth < 0) { viewMonth += 12; viewYear -= 1; }
    while (viewMonth > 11) { viewMonth -= 12; viewYear += 1; }
    notifyListeners();
  }
  void jumpToToday() { viewYear = today.year; viewMonth = today.month - 1; notifyListeners(); }

  // ── Focus mode ──
  List<FocusApp> focusApps = [
    FocusApp(name: 'Notes', icon: '📝', allowed: true),
    FocusApp(name: 'Music', icon: '🎵', allowed: true),
    FocusApp(name: 'Browser', icon: '🌐', allowed: false),
    FocusApp(name: 'Messages', icon: '💬', allowed: false),
    FocusApp(name: 'Calculator', icon: '🔢', allowed: true),
    FocusApp(name: 'Social', icon: '📱', allowed: false),
  ];
  void toggleFocusApp(String name) {
    focusApps.firstWhere((a) => a.name == name).allowed = !focusApps.firstWhere((a) => a.name == name).allowed;
    notifyListeners();
  }
  int focusDuration = 25 * 60;
  void setFocusDuration(int s) { focusDuration = s; notifyListeners(); }

  // ── Reminder ──
  ReminderData? activeReminder;
  void showReminder(ReminderData r) { activeReminder = r; notifyListeners(); }
  void dismissReminder() { activeReminder = null; notifyListeners(); }

  // ── Auth ──
  AppUser? user = AppUser(name: 'Ari Reed', email: 'ari@goaldigger.app', joined: 'April 2026');
  void login(String email, String name) { user = AppUser(name: name, email: email, joined: 'April 2026'); notifyListeners(); }
  void logout() { user = null; notifyListeners(); }

  // ── Settings ──
  bool kindMode = true;
  bool notificationsOn = true;
  bool soundOn = true;
  bool darkModeOn = false;
  bool dailyPlanOn = true;
  void toggleSetting(String key) {
    switch (key) {
      case 'kind': kindMode = !kindMode;
      case 'notif': notificationsOn = !notificationsOn;
      case 'sound': soundOn = !soundOn;
      case 'dark': darkModeOn = !darkModeOn;
      case 'daily': dailyPlanOn = !dailyPlanOn;
    }
    notifyListeners();
  }

  // ── Community ──
  List<FriendItem> myFriends = [
    FriendItem(name: 'Sam', status: 'Finished 3 tiny wins'),
    FriendItem(name: 'Lee', status: 'Needs a gentle nudge'),
  ];
  List<CommunityUser> friendSuggestions = const [
    CommunityUser(name: 'Mira S.', compatibility: 72, avatar: 'MS'),
    CommunityUser(name: 'Dev P.', compatibility: 56, avatar: 'DP'),
    CommunityUser(name: 'Luna R.', compatibility: 23, avatar: 'LR'),
  ];
  List<CommunityGroup> myCommunities = [
    const CommunityGroup(name: 'Portfolio Builders', members: 142, tag: 'Build portfolios', creator: 'Maya Chen', created: 'Apr 2026', about: 'Portfolio builders sharing weekly reviews.'),
  ];
  List<CommunityGroup> communitySuggestions = const [
    CommunityGroup(name: 'Study Sprint Club', members: 89, tag: 'Exam prep', creator: 'Dr. Noor', created: 'Mar 2026', about: 'Focused study sprints.'),
    CommunityGroup(name: 'Consistency Crew', members: 234, tag: 'Habit trackers', creator: 'Ari Reed', created: 'Feb 2026', about: 'Daily routines and tiny wins.'),
    CommunityGroup(name: 'Creative Side Hustle', members: 67, tag: 'Designers & writers', creator: 'Zoe Park', created: 'Apr 2026', about: 'Creative side projects.'),
  ];
  void addFriend(CommunityUser u) {
    if (myFriends.any((f) => f.name == u.name)) return;
    myFriends.add(FriendItem(name: u.name, status: '${u.compatibility ?? 0}% match'));
    friendSuggestions = friendSuggestions.where((f) => f.name != u.name).toList();
    notifyListeners();
  }
  void removeFriend(String name) { myFriends.removeWhere((f) => f.name == name); notifyListeners(); }
  void joinCommunity(CommunityGroup g) {
    if (myCommunities.any((c) => c.name == g.name)) return;
    myCommunities.add(g);
    communitySuggestions = communitySuggestions.where((c) => c.name != g.name).toList();
    notifyListeners();
  }
  void createCommunity(String name) {
    myCommunities.add(CommunityGroup(name: name, members: 1, tag: 'Created by you', creator: user?.name ?? 'You', created: 'Today', about: 'New community for shared goals.'));
    notifyListeners();
  }
  void removeCommunity(String name) { myCommunities.removeWhere((c) => c.name == name); notifyListeners(); }

  // ── Guidance ──
  static const Map<String, String> guidance = {
    'Draft project outline': 'Start with 3 bullet points. Don\'t aim for perfect — just capture the core idea.',
    'Sketch homepage layout': 'Draw three blocks: hero, about, projects. Order first, details later.',
    'Write project descriptions': 'For each project: 1 sentence what, 1 sentence why. Max 2 paragraphs.',
    'Build hero section': 'Copy a hero you like, then replace the text and image.',
    'Solve 5 practice problems': 'Pick problems you\'re 70% confident about. Write the solution first.',
    'Make flashcards (chapter 4)': 'One concept per card. Max 15 cards per session.',
    'Mock exam timed': '30 minutes, no distractions. Skip stuck questions and return.',
    'Send weekly update': '3 lines: done, next, blocked.',
    'Reply to pending DMs': 'Batch reply, oldest first. Keep each under 3 sentences.',
  };
  static const String defaultGuidance = 'Start with the smallest step. Set a timer and go.';

  static List<GoalItem> _starterGoals() => [
    GoalItem(id: 1, title: 'Launch portfolio', importance: 5, category: 'Career',
      deadline: DateTime(2026, 4, 22), startColor: const Color(0xFF2DD4BF), endColor: const Color(0xFF10B981),
      subtasks: [
        SubTask(id: 101, goalId: 1, title: 'Draft project outline', duration: '12 min', load: TaskLoad.focus, points: 20, scheduledDate: DateTime(2026, 4, 15)),
        SubTask(id: 102, goalId: 1, title: 'Sketch homepage layout', duration: '15 min', load: TaskLoad.focus, points: 20, scheduledDate: DateTime(2026, 4, 16)),
        SubTask(id: 103, goalId: 1, title: 'Write project descriptions', duration: '20 min', load: TaskLoad.stretch, points: 25, scheduledDate: DateTime(2026, 4, 17)),
        SubTask(id: 105, goalId: 1, title: 'Build hero section', duration: '25 min', load: TaskLoad.stretch, points: 30, scheduledDate: DateTime(2026, 4, 19)),
      ]),
    GoalItem(id: 2, title: 'Exam prep', importance: 4, category: 'Study',
      deadline: DateTime(2026, 4, 28), startColor: const Color(0xFFFBBF24), endColor: const Color(0xFFF97316),
      subtasks: [
        SubTask(id: 202, goalId: 2, title: 'Solve 5 practice problems', duration: '15 min', load: TaskLoad.focus, points: 20, scheduledDate: DateTime(2026, 4, 15)),
        SubTask(id: 203, goalId: 2, title: 'Make flashcards (chapter 4)', duration: '12 min', load: TaskLoad.focus, points: 15, scheduledDate: DateTime(2026, 4, 17)),
        SubTask(id: 204, goalId: 2, title: 'Mock exam timed', duration: '30 min', load: TaskLoad.stretch, points: 35, scheduledDate: DateTime(2026, 4, 20)),
      ]),
    GoalItem(id: 3, title: 'Team comms', importance: 2, category: 'Work',
      deadline: DateTime(2026, 4, 30), startColor: const Color(0xFFA78BFA), endColor: const Color(0xFF8B5CF6),
      subtasks: [
        SubTask(id: 301, goalId: 3, title: 'Send weekly update', duration: '5 min', load: TaskLoad.light, points: 10, scheduledDate: DateTime(2026, 4, 15)),
        SubTask(id: 302, goalId: 3, title: 'Reply to pending DMs', duration: '10 min', load: TaskLoad.light, points: 10, scheduledDate: DateTime(2026, 4, 18)),
      ]),
  ];
}

class BreakdownChat {
  final String goal;
  final List<ChatMsg> messages;
  BreakdownChat({required this.goal, required this.messages});
}
