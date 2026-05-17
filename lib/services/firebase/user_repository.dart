/// user_repository.dart
/// ---------------------
/// Firebase Authentication sign-in helpers and Firestore user-profile CRUD.
///
/// Firestore path: users/{uid}
///
/// Folder: lib/services/firebase/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_config.dart';
import 'firebase_models.dart';

class UserRepository {
  // ── Auth helpers ──────────────────────────────────────────────────────────

  /// Stream of auth state changes. Emits null when signed out.
  Stream<User?> get authStateChanges => auth.authStateChanges();

  /// Sign in anonymously (Guest mode). Creates the Firestore profile if new.
  Future<UserCredential> signInAnonymously() async {
    final cred = await auth.signInAnonymously();
    await _ensureProfile(cred.user!, displayName: 'Guest');
    return cred;
  }

  /// Sign in with email + password.
  Future<UserCredential> signInWithEmail(String email, String password) async {
    final cred = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _ensureProfile(cred.user!);
    return cred;
  }

  /// Create a new account with email + password.
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user!.updateDisplayName(displayName);
    await _createProfile(cred.user!, displayName: displayName);
    return cred;
  }

  Future<void> signOut() => auth.signOut();

  // ── Profile CRUD ──────────────────────────────────────────────────────────

  DocumentReference<Map<String, dynamic>> _profileRef(String uid) =>
      firestore.collection('users').doc(uid);

  /// Returns null when the user document doesn't exist yet.
  Future<UserProfile?> fetchProfile(String uid) async {
    final doc = await _profileRef(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  /// Real-time stream of the user's profile document.
  Stream<UserProfile?> watchProfile(String uid) {
    return _profileRef(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    });
  }

  /// Overwrite specific fields on the profile (merge = true keeps other fields).
  Future<void> updateProfileFields(
    String uid,
    Map<String, dynamic> fields,
  ) async {
    await _profileRef(uid).set(
      {...fields, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  /// Increment coins by [amount] (can be negative to deduct).
  Future<void> addCoins(String uid, int amount) async {
    await _profileRef(uid).update({
      'coins': FieldValue.increment(amount),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Increment the streak counter by 1.
  Future<void> incrementStreak(String uid) async {
    await _profileRef(uid).update({
      'streak': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Reset the streak counter to zero.
  Future<void> resetStreak(String uid) async {
    await _profileRef(uid)
        .update({'streak': 0, 'updatedAt': FieldValue.serverTimestamp()});
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _ensureProfile(User user, {String? displayName}) async {
    final doc = await _profileRef(user.uid).get();
    if (!doc.exists) {
      await _createProfile(user, displayName: displayName);
    }
  }

  Future<void> _createProfile(User user, {String? displayName}) async {
    final profile = UserProfile(
      uid: user.uid,
      displayName: displayName ?? user.displayName ?? 'Goal Digger',
      coins: 140,         // starter coins (matches original seed data)
      streak: 0,
      petHappiness: 62,   // matches original seed data
      activePetSkin: 'Mint',
      activeAccessory: 'Cap',
      onboarded: false,
      mood: 'Okay',
    );
    await _profileRef(user.uid).set(profile.toFirestore());
  }
}
