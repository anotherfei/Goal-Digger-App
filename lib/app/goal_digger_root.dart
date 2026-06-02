import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants/gd_constants.dart';
import '../core/theme/gd_colors.dart';
import '../core/utils/date_helpers.dart';
import '../data/seed_data.dart';
import '../features/calendar/calendar_page.dart';
import '../features/community/community_page.dart';
import '../features/companion/companion_page.dart';
import '../features/focus/widgets/focus_widgets.dart';
import '../features/notifications/models/notification_models.dart';
import '../features/notifications/notification_inbox_page.dart';
import '../features/notifications/services/android_notification_service.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/planner/planner_page.dart';
import '../features/profile/profile_screen.dart';
import '../features/responsive/responsive_goal_shell.dart';
import '../features/settings/settings_screen.dart';
import '../features/tasks/tasks_page.dart';
import '../firebase/auth/auth_service.dart';
import '../firebase/auth/auth_state.dart';
import '../firebase/firestore/repositories/user_repository.dart';
import '../firebase/sync/app_sync_service.dart';
import '../genkit/genkit_service.dart';
import '../models/models.dart';
import '../shared/widgets/shared_widgets.dart';
import '../services/google_calendar_service.dart';

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

class _SystemNotificationRequest {
  const _SystemNotificationRequest({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.important,
    required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final bool important;
  final String payload;
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
  String? _profileDisplayName;
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
  StreamSubscription<List<AppNotification>>? _notificationsSub;
  String? _activeUid;
  Set<String> _joinedCommunityIds = {};
  List<RoutineItem> _routines = [];
  List<AppNotification> _notifications = [];
  final Set<String> _locallyReadNotificationIds = {};
  final AndroidNotificationService _androidNotifications =
      AndroidNotificationService();
  NotificationSettings _notificationSettings =
      const NotificationSettings.defaults();
  Timer? _notificationScheduleDebounce;
  bool _notificationBridgeReady = false;
  bool _notificationPermissionPrompted = false;
  Future<bool>? _notificationPermissionRequest;

  // Auth listener wiring — avoids calling side-effecting _bindAuthState
  // inside build(), which can trigger setState-during-build violations.
  AuthState? _watchedAuthState;

  DateTime _newGoalDeadline = addDays(DateTime.now(), 14);
  int _newGoalPriority = 3;
  String _newGoalCategory = 'Study';

  bool _isProcessing = false;
  double _processingProgress = 0;
  Timer? _processingTimer;
  Timer? _moodAdviceTimer;
  bool _moodAdvisorAvailable = true;
  int _moodAdviceRequestSerial = 0;

  String _selectedMood = 'Okay';
  int _petHappiness = 62;
  int _coins = 140;
  int _streak = 7;
  bool _goalReminders = true;
  bool _friendProgressSharing = true;
  List<String> _friends = ['Maya Chen', 'Leo Tan', 'Ari Putra'];
  final List<String> _friendSuggestions = [
    'Nina Rahman',
    'Jay Lim',
    'Sofia Hart'
  ];
  PetSkin _activePetSkin = defaultPet;
  String _activeAccessory = 'Cap';

  FocusSessionConfig? _activeFocusConfig;
  int _focusRemainingSeconds = 0;
  bool _focusPaused = false;
  bool _focusCompletionHandled = false;
  Timer? _focusTimer;
  final Set<String> _sentDeadlineSystemNoticeIds = {};

  bool get _hasActiveFocus =>
      _activeFocusConfig != null && _focusRemainingSeconds > 0;
  bool get _focusComplete =>
      _activeFocusConfig != null && _focusRemainingSeconds <= 0;

  Future<void> _syncTaskToGoogleCalendar(
    MicroTask task,
    GoalProject goal,
  ) async {
    final user = context.read<AuthService>().currentUser;

    if (user == null || user.isAnonymous) {
      _showHelpfulError(
        title: 'Google sign-in required',
        message: 'Please sign in with Google before syncing to Google Calendar.',
        actionLabel: 'OK',
        onAction: () {},
      );
      return;
    }

    try {
      await context.read<GoogleCalendarService>().createTaskEvent(task, goal);
      _showMessage('Task synced to Google Calendar.');
    } catch (e) {
      _showHelpfulError(
        title: 'Calendar sync failed',
        message: '$e',
        actionLabel: 'OK',
        onAction: () {},
      );
    }
  }

  Future<void> _syncAllTasksToGoogleCalendar() async {
  final user = context.read<AuthService>().currentUser;

  if (user == null || user.isAnonymous) {
    _showHelpfulError(
      title: 'Google sign-in required',
      message: 'Please sign in with Google before syncing to Google Calendar.',
      actionLabel: 'OK',
      onAction: () {},
    );
    return;
  }

  if (_allTasks.isEmpty) {
    _showMessage('No tasks available to sync.');
    return;
  }

  try {
    final result = await context
        .read<GoogleCalendarService>()
        .syncAllTaskEvents(_allTasks, _goalForTask);

    _showMessage(
      'Calendar sync complete: ${result.created} created, ${result.skipped} already synced, ${result.failed} failed.',
    );
  } catch (e) {
    _showHelpfulError(
      title: 'Calendar sync failed',
      message: '$e',
      actionLabel: 'OK',
      onAction: () {},
    );
  }
}

  @override
  void initState() {
    super.initState();
    _goals = seedGoals(today);
    _routines = _defaultRoutines();
    _communities = _defaultCommunities();
    unawaited(_initializeNotificationBridge());
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
    _moodAdvisorAvailable = true;
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
          description:
              'Short daily sprints for students who want accountability.',
        ),
        CommunityGroup(
          name: 'Portfolio Builders',
          members: 142,
          tag: 'Career',
          similarity: 88,
          description:
              'Share portfolio progress and get feedback from builders.',
        ),
        CommunityGroup(
          name: 'Calm Wellness Crew',
          members: 76,
          tag: 'Wellness',
          similarity: 81,
          description:
              'Build low-pressure routines around sleep, movement, and reflection.',
        ),
      ];

  @override
  void dispose() {
    _watchedAuthState?.removeListener(_onAuthStateChanged);
    _processingTimer?.cancel();
    _moodAdviceTimer?.cancel();
    _focusTimer?.cancel();
    _notificationScheduleDebounce?.cancel();
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
    _notificationsSub?.cancel();
    _goalsSub = null;
    _profileSub = null;
    _communitiesSub = null;
    _joinedCommunitiesSub = null;
    _routinesSub = null;
    _notificationsSub = null;
    _sync?.dispose();
    _sync = null;
  }

  void _resetForSignedOutState() {
    _activeUid = null;
    _moodAdviceTimer?.cancel();
    _moodAdviceRequestSerial++;
    _moodAdvisorAvailable = true;
    _notificationPermissionRequest = null;
    _disposeSync();
    setState(() {
      _onboarded = false;
      _profileDisplayName = null;
      _signedInWith = 'Guest';
      _selectedIndex = 2;
      _goals = seedGoals(today);
      _routines = _defaultRoutines();
      _notifications = [];
      _locallyReadNotificationIds.clear();
      _sentDeadlineSystemNoticeIds.clear();
      _notificationSettings = const NotificationSettings.defaults();
      _goalReminders = _notificationSettings.systemNotificationsEnabled;
      _friends = ['Maya Chen', 'Leo Tan', 'Ari Putra'];
    });
    unawaited(_androidNotifications.cancelAll());
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
        _queueNotificationScheduleSync();
        _ensureImportantDeadlineNotifications();
      },
      onError: (Object error) => debugPrint('Goal sync error: $error'),
    );

    _profileSub = sync.profileStream.listen(
      (profile) {
        if (!mounted || profile == null) return;
        final user = context.read<AuthService>().currentUser;
        final authDisplayName = user?.displayName?.trim();
        final syncedDisplayName = authDisplayName?.isNotEmpty == true
            ? authDisplayName!
            : profile.displayName.trim();
        setState(() {
          _coins = profile.coins;
          _streak = profile.streak;
          _petHappiness = profile.petHappiness;
          _activePetSkin = profile.activePetSkin;
          _activeAccessory = profile.activeAccessory;
          _selectedMood = profile.selectedMood;
          _profileDisplayName = syncedDisplayName.isNotEmpty
              ? syncedDisplayName
              : _profileDisplayName;
          _goalReminders = profile.goalReminders;
          _notificationSettings = profile.notificationSettings;
          _friendProgressSharing = profile.friendProgressSharing;
          _friends = profile.friends.isEmpty
              ? ['Maya Chen', 'Leo Tan', 'Ari Putra']
              : List<String>.from(profile.friends);
          _onboarded = profile.onboarded;
          final providerId = user?.providerData.isNotEmpty == true
              ? user!.providerData.first.providerId
              : null;
          _signedInWith = user?.isAnonymous == true
              ? 'Guest'
              : providerId == 'google.com'
                  ? 'Google'
                  : providerId == 'password'
                      ? 'Email'
              : 'Firebase';
        });
        _queueNotificationScheduleSync();
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
        _queueNotificationScheduleSync();
      },
      onError: (Object error) => debugPrint('Routine sync error: $error'),
    );

    _notificationsSub = sync.notificationsStream.listen(
      (notifications) {
        if (!mounted) return;
        final now = DateTime.now();
        final mergedNotifications = notifications
            .map(
              (notification) =>
                  _locallyReadNotificationIds.contains(notification.id) &&
                          notification.isUnread
                      ? notification.copyWith(readAt: now)
                      : notification,
            )
            .toList();
        setState(() => _notifications = mergedNotifications);
        _ensureImportantDeadlineNotifications();
      },
      onError: (Object error) => debugPrint('Notification sync error: $error'),
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
      await sync.updatePetState(
          _petHappiness, _activePetSkin, _activeAccessory);
    } catch (e) {
      debugPrint('Profile write failed: $e');
    }
  }

  Future<void> _persistMood(String mood) async {
    final sync = _sync;
    if (sync == null) return;
    try {
      await sync.updateMood(mood);
    } catch (e) {
      debugPrint('Mood write failed: $e');
    }
  }

  Future<void> _persistPreferences() async {
    final sync = _sync;
    if (sync == null) return;
    try {
      await sync.updatePreferences(
        goalReminders: _goalReminders,
        friendProgressSharing: _friendProgressSharing,
        notificationSettings: _notificationSettings,
      );
    } catch (e) {
      debugPrint('Preference write failed: $e');
    }
  }

  void _setGoalReminders(bool value) {
    setState(() {
      _goalReminders = value;
      _notificationSettings = _notificationSettings.copyWith(
        systemNotificationsEnabled: value,
      );
    });
    unawaited(_persistPreferences());
    _queueNotificationScheduleSync();
  }

  void _setFriendProgressSharing(bool value) {
    setState(() => _friendProgressSharing = value);
    unawaited(_persistPreferences());
  }

  void _setNotificationSettings(NotificationSettings settings) {
    setState(() {
      _notificationSettings = settings;
      _goalReminders = settings.systemNotificationsEnabled;
    });
    unawaited(_persistPreferences());
    _queueNotificationScheduleSync();
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
      await _finishAuthenticatedOnboarding(provider, authState);
    } catch (e) {
      _showAuthFailure(provider, e);
    }
  }

  Future<void> _completeOnboardingWithEmail({
    required String email,
    required String password,
    required bool isSignUp,
    String? displayName,
  }) async {
    final authState = context.read<AuthState>();
    try {
      if (isSignUp) {
        await authState.createAccountWithEmail(
          email: email,
          password: password,
          displayName: displayName,
        );
      } else {
        await authState.signInWithEmail(email, password);
      }
      await _finishAuthenticatedOnboarding('Email', authState);
    } catch (e) {
      _showAuthFailure('Email', e);
    }
  }

  Future<void> _finishAuthenticatedOnboarding(
    String provider,
    AuthState authState,
  ) async {
    final user = context.read<AuthService>().currentUser ?? authState.user;
    if (user == null) {
      if (authState.errorMessage != null) return;
      throw StateError('Firebase did not return a signed-in user.');
    }

    final displayName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : provider == 'Guest'
            ? 'Guest User'
            : 'Goal Digger User';

    await _userRepository.createOrUpdateProfile(
      uid: user.uid,
      displayName: displayName,
      email: user.email,
      photoUrl: user.photoURL,
    );
    await _userRepository.markOnboarded(user.uid);
    _activeUid = user.uid;
    _activateSync(user.uid);

    if (!mounted) return;
    authState.clearError();
    setState(() {
      _profileDisplayName = displayName;
      _signedInWith = provider;
      _onboarded = true;
    });
    _queueNotificationScheduleSync();
    _showMessage('Welcome! You signed in with $provider.');
  }

  void _showAuthFailure(String provider, Object error) {
    if (!mounted) return;
    _showHelpfulError(
      title: '$provider sign-in failed',
      message:
          'Firebase could not complete sign-in. Check that Firebase Auth is enabled and your app uses the correct Firebase project. Details: $error',
      actionLabel: 'Continue as guest',
      onAction: () => unawaited(_completeOnboardingWithAuth('Guest')),
    );
  }

  List<MicroTask> get _allTasks => _goals.expand((goal) => goal.tasks).toList();

  List<MicroTask> get _todayTasks =>
      _allTasks.where((task) => dateOnly(task.scheduledDate) == today).toList();

  GoalProject _goalForTask(MicroTask task) {
    return _goals.firstWhere((goal) => goal.id == task.goalId);
  }

  int get _todayCompleted => _todayTasks.where((task) => task.done).length;

  double get _todayProgress =>
      _todayTasks.isEmpty ? 0 : _todayCompleted / _todayTasks.length;

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

  void _showCoinRewardPrompt(int coins, String reason) {
    if (coins <= 0) return;
    _showMessage('${_activePetSkin.name} says: +$coins coins $reason.');
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
                child: const Text('Cancel')),
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

  Future<void> _initializeNotificationBridge() async {
    _notificationBridgeReady = await _androidNotifications.initialize();
    _queueNotificationScheduleSync();
  }

  void _queueNotificationScheduleSync() {
    _notificationScheduleDebounce?.cancel();
    _notificationScheduleDebounce =
        Timer(const Duration(milliseconds: 350), () {
      unawaited(_syncSystemNotifications());
    });
  }

  Future<void> _syncSystemNotifications() async {
    if (!_onboarded) return;
    if (!_androidNotifications.isSupported) return;
    if (!_notificationBridgeReady) {
      _notificationBridgeReady = await _androidNotifications.initialize();
    }

    if (!_notificationSettings.hasAnySystemNotification) {
      await _androidNotifications.cancelAll();
      return;
    }

    final allowed = await _ensureAndroidNotificationPermission();
    if (!allowed) {
      await _androidNotifications.cancelAll();
      _addInAppNotification(
        id: 'important_android_notifications_disabled',
        title: 'Android notifications are off',
        body:
            'Goal Digger cannot show routine, streak, deadline, or focus pop-ups until notification permission is enabled.',
        type: AppNotificationType.important,
        important: true,
        sourceId: 'android_permission',
      );
      return;
    }

    await _androidNotifications.cancelScheduled();
    final requests = _buildSystemNotificationRequests();
    for (final request in requests.take(80)) {
      await _androidNotifications.schedule(
        id: request.id,
        title: request.title,
        body: request.body,
        scheduledAt: request.scheduledAt,
        important: request.important,
        payload: request.payload,
      );
    }
  }

  Future<bool> _ensureAndroidNotificationPermission() async {
    if (await _androidNotifications.areNotificationsEnabled()) return true;
    final pendingRequest = _notificationPermissionRequest;
    if (pendingRequest != null) return pendingRequest;
    if (_notificationPermissionPrompted) return false;
    _notificationPermissionPrompted = true;
    final request = () async {
      final granted = await _androidNotifications.requestPermission();
      if (!granted) return false;
      return _androidNotifications.areNotificationsEnabled();
    }();
    _notificationPermissionRequest = request;
    try {
      return await request;
    } finally {
      _notificationPermissionRequest = null;
    }
  }

  Future<void> _showSystemNotificationNow({
    required String key,
    required String title,
    required String body,
    required AppNotificationType type,
    bool important = false,
    String? sourceId,
  }) async {
    if (!_androidNotifications.isSupported) return;
    if (!_notificationBridgeReady) {
      _notificationBridgeReady = await _androidNotifications.initialize();
    }
    final allowed = await _ensureAndroidNotificationPermission();
    if (!allowed) return;

    final id = _stableNotificationId(key);
    await _androidNotifications.cancel(id);
    await _androidNotifications.showNow(
      id: id,
      title: title,
      body: body,
      important: important,
      payload: '${type.name}:${sourceId ?? key}',
    );
  }

  List<_SystemNotificationRequest> _buildSystemNotificationRequests() {
    final now = DateTime.now();
    final start = dateOnly(now);
    final horizon = addDays(start, 30);
    final requests = <_SystemNotificationRequest>[];

    void addRequest({
      required String key,
      required String title,
      required String body,
      required DateTime scheduledAt,
      required AppNotificationType type,
      bool important = false,
      String? sourceId,
    }) {
      if (!scheduledAt.isAfter(now)) return;
      if (!scheduledAt.isBefore(horizon)) return;
      requests.add(
        _SystemNotificationRequest(
          id: _stableNotificationId(key),
          title: title,
          body: body,
          scheduledAt: scheduledAt,
          important: important,
          payload: '${type.name}:${sourceId ?? key}',
        ),
      );
    }

    if (_notificationSettings.dailyPlanEnabled) {
      for (var offset = 0; offset < 7; offset++) {
        final day = addDays(start, offset);
        final tasks = _unfinishedTasksForDay(day);
        if (tasks.isEmpty) continue;
        final minutes = tasks.fold<int>(
          0,
          (sum, task) => sum + task.durationMinutes,
        );
        addRequest(
          key: 'daily_plan_${dateKey(day)}',
          title: 'Today in Goal Digger',
          body:
              '${tasks.length} goal action${tasks.length == 1 ? '' : 's'} are waiting, about $minutes minutes total.',
          scheduledAt: _dateAtNotificationTime(
            day,
            _notificationSettings.dailyPlanHour,
            _notificationSettings.dailyPlanMinute,
          ),
          type: AppNotificationType.dailyPlan,
          sourceId: dateKey(day),
        );
      }
    }

    if (_notificationSettings.streakSaverEnabled) {
      for (var offset = 0; offset < 7; offset++) {
        final day = addDays(start, offset);
        final tasks = _unfinishedTasksForDay(day);
        if (tasks.isEmpty) continue;
        if (dateOnly(day) == start && _todayCompleted > 0) continue;
        addRequest(
          key: 'streak_${dateKey(day)}',
          title: 'Protect your streak',
          body: 'One small completed task keeps your momentum alive.',
          scheduledAt: _dateAtNotificationTime(
            day,
            _notificationSettings.streakSaverHour,
            _notificationSettings.streakSaverMinute,
          ),
          type: AppNotificationType.streakSaver,
          important: offset == 0,
          sourceId: dateKey(day),
        );
      }
    }

    if (_notificationSettings.deadlineWarningsEnabled) {
      for (final goal in _goals.where((goal) => goal.progress < 1)) {
        final deadlineDay = dateOnly(goal.deadline);
        final daysLeft = daysBetween(start, deadlineDay);
        final warningDay =
            addDays(deadlineDay, -_notificationSettings.deadlineWarningDays);
        final candidateDays = <String, DateTime>{
          'warning': warningDay,
          'deadline': deadlineDay,
          if (daysLeft < 0) 'overdue': start,
        };

        for (final entry in candidateDays.entries) {
          final day = entry.value;
          if (day.isBefore(start)) continue;
          addRequest(
            key: 'deadline_${goal.id}_${entry.key}_${dateKey(day)}',
            title: daysLeft < 0 ? 'Goal overdue' : 'Deadline coming up',
            body:
                '${goal.title} is ${daysLeft < 0 ? 'overdue' : 'due in $daysLeft day${daysLeft == 1 ? '' : 's'}'}.',
            scheduledAt: _dateAtNotificationTime(
              day,
              _notificationSettings.dailyPlanHour,
              _notificationSettings.dailyPlanMinute,
            ).add(const Duration(minutes: 45)),
            type: AppNotificationType.deadlineWarning,
            important: daysLeft <= 1,
            sourceId: goal.id.toString(),
          );
        }
      }
    }

    if (_notificationSettings.routineRemindersEnabled) {
      for (final routine in _routines) {
        for (final occurrence in _routineOccurrences(routine, now, horizon)) {
          addRequest(
            key: 'routine_${routine.id}_${occurrence.millisecondsSinceEpoch}',
            title: routine.title,
            body: '${routine.repeat.label} routine in Goal Digger.',
            scheduledAt: occurrence,
            type: AppNotificationType.routineReminder,
            sourceId: routine.id,
          );
        }
      }
    }

    final focusConfig = _activeFocusConfig;
    if (_notificationSettings.focusNotificationsEnabled &&
        focusConfig != null &&
        _focusRemainingSeconds > 0 &&
        !_focusPaused) {
      addRequest(
        key: 'focus_complete',
        title: 'Focus session complete',
        body: '${focusConfig.title} is ready to wrap up.',
        scheduledAt: now.add(Duration(seconds: _focusRemainingSeconds)),
        type: AppNotificationType.focusComplete,
        important: true,
        sourceId: focusConfig.title,
      );
    }

    requests.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return requests;
  }

  List<MicroTask> _unfinishedTasksForDay(DateTime day) {
    final target = dateOnly(day);
    return _allTasks
        .where(
          (task) => dateOnly(task.scheduledDate) == target && !task.done,
        )
        .toList()
      ..sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
  }

  DateTime _dateAtNotificationTime(DateTime day, int hour, int minute) {
    final date = dateOnly(day);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  Iterable<DateTime> _routineOccurrences(
    RoutineItem routine,
    DateTime now,
    DateTime horizon,
  ) sync* {
    var current = routine.startsAt;
    while (current.isBefore(now)) {
      final next = _nextRoutineOccurrence(current, routine.repeat);
      if (!next.isAfter(current)) return;
      current = next;
    }

    var emitted = 0;
    while (current.isBefore(horizon) && emitted < 40) {
      yield current;
      emitted++;
      if (routine.repeat == RoutineRepeat.custom) return;
      current = _nextRoutineOccurrence(current, routine.repeat);
    }
  }

  DateTime _nextRoutineOccurrence(DateTime from, RoutineRepeat repeat) {
    switch (repeat) {
      case RoutineRepeat.daily:
        return from.add(const Duration(days: 1));
      case RoutineRepeat.weekly:
        return from.add(const Duration(days: 7));
      case RoutineRepeat.monthly:
        final month = DateTime(from.year, from.month + 1);
        final day = min(from.day, DateTime(month.year, month.month + 1, 0).day);
        return DateTime(
          month.year,
          month.month,
          day,
          from.hour,
          from.minute,
        );
      case RoutineRepeat.yearly:
        final year = from.year + 1;
        final day = min(from.day, DateTime(year, from.month + 1, 0).day);
        return DateTime(year, from.month, day, from.hour, from.minute);
      case RoutineRepeat.custom:
        return from.add(const Duration(days: 3650));
    }
  }

  int _stableNotificationId(String key) {
    var hash = 0x811c9dc5;
    for (final codeUnit in key.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash == 0 ? 1 : hash;
  }

  bool _addInAppNotification({
    String? id,
    required String title,
    required String body,
    required AppNotificationType type,
    bool important = false,
    String? sourceId,
    Map<String, dynamic>? payload,
  }) {
    if (!important && !_notificationSettings.inAppNotificationsEnabled) {
      return false;
    }
    if (important && !_notificationSettings.importantInAppEnabled) {
      return false;
    }

    final notificationId =
        id ?? 'local_${DateTime.now().microsecondsSinceEpoch}';
    if (_notifications.any((item) => item.id == notificationId)) return false;

    final notification = AppNotification(
      id: notificationId,
      title: title,
      body: body,
      type: type,
      delivery: NotificationDelivery.inApp,
      createdAt: DateTime.now(),
      important: important,
      sourceId: sourceId,
      payload: payload,
    );

    if (mounted) {
      setState(() => _notifications = [notification, ..._notifications]);
    }

    final sync = _sync;
    if (sync != null) {
      unawaited(sync.addNotification(notification).catchError((Object e) {
        debugPrint('Notification save failed: $e');
      }));
    }

    if (important) _showImportantNotificationSnack(notification);
    return true;
  }

  void _showImportantNotificationSnack(AppNotification notification) {
    if (!mounted) return;
    final isPermissionNotice = notification.sourceId == 'android_permission';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Important: ${notification.title}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: isPermissionNotice ? 'Settings' : 'Inbox',
          onPressed: isPermissionNotice
              ? _openAndroidNotificationSettings
              : _openNotifications,
        ),
      ),
    );
  }

  void _ensureImportantDeadlineNotifications() {
    final todayKey = dateKey(today);
    for (final goal in _goals.where((goal) => goal.progress < 1)) {
      final daysLeft = daysBetween(today, goal.deadline);
      if (daysLeft > 1) continue;
      final id = 'important_deadline_${goal.id}_$todayKey';
      final title = daysLeft < 0 ? 'Goal is overdue' : 'Goal deadline is near';
      final body = daysLeft < 0
          ? '${goal.title} is overdue. Pick one unfinished task to regain control.'
          : '${goal.title} is due ${daysLeft == 0 ? 'today' : 'tomorrow'}.';
      _addInAppNotification(
        id: id,
        title: title,
        body: body,
        type: AppNotificationType.important,
        important: true,
        sourceId: goal.id.toString(),
      );
      if (_notificationSettings.systemNotificationsEnabled &&
          _notificationSettings.deadlineWarningsEnabled &&
          _sentDeadlineSystemNoticeIds.add(id)) {
        unawaited(
          _showSystemNotificationNow(
            key: 'system_$id',
            title: title,
            body: body,
            type: AppNotificationType.deadlineWarning,
            important: true,
            sourceId: goal.id.toString(),
          ),
        );
      }
    }
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => NotificationInboxPage(
          notifications: _notifications,
          onMarkRead: _markNotificationRead,
          onMarkAllRead: _markAllNotificationsRead,
          onDelete: _deleteNotification,
          onOpenNotificationSettings: _openAndroidNotificationSettings,
        ),
      ),
    );
  }

  void _openAndroidNotificationSettings() {
    if (!_androidNotifications.isSupported) {
      _openSettings();
      return;
    }
    unawaited(_androidNotifications.openNotificationSettings());
  }

  void _markNotificationRead(AppNotification notification) {
    if (!notification.isUnread) return;
    setState(() {
      _locallyReadNotificationIds.add(notification.id);
      _notifications = _notifications
          .map((item) => item.id == notification.id
              ? item.copyWith(readAt: DateTime.now())
              : item)
          .toList();
    });
    final sync = _sync;
    if (sync != null) {
      unawaited(
        sync.markNotificationRead(notification.id).catchError((Object e) {
          debugPrint('Notification read sync failed: $e');
        }),
      );
    }
  }

  void _markAllNotificationsRead() {
    final now = DateTime.now();
    setState(() {
      _locallyReadNotificationIds
          .addAll(_notifications.map((notification) => notification.id));
      _notifications = _notifications
          .map((item) => item.isUnread ? item.copyWith(readAt: now) : item)
          .toList();
    });
    final sync = _sync;
    if (sync != null) {
      unawaited(sync.markAllNotificationsRead().catchError((Object e) {
        debugPrint('Notification mark-all sync failed: $e');
      }));
    }
  }

  void _deleteNotification(AppNotification notification) {
    setState(() {
      _notifications =
          _notifications.where((item) => item.id != notification.id).toList();
    });
    final sync = _sync;
    if (sync != null) {
      unawaited(sync.deleteNotification(notification.id).catchError((Object e) {
        debugPrint('Notification delete sync failed: $e');
      }));
    }
  }

  Future<void> _sendTestNotification() async {
    if (!_androidNotifications.isSupported) {
      _showMessage('Android notifications are only available on Android.');
      return;
    }
    final allowed = await _ensureAndroidNotificationPermission();
    if (!allowed) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Android notification permission is not enabled.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: _openAndroidNotificationSettings,
          ),
        ),
      );
      return;
    }
    await _androidNotifications.showNow(
      id: _stableNotificationId('test_${DateTime.now().millisecondsSinceEpoch}'),
      title: 'Goal Digger test',
      body: 'Android notifications are ready.',
      important: true,
      payload: 'test',
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
        message:
            'Please write one clear goal first. Example: "Prepare for midterm" or "Build my portfolio".',
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

  // Loose yes/no detection for the "are you sure?" feasibility confirmation.
  bool _isAffirmativeReply(String text) {
    final s = text.trim().toLowerCase();
    return RegExp(
      r"^(y|ya|yes|yeah|yep|yup|sure|ok|okay|confirm|confirmed|do it|go ahead|proceed|absolutely|definitely|i'?m sure|still want|keep all)\b",
    ).hasMatch(s);
  }

  bool _isNegativeReply(String text) {
    final s = text.trim().toLowerCase();
    return RegExp(
      r"^(n|no|nope|nah|cancel|stop|never mind|nevermind|don'?t|do not|keep it|leave it|that'?s fine|fewer|less)\b",
    ).hasMatch(s);
  }

  // Centered, non-dismissible loading card shown while the AI generates a plan.
  Widget _buildGeneratingLoader(String label) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
          decoration: BoxDecoration(
            color: gdSurface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 38,
                height: 38,
                child: CircularProgressIndicator(strokeWidth: 3, color: gdPrimary),
              ),
              const SizedBox(height: 18),
              Text(
                label,
                style: const TextStyle(
                  color: gdInk,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'This may take a few seconds…',
                style: TextStyle(color: gdMuted, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _runGoalBreakdownDialog(
      String title, TextEditingController chatController) async {
    final ai = context.read<GenkitService>();
    final fallbackSpecs = _draftSpecsFromTitles(_generateTaskTitles(title));
    final deadlineDays =
        max(1, dateOnly(_newGoalDeadline).difference(today).inDays);
    var draftSpecs = List<_DraftTaskSpec>.from(fallbackSpecs);
    var aiAvailable = false;
    var fromAgent = false;
    String? agentStrategy;
    String? agentHabitInsight;
    String? agentRecommendation;
    String? agentScheduleNote;
    String? agentBurnoutRisk;
    var agentDegraded = false;
    List<_DraftTaskSpec> agentSpecs = const [];

    // Block the UI with a non-dismissible loader while the agent generates the
    // first plan, so the user can't tap other things mid-generation.
    var loaderOpen = false;
    if (mounted) {
      loaderOpen = true;
      // ignore: unawaited_futures
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _buildGeneratingLoader('Generating your plan…'),
      );
    }

    // Step 1: Run the planning agent. It plans, executes tools (habit analysis,
    // milestones, burnout-aware scheduling) and reflects — we consume ALL of it.
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
      agentStrategy = agentPlan.strategy;
      agentDegraded = agentPlan.degraded;
      agentHabitInsight = agentPlan.habitInsight;
      agentRecommendation = agentPlan.primaryInsight;
      agentBurnoutRisk = agentPlan.burnoutRisk;
      agentScheduleNote = agentPlan.schedule['scheduleNote']?.toString();
      if (agentPlan.milestones.isNotEmpty) {
        agentSpecs = _draftSpecsFromTitles(agentPlan.milestones).toList();
      }
    } catch (e) {
      debugPrint('Agent planner unavailable: $e');
    }

    if (agentSpecs.isNotEmpty) {
      draftSpecs = agentSpecs;
      aiAvailable = true;
      fromAgent = true;
    } else {
      // Step 2 (fallback): the agent produced no milestones — try the task
      // generator, then fall back to the local heuristic plan.
      try {
        final generated = await ai.taskGenerator.generate(
          TaskGeneratorRequest(
            goalTitle: title,
            category: _newGoalCategory,
            priority: _newGoalPriority,
            deadlineDays: deadlineDays,
          ),
        );
        final aiSpecs = _draftSpecsFromGeneratedTasks(generated.tasks).toList();
        if (aiSpecs.isNotEmpty) {
          draftSpecs = aiSpecs;
          aiAvailable = true;
        }
      } catch (e) {
        debugPrint('AI task generation fallback used: $e');
      }
    }

    // Compose the opening message from the agent's REAL output, not a cosmetic
    // suffix. Surface the habit insight, schedule note, and top recommendation.
    final intro = StringBuffer();
    if (fromAgent && !agentDegraded) {
      final strategy = agentStrategy?.trim();
      intro.write('I ran the planning agent');
      if (strategy != null && strategy.isNotEmpty) intro.write(' ($strategy)');
      intro.write(' and broke "$title" into ${draftSpecs.length} milestones.');
    } else if (aiAvailable) {
      intro.write(
          'I used the AI task generator to break "$title" into ${draftSpecs.length} tasks.');
    } else {
      intro.write(
          'I could not reach the AI planner, so I prepared a local fallback plan for "$title".');
    }
    final habit = agentHabitInsight?.trim();
    if (habit != null && habit.isNotEmpty) {
      final risk = agentBurnoutRisk?.trim();
      final riskTag = (risk != null && risk.isNotEmpty) ? ' (burnout risk: $risk)' : '';
      intro.write('\n\n🧠 $habit$riskTag');
    }
    final note = agentScheduleNote?.trim();
    if (note != null && note.isNotEmpty) intro.write('\n📅 $note');
    final rec = agentRecommendation?.trim();
    if (rec != null && rec.isNotEmpty) intro.write('\n👉 $rec');
    intro.write(
        '\n\nYou can ask me to make the plan easier, more detailed, or reorder it before scheduling.');

    final messages = <Map<String, dynamic>>[
      {
        'role': 'assistant',
        'text': intro.toString(),
        'tasks': _draftPreviewLabels(draftSpecs),
      },
    ];

    // Generation done — close the blocking loader before showing the plan.
    if (loaderOpen && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      loaderOpen = false;
    }

    final result = await showDialog<List<_DraftTaskSpec>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        var isAiThinking = false;
        // When the agent scales back an unrealistic request, it asks "are you
        // sure?". We stash the original request here so a "yes" re-issues it as
        // a confirmed (forced) request, and a "no" keeps the scaled-back plan.
        String? pendingForceRequest;
        return StatefulBuilder(
          builder: (dialogContext, setLocalState) {
            Future<void> sendMessage() async {
              final request = chatController.text.trim();
              if (request.isEmpty || isAiThinking) return;

              final pending = pendingForceRequest;

              // User declined the "are you sure?" question — keep current plan.
              if (pending != null && _isNegativeReply(request)) {
                setLocalState(() {
                  messages.add({'role': 'user', 'text': request});
                  messages.add({
                    'role': 'assistant',
                    'text': "Got it — I'll keep the plan as it is.",
                    'tasks': _draftPreviewLabels(draftSpecs),
                  });
                  chatController.clear();
                  pendingForceRequest = null;
                });
                return;
              }

              // User confirmed — re-issue the original request, forced this time.
              final useForce = pending != null && _isAffirmativeReply(request);
              final effectiveRequest = useForce ? pending : request;

              setLocalState(() {
                isAiThinking = true;
                messages.add({'role': 'user', 'text': request});
                chatController.clear();
              });

              try {
                // Route refinements through the planning agent so requests like
                // "10 milestones" or "2 per day" reach the createMilestones tool,
                // which sizes the roadmap (and flags unrealistic asks) for us.
                final refinedPlan = await ai.agentPlanner.plan(
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
                      'specialRequest': effectiveRequest,
                      if (useForce) 'force': true,
                    },
                  ),
                );

                final refinedTitles = refinedPlan.milestones
                    .map((task) => task.trim())
                    .where((task) => task.isNotEmpty)
                    .toList();
                if (refinedTitles.isNotEmpty) {
                  draftSpecs = _draftSpecsFromTitles(refinedTitles).toList();
                }

                // Prefer the agent's feasibility note (e.g. "…Are you sure you
                // still want all 30? (yes / no)"); otherwise confirm the count.
                final note = refinedPlan.milestoneNote?.trim();
                final replyText = (note != null && note.isNotEmpty)
                    ? note
                    : (refinedTitles.isNotEmpty
                        ? 'Updated the plan to ${refinedTitles.length} milestones.'
                        : 'I refined the plan based on your request.');

                if (!dialogContext.mounted) return;
                setLocalState(() {
                  // Remember the request only while a confirmation is pending.
                  pendingForceRequest = refinedPlan.milestoneNeedsConfirmation
                      ? effectiveRequest
                      : null;
                  messages.add({
                    'role': 'assistant',
                    'text': replyText,
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
                draftSpecs = _draftSpecsFromTitles(refined).toList();
                if (!dialogContext.mounted) return;
                setLocalState(() {
                  pendingForceRequest = null;
                  messages.add({
                    'role': 'assistant',
                    'text': 'The AI planner is unavailable right now, so I refined the plan locally. You can still finalize this draft.',
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
                alignment:
                    isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 680),
                  margin: EdgeInsets.only(
                      left: isUser ? 44 : 0, right: isUser ? 0 : 44),
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
                              child: Icon(Icons.auto_awesome_rounded,
                                  size: 16, color: gdPrimary),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'AI Assistant',
                              style: TextStyle(
                                  color: gdMuted, fontWeight: FontWeight.w900),
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
                                    color: isUser
                                        ? Colors.white.withValues(alpha: 0.14)
                                        : Colors.white,
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
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
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
                        color: Colors.black.withValues(alpha: 0.12),
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
                                icon: const Icon(Icons.close_rounded,
                                    color: gdMuted),
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
                              itemCount:
                                  messages.length + (isAiThinking ? 1 : 0),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
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
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
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
                                enabled: !isAiThinking,
                                minLines: 1,
                                maxLines: 4,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => sendMessage(),
                                decoration: InputDecoration(
                                  hintText: isAiThinking
                                      ? 'AI is thinking…'
                                      : 'Adjust the AI plan...',
                                  filled: true,
                                  fillColor: const Color(0xFFF7F5EF),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 18),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE6DFD2)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: const BorderSide(
                                        color: gdPrimary, width: 1.6),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24)),
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
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24)),
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

  Future<void> _finishCreateGoal(String title,
      {List<_DraftTaskSpec>? approvedTaskSpecs}) async {
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
        _showMessage(
            'Goal created locally, but Firebase save failed. Check Firestore rules/network.');
        return;
      }
    }
    _queueNotificationScheduleSync();
    _ensureImportantDeadlineNotifications();
    _showMessage('Goal created. AI subtasks are scheduled and synced.');
  }

  List<Color> _categoryColors(String category) {
    switch (category) {
      case 'Career':
        return [gdGradientCareerFrom, gdGradientCareerTo];
      case 'Wellness':
        return [gdGradientWellnessFrom, gdGradientWellnessTo];
      case 'Finance':
        return [gdGradientFinanceFrom, gdGradientFinanceTo];
      case 'Creative':
        return [gdGradientCreativeFrom, gdGradientCreativeTo];
      default:
        return [gdGradientStudyFrom, gdGradientStudyTo];
    }
  }

  List<String> _generateTaskTitles(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('exam') ||
        lower.contains('midterm') ||
        lower.contains('study')) {
      return [
        'List topics to review',
        'Study the hardest topic for 20 minutes',
        'Solve practice questions',
        'Review mistakes and make flashcards'
      ];
    } else if (lower.contains('portfolio') || lower.contains('project')) {
      return [
        'Define the project outcome',
        'Create the first rough draft',
        'Improve one visible section',
        'Share for feedback'
      ];
    }
    return [
      'Write the desired outcome',
      'Break the goal into 3 milestones',
      'Do the smallest first action',
      'Review progress and adjust tomorrow'
    ];
  }

  List<String> _refineTaskTitlesFromPrompt(
      List<String> currentTitles, String request, String goalTitle) {
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

  List<_DraftTaskSpec> _draftSpecsFromGeneratedTasks(
      List<GeneratedTask> tasks) {
    final deadlineDays =
        max(1, dateOnly(_newGoalDeadline).difference(today).inDays);
    return tasks.where((task) => task.title.trim().isNotEmpty).map((task) {
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

  List<MicroTask> _generateMicroTasksFromTitles(
      List<String> taskTitles, int goalId) {
    return _generateMicroTasksFromSpecs(
        _draftSpecsFromTitles(taskTitles), goalId);
  }

  List<MicroTask> _generateMicroTasksFromSpecs(
      List<_DraftTaskSpec> taskSpecs, int goalId) {
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
    if (task.done) {
      _showCoinRewardPrompt(
        task.points,
        'for completing "${task.title}"',
      );
    }
    unawaited(_persistTaskToggle(goal, task));
    unawaited(_persistProfileStats());
    _queueNotificationScheduleSync();
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

  unawaited(_deleteGoalEverywhere(goal));

  _queueNotificationScheduleSync();
  _showMessage('Removed ${goal.title}.');
}

Future<void> _deleteGoalEverywhere(GoalProject goal) async {
  final user = context.read<AuthService>().currentUser;

  if (user != null && !user.isAnonymous) {
    try {
      final deletedEvents = await context
          .read<GoogleCalendarService>()
          .deleteTaskEventsForGoal(goal);

      debugPrint(
        'Deleted $deletedEvents Google Calendar events for goal ${goal.title}.',
      );
    } catch (e) {
      debugPrint('Google Calendar goal cleanup failed: $e');

      if (mounted) {
        _showMessage(
          'Goal removed, but Google Calendar cleanup failed.',
        );
      }
    }
  }

  final sync = _sync;

  if (sync != null) {
    try {
      await sync.deleteGoal(goal.id.toString());
    } catch (e) {
      debugPrint('Delete goal sync failed: $e');

      if (mounted) {
        _showMessage('Goal removed locally, but Firebase delete failed.');
      }
    }
  }
}


  void _addCommunity() {
    final title = _communityController.text.trim();
    if (title.isEmpty) {
      _showHelpfulError(
        title: 'Community name is missing',
        message:
            'Write a short community name first, then you can invite people later.',
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
      description:
          'A new accountability group for people working on similar goals.',
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
    _addInAppNotification(
      title: 'Community created',
      body: '${community.name} is ready for accountability.',
      type: AppNotificationType.community,
      sourceId: community.name,
    );
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
    _addInAppNotification(
      title: 'Community joined',
      body: 'You joined ${group.name}.',
      type: AppNotificationType.community,
      sourceId: id ?? group.name,
    );
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
    _addInAppNotification(
      title: 'Friend added',
      body: '$cleaned can now be part of your accountability circle.',
      type: AppNotificationType.community,
      sourceId: cleaned,
    );
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
        message:
            'A mystery chest costs 50 coins. Complete a few tasks first, then try again.',
        actionLabel: 'Got it',
        onAction: () {},
      );
      return;
    }
    final skins = [
      defaultPet,
      const PetSkin(
          name: 'Peach',
          from: Color(0xFFFFB4A2),
          to: Color(0xFFFFD6A5),
          accent: Color(0xFFFFF1E6)),
      const PetSkin(
          name: 'Lunar',
          from: Color(0xFF64748B),
          to: Color(0xFF1E293B),
          accent: Color(0xFFE2E8F0)),
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
    _addInAppNotification(
      title: 'Chest reward unlocked',
      body: '${skin.name} skin and $accessory are now in your collection.',
      type: AppNotificationType.reward,
      sourceId: '${skin.name}_$accessory',
    );
    _showMessage('Chest opened: ${skin.name} skin + $accessory unlocked!');
  }

  void _feedPet() {
    if (_coins < 10) {
      _showHelpfulError(
        title: 'Not enough coins',
        message:
            'Complete one task first. Each completed task gives coins you can use for your companion.',
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
    final config = await showModalBottomSheet<FocusSessionConfig>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: gdSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => FocusSetupSheet(goals: _goals, today: today),
    );
    if (!mounted || config == null) return;
    _startFocusSession(config);
  }

  void _handleMoodChanged(String value) {
    if (value == _selectedMood) return;

    setState(() => _selectedMood = value);
    unawaited(_persistMood(value));

    if (!_moodAdvisorAvailable) return;
    _moodAdviceTimer?.cancel();
    _moodAdviceTimer = Timer(const Duration(milliseconds: 450), () {
      unawaited(_requestMoodAdvice(value));
    });
  }

  Future<void> _requestMoodAdvice(String mood) async {
    final requestSerial = ++_moodAdviceRequestSerial;
    try {
      final advice = await context.read<GenkitService>().moodAdvisor.advise(
            MoodAdvisorRequest(
              mood: mood,
              completedToday: _todayCompleted,
              totalToday: _todayTasks.length,
              streak: _streak,
            ),
          );
      if (!mounted ||
          requestSerial != _moodAdviceRequestSerial ||
          mood != _selectedMood) {
        return;
      }
      _addInAppNotification(
        title: 'AI mood plan',
        body: advice.message,
        type: AppNotificationType.moodNudge,
        important: mood == 'Tired' || mood == 'Stressed',
        sourceId: mood,
      );
      _showMessage('AI mood plan: ${advice.message}');
    } catch (e) {
      if (e.toString().contains('not-found')) {
        _moodAdvisorAvailable = false;
      }
      debugPrint('Mood advisor unavailable: $e');
    }
  }

  void _startFocusSession(FocusSessionConfig config) {
    _focusTimer?.cancel();
    setState(() {
      _activeFocusConfig = config;
      _focusRemainingSeconds = config.durationMinutes * 60;
      _focusPaused = false;
      _focusCompletionHandled = false;
    });
    _focusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_focusPaused) return;
      setState(
          () => _focusRemainingSeconds = max(0, _focusRemainingSeconds - 1));
      if (_focusRemainingSeconds == 0) {
        timer.cancel();
        _handleFocusSessionCompleted();
      }
    });
    _queueNotificationScheduleSync();
    _openActiveFocusDialog();
  }

  void _handleFocusSessionCompleted() {
    final config = _activeFocusConfig;
    if (_focusCompletionHandled || config == null) return;
    _focusCompletionHandled = true;
    _focusTimer?.cancel();
    unawaited(SystemSound.play(SystemSoundType.alert));
    _showMessage('Focus session complete. Nice work.');
    if (_notificationSettings.systemNotificationsEnabled &&
        _notificationSettings.focusNotificationsEnabled) {
      unawaited(_showFocusCompleteSystemNotification(config));
    }
    _queueNotificationScheduleSync();
  }

  Future<void> _showFocusCompleteSystemNotification(
    FocusSessionConfig config,
  ) {
    return _showSystemNotificationNow(
      key: 'focus_complete',
      title: 'Focus session complete',
      body: '${config.title} is ready to wrap up.',
      type: AppNotificationType.focusComplete,
      important: true,
      sourceId: config.title,
    );
  }

  void _openActiveFocusDialog() {
    final config = _activeFocusConfig;
    if (config == null) return;
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.18),
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
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
                scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
                child: child));
      },
    );
  }

  void _toggleFocusPause() {
    setState(() => _focusPaused = !_focusPaused);
    _queueNotificationScheduleSync();
  }

  void _stopFocusSession() {
    final config = _activeFocusConfig;
    final completed = _focusRemainingSeconds <= 0;
    if (completed) _handleFocusSessionCompleted();
    _focusTimer?.cancel();

    if (completed && config?.task != null && config!.task!.done == false) {
      _toggleTask(config.task!);
    }

    setState(() {
      _activeFocusConfig = null;
      _focusRemainingSeconds = 0;
      _focusPaused = false;
      _focusCompletionHandled = false;
    });
    _queueNotificationScheduleSync();
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
        _showMessage(
          '${_activePetSkin.name} says: +${insight.coinsEarned} coins for finishing ${config.durationMinutes} focused minutes. AI focus insight: ${insight.insight}',
        );
      } else {
        _showMessage('AI focus insight: ${insight.insight}');
      }
    } catch (e) {
      debugPrint('Focus insight unavailable: $e');
    }
  }

  void _openProfile() {
    final authState = context.read<AuthState>();
    final user = context.read<AuthService>().currentUser ?? authState.user;
    final displayName = _currentProfileDisplayName(user, authState);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => ProfileScreen(
          displayName: displayName,
          email: user?.email ?? '',
          photoUrl: user?.photoURL,
          signedInWith: _signedInWith,
          isGuest: user?.isAnonymous ?? authState.isGuest,
          emailVerified: authState.emailVerified,
          providerIds: authState.providerIds,
          coins: _coins,
          streak: _streak,
          petHappiness: _petHappiness,
          pet: _activePetSkin,
          accessory: _activeAccessory,
          selectedMood: _selectedMood,
          goals: _goals,
          tasks: _allTasks,
          communities: _communities,
          friends: _friends,
          routines: _routines,
          goalReminders: _goalReminders,
          friendProgressSharing: _friendProgressSharing,
          onDisplayNameChanged: _updateDisplayName,
          onSendEmailVerification: authState.sendEmailVerification,
          onRefreshEmailVerification: authState.reloadUser,
          onSendPasswordReset: authState.sendPasswordResetEmail,
          onUpgradeGuestWithEmail: _upgradeGuestWithEmail,
          onUpgradeGuestWithGoogle: _upgradeGuestWithGoogle,
          onGoalRemindersChanged: _setGoalReminders,
          onFriendProgressSharingChanged: _setFriendProgressSharing,
          onSignOut: () => unawaited(_handleSignOut()),
          onDeleteAccount: _deleteCurrentAccount,
        ),
      ),
    );
  }

  String _currentProfileDisplayName(
    firebase_auth.User? user,
    AuthState authState,
  ) {
    if (_profileDisplayName?.trim().isNotEmpty == true) {
      return _profileDisplayName!.trim();
    }
    if (user?.displayName?.trim().isNotEmpty == true) {
      return user!.displayName!.trim();
    }
    return authState.displayName;
  }

  Future<bool> _updateDisplayName(String displayName) async {
    final authService = context.read<AuthService>();
    try {
      final cleaned = displayName.trim();
      await authService.updateDisplayName(displayName);
      final user = authService.currentUser;
      if (user == null) return false;
      if (mounted) {
        setState(() => _profileDisplayName = cleaned);
      }
      try {
        await _userRepository.createOrUpdateProfile(
          uid: user.uid,
          displayName: cleaned,
          email: user.email,
          photoUrl: user.photoURL,
        );
      } catch (e) {
        debugPrint('Display name profile sync failed: $e');
      }
      return true;
    } catch (e) {
      debugPrint('Display name update failed: $e');
      return false;
    }
  }

  Future<bool> _upgradeGuestWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final authState = context.read<AuthState>();
    final authService = context.read<AuthService>();
    final upgraded = await authState.upgradeGuestWithEmail(
      displayName: displayName,
      email: email,
      password: password,
    );
    final user = authService.currentUser ?? authState.user;
    if (!upgraded || user == null) return false;

    try {
      await _userRepository.createOrUpdateProfile(
        uid: user.uid,
        displayName: displayName.trim(),
        email: user.email ?? email.trim(),
        photoUrl: user.photoURL,
      );
      await _userRepository.markOnboarded(user.uid);
      if (mounted) {
        setState(() {
          _profileDisplayName = displayName.trim();
          _signedInWith = 'Email';
        });
      }
      return true;
    } catch (e) {
      debugPrint('Guest upgrade profile sync failed: $e');
      if (mounted) {
        setState(() {
          _profileDisplayName = displayName.trim();
          _signedInWith = 'Email';
        });
      }
      return true;
    }
  }

  Future<GuestGoogleUpgradeResult?> _upgradeGuestWithGoogle() async {
    final authState = context.read<AuthState>();
    final authService = context.read<AuthService>();
    final upgraded = await authState.upgradeGuestWithGoogle();
    final user = authService.currentUser ?? authState.user;
    if (!upgraded || user == null) return null;

    final displayName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : _profileDisplayName?.trim().isNotEmpty == true
            ? _profileDisplayName!.trim()
            : 'Goal Digger User';
    final email = user.email ?? '';

    try {
      await _userRepository.createOrUpdateProfile(
        uid: user.uid,
        displayName: displayName,
        email: email,
        photoUrl: user.photoURL,
      );
      await _userRepository.markOnboarded(user.uid);
    } catch (e) {
      debugPrint('Guest Google upgrade profile sync failed: $e');
    }

    if (mounted) {
      setState(() {
        _profileDisplayName = displayName;
        _signedInWith = 'Google';
      });
    }

    return GuestGoogleUpgradeResult(displayName: displayName, email: email);
  }

  Future<bool> _deleteCurrentAccount() async {
    final deleted = await context.read<AuthState>().deleteCurrentUser();
    if (!deleted || !mounted) return false;
    _resetForSignedOutState();
    return true;
  }

  void _addRoutine(RoutineItem routine) {
    setState(() => _routines.add(routine));
    final sync = _sync;
    if (sync != null) {
      unawaited(sync.createRoutine(routine).catchError((Object e) {
        debugPrint('Routine sync failed: $e');
        _showMessage('Routine added locally, but Firebase save failed.');
        return routine;
      }));
    }
    _queueNotificationScheduleSync();
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
    _queueNotificationScheduleSync();
    _showMessage('Routine deleted.');
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => SettingsScreen(
          goalReminders: _goalReminders,
          friendProgressSharing: _friendProgressSharing,
          notificationSettings: _notificationSettings,
          onGoalRemindersChanged: _setGoalReminders,
          onFriendProgressSharingChanged: _setFriendProgressSharing,
          onNotificationSettingsChanged: _setNotificationSettings,
          onTestNotification: () => unawaited(_sendTestNotification()),
          onOpenNotificationSettings: _openAndroidNotificationSettings,
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
    _queueNotificationScheduleSync();
    _ensureImportantDeadlineNotifications();
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
              Text(goal.title,
                  style: const TextStyle(
                      color: gdMuted, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              PrioritySelector(
                value: draftPriority,
                onChanged: (value) =>
                    setLocalState(() => draftPriority = value),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(context, draftPriority),
                child: const Text('Save priority')),
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
    _queueNotificationScheduleSync();
    _showMessage('Priority updated.');
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild the root only when the auth status itself changes. Loading and
    // error changes are only needed by onboarding, and rebuilding the signed-in
    // shell during modal cleanup can upset Flutter's inherited-widget tree.
    final authStatus =
        context.select<AuthState, AuthStatus>((authState) => authState.status);

    // All side effects (sync activation, Firestore writes) are handled
    // in _onAuthStateChanged via the addListener wired in didChangeDependencies.
    if (authStatus == AuthStatus.unknown) {
      return const Scaffold(
        backgroundColor: gdBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_onboarded) {
      return Consumer<AuthState>(
        builder: (context, authState, _) => OnboardingScreen(
          isLoading: authState.isLoading,
          errorMessage: authState.errorMessage,
          onClearError: authState.clearError,
          onPasswordReset: authState.sendPasswordResetEmail,
          onEmailAuth: (email, password, displayName, isSignUp) =>
              _completeOnboardingWithEmail(
            email: email,
            password: password,
            displayName: displayName,
            isSignUp: isSignUp,
          ),
          onGoogle: () => unawaited(_completeOnboardingWithAuth('Google')),
          onGuest: () => unawaited(_completeOnboardingWithAuth('Guest')),
        ),
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
        onSyncTaskToGoogle: _syncTaskToGoogleCalendar,
        onSyncAllTasksToGoogle: _syncAllTasksToGoogleCalendar,
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
      onNotifications: _openNotifications,
      unreadNotifications:
          _notifications.where((notification) => notification.isUnread).length,
      importantUnreadNotifications: _notifications
          .where((notification) => notification.important && notification.isUnread)
          .length,
      hasActiveFocus: _hasActiveFocus || _focusComplete,
      focusLabel: _activeFocusConfig == null
          ? null
          : (_focusComplete
              ? 'Done'
              : _formatFocusTime(_focusRemainingSeconds)),
    );
  }
}
