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
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Thin wrapper around [FirebaseAuth] and [GoogleSignIn].
///
/// Inject via Provider or pass around; it holds no UI references.
class AuthService {
  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: const [
                'email',
                'https://www.googleapis.com/auth/calendar.events'
              ],
            );

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  // Calendar
  Future<Map<String, String>> getGoogleCalendarAuthHeaders() async {
    var account = _googleSignIn.currentUser;

    account ??= await _googleSignIn.signInSilently();

    account ??= await _googleSignIn.signIn();

    if (account == null) {
      throw const AuthException('Google sign-in is required to sync Calendar.');
    }

    final granted = await _googleSignIn.requestScopes(const [
      'https://www.googleapis.com/auth/calendar.events',
    ]);

    if (!granted) {
      throw const AuthException('Google Calendar permission was not granted.');
    }

    return account.authHeaders;
  }

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
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign-in was cancelled by the user.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Upgrade anonymous account to a real account while preserving data.
      if (currentUser != null && currentUser!.isAnonymous) {
        try {
          return await currentUser!.linkWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use') {
            return _auth.signInWithCredential(credential);
          }
          rethrow;
        }
      }

      return _auth.signInWithCredential(credential);
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_firebaseAuthMessage(e));
    } on PlatformException catch (e) {
      throw AuthException(_googleSignInMessage(e));
    }
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_firebaseAuthMessage(e));
    }
  }

  Future<UserCredential> createAccountWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );

      final user = currentUser;
      final result = user != null && user.isAnonymous
          ? await user.linkWithCredential(credential)
          : await _auth.createUserWithEmailAndPassword(
              email: email.trim(),
              password: password,
            );

      final cleanedName = displayName?.trim();
      if (cleanedName != null && cleanedName.isNotEmpty) {
        await result.user?.updateDisplayName(cleanedName);
        await result.user?.reload();
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_firebaseAuthMessage(e));
    }
  }

  Future<UserCredential> upgradeGuestWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try {
      final user = currentUser;
      if (user == null || !user.isAnonymous) {
        throw const AuthException('Start from a guest account first.');
      }

      final cleanedName = displayName.trim();
      if (cleanedName.isEmpty) {
        throw const AuthException('Display name cannot be empty.');
      }

      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );
      final result = await user.linkWithCredential(credential);

      await result.user?.updateDisplayName(cleanedName);
      await result.user?.sendEmailVerification();
      await result.user?.reload();
      return result;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_firebaseAuthMessage(e));
    }
  }

  Future<UserCredential> upgradeGuestWithGoogle() async {
    final user = currentUser;
    if (user == null || !user.isAnonymous) {
      throw const AuthException('Start from a guest account first.');
    }

    await _googleSignIn.signOut();
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw const AuthException('Google sign-in was cancelled by the user.');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      final result = await user.linkWithCredential(credential);
      final cleanedName = googleUser.displayName?.trim();
      final photoUrl = googleUser.photoUrl?.trim();
      if (cleanedName != null && cleanedName.isNotEmpty) {
        await result.user?.updateDisplayName(cleanedName);
      }
      if (photoUrl != null && photoUrl.isNotEmpty) {
        await result.user?.updatePhotoURL(photoUrl);
      }
      await result.user?.reload();
      return result;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use' ||
          e.code == 'email-already-in-use' ||
          e.code == 'account-exists-with-different-credential') {
        throw const AuthException(
          'That Google account already belongs to another Goal Digger account.',
        );
      }
      throw AuthException(_firebaseAuthMessage(e));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return;
      throw AuthException(_passwordResetAuthMessage(e));
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user == null || user.isAnonymous) {
        throw const AuthException('Sign in with an email account first.');
      }
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_firebaseAuthMessage(e));
    }
  }

  Future<void> reloadUser() async {
    await currentUser?.reload();
  }

  Future<void> updateDisplayName(String displayName) async {
    try {
      final cleaned = displayName.trim();
      if (cleaned.isEmpty) {
        throw const AuthException('Display name cannot be empty.');
      }
      final user = currentUser;
      if (user == null) {
        throw const AuthException('Sign in before editing your profile.');
      }
      await user.updateDisplayName(cleaned);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_firebaseAuthMessage(e));
    }
  }

  Future<void> deleteCurrentUser() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw const AuthException('No signed-in account to delete.');
      }
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_firebaseAuthMessage(e));
    }
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

String _firebaseAuthMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'Enter a valid email address.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'user-not-found':
      return 'No Goal Digger account uses that email yet.';
    case 'wrong-password':
    case 'invalid-credential':
      return 'Email or password did not match.';
    case 'email-already-in-use':
    case 'credential-already-in-use':
      return 'That email already has an account. Log in instead.';
    case 'weak-password':
      return 'Use a password with at least 6 characters.';
    case 'network-request-failed':
      return 'Network connection failed. Try again.';
    case 'operation-not-allowed':
      return 'This sign-in method is not enabled in Firebase Auth yet.';
    case 'requires-recent-login':
      return 'Please sign out, sign back in, then try this account change again.';
    case 'too-many-requests':
      return 'Too many attempts. Please wait a bit and try again.';
    default:
      return e.message ?? 'Authentication failed. Please try again.';
  }
}

String _googleSignInMessage(PlatformException e) {
  final details = '${e.message ?? ''} ${e.details ?? ''}'.toLowerCase();
  if (e.code == 'sign_in_canceled') {
    return 'Google sign-in was cancelled by the user.';
  }
  if (e.code == 'network_error') {
    return 'Network connection failed during Google sign-in. Try again.';
  }
  if (e.code == 'sign_in_failed' && details.contains('10')) {
    return 'Google sign-in is not configured for this Android build. Check the Firebase Google provider and add this app signing SHA-1/SHA-256 fingerprint.';
  }
  return e.message ?? 'Google sign-in failed. Please try again.';
}

String _passwordResetAuthMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'Enter a valid email address.';
    case 'network-request-failed':
      return 'Network connection failed. Try again.';
    case 'too-many-requests':
      return 'Too many reset attempts. Please wait a bit and try again.';
    case 'operation-not-allowed':
      return 'Password reset is not enabled for this Firebase project yet.';
    default:
      return e.message ??
          'Could not send reset instructions. Please try again.';
  }
}
