// ─────────────────────────────────────────────────────────────────────────────
// lib/firebase/sync/app_sync_service.dart
//
// The bridge between Firebase real-time data and the app's in-memory state.
// All stream subscriptions are managed by the caller (GoalDiggerRoot), which
// cancels them when the user signs out or the widget is disposed.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

import '../../models/models.dart';
import '../../features/notifications/models/notification_models.dart';
import '../firestore/repositories/community_repository.dart';
import '../firestore/repositories/goal_repository.dart';
import '../firestore/repositories/notification_repository.dart';
import '../firestore/repositories/routine_repository.dart';
import '../firestore/repositories/user_repository.dart';

class AppSyncService {
  AppSyncService({
    required this.uid,
    GoalRepository? goalRepo,
    UserRepository? userRepo,
    CommunityRepository? communityRepo,
    RoutineRepository? routineRepo,
    NotificationRepository? notificationRepo,
  })  : _goalRepo = goalRepo ?? GoalRepository(),
        _userRepo = userRepo ?? UserRepository(),
        _communityRepo = communityRepo ?? CommunityRepository(),
        _routineRepo = routineRepo ?? RoutineRepository(),
        _notificationRepo = notificationRepo ?? NotificationRepository();

  final String uid;
  final GoalRepository _goalRepo;
  final UserRepository _userRepo;
  final CommunityRepository _communityRepo;
  final RoutineRepository _routineRepo;
  final NotificationRepository _notificationRepo;

  // ── Public streams ───────────────────────────────────────────────────────────

  Stream<List<GoalProject>> get goalsStream => _goalRepo.watchGoals(uid);

  Stream<UserProfile?> get profileStream => _userRepo.watchProfile(uid);

  Stream<List<CommunityGroup>> get communitiesStream =>
      _communityRepo.watchAllCommunities();

  Stream<Set<String>> get joinedCommunityIdsStream =>
      _communityRepo.watchJoinedIds(uid);

  Stream<List<RoutineItem>> get routinesStream =>
      _routineRepo.watchRoutines(uid);

  Stream<List<AppNotification>> get notificationsStream =>
      _notificationRepo.watchNotifications(uid);

  // ── Convenience write delegates ──────────────────────────────────────────────

  // Goals
  Future<GoalProject> createGoal(GoalProject goal) =>
      _goalRepo.createGoal(uid, goal);

  Future<void> updateGoal(GoalProject goal) => _goalRepo.updateGoal(uid, goal);

  Future<void> deleteGoal(String goalId) => _goalRepo.deleteGoal(uid, goalId);

  Future<void> toggleTask(String goalId, String taskId, bool done) =>
      _goalRepo.toggleTask(uid, goalId, taskId, done);

  Future<void> upsertTask(String goalId, MicroTask task) =>
      _goalRepo.upsertTask(uid, goalId, task);

  // User profile
  Future<void> updateStreak(
    int streak, {
    String? lastStreakDateKey,
  }) =>
      _userRepo.updateStreak(
        uid,
        streak,
        lastStreakDateKey: lastStreakDateKey,
      );

  /// Adds [amount] to the user's coin balance using a Firestore increment
  /// so concurrent updates don't race (e.g. two tasks completed in quick
  /// succession won't clobber each other's coin award).
  Future<void> addCoins(int amount) => _userRepo.addCoins(uid, amount);

  /// Overwrites the coin balance with an absolute [coins] value.
  /// Use this when syncing the authoritative local total back to Firestore
  /// (e.g. after purchasing a pet chest).
  Future<void> setCoins(int coins) => _userRepo.updateCoins(uid, coins);

  Future<void> updateProfileStats({
    required int coins,
    required int streak,
    required String? lastStreakDateKey,
    required String selectedMood,
    required int petHappiness,
    required PetSkin activePetSkin,
    required String activeAccessory,
  }) =>
      _userRepo.updateProfileStats(
        uid: uid,
        coins: coins,
        streak: streak,
        lastStreakDateKey: lastStreakDateKey,
        selectedMood: selectedMood,
        petHappiness: petHappiness,
        activePetSkin: activePetSkin,
        activeAccessory: activeAccessory,
      );

  Future<void> updateMood(String mood) => _userRepo.updateMood(uid, mood);

  Future<void> updatePreferences({
    required bool goalReminders,
    required bool friendProgressSharing,
    NotificationSettings? notificationSettings,
  }) =>
      _userRepo.updatePreferences(
        uid: uid,
        goalReminders: goalReminders,
        friendProgressSharing: friendProgressSharing,
        notificationSettings: notificationSettings,
      );

  Future<void> updateFriends(List<String> friends) =>
      _userRepo.updateFriends(uid, friends);

  Future<void> updatePetState(int happiness, PetSkin skin, String accessory) =>
      _userRepo.updatePetState(uid, happiness, skin, accessory);

  Future<void> markOnboarded() => _userRepo.markOnboarded(uid);

  // Community
  Future<void> joinCommunity(String communityId) =>
      _communityRepo.join(uid, communityId);

  Future<void> leaveCommunity(String communityId) =>
      _communityRepo.leave(uid, communityId);

  Future<CommunityGroup> createCommunity(CommunityGroup group) =>
      _communityRepo.createCommunity(group, uid);

  // Routines
  Future<RoutineItem> createRoutine(RoutineItem routine) =>
      _routineRepo.createRoutine(uid, routine);

  Future<void> deleteRoutine(String routineId) =>
      _routineRepo.deleteRoutine(uid, routineId);

  // Notifications
  Future<void> addNotification(AppNotification notification) =>
      _notificationRepo.addNotification(uid, notification);

  Future<void> markNotificationRead(String notificationId) =>
      _notificationRepo.markRead(uid, notificationId);

  Future<void> markAllNotificationsRead() => _notificationRepo.markAllRead(uid);

  Future<void> deleteNotification(String notificationId) =>
      _notificationRepo.deleteNotification(uid, notificationId);

  // ── Cleanup ─────────────────────────────────────────────────────────────────

  void dispose() {
    debugPrint('🔌 AppSyncService disposed for uid=$uid');
  }
}
