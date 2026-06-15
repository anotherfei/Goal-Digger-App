// ─────────────────────────────────────────────────────────────────────────────
// lib/firebase/firestore/repositories/user_repository.dart
//
// Persists user profile data: display name, streak, coins, pet happiness,
// active companion, unlocked companions, and mood.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../features/notifications/models/notification_models.dart';
import '../../../models/models.dart';
import '../firestore_paths.dart';
import '../firestore_service.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.streak,
    required this.lastStreakDateKey,
    required this.coins,
    required this.petHappiness,
    required this.lastHappinessDecayDateKey,
    required this.activeCompanion,
    required this.unlockedCompanions,
    required this.selectedMood,
    required this.goalReminders,
    required this.notificationSettings,
    required this.friendProgressSharing,
    required this.friends,
    required this.onboarded,
    required this.createdAt,
    required this.updatedAt,
  });

  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final int streak;
  final String? lastStreakDateKey;
  final int coins;
  final int petHappiness;
  final String? lastHappinessDecayDateKey;
  final CompanionKind activeCompanion;
  final Set<CompanionKind> unlockedCompanions;
  final String selectedMood;
  final bool goalReminders;
  final NotificationSettings notificationSettings;
  final bool friendProgressSharing;
  final List<String> friends;
  final bool onboarded;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class UserRepository {
  UserRepository({FirestoreService? service})
      : _svc = service ?? FirestoreService();

  final FirestoreService _svc;

  // ── Stream ───────────────────────────────────────────────────────────────────

  Stream<UserProfile?> watchProfile(String uid) {
    return _svc.watchDoc(FirestorePaths.userDoc(uid)).map((snap) {
      if (!snap.exists) return null;
      return _profileFromDoc(snap);
    });
  }

  // ── Fetch ────────────────────────────────────────────────────────────────────

  Future<UserProfile?> fetchProfile(String uid) async {
    final snap = await _svc.getDoc(FirestorePaths.userDoc(uid));
    if (!snap.exists) return null;
    return _profileFromDoc(snap);
  }

  // ── Create / upsert ─────────────────────────────────────────────────────────

  Future<void> createOrUpdateProfile({
    required String uid,
    required String displayName,
    String? email,
    String? photoUrl,
  }) async {
    final path = FirestorePaths.userDoc(uid);
    final existing = await _svc.getDoc(path);

    final identityData = {
      'uid': uid,
      'displayName': displayName,
      'email': email ?? '',
      'photoUrl': photoUrl,
      'updatedAt': FirestoreService.serverTimestamp,
    };

    if (existing.exists) {
      await _svc.setDoc(path, identityData, merge: true);
      return;
    }

    await _svc.setDoc(path, {
      ...identityData,
      'createdAt': FirestoreService.serverTimestamp,
      'streak': 0,
      'lastStreakDateKey': null,
      'coins': 140,
      'petHappiness': 62,
      'lastHappinessDecayDateKey': null,
      'activeCompanion': CompanionKind.lumi.id,
      'unlockedCompanions': [CompanionKind.lumi.id],
      'selectedMood': 'Okay',
      'goalReminders': true,
      'notificationSettings': const NotificationSettings.defaults().toMap(),
      'friendProgressSharing': true,
      'friends': <String>[],
      'onboarded': false,
    });
  }

  // ── Partial updates ──────────────────────────────────────────────────────────

  Future<void> markOnboarded(String uid) async {
    await _svc.updateDoc(FirestorePaths.userDoc(uid), {
      'onboarded': true,
      'updatedAt': FirestoreService.serverTimestamp,
    });
  }

  Future<void> updateStreak(
    String uid,
    int streak, {
    String? lastStreakDateKey,
  }) async {
    final data = <String, dynamic>{
      'streak': streak,
      'updatedAt': FirestoreService.serverTimestamp,
    };
    if (lastStreakDateKey != null) {
      data['lastStreakDateKey'] = lastStreakDateKey;
    }
    await _svc.updateDoc(FirestorePaths.userDoc(uid), data);

    final publicProfilePath = FirestorePaths.publicProfileDoc(uid);
    final publicProfile = await _svc.getDoc(publicProfilePath);
    if (publicProfile.exists) {
      await _svc.setDoc(publicProfilePath, data, merge: true);
    }
  }

  Future<void> updateProfileStats({
    required String uid,
    required int coins,
    required int streak,
    required String? lastStreakDateKey,
    required String selectedMood,
    required int petHappiness,
    required String? lastHappinessDecayDateKey,
    required CompanionKind activeCompanion,
    required Set<CompanionKind> unlockedCompanions,
  }) async {
    final data = <String, dynamic>{
      'coins': coins,
      'streak': streak,
      'lastStreakDateKey': lastStreakDateKey,
      'selectedMood': selectedMood,
      'petHappiness': petHappiness,
      'lastHappinessDecayDateKey': lastHappinessDecayDateKey,
      'activeCompanion': activeCompanion.id,
      'unlockedCompanions': _companionIds(unlockedCompanions),
      'updatedAt': FirestoreService.serverTimestamp,
    };

    await _svc.updateDoc(FirestorePaths.userDoc(uid), data);

    final publicProfilePath = FirestorePaths.publicProfileDoc(uid);
    final publicProfile = await _svc.getDoc(publicProfilePath);
    if (publicProfile.exists) {
      await _svc.setDoc(
        publicProfilePath,
        {
          'streak': streak,
          'lastStreakDateKey': lastStreakDateKey,
          'updatedAt': FirestoreService.serverTimestamp,
        },
        merge: true,
      );
    }
  }

  Future<void> updateCoins(String uid, int coins) async {
    await _svc.updateDoc(FirestorePaths.userDoc(uid), {
      'coins': coins,
      'updatedAt': FirestoreService.serverTimestamp,
    });
  }

  Future<void> addCoins(String uid, int amount) async {
    await _svc.updateDoc(FirestorePaths.userDoc(uid), {
      'coins': FirestoreService.increment(amount),
      'updatedAt': FirestoreService.serverTimestamp,
    });
  }

  Future<void> updateCompanionState({
    required String uid,
    required int coins,
    required int happiness,
    required CompanionKind activeCompanion,
    required Set<CompanionKind> unlockedCompanions,
  }) async {
    await _svc.updateDoc(FirestorePaths.userDoc(uid), {
      'coins': coins,
      'petHappiness': happiness,
      'activeCompanion': activeCompanion.id,
      'unlockedCompanions': _companionIds(unlockedCompanions),
      'updatedAt': FirestoreService.serverTimestamp,
    });
  }

  Future<void> updateMood(String uid, String mood) async {
    await _svc.updateDoc(FirestorePaths.userDoc(uid), {
      'selectedMood': mood,
      'updatedAt': FirestoreService.serverTimestamp,
    });
  }

  Future<void> updatePreferences({
    required String uid,
    required bool goalReminders,
    required bool friendProgressSharing,
    NotificationSettings? notificationSettings,
  }) async {
    final data = <String, dynamic>{
      'goalReminders': goalReminders,
      'friendProgressSharing': friendProgressSharing,
      'updatedAt': FirestoreService.serverTimestamp,
    };
    if (notificationSettings != null) {
      data['notificationSettings'] = notificationSettings.toMap();
    }
    await _svc.updateDoc(FirestorePaths.userDoc(uid), data);
  }

  Future<void> updateFriends(String uid, List<String> friends) async {
    final cleaned = friends
        .map((friend) => friend.trim())
        .where((friend) => friend.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    await _svc.updateDoc(FirestorePaths.userDoc(uid), {
      'friends': cleaned,
      'updatedAt': FirestoreService.serverTimestamp,
    });
  }

  // ── Serialisation ─────────────────────────────────────────────────────────────

  List<String> _companionIds(Set<CompanionKind> companions) {
    return ({CompanionKind.lumi, ...companions}.map((kind) => kind.id).toList()
      ..sort());
  }

  Set<CompanionKind> _companionSetFromDoc(Object? value) {
    final ids = value is List<dynamic> ? value : const <dynamic>[];
    final companions =
        ids.map((id) => companionKindFromId(id.toString())).toSet();
    companions.add(CompanionKind.lumi);
    return companions;
  }

  UserProfile _profileFromDoc(DocumentSnapshot<Map<String, dynamic>> snap) {
    final d = snap.data()!;
    final activeCompanion =
        companionKindFromId(d['activeCompanion'] as String?);
    final unlockedCompanions = _companionSetFromDoc(d['unlockedCompanions']);
    unlockedCompanions.add(activeCompanion);

    return UserProfile(
      uid: d['uid'] as String? ?? snap.id,
      displayName: d['displayName'] as String? ?? 'User',
      email: d['email'] as String? ?? '',
      photoUrl: d['photoUrl'] as String?,
      streak: (d['streak'] as num?)?.toInt() ?? 0,
      lastStreakDateKey: d['lastStreakDateKey'] as String?,
      coins: (d['coins'] as num?)?.toInt() ?? 0,
      petHappiness: (d['petHappiness'] as num?)?.toInt() ?? 50,
      lastHappinessDecayDateKey: d['lastHappinessDecayDateKey'] as String?,
      activeCompanion: activeCompanion,
      unlockedCompanions: unlockedCompanions,
      selectedMood: d['selectedMood'] as String? ?? 'Okay',
      goalReminders: d['goalReminders'] as bool? ?? true,
      notificationSettings: NotificationSettings.fromMap(
        d['notificationSettings'] as Map<String, dynamic>?,
      ).copyWith(
        systemNotificationsEnabled: d['goalReminders'] as bool?,
      ),
      friendProgressSharing: d['friendProgressSharing'] as bool? ?? true,
      friends: (d['friends'] as List<dynamic>? ?? [])
          .map((friend) => friend.toString())
          .where((friend) => friend.trim().isNotEmpty)
          .toList(),
      onboarded: d['onboarded'] as bool? ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
