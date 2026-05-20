// ─────────────────────────────────────────────────────────────────────────────
// lib/firebase/sync/app_sync_service.dart
//
// The bridge between Firebase real-time data and the app's in-memory state.
//
// Usage in GoalDiggerRoot (or a top-level Provider):
//
//   final _sync = AppSyncService(uid: authState.uid);
//
//   @override
//   void initState() {
//     super.initState();
//     _sync.goalsStream.listen((goals) => setState(() => _goals = goals));
//     _sync.profileStream.listen((p) => setState(() { _coins = p.coins; ... }));
//   }
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/models.dart';
import '../firestore/repositories/community_repository.dart';
import '../firestore/repositories/goal_repository.dart';
import '../firestore/repositories/user_repository.dart';

class AppSyncService {
  AppSyncService({
    required this.uid,
    GoalRepository? goalRepo,
    UserRepository? userRepo,
    CommunityRepository? communityRepo,
  })  : _goalRepo = goalRepo ?? GoalRepository(),
        _userRepo = userRepo ?? UserRepository(),
        _communityRepo = communityRepo ?? CommunityRepository();

  final String uid;
  final GoalRepository _goalRepo;
  final UserRepository _userRepo;
  final CommunityRepository _communityRepo;

  final List<StreamSubscription<dynamic>> _subs = [];

  // ── Public streams ───────────────────────────────────────────────────────────

  Stream<List<GoalProject>> get goalsStream => _goalRepo.watchGoals(uid);

  Stream<UserProfile?> get profileStream => _userRepo.watchProfile(uid);

  Stream<List<CommunityGroup>> get communitiesStream =>
      _communityRepo.watchAllCommunities();

  Stream<Set<String>> get joinedCommunityIdsStream =>
      _communityRepo.watchJoinedIds(uid);

  // ── Convenience write delegates ──────────────────────────────────────────────

  // Goals
  Future<GoalProject> createGoal(GoalProject goal) =>
      _goalRepo.createGoal(uid, goal);

  Future<void> updateGoal(GoalProject goal) =>
      _goalRepo.updateGoal(uid, goal);

  Future<void> deleteGoal(String goalId) =>
      _goalRepo.deleteGoal(uid, goalId);

  Future<void> toggleTask(String goalId, String taskId, bool done) =>
      _goalRepo.toggleTask(uid, goalId, taskId, done);

  Future<void> upsertTask(String goalId, MicroTask task) =>
      _goalRepo.upsertTask(uid, goalId, task);

  // User profile
  Future<void> updateStreak(int streak) => _userRepo.updateStreak(uid, streak);
  Future<void> addCoins(int amount) => _userRepo.addCoins(uid, amount);
  Future<void> updateMood(String mood) => _userRepo.updateMood(uid, mood);
  Future<void> updatePetState(
          int happiness, PetSkin skin, String accessory) =>
      _userRepo.updatePetState(uid, happiness, skin, accessory);
  Future<void> markOnboarded() => _userRepo.markOnboarded(uid);

  // Community
  Future<void> joinCommunity(String communityId) =>
      _communityRepo.join(uid, communityId);
  Future<void> leaveCommunity(String communityId) =>
      _communityRepo.leave(uid, communityId);
  Future<CommunityGroup> createCommunity(CommunityGroup group) =>
      _communityRepo.createCommunity(group, uid);

  // ── Cleanup ─────────────────────────────────────────────────────────────────

  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    _subs.clear();
    debugPrint('🔌 AppSyncService disposed for uid=$uid');
  }
}
