import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import '../core/constants/gd_constants.dart';
import '../core/theme/gd_colors.dart';
import '../core/utils/date_helpers.dart';
import '../data/seed_data.dart';
import '../features/calendar/calendar_page.dart';
import '../features/community/community_page.dart';
import '../features/companion/companion_page.dart';
import '../features/focus/widgets/focus_widgets.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/planner/planner_page.dart';
import '../features/responsive/responsive_goal_shell.dart';
import '../features/settings/settings_screen.dart';
import '../features/tasks/tasks_page.dart';
import '../main.dart';
import '../models/models.dart';
import '../services/ai/ai_models.dart';
import '../services/firebase/firebase_config.dart';
import '../services/firebase/goal_repository.dart';
import '../services/firebase/user_repository.dart';
import '../services/firebase/community_repository.dart';
import '../shared/widgets/shared_widgets.dart';

class GoalDiggerRoot extends StatefulWidget {
  const GoalDiggerRoot({super.key});
  @override
  State<GoalDiggerRoot> createState() => _GoalDiggerRootState();
}

class _GoalDiggerRootState extends State<GoalDiggerRoot> {
  // ── Services ────────────────────────────────────────────────────────────────
  late GoalRepository _goalRepo;
  late UserRepository _userRepo;
  late CommunityRepository _communityRepo;

  // ── Core state ───────────────────────────────────────────────────────────────
  final DateTime today = dateOnly(DateTime.now());
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _communityController = TextEditingController();

  bool _onboarded = false;
  bool _servicesReady = false;
  String _signedInWith = 'Guest';
  String? _uid;

  int _selectedIndex = 2;
  int _nextGoalId = 3;
  int _nextTaskId = 300;
  List<GoalProject> _goals = [];
  List<CommunityGroup> _communities = [];

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

  // ── Lifecycle ─────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _userRepo = UserRepository();
    _communities = _defaultCommunities();
    _initFirebaseSession();
  }

  @override
  void dispose() {
    _processingTimer?.cancel();
    _focusTimer?.cancel();
    _goalController.dispose();
    _communityController.dispose();
    super.dispose();
  }

  // ── Firebase session ──────────────────────────────────────────────────────────
  Future<void> _initFirebaseSession() async {
    try {
      if (auth.currentUser == null) {
        await _userRepo.signInAnonymously();
      }
      final uid = auth.currentUser!.uid;
      _uid = uid;
      _goalRepo = GoalRepository(uid: uid);
      _communityRepo = CommunityRepository(uid: uid);

      final profile = await _userRepo.fetchProfile(uid);
      if (profile != null && mounted) {
        setState(() {
          _coins = profile.coins;
          _streak = profile.streak;
          _petHappiness = profile.petHappiness;
          _activePetSkin = _skinFromName(profile.activePetSkin);
          _activeAccessory = profile.activeAccessory;
          _onboarded = profile.onboarded;
        });
      }

      final cloudGoals = await _goalRepo.fetchAllGoals();
      if (mounted) {
        if (cloudGoals.isNotEmpty) {
          setState(() => _goals = cloudGoals);
          _nextGoalId = cloudGoals.map((g) => g.id).reduce(max) + 1;
          final allTaskIds = cloudGoals.expand((g) => g.tasks.map((t) => t.id));
          if (allTaskIds.isNotEmpty) _nextTaskId = allTaskIds.reduce(max) + 1;
        } else {
          final seeded = seedGoals(today);
          setState(() => _goals = seeded);
          for (final g in seeded) await _goalRepo.saveGoal(g);
        }
        setState(() => _servicesReady = true);
      }
    } catch (e) {
      debugPrint('[GoalDigger] Firebase init failed, running offline: $e');
      if (mounted) {
        setState(() {
          _goals = seedGoals(today);
          _servicesReady = true;
        });
      }
    }
  }

  // ── Computed ──────────────────────────────────────────────────────────────────
  List<MicroTask> get _allTasks => _goals.expand((g) => g.tasks).toList();
  List<MicroTask> get _todayTasks =>
      _allTasks.where((t) => dateOnly(t.scheduledDate) == today).toList();
  GoalProject _goalForTask(MicroTask task) =>
      _goals.firstWhere((g) => g.id == task.goalId);
  int get _todayCompleted => _todayTasks.where((t) => t.done).length;
  double get _todayProgress =>
      _todayTasks.isEmpty ? 0 : _todayCompleted / _todayTasks.length;
  int get _remainingMinutes =>
      _todayTasks.where((t) => !t.done).fold(0, (s, t) => s + t.durationMinutes);
  String _formatFocusTime(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  // ── Persistence helpers ───────────────────────────────────────────────────────
  Future<void> _persistProfile() async {
    if (_uid == null) return;
    try {
      await _userRepo.updateProfileFields(_uid!, {
        'coins': _coins,
        'streak': _streak,
        'petHappiness': _petHappiness,
        'activePetSkin': _activePetSkin.name,
        'activeAccessory': _activeAccessory,
        'onboarded': _onboarded,
        'mood': _selectedMood,
      });
    } catch (e) { debugPrint('[GoalDigger] Profile save: $e'); }
  }

  Future<void> _persistGoal(GoalProject goal) async {
    try { await _goalRepo.saveGoal(goal); }
    catch (e) { debugPrint('[GoalDigger] Goal save: $e'); }
  }

  // ── UI helpers ────────────────────────────────────────────────────────────────
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
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.error_outline_rounded, color: gdError),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () { Navigator.pop(ctx); onAction(); },
            child: Text(actionLabel),
          ),
        ],
      ),
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

  // ── Onboarding ────────────────────────────────────────────────────────────────
  void _completeOnboarding(String provider) {
    setState(() { _signedInWith = provider; _onboarded = true; });
    _showMessage('Welcome! You signed in with $provider.');
    _persistProfile();
  }

  // ── Goal creation ─────────────────────────────────────────────────────────────
  void _createGoalWithProgress() {
    final title = _goalController.text.trim();
    if (title.isEmpty) {
      _showHelpfulError(
        title: 'Goal name is missing',
        message: 'Please write one clear goal. Example: "Prepare for midterm".',
        actionLabel: 'Write goal',
        onAction: () {},
      );
      return;
    }
    _openGoalBreakdownDialog(title);
  }

  Future<void> _openGoalBreakdownDialog(String goalTitle) async {
    final chatController = TextEditingController();

    final tempGoal = GoalProject(
      id: -1, title: goalTitle, importance: _newGoalPriority,
      category: _newGoalCategory, deadline: _newGoalDeadline,
      from: Colors.transparent, to: Colors.transparent, tasks: [],
    );

    List<String> draftTitles = [];
    bool aiLoading = true;
    String? aiErrorMsg;
    bool refining = false;

    final messages = <Map<String, dynamic>>[
      {'role': 'assistant', 'text': 'Breaking down "$goalTitle" with Gemma AI…',
       'tasks': <String>[], 'loading': true},
    ];

    final result = await showDialog<List<String>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(builder: (dialogCtx, setLocal) {

          // ── Load initial AI plan once ─────────────────────────────────────
          Future<void> loadPlan() async {
            try {
              final plan = await goalAI.generateTaskPlan(goal: tempGoal, today: today);
              draftTitles = plan.tasks.map((t) => t.title).toList();
              setLocal(() {
                aiLoading = false;
                messages[0] = {
                  'role': 'assistant',
                  'text': 'Here\'s a Gemma AI plan for "$goalTitle". ${plan.reasoning} '
                      'Ask me to adjust anything.',
                  'tasks': List<String>.from(draftTitles),
                  'loading': false,
                };
              });
            } catch (e) {
              draftTitles = _fallbackTaskTitles(goalTitle);
              setLocal(() {
                aiLoading = false;
                aiErrorMsg = e.toString();
                messages[0] = {
                  'role': 'assistant',
                  'text': 'Here are suggested tasks for "$goalTitle". You can refine them below.',
                  'tasks': List<String>.from(draftTitles),
                  'loading': false,
                };
              });
            }
          }

          if (aiLoading && aiErrorMsg == null) Future.microtask(loadPlan);

          // ── Refine via Gemma ──────────────────────────────────────────────
          Future<void> sendRefinement() async {
            final req = chatController.text.trim();
            if (req.isEmpty || aiLoading || refining) return;
            setLocal(() {
              refining = true;
              messages.add({'role': 'user', 'text': req, 'tasks': null, 'loading': false});
              messages.add({'role': 'assistant', 'text': 'Refining…', 'tasks': null, 'loading': true});
            });
            chatController.clear();
            try {
              final prompt = 'Current tasks for "$goalTitle":\n'
                  + draftTitles.asMap().entries.map((e) => '${e.key+1}. ${e.value}').join('\n')
                  + '\n\nUser request: $req\n\n'
                  'Return ONLY a JSON object: {"tasks": ["task 1", "task 2", ...]}. No markdown.';
              final response = await gemmaService.generate(
                GemmaRequest.singleTurn(prompt,
                  systemInstruction: 'Return only valid JSON.',
                  maxTokens: 600, temperature: 0.4,
                ),
              );
              final raw = response.text.trim();
              final start = raw.indexOf('{');
              final end = raw.lastIndexOf('}');
              if (start != -1 && end != -1) {
                final decoded = jsonDecode(raw.substring(start, end + 1)) as Map<String, dynamic>;
                final list = (decoded['tasks'] as List?)?.map((e) => e.toString()).toList();
                if (list != null && list.isNotEmpty) draftTitles = list;
              }
              setLocal(() {
                refining = false;
                messages.last = {
                  'role': 'assistant', 'text': 'Updated plan:',
                  'tasks': List<String>.from(draftTitles), 'loading': false,
                };
              });
            } catch (_) {
              setLocal(() {
                refining = false;
                messages.last = {
                  'role': 'assistant',
                  'text': 'Could not refine. Current plan still applies.',
                  'tasks': null, 'loading': false,
                };
              });
            }
          }

          // ── Bubble widget ─────────────────────────────────────────────────
          Widget bubble(Map<String, dynamic> msg) {
            final isUser = msg['role'] == 'user';
            final isLoad = msg['loading'] == true;
            final tasks = (msg['tasks'] as List?)?.cast<String>();
            final bgColor = isUser ? gdPrimary : const Color(0xFFF3F5F8);
            final fgColor = isUser ? Colors.white : gdInk;
            return Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 680),
                margin: EdgeInsets.only(left: isUser ? 44 : 0, right: isUser ? 0 : 44),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(26),
                    topRight: const Radius.circular(26),
                    bottomLeft: Radius.circular(isUser ? 26 : 8),
                    bottomRight: Radius.circular(isUser ? 8 : 26),
                  ),
                  border: !isUser ? Border.all(color: gdBorder) : null,
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (!isUser) ...[
                    Row(children: const [
                      CircleAvatar(radius: 15, backgroundColor: gdPrimarySoft,
                        child: Icon(Icons.auto_awesome_rounded, size: 16, color: gdPrimary)),
                      SizedBox(width: 8),
                      Text('Gemma AI', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w900)),
                    ]),
                    const SizedBox(height: 10),
                  ],
                  if (isLoad)
                    const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: gdPrimary))
                  else
                    Text(msg['text'] as String,
                      style: TextStyle(color: fgColor, fontSize: 15, height: 1.55, fontWeight: FontWeight.w700)),
                  if (tasks != null && tasks.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    for (var i = 0; i < tasks.length; i++)
                      Padding(padding: const EdgeInsets.only(bottom: 8),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            width: 26, height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isUser ? Colors.white.withOpacity(0.14) : Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: isUser ? Colors.white24 : gdBorder),
                            ),
                            child: Text('${i+1}',
                              style: TextStyle(color: isUser ? Colors.white : gdPrimary, fontWeight: FontWeight.w900)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Padding(padding: const EdgeInsets.only(top: 3),
                            child: Text(tasks[i],
                              style: TextStyle(color: fgColor, fontSize: 15, height: 1.45, fontWeight: FontWeight.w700)))),
                        ]),
                      ),
                  ],
                ]),
              ),
            );
          }

          // ── Dialog layout ─────────────────────────────────────────────────
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 880, maxHeight: MediaQuery.of(dialogCtx).size.height * 0.86),
              child: Container(
                decoration: BoxDecoration(
                  color: gdSurface,
                  borderRadius: BorderRadius.circular(34),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 28, offset: const Offset(0, 16))],
                ),
                child: Padding(padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                  child: Column(children: [
                    // Header
                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('AI GOAL BREAKDOWN',
                          style: TextStyle(color: Color(0xFF7C8AA5), fontSize: 13, letterSpacing: 3, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        Text(goalTitle, style: const TextStyle(color: gdInk, fontSize: 22, fontWeight: FontWeight.w900)),
                      ])),
                      Container(
                        decoration: BoxDecoration(color: const Color(0xFFF1F3F6), borderRadius: BorderRadius.circular(999)),
                        child: IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.pop(dialogCtx),
                          icon: const Icon(Icons.close_rounded, color: gdMuted),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 18),

                    // Chat feed
                    Expanded(child: Container(
                      decoration: BoxDecoration(color: const Color(0xFFFBFCFE), borderRadius: BorderRadius.circular(28), border: Border.all(color: gdBorder)),
                      padding: const EdgeInsets.all(16),
                      child: ListView.separated(
                        itemCount: messages.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => bubble(messages[i]),
                      ),
                    )),
                    const SizedBox(height: 16),

                    // Input row
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Expanded(child: TextField(
                        controller: chatController,
                        minLines: 1, maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => sendRefinement(),
                        decoration: InputDecoration(
                          hintText: 'Ask Gemma to adjust the plan…',
                          filled: true, fillColor: const Color(0xFFF7F5EF),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Color(0xFFE6DFD2))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: gdPrimary, width: 1.6)),
                        ),
                      )),
                      const SizedBox(width: 12),
                      SizedBox(height: 56, child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: gdPrimary, foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: refining ? null : sendRefinement,
                        child: refining
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Refine'),
                      )),
                    ]),
                    const SizedBox(height: 18),

                    // Finalize button
                    SizedBox(width: double.infinity, child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(64),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: aiLoading ? null : () => Navigator.pop(dialogCtx, List<String>.from(draftTitles)),
                      child: aiLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : const Text('Looks good, finalize!'),
                    )),
                  ]),
                ),
              ),
            ),
          );
        });
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => chatController.dispose());
    if (result != null) {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      _finishCreateGoal(goalTitle, approvedTaskTitles: result);
    }
  }

  void _finishCreateGoal(String title, {List<String>? approvedTaskTitles}) {
    final goalId = _nextGoalId++;
    final colors = _categoryColors(_newGoalCategory);
    final tasks = approvedTaskTitles == null
        ? _generateMicroTasks(title, goalId)
        : _buildMicroTasksFromTitles(approvedTaskTitles, goalId);
    final newGoal = GoalProject(
      id: goalId, title: title, importance: _newGoalPriority,
      category: _newGoalCategory, deadline: _newGoalDeadline,
      from: colors[0], to: colors[1], tasks: tasks,
    );
    setState(() {
      _goals.insert(0, newGoal);
      _isProcessing = false; _processingProgress = 0;
      _goalController.clear();
      _newGoalPriority = 3; _newGoalCategory = 'Study';
      _newGoalDeadline = addDays(today, 14);
    });
    _persistGoal(newGoal);
    _showMessage('Goal created. Your subtasks are scheduled.');
  }

  // ── Task operations ───────────────────────────────────────────────────────────
  void _toggleTask(MicroTask task) {
    setState(() {
      task.done = !task.done;
      if (task.done) { _coins += task.points; _petHappiness = min(100, _petHappiness + 8); }
      else { _coins = max(0, _coins - task.points); _petHappiness = max(0, _petHappiness - 8); }
    });
    _goalRepo.markTaskDone(task.goalId, task.id, done: task.done).catchError((_) {});
    _persistProfile();
  }

  void _deleteGoal(GoalProject goal) {
    setState(() => _goals.removeWhere((g) => g.id == goal.id));
    _showMessage('Removed ${goal.title}.');
    _goalRepo.deleteGoal(goal.id).catchError((_) {});
  }

  Future<void> _editGoalDeadline(GoalProject goal) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: goal.deadline.isBefore(today) ? today : goal.deadline,
      firstDate: today, lastDate: DateTime(today.year + 5),
    );
    if (picked == null) return;
    setState(() => goal.deadline = picked);
    _showMessage('Deadline updated to ${shortDate(picked)}.');
    _goalRepo.updateGoalFields(goal.id, {'deadline': picked.millisecondsSinceEpoch}).catchError((_) {});
  }

  Future<void> _editGoalPriority(GoalProject goal) async {
    var draft = goal.importance;
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: gdSurface,
          title: const Text('Edit priority'),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(goal.title, style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            PrioritySelector(value: draft, onChanged: (v) => setLocal(() => draft = v)),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, draft), child: const Text('Save priority')),
          ],
        ),
      ),
    );
    if (result == null) return;
    setState(() => goal.importance = result);
    _showMessage('Priority updated.');
    _goalRepo.updateGoalFields(goal.id, {'importance': result}).catchError((_) {});
  }

  // ── Community ─────────────────────────────────────────────────────────────────
  void _addCommunity() {
    final title = _communityController.text.trim();
    if (title.isEmpty) {
      _showHelpfulError(title: 'Community name is missing', message: 'Write a short name first.', actionLabel: 'Try again', onAction: () {});
      return;
    }
    final group = CommunityGroup(name: title, members: 1, tag: 'Created by you', similarity: 100, joined: true,
      description: 'A new accountability group for people with similar goals.');
    setState(() { _communities.insert(0, group); _communityController.clear(); });
    _communityRepo.addCommunity(group).catchError((_) {});
    _showMessage('Community created.');
  }

  void _joinCommunity(CommunityGroup group) { setState(() => group.joined = true); _showMessage('Joined ${group.name}.'); }
  void _deleteCommunity(CommunityGroup group) { setState(() => _communities.remove(group)); _showMessage('Removed ${group.name}.'); }
  void _addFriend(String name) { if (_friends.contains(name)) return; setState(() => _friends.add(name)); _showMessage('$name added.'); }
  void _deleteFriend(String name) { setState(() => _friends.remove(name)); _showMessage('Removed $name.'); }

  // ── Companion ─────────────────────────────────────────────────────────────────
  void _openPetChest() {
    if (_coins < 50) {
      _showHelpfulError(title: 'Not enough coins', message: 'A mystery chest costs 50 coins. Complete a few tasks first.', actionLabel: 'Got it', onAction: () {});
      return;
    }
    final skins = [defaultPet,
      const PetSkin(name: 'Peach', from: Color(0xFFFFB4A2), to: Color(0xFFFFD6A5), accent: Color(0xFFFFF1E6)),
      const PetSkin(name: 'Lunar', from: Color(0xFF64748B), to: Color(0xFF1E293B), accent: Color(0xFFE2E8F0))];
    final accessories = ['Cap', 'Star badge', 'Tiny scarf', 'Focus glasses'];
    final skin = skins[Random().nextInt(skins.length)];
    final acc = accessories[Random().nextInt(accessories.length)];
    setState(() { _coins -= 50; _activePetSkin = skin; _activeAccessory = acc; _petHappiness = min(100, _petHappiness + 6); });
    _persistProfile();
    _showMessage('Chest opened: ${skin.name} skin + $acc unlocked!');
  }

  void _feedPet() {
    if (_coins < 10) {
      _showHelpfulError(title: 'Not enough coins', message: 'Complete one task first.', actionLabel: 'Go to home', onAction: () => setState(() => _selectedIndex = 2));
      return;
    }
    setState(() { _coins -= 10; _petHappiness = min(100, _petHappiness + 12); });
    _persistProfile();
  }

  void _interactWithPet() {
    final reactions = [
      '${_activePetSkin.name} is cheering for you!',
      '${_activePetSkin.name} did a happy little bounce.',
      '${_activePetSkin.name} says: one tiny step counts!',
    ];
    setState(() => _petHappiness = min(100, _petHappiness + 2));
    _showMessage(reactions[Random().nextInt(reactions.length)]);
    _persistProfile();
  }

  // ── Focus mode ────────────────────────────────────────────────────────────────
  Future<void> _openFocusMode() async {
    if (_hasActiveFocus || _focusComplete) { _openActiveFocusDialog(); return; }
    final config = await showModalBottomSheet<FocusSessionConfig>(
      context: context, isScrollControlled: true, showDragHandle: true,
      backgroundColor: gdSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => FocusSetupSheet(todayTasks: _todayTasks.where((t) => !t.done).toList()),
    );
    if (!mounted || config == null) return;
    _startFocusSession(config);
  }

  void _startFocusSession(FocusSessionConfig config) {
    _focusTimer?.cancel();
    setState(() { _activeFocusConfig = config; _focusRemainingSeconds = config.durationMinutes * 60; _focusPaused = false; });
    _focusTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_focusPaused) return;
      setState(() => _focusRemainingSeconds = max(0, _focusRemainingSeconds - 1));
      if (_focusRemainingSeconds == 0) t.cancel();
    });
    _openActiveFocusDialog();
  }

  void _openActiveFocusDialog() {
    final config = _activeFocusConfig;
    if (config == null) return;
    showGeneralDialog<void>(
      context: context, barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.18),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, a, sa) => FocusCountdownDialog(
        config: config,
        remainingSecondsProvider: () => _focusRemainingSeconds,
        pausedProvider: () => _focusPaused,
        onPauseToggle: _toggleFocusPause,
        onMinimize: () => Navigator.of(ctx).pop(),
        onStop: _stopFocusSession,
      ),
      transitionBuilder: (ctx, a, sa, child) {
        final c = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
        return FadeTransition(opacity: c, child: ScaleTransition(scale: Tween<double>(begin: 0.98, end: 1).animate(c), child: child));
      },
    );
  }

  void _toggleFocusPause() => setState(() => _focusPaused = !_focusPaused);

  void _stopFocusSession() {
    _focusTimer?.cancel();
    setState(() { _activeFocusConfig = null; _focusRemainingSeconds = 0; _focusPaused = false; });
    Navigator.of(context, rootNavigator: true).maybePop();
  }

  // ── Profile & settings ────────────────────────────────────────────────────────
  void _openProfile() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (ctx) => Scaffold(
        backgroundColor: gdBackground,
        appBar: AppBar(centerTitle: true, title: const Text('Profile'),
          leading: IconButton(tooltip: 'Close', icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx))),
        body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 14, 20, 28), children: [
          AppCard(color: gdSurface, child: Padding(padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const CircleAvatar(radius: 36, backgroundColor: gdPrimarySoft,
                  child: Icon(Icons.account_circle_rounded, size: 42, color: gdPrimary)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Goal Digger User', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: gdInk)),
                  const SizedBox(height: 4),
                  Text('Signed in with $_signedInWith', style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
                  if (_uid != null) ...[
                    const SizedBox(height: 2),
                    Text('UID: ${_uid!.substring(0, 8)}…', style: const TextStyle(color: gdMuted, fontSize: 11)),
                  ],
                ])),
              ]),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(child: StatMiniCard(icon: Icons.paid_rounded, label: 'Coins', value: '$_coins')),
                const SizedBox(width: 10),
                Expanded(child: StatMiniCard(icon: Icons.local_fire_department_rounded, label: 'Streak', value: '$_streak days')),
              ]),
              const SizedBox(height: 14),
              Row(children: const [
                Icon(Icons.cloud_done_rounded, color: gdPrimary, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('Synced with Firebase Firestore', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700, fontSize: 13))),
                SizedBox(width: 8),
                Icon(Icons.auto_awesome_rounded, color: gdPrimary, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('Powered by Gemma 4 AI', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700, fontSize: 13))),
              ]),
            ]),
          )),
          const SizedBox(height: 16),
          AppCard(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: gdInk)),
            SizedBox(height: 10),
            ListTile(leading: Icon(Icons.shield_rounded), title: Text('Privacy'), subtitle: Text('Control what friends and communities can see.')),
          ]))),
          const SizedBox(height: 16),
          AppCard(color: gdPrimarySoft, child: const Padding(padding: EdgeInsets.all(18),
            child: Text('Friends are managed from the Community page under the Friends tab.',
              style: TextStyle(color: gdInk, fontWeight: FontWeight.w800, height: 1.4)))),
        ])),
      ),
    ));
  }

  void _openSettings() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true, builder: (ctx) => const SettingsScreen()));
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (!_onboarded) {
      return OnboardingScreen(
        onGoogle: () => _completeOnboarding('Google'),
        onLinkedIn: () => _completeOnboarding('LinkedIn'),
        onGuest: () => _completeOnboarding('Guest'),
      );
    }

    if (!_servicesReady) {
      return const Scaffold(
        backgroundColor: gdBackground,
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(color: gdPrimary),
          SizedBox(height: 16),
          Text('Loading your goals…', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
        ])),
      );
    }

    final pages = [
      PlannerPage(goals: _goals, today: today, goalController: _goalController,
        deadline: _newGoalDeadline, priority: _newGoalPriority, category: _newGoalCategory,
        isProcessing: _isProcessing, processingProgress: _processingProgress,
        onDeadlinePick: _pickDeadline,
        onPriorityChanged: (v) => setState(() => _newGoalPriority = v),
        onCategoryChanged: (v) => setState(() => _newGoalCategory = v),
        onCreateGoal: _createGoalWithProgress, onDeleteGoal: _deleteGoal,
        onEditGoalDeadline: _editGoalDeadline, onEditGoalPriority: _editGoalPriority,
        onCreateFirstGoal: () => setState(() => _selectedIndex = 0),
      ),
      CalendarPage(tasks: _allTasks, goalForTask: _goalForTask, today: today,
        onCreateGoal: () => setState(() => _selectedIndex = 0)),
      TasksPage(mood: _selectedMood, todayTasks: _todayTasks, todayProgress: _todayProgress,
        todayCompleted: _todayCompleted, todayTotal: _todayTasks.length,
        remainingMinutes: _remainingMinutes, goalForTask: _goalForTask,
        onMoodChanged: (v) => setState(() => _selectedMood = v),
        onToggleTask: _toggleTask, onCreateGoal: () => setState(() => _selectedIndex = 0)),
      CommunityPage(controller: _communityController, communities: _communities,
        friends: _friends, friendSuggestions: _friendSuggestions, streak: _streak,
        onAddCommunity: _addCommunity, onJoinCommunity: _joinCommunity,
        onDeleteCommunity: _deleteCommunity, onAddFriend: _addFriend, onDeleteFriend: _deleteFriend),
      CompanionPage(coins: _coins, happiness: _petHappiness, pet: _activePetSkin,
        accessory: _activeAccessory, onFeed: _feedPet, onOpenChest: _openPetChest, onPetInteract: _interactWithPet),
    ];

    return ResponsiveGoalShell(
      selectedIndex: _selectedIndex, signedInWith: _signedInWith, pages: pages,
      onSelect: (i) => setState(() => _selectedIndex = i),
      onFocusMode: _openFocusMode, onProfile: _openProfile, onSettings: _openSettings,
      hasActiveFocus: _hasActiveFocus || _focusComplete,
      focusLabel: _activeFocusConfig == null ? null : (_focusComplete ? 'Done' : _formatFocusTime(_focusRemainingSeconds)),
    );
  }

  // ── Utilities ─────────────────────────────────────────────────────────────────
  List<Color> _categoryColors(String cat) => switch (cat) {
    'Career'   => [gdGradientCareerFrom, gdGradientCareerTo],
    'Wellness' => [gdGradientWellnessFrom, gdGradientWellnessTo],
    'Finance'  => [gdGradientFinanceFrom, gdGradientFinanceTo],
    'Creative' => [gdGradientCreativeFrom, gdGradientCreativeTo],
    _          => [gdGradientStudyFrom, gdGradientStudyTo],
  };

  List<String> _fallbackTaskTitles(String title) {
    final l = title.toLowerCase();
    if (l.contains('exam') || l.contains('study'))
      return ['List topics to review', 'Study hardest topic 20 min', 'Solve practice problems', 'Review and make flashcards'];
    if (l.contains('portfolio') || l.contains('project'))
      return ['Define the project outcome', 'Create first rough draft', 'Improve one visible section', 'Share for feedback'];
    return ['Write the desired outcome', 'Break into 3 milestones', 'Do the smallest first action', 'Review and adjust tomorrow'];
  }

  List<MicroTask> _generateMicroTasks(String title, int goalId) =>
      _buildMicroTasksFromTitles(_fallbackTaskTitles(title), goalId);

  List<MicroTask> _buildMicroTasksFromTitles(List<String> titles, int goalId) =>
      List.generate(titles.length, (i) => MicroTask(
        id: _nextTaskId++, goalId: goalId, title: titles[i],
        durationMinutes: i == 0 ? 8 : 15 + i * 5,
        load: i == 0 ? TaskLoad.light : i == titles.length - 1 ? TaskLoad.stretch : TaskLoad.focus,
        scheduledDate: addDays(today, i),
        points: 10 + i * 5,
      ));

  PetSkin _skinFromName(String name) => switch (name) {
    'Peach' => const PetSkin(name: 'Peach', from: Color(0xFFFFB4A2), to: Color(0xFFFFD6A5), accent: Color(0xFFFFF1E6)),
    'Lunar' => const PetSkin(name: 'Lunar', from: Color(0xFF64748B), to: Color(0xFF1E293B), accent: Color(0xFFE2E8F0)),
    _       => defaultPet,
  };

  List<CommunityGroup> _defaultCommunities() => [
    CommunityGroup(name: 'Study Sprint Club', members: 89, tag: 'Exam prep', similarity: 94,
      description: 'Short daily sprints for students who want accountability.'),
    CommunityGroup(name: 'Portfolio Builders', members: 142, tag: 'Career', similarity: 88,
      description: 'Share portfolio progress and get feedback from builders.'),
    CommunityGroup(name: 'Calm Wellness Crew', members: 76, tag: 'Wellness', similarity: 81,
      description: 'Build low-pressure routines around sleep, movement, and reflection.'),
  ];
}
