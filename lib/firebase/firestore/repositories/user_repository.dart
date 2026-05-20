// ─────────────────────────────────────────────────────────────────────────────
// lib/firebase/firestore/repositories/user_repository.dart
//
// Persists user profile data: display name, streak, coins, pet happiness,
// active pet skin, active accessory, and mood.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../models/models.dart';
import '../firestore_paths.dart';
import '../firestore_service.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.streak,
    required this.coins,
    required this.petHappiness,
    required this.activePetSkin,
    required this.activeAccessory,
    required this.selectedMood,
    required this.onboarded,
    required this.createdAt,
    required this.updatedAt,
  });

  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final int streak;
  final int coins;
  final int petHappiness;
  final PetSkin activePetSkin;
  final String activeAccessory;
  final String selectedMood;
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
    await _svc.setDoc(
      FirestorePaths.userDoc(uid),
      {
        'uid': uid,
        'displayName': displayName,
        'email': email ?? '',
        'photoUrl': photoUrl,
        'createdAt': FirestoreService.serverTimestamp,
        'updatedAt': FirestoreService.serverTimestamp,
        // Default values – only written on first create (merge=true keeps
        // existing values on subsequent calls)
        'streak': 0,
        'coins': 140,
        'petHappiness': 62,
        'activeAccessory': 'Cap',
        'selectedMood': 'Okay',
        'onboarded': false,
        'petSkin': {
          'name': 'Mint',
          'colorFrom': Colors.teal.shade200.value,
          'colorTo': Colors.teal.shade400.value,
          'accent': Colors.tealAccent.value,
        },
      },
      merge: true,
    );
  }

  // ── Partial updates ──────────────────────────────────────────────────────────

  Future<void> markOnboarded(String uid) async {
    await _svc.updateDoc(FirestorePaths.userDoc(uid), {
      'onboarded': true,
      'updatedAt': FirestoreService.serverTimestamp,
    });
  }

  Future<void> updateStreak(String uid, int streak) async {
    await _svc.updateDoc(FirestorePaths.userDoc(uid), {
      'streak': streak,
      'updatedAt': FirestoreService.serverTimestamp,
    });
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

  Future<void> updatePetState(
      String uid, int happiness, PetSkin skin, String accessory) async {
    await _svc.updateDoc(FirestorePaths.userDoc(uid), {
      'petHappiness': happiness,
      'activeAccessory': accessory,
      'petSkin': {
        'name': skin.name,
        'colorFrom': skin.from.value,
        'colorTo': skin.to.value,
        'accent': skin.accent.value,
      },
      'updatedAt': FirestoreService.serverTimestamp,
    });
  }

  Future<void> updateMood(String uid, String mood) async {
    await _svc.updateDoc(FirestorePaths.userDoc(uid), {
      'selectedMood': mood,
      'updatedAt': FirestoreService.serverTimestamp,
    });
  }

  // ── Serialisation ─────────────────────────────────────────────────────────────

  UserProfile _profileFromDoc(
      DocumentSnapshot<Map<String, dynamic>> snap) {
    final d = snap.data()!;
    final petMap = d['petSkin'] as Map<String, dynamic>? ?? {};

    return UserProfile(
      uid: d['uid'] as String? ?? snap.id,
      displayName: d['displayName'] as String? ?? 'User',
      email: d['email'] as String? ?? '',
      photoUrl: d['photoUrl'] as String?,
      streak: (d['streak'] as num?)?.toInt() ?? 0,
      coins: (d['coins'] as num?)?.toInt() ?? 0,
      petHappiness: (d['petHappiness'] as num?)?.toInt() ?? 50,
      activePetSkin: PetSkin(
        name: petMap['name'] as String? ?? 'Mint',
        from: Color(petMap['colorFrom'] as int? ?? Colors.teal.shade200.value),
        to: Color(petMap['colorTo'] as int? ?? Colors.teal.shade400.value),
        accent:
            Color(petMap['accent'] as int? ?? Colors.tealAccent.value),
      ),
      activeAccessory: d['activeAccessory'] as String? ?? 'Cap',
      selectedMood: d['selectedMood'] as String? ?? 'Okay',
      onboarded: d['onboarded'] as bool? ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
