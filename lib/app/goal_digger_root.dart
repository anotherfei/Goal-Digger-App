import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
import '../firebase/auth/auth_service.dart';
import '../firebase/auth/auth_state.dart';
import '../firebase/firestore/repositories/user_repository.dart';
import '../firebase/sync/app_sync_service.dart';
import '../genkit/genkit_service.dart';
import '../genkit/models/ai_models.dart';
import '../models/models.dart';
import '../shared/widgets/shared_widgets.dart';


class _DraftTaskSpec {
  const _DraftTaskSpec({
    required this.title,
    required this.durationMinutes,
    required this.load,
    required this.dayOffset,
  });

  final String title;
  final int durationMinutes;
  final TaskLoad load;
  final int dayOffset;

  String get previewLabel =>
      '$title · $durationMinutes min · ${load.label} · Day ${dayOffset + 1}';
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
  late List<GoalProject> _goals;
  late List<CommunityGroup> _communities;

  final UserRepository _userRepository = UserRepository();
  AppSyncService? _sync;
  StreamSubscription<List<GoalProject>>? _goalsSub;
  StreamSubscription<UserProfile?>? _profileSub;
  StreamSubscription<List<CommunityGroup>>? _communitiesSub;
  StreamSubscription<Set<String>>? _joinedCommunitiesSub;
  StreamSubscription<List<RoutineItem>>? _routinesSub;
  String? _activeUid;
  Set<String> _joinedCommunityIds = {};
  List<RoutineItem> _routines = [];

  // Auth listener wiring — avoids calling side-effecting _bindAuthState
  // inside build(), which can trigger setState-during-build violations.
  AuthState? _watchedAuthState;

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
  bool _goalReminders = true;
  bool _friendProgressSharing = true;
  List<String> _friends = ['Maya Chen', 'Leo Tan', 'Ari Putra'];
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
    _routines = _defaultRoutines();
    _communities = _defaultCommunities();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Attach a listener to AuthState so auth-change side effects (sync
    // activation, Firestore writes) never run inside build().
    final newAuth = context.read<AuthState>();
    if (_watchedAuthState != newAuth) {
      _watchedAuthState?.removeListener(_onAuthStateChanged);
      _watchedAuthState = newAuth;
      newAuth.addListener(_onAuthStateChanged);
      // Handle the state that is already current on first attach.
      _onAuthStateChanged();
    }
  }

  // Called by AuthState whenever the Firebase user changes.
  void _onAuthStateChanged() {
    if (!mounted) return;
    final authState = _watchedAuthState;
    if (authState == null) return;

    final uid = authState.uid;
    if (uid.isEmpty) {
      if (_activeUid != null) {
        _resetForSignedOutState();
      }
      return;
    }

    if (_activeUid == uid) return;
    _activeUid = uid;
    _activateSync(uid);
    unawaited(_ensureUserProfile(authState));
  }

  List<RoutineItem> _defaultRoutines() => [
        RoutineItem(
          title: 'Morning goal review',
          startsAt: DateTime(today.year, today.month, today.day, 8),
          repeat: RoutineRepeat.daily,
        ),
        RoutineItem(
          title: 'Evening reflection',
          startsAt: DateTime(today.year, today.month, today.day, 20),
          repeat: RoutineRepeat.weekly,
        ),
      ];

  List<CommunityGroup> _defaultCommunities() => [
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

  @override
  void dispose() {
    _watchedAuthState?.removeListener(_onAuthStateChanged);
    _processingTimer?.cancel();
    _focusTimer?.cancel();
    _disposeSync();
    _goalController.dispose();
    _communityController.dispose();
    super.dispose();
  }

  void _disposeSync() {
    _goalsSub?.cancel();
    _profileSub?.cancel();
    _communitiesSub?.cancel();
    _joinedCommunitiesSub?.cancel();
    _routinesSub?.cancel();
    _goalsSub = null;
    _profileSub = null;
    _communitiesSub = null;
    _joinedCommunitiesSub = null;
    _routinesSub = null;
    _sync?.dispose();
    _sync = null;
  }

  void _resetForSignedOutState() {
    _activeUid = null;
    _disposeSync();
    setState(() {
      _onboarded = false;
      _signedInWith = 'Guest';
      _selectedIndex = 2;
      _goals = seedGoals(today);
      _routines = _defaultRoutines();
      _friends = ['Maya Chen', 'Leo Tan', 'Ari Putra'];
    });
  }

  Future<void> _ensureUserProfile(AuthState authState) async {
    final user = authState.user ?? context.read<AuthService>().currentUser;
    if (user == null) return;
    try {
      await _userRepository.createOrUpdateProfile(
        uid: user.uid,
        displayName: user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : user.isAnonymous
                ? 'Guest User'
                : 'Goal Digger User',
        email: user.email,
        photoUrl: user.photoURL,
      );
    } catch (e) {
      debugPrint('Could not ensure user profile: $e');
    }
  }

  void _activateSync(String uid) {
    _disposeSync();
    final sync = AppSyncService(uid: uid);
    _sync = sync;

    _goalsSub = sync.goalsStream.listen(
      (goals) {
        if (!mounted) return;
        setState(() => _goals = goals);
      },
      onError: (Object error) => debugPrint('Goal sync error: $error'),
    );

    _profileSub = sync.profileStream.listen(
      (profile) {
        if (!mounted || profile == null) return;
        setState(() {
          _coins = profile.coins;
          _streak = profile.streak;
          _petHappiness = profile.petHappiness;
          _activePetSkin = profile.activePetSkin;
          _activeAccessory = profile.activeAccessory;
          _selectedMood = profile.selectedMood;
          _goalReminders = profile.goalReminders;
          _friendProgressSharing = profile.friendProgressSharing;
          _friends = profile.friends.isEmpty
              ? ['Maya Chen', 'Leo Tan', 'Ari Putra']
              : List<String>.from(profile.friends);
          _onboarded = profile.onboarded;
          final user = context.read<AuthService>().currentUser;
          final providerId = user?.providerData.isNotEmpty == true
              ? user!.providerData.first.providerId
              : null;
          _signedInWith = user?.isAnonymous == true
              ? 'Guest'
              : providerId == 'google.com'
                  ? 'Google'
                  : 'Firebase';
        });
      },
      onError: (Object error) => debugPrint('Profile sync error: $error'),
    );

    _communitiesSub = sync.communitiesStream.listen(
      (communities) {
        if (!mounted || communities.isEmpty) return;
        setState(() => _communities = _withJoinedCommunityState(communities));
      },
      onError: (Object error) => debugPrint('Community sync error: $error'),
    );

    _joinedCommunitiesSub = sync.joinedCommunityIdsStream.listen(
      (ids) {
        if (!mounted) return;
        setState(() {
          _joinedCommunityIds = ids;
          _communities = _withJoinedCommunityState(_communities);
        });
      },
      onError: (Object error) => debugPrint('Membership sync error: $error'),
    );

    _routinesSub = sync.routinesStream.listen(
      (routines) {
        if (!mounted) return;
        setState(() => _routines = routines);
      },
      onError: (Object error) => debugPrint('Routine sync error: $error'),
    );
  }

  List<CommunityGroup> _withJoinedCommunityState(List<CommunityGroup> groups) {
    for (final group in groups) {
      final id = group.backendId;
      if (id != null) group.joined = _joinedCommunityIds.contains(id);
    }
    return groups;
  }

  Future<void> _persistProfileStats() async {
    final sync = _sync;
    if (sync == null) return;
    try {
      // Use setCoins (absolute write) so the Firestore value always matches
      // the authoritative local total, which already has all increments/
      // decrements from task toggles and pet interactions applied.
      await sync.setCoins(_coins);
      await sync.updateStreak(_streak);
      await sync.updateMood(_selectedMood);
      await sync.updatePetState(_petHappiness, _activePetSkin, _activeAccessory);
    } catch (e) {
      debugPrint('Profile write failed: $e');
    }
  }

  Future<void> _persistPreferences() async {
    final sync = _sync;
    if (sync == null) return;
    try {
      await sync.updatePreferences(
        goalReminders: _goalReminders,
        friendProgressSharing: _friendProgressSharing,
      );
    } catch (e) {
      debugPrint('Preference write failed: $e');
    }
  }

  void _setGoalReminders(bool value) {
    setState(() => _goalReminders = value);
    unawaited(_persistPreferences());
  }

  void _setFriendProgressSharing(bool value) {
    setState(() => _friendProgressSharing = value);
    unawaited(_persistPreferences());
  }

  Future<void> _handleSignOut() async {
    unawaited(Navigator.of(context).maybePop());
    try {
      await context.read<AuthState>().signOut();
    } catch (e) {
      debugPrint('Sign out failed: $e');
    }
    if (!mounted) return;
    _resetForSignedOutState();
  }

  Future<void> _completeOnboardingWithAuth(String provider) async {
    final authState = context.read<AuthState>();
    try {
      if (provider == 'Google') {
        await authState.signInWithGoogle();
      } else {
        await authState.signInAsGuest();
      }

      final user = context.read<AuthService>().currentUser ?? authState.user;
      if (user == null) {
        throw StateError('Firebase did not return a signed-in user.');
      }

      await _userRepository.createOrUpdateProfile(
        uid: user.uid,
        displayName: user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : provider == 'Guest'
                ? 'Guest User'
                : 'Goal Digger User',
        email: user.email,
        photoUrl: user.photoURL,
      );
      await _userRepository.markOnboarded(user.uid);
      _activeUid = user.uid;
      _activateSync(user.uid);

      if (!mounted) return;
      setState(() {
        _signedInWith = provider;
        _onboarded = true;
      });
      _showMessage('Welcome! You signed in with $provider.');
    } catch (e) {
      if (!mounted) return;
      _showHelpfulError(
        title: '$provider sign-in failed',
        message: 'Firebase could not complete sign-in. Check that Firebase Auth is enabled and your app uses the correct Firebase project. Details: $e',
        actionLabel: 'Continue as guest',
        onAction: () => unawaited(_completeOnboardingWithAuth('Guest')),
      );
    }
  }

  void _showLinkedInUnavailable() {
    _showHelpfulError(
      title: 'LinkedIn is not configured yet',
      message: 'The backend currently supports Firebase Google sign-in and anonymous guest preview. LinkedIn needs an OAuth provider setup before it can be a real login method.',
      actionLabel: 'Preview as guest',
      onAction: () => unawaited(_completeOnboardingWithAuth('Guest')),
    );
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
        message: 'Please write one clear goal first. Example: "Prepare for midterm" or "Build my portfolio".',
        actionLabel: 'Write goal',
        onAction: () {},
      );
      return;
    }
    _openGoalBreakdownDialog(title);
  }

  Future<void> _openGoalBreakdownDialog(String title) async {
    // Create the controller here and dispose it reliably when the dialog closes.
    final chatController = TextEditingController();

    try {
      await _runGoalBreakdownDialog(title, chatController);
    } finally {
      // Guaranteed disposal — regardless of how the dialog was dismissed.
      chatController.dispose();
    }
  }

  Future<void> _runGoalBreakdownDialog(
      String title, TextEditingController chatController) async {
    final ai = context.read<GenkitService>();
    final fallbackSpecs = _draftSpecsFromTitles(_generateTaskTitles(title));
    final deadlineDays = max(1, dateOnly(_newGoalDeadline).difference(today).inDays);
    var draftSpecs = List<_DraftTaskSpec>.from(fallbackSpecs);
    var aiAvailable = false;
    String? agentStrategy;

    try {
      final agentPlan = await ai.agentPlanner.plan(
        AgentPlannerRequest(
          goal: title,
          context: {
            'category': _newGoalCategory,
            'priority': _newGoalPriority,
            'deadlineDays': deadlineDays,
            'completedToday': _todayCompleted,
            'totalToday': _todayTasks.length,
            'mood': _selectedMood,
            'streak': _streak,
          },
        ),
      );
      agentStrategy = agentPlan.plan['strategy']?.toString();
    } catch (e) {
      debugPrint('Agent planner unavailable: $e');
    }

    try {
      final generated = await ai.taskGenerator.generate(
        TaskGeneratorRequest(
          goalTitle: title,
          category: _newGoalCategory,
          priority: _newGoalPriority,
          deadlineDays: deadlineDays,
        ),
      );
      final aiSpecs = _draftSpecsFromGeneratedTasks(generated.tasks).take(6).toList();
      if (aiSpecs.isNotEmpty) {
        draftSpecs = aiSpecs;
        aiAvailable = true;
      }
    } catch (e) {
      debugPrint('AI task generation fallback used: $e');
    }

    final agentSuffix = agentStrategy == null ? '' : ' and agent planner ($agentStrategy)';
    final messages = <Map<String, dynamic>>[
      {
        'role': 'assistant',
        'text': aiAvailable
            ? 'Great! I used the backend AI task generator$agentSuffix to break "$title" into ${draftSpecs.length} micro-tasks. You can ask me to make the plan easier, more detailed, or reorder it before scheduling.'
            : 'I could not reach the backend AI task generator, so I prepared a local fallback plan for "$title". You can still adjust it before scheduling.',
        'tasks': _draftPreviewLabels(draftSpecs),
      },
    ];

    final result = await showDialog<List<_DraftTaskSpec>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        var isAiThinking = false;
        return StatefulBuilder(
          builder: (dialogContext, setLocalState) {
            Future<void> sendMessage() async {
              final request = chatController.text.trim();
              if (request.isEmpty || isAiThinking) return;

              final history = messages
                  .where((message) => message['text'] is String)
                  .map(
                    (message) => ChatMessage(
                      role: message['role'] == 'user' ? 'user' : 'model',
                      content: message['text'] as String,
                    ),
                  )
                  .toList();

              setLocalState(() {
                isAiThinking = true;
                messages.add({'role': 'user', 'text': request});
                chatController.clear();
              });

              try {
                final reply = await ai.goalCoach.ask(
                  GoalCoachRequest(
                    userMessage: "$request\nCurrent draft tasks: ${draftSpecs.map((task) => task.previewLabel).join('; ')}",
                    goalTitle: title,
                    conversationHistory: history,
                    progressPercent: 0,
                  ),
                );

                final suggested = reply.suggestedActions
                    .map((task) => task.trim())
                    .where((task) => task.isNotEmpty)
                    .take(6)
                    .toList();
                if (suggested.isNotEmpty) {
                  draftSpecs = _draftSpecsFromTitles(suggested).take(6).toList();
                }

                if (!dialogContext.mounted) return;
                setLocalState(() {
                  messages.add({
                    'role': 'assistant',
                    'text': reply.reply.trim().isEmpty
                        ? 'I refined the plan based on your request.'
                        : reply.reply.trim(),
                    'tasks': _draftPreviewLabels(draftSpecs),
                  });
                  isAiThinking = false;
                });
              } catch (e) {
                final refined = _refineTaskTitlesFromPrompt(
                  draftSpecs.map((task) => task.title).toList(),
                  request,
                  title,
                );
                draftSpecs = _draftSpecsFromTitles(refined).take(6).toList();
                if (!dialogContext.mounted) return;
                setLocalState(() {
                  messages.add({
                    'role': 'assistant',
                    'text': 'The AI coach endpoint is unavailable right now, so I refined the plan locally. You can still finalize this draft.',
                    'tasks': _draftPreviewLabels(draftSpecs),
                  });
                  isAiThinking = false;
                });
              }
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
                              'AI Assistant',
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
                              itemCount: messages.length + (isAiThinking ? 1 : 0),
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                if (index < messages.length) {
                                  return buildMessageBubble(messages[index]);
                                }
                                return const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Chip(
                                    avatar: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    label: Text('AI is thinking...'),
                                  ),
                                );
                              },
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
                                  hintText: 'Adjust the AI plan...',
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
                                onPressed: isAiThinking ? null : sendMessage,
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
                            onPressed: isAiThinking
                                ? null
                                : () => Navigator.pop(
                                      dialogContext,
                                      List<_DraftTaskSpec>.from(draftSpecs),
                                    ),
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

    if (result != null && mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      await _finishCreateGoal(title, approvedTaskSpecs: result);
    }
  }

  Future<void> _finishCreateGoal(String title, {List<_DraftTaskSpec>? approvedTaskSpecs}) async {
    final goalId = DateTime.now().microsecondsSinceEpoch;
    final colors = _categoryColors(_newGoalCategory);
    final steps = approvedTaskSpecs == null
        ? _generateMicroTasks(title, goalId)
        : _generateMicroTasksFromSpecs(approvedTaskSpecs, goalId);
    final goal = GoalProject(
      id: goalId,
      title: title,
      importance: _newGoalPriority,
      category: _newGoalCategory,
      deadline: _newGoalDeadline,
      from: colors[0],
      to: colors[1],
      tasks: steps,
    );

    setState(() {
      _goals.insert(0, goal);
      _isProcessing = false;
      _processingProgress = 0;
      _goalController.clear();
      _newGoalPriority = 3;
      _newGoalCategory = 'Study';
      _newGoalDeadline = addDays(today, 14);
    });

    final sync = _sync;
    if (sync != null) {
      try {
        await sync.createGoal(goal);
      } catch (e) {
        debugPrint('Goal persistence failed: $e');
        _showMessage('Goal created locally, but Firebase save failed. Check Firestore rules/network.');
        return;
      }
    }
    _showMessage('Goal created. AI subtasks are scheduled and synced.');
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

  List<String> _draftPreviewLabels(List<_DraftTaskSpec> specs) {
    return specs.map((task) => task.previewLabel).toList();
  }

  List<_DraftTaskSpec> _draftSpecsFromGeneratedTasks(List<GeneratedTask> tasks) {
    final deadlineDays = max(1, dateOnly(_newGoalDeadline).difference(today).inDays);
    return tasks
        .where((task) => task.title.trim().isNotEmpty)
        .map((task) {
      final duration = task.durationMinutes.clamp(5, 90).toInt();
      return _DraftTaskSpec(
        title: task.title.trim(),
        durationMinutes: duration,
        load: _taskLoadFromAi(task.load, duration),
        dayOffset: task.dayOffset.clamp(0, deadlineDays).toInt(),
      );
    }).toList();
  }

  List<_DraftTaskSpec> _draftSpecsFromTitles(Iterable<String> titles) {
    final cleaned = titles
        .map((title) => title.trim())
        .where((title) => title.isNotEmpty)
        .toList();

    return List.generate(cleaned.length, (index) {
      final duration = index == 0 ? 10 : 15 + index * 5;
      final load = index == 0
          ? TaskLoad.light
          : index == cleaned.length - 1
              ? TaskLoad.stretch
              : TaskLoad.focus;
      return _DraftTaskSpec(
        title: cleaned[index],
        durationMinutes: duration,
        load: load,
        dayOffset: index,
      );
    });
  }

  TaskLoad _taskLoadFromAi(String load, int durationMinutes) {
    switch (load.toLowerCase().trim()) {
      case 'light':
        return TaskLoad.light;
      case 'stretch':
        return TaskLoad.stretch;
      case 'focus':
        return TaskLoad.focus;
    }
    if (durationMinutes <= 15) return TaskLoad.light;
    if (durationMinutes > 30) return TaskLoad.stretch;
    return TaskLoad.focus;
  }

  List<MicroTask> _generateMicroTasks(String title, int goalId) {
    return _generateMicroTasksFromTitles(_generateTaskTitles(title), goalId);
  }

  List<MicroTask> _generateMicroTasksFromTitles(List<String> taskTitles, int goalId) {
    return _generateMicroTasksFromSpecs(_draftSpecsFromTitles(taskTitles), goalId);
  }

  List<MicroTask> _generateMicroTasksFromSpecs(List<_DraftTaskSpec> taskSpecs, int goalId) {
    final baseTaskId = DateTime.now().microsecondsSinceEpoch;
    return List.generate(taskSpecs.length, (index) {
      final spec = taskSpecs[index];
      return MicroTask(
        id: baseTaskId + index,
        goalId: goalId,
        title: spec.title,
        durationMinutes: spec.durationMinutes,
        load: spec.load,
        scheduledDate: addDays(today, spec.dayOffset),
        points: max(8, (spec.durationMinutes / 2).round() + index * 3),
      );
    });
  }

  void _toggleTask(MicroTask task) {
    final goal = _goalForTask(task);
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
    unawaited(_persistTaskToggle(goal, task));
    unawaited(_persistProfileStats());
  }

  Future<void> _persistTaskToggle(GoalProject goal, MicroTask task) async {
    final sync = _sync;
    if (sync == null) return;
    try {
      await sync.toggleTask(
        goal.id.toString(),
        task.id.toString(),
        task.done,
      );
      await sync.updateGoal(goal);
    } catch (e) {
      debugPrint('Task sync failed: $e');
    }
  }

  void _deleteGoal(GoalProject goal) {
    setState(() => _goals.removeWhere((item) => item.id == goal.id));
    final sync = _sync;
    if (sync != null) {
      unawaited(sync.deleteGoal(goal.id.toString()).catchError((Object e) {
        debugPrint('Delete goal sync failed: $e');
      }));
    }
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

    final community = CommunityGroup(
      name: title,
      members: 1,
      tag: 'Created by you',
      similarity: 100,
      joined: true,
      description: 'A new accountability group for people working on similar goals.',
    );
    setState(() {
      _communities.insert(0, community);
      _communityController.clear();
    });

    final sync = _sync;
    if (sync != null) {
      unawaited(sync.createCommunity(community).then((persisted) {
        if (!mounted) return;
        setState(() {
          _communities.remove(community);
          _communities.insert(0, persisted);
        });
      }).catchError((Object e) {
        debugPrint('Create community sync failed: $e');
        _showMessage('Community created locally, but Firebase save failed.');
      }));
    }
    _showMessage('Community created.');
  }

  void _joinCommunity(CommunityGroup group) {
    setState(() => group.joined = true);
    final id = group.backendId;
    final sync = _sync;
    if (sync != null && id != null) {
      unawaited(sync.joinCommunity(id).catchError((Object e) {
        debugPrint('Join community sync failed: $e');
      }));
    }
    _showMessage('Joined ${group.name}.');
  }

  void _deleteCommunity(CommunityGroup group) {
    setState(() => group.joined = false);
    final id = group.backendId;
    final sync = _sync;
    if (sync != null && id != null) {
      unawaited(sync.leaveCommunity(id).catchError((Object e) {
        debugPrint('Leave community sync failed: $e');
      }));
    }
    _showMessage('Left ${group.name}.');
  }

  void _persistFriends() {
    final sync = _sync;
    if (sync == null) return;
    unawaited(sync.updateFriends(_friends).catchError((Object e) {
      debugPrint('Friend sync failed: $e');
    }));
  }

  void _addFriend(String name) {
    final cleaned = name.trim();
    if (cleaned.isEmpty || _friends.contains(cleaned)) return;
    setState(() => _friends.add(cleaned));
    _persistFriends();
    _showMessage('$cleaned added as a friend.');
  }

  void _deleteFriend(String name) {
    setState(() => _friends.remove(name));
    _persistFriends();
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
    unawaited(_persistProfileStats());
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
    unawaited(_persistProfileStats());
  }

  void _interactWithPet() {
    final reactions = [
      '${_activePetSkin.name} is cheering for you!',
      '${_activePetSkin.name} did a happy little bounce.',
      '${_activePetSkin.name} says: one tiny step counts!',
      '${_activePetSkin.name} feels closer to you.',
    ];
    setState(() => _petHappiness = min(100, _petHappiness + 2));
    unawaited(_persistProfileStats());
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

  void _handleMoodChanged(String value) {
    setState(() => _selectedMood = value);
    unawaited(_persistProfileStats());
    unawaited(_requestMoodAdvice(value));
  }

  Future<void> _requestMoodAdvice(String mood) async {
    try {
      final advice = await context.read<GenkitService>().moodAdvisor.advise(
            MoodAdvisorRequest(
              mood: mood,
              completedToday: _todayCompleted,
              totalToday: _todayTasks.length,
              streak: _streak,
            ),
          );
      if (!mounted) return;
      _showMessage('AI mood plan: ${advice.message}');
    } catch (e) {
      debugPrint('Mood advisor unavailable: $e');
    }
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
    final config = _activeFocusConfig;
    final completed = _focusRemainingSeconds <= 0;
    _focusTimer?.cancel();

    if (completed && config?.task != null && config!.task!.done == false) {
      _toggleTask(config.task!);
    }

    setState(() {
      _activeFocusConfig = null;
      _focusRemainingSeconds = 0;
      _focusPaused = false;
    });
    Navigator.of(context, rootNavigator: true).maybePop();

    if (config != null) {
      unawaited(_requestFocusInsight(config, completed: completed));
    }
  }

  Future<void> _requestFocusInsight(
    FocusSessionConfig config, {
    required bool completed,
  }) async {
    try {
      final task = config.task;
      final goal = task == null ? null : _goalForTask(task);
      final insight = await context.read<GenkitService>().focusInsight.analyse(
            FocusInsightRequest(
              taskTitle: config.title,
              goalTitle: goal?.title ?? 'Custom focus session',
              durationMinutes: config.durationMinutes,
              completed: completed,
            ),
          );
      if (!mounted) return;
      if (completed && insight.coinsEarned > 0) {
        setState(() {
          _coins += insight.coinsEarned;
          _petHappiness = min(100, _petHappiness + 4);
        });
        unawaited(_persistProfileStats());
      }
      _showMessage('AI focus insight: ${insight.insight}');
    } catch (e) {
      debugPrint('Focus insight unavailable: $e');
    }
  }

  void _openProfile() {
    final authState = context.read<AuthState>();
    final displayName = authState.displayName;
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
                                  Text(displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: gdInk)),
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

  void _addRoutine(RoutineItem routine) {
    setState(() => _routines.add(routine));
    final sync = _sync;
    if (sync != null) {
      unawaited(sync.createRoutine(routine).catchError((Object e) {
        debugPrint('Routine sync failed: $e');
        _showMessage('Routine added locally, but Firebase save failed.');
      }));
    }
    _showMessage('Routine added.');
  }

  void _deleteRoutine(RoutineItem routine) {
    setState(() => _routines.removeWhere((item) => item.id == routine.id));
    final sync = _sync;
    if (sync != null) {
      unawaited(sync.deleteRoutine(routine.id).catchError((Object e) {
        debugPrint('Routine delete sync failed: $e');
      }));
    }
    _showMessage('Routine deleted.');
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => SettingsScreen(
          goalReminders: _goalReminders,
          friendProgressSharing: _friendProgressSharing,
          onGoalRemindersChanged: _setGoalReminders,
          onFriendProgressSharingChanged: _setFriendProgressSharing,
          onSignOut: () => unawaited(_handleSignOut()),
        ),
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
    final sync = _sync;
    if (sync != null) {
      unawaited(sync.updateGoal(goal).catchError((Object e) {
        debugPrint('Deadline sync failed: $e');
      }));
    }
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
    final sync = _sync;
    if (sync != null) {
      unawaited(sync.updateGoal(goal).catchError((Object e) {
        debugPrint('Priority sync failed: $e');
      }));
    }
    _showMessage('Priority updated.');
  }

  @override
  Widget build(BuildContext context) {
    // context.watch triggers rebuild when AuthState notifies.
    // All side effects (sync activation, Firestore writes) are handled
    // in _onAuthStateChanged via the addListener wired in didChangeDependencies.
    final authState = context.watch<AuthState>();

    if (!authState.isKnown) {
      return const Scaffold(
        backgroundColor: gdBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_onboarded) {
      return OnboardingScreen(
        onGoogle: () => unawaited(_completeOnboardingWithAuth('Google')),
        onLinkedIn: _showLinkedInUnavailable,
        onGuest: () => unawaited(_completeOnboardingWithAuth('Guest')),
      );
    }

    final pages = [
      PlannerPage(
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
      CalendarPage(
        tasks: _allTasks,
        routines: _routines,
        goalForTask: _goalForTask,
        today: today,
        onCreateGoal: () => setState(() => _selectedIndex = 0),
        onAddRoutine: _addRoutine,
        onDeleteRoutine: _deleteRoutine,
      ),
      TasksPage(
        mood: _selectedMood,
        todayTasks: _todayTasks,
        todayProgress: _todayProgress,
        todayCompleted: _todayCompleted,
        todayTotal: _todayTasks.length,
        remainingMinutes: _remainingMinutes,
        goalForTask: _goalForTask,
        onMoodChanged: _handleMoodChanged,
        onToggleTask: _toggleTask,
        onCreateGoal: () => setState(() => _selectedIndex = 0),
      ),
      CommunityPage(
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
      CompanionPage(
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
