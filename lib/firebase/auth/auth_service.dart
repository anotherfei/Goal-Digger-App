// ─────────────────────────────────────────────────────────────────────────────
// lib/firebase/auth/auth_service.dart
//
// Wraps Firebase Auth. Supports:
//   • Google Sign-In
//   • Anonymous (Guest) sign-in
//   • Sign-out
//   • Auth state stream
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Thin wrapper around [FirebaseAuth] and [GoogleSignIn].
///
/// Inject via Provider or pass around; it holds no UI references.
class AuthService {
  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  // ── Streams ─────────────────────────────────────────────────────────────────

  /// Emits the current [User] whenever the auth state changes.
  Stream<User?> get userStream => _auth.authStateChanges();

  /// The currently signed-in user, or null.
  User? get currentUser => _auth.currentUser;

  /// True when a real (non-anonymous) user is signed in.
  bool get isSignedInWithProvider =>
      currentUser != null && !currentUser!.isAnonymous;

  // ── Sign-in ─────────────────────────────────────────────────────────────────

  /// Signs in with Google. If the user was previously anonymous, links the
  /// Google credential to the anonymous account so that local data is
  /// preserved after the upgrade.
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw const AuthException('Google sign-in was cancelled by the user.');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Upgrade anonymous account → real account (links data, avoids orphans)
    if (currentUser != null && currentUser!.isAnonymous) {
      try {
        return await currentUser!.linkWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        // Credential already in use on another account – just sign in normally
        if (e.code == 'credential-already-in-use') {
          return _auth.signInWithCredential(credential);
        }
        rethrow;
      }
    }

    return _auth.signInWithCredential(credential);
  }

  /// Creates an anonymous account so the user can start immediately and
  /// upgrade later via [signInWithGoogle].
  Future<UserCredential> signInAsGuest() async {
    return _auth.signInAnonymously();
  }

  // ── Sign-out ─────────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    debugPrint('👋 User signed out');
  }

  // ── Token (for Genkit backend calls) ─────────────────────────────────────────

  /// Returns a fresh Firebase ID token to authenticate Genkit flow requests.
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return currentUser?.getIdToken(forceRefresh);
  }
}

// ── Exception ─────────────────────────────────────────────────────────────────

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => 'AuthException: $message';
}
