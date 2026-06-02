// ─────────────────────────────────────────────────────────────────────────────
// lib/firebase/auth/auth_state.dart
//
// ChangeNotifier that tracks Firebase Auth state and exposes helpers
// for the UI to branch on sign-in status.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'auth_service.dart';

enum AuthStatus { unknown, signedOut, guest, signedIn }

class AuthState extends ChangeNotifier {
  AuthState(this._authService) {
    _sub = _authService.userStream.listen(_onUserChanged);
  }

  final AuthService _authService;
  late final StreamSubscription<User?> _sub;

  User? _user;
  AuthStatus _status = AuthStatus.unknown;
  bool _isLoading = false;
  String? _errorMessage;

  // ── Public getters ───────────────────────────────────────────────────────────

  User? get user => _user;
  AuthStatus get status => _status;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isSignedIn => _status == AuthStatus.signedIn;
  bool get isGuest => _status == AuthStatus.guest;
  bool get isKnown => _status != AuthStatus.unknown;

  /// Display name: real name, anonymous label, or "Guest".
  String get displayName {
    if (_user == null) return 'Guest';
    if (_user!.isAnonymous) return 'Guest';
    return _user!.displayName ?? _user!.email ?? 'User';
  }

  String get uid => _user?.uid ?? '';
  bool get emailVerified => _user?.emailVerified ?? false;

  List<String> get providerIds =>
      _user?.providerData.map((provider) => provider.providerId).toList() ??
      const [];

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Auth actions ─────────────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      await _authService.signInWithGoogle();
      _errorMessage = null;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Google sign-in failed. Please try again.';
      debugPrint('signInWithGoogle error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      _errorMessage = null;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Email login failed. Please try again.';
      debugPrint('signInWithEmail error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createAccountWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _setLoading(true);
    try {
      await _authService.createAccountWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      _errorMessage = null;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Could not create that account. Please try again.';
      debugPrint('createAccountWithEmail error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> upgradeGuestWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await _authService.upgradeGuestWithEmail(
        displayName: displayName,
        email: email,
        password: password,
      );
      _user = _authService.currentUser;
      _status = _user == null
          ? AuthStatus.signedOut
          : _user!.isAnonymous
              ? AuthStatus.guest
              : AuthStatus.signedIn;
      _errorMessage = null;
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Could not upgrade the guest account. Please try again.';
      debugPrint('upgradeGuestWithEmail error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> upgradeGuestWithGoogle() async {
    _setLoading(true);
    try {
      await _authService.upgradeGuestWithGoogle();
      _user = _authService.currentUser;
      _status = _user == null
          ? AuthStatus.signedOut
          : _user!.isAnonymous
              ? AuthStatus.guest
              : AuthStatus.signedIn;
      _errorMessage = null;
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Could not bind Google to this guest account.';
      debugPrint('upgradeGuestWithGoogle error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email);
      _errorMessage = null;
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Could not send reset instructions. Please try again.';
      debugPrint('sendPasswordResetEmail error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendEmailVerification() async {
    _setLoading(true);
    try {
      await _authService.sendEmailVerification();
      _errorMessage = null;
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Could not send verification email. Please try again.';
      debugPrint('sendEmailVerification error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> reloadUser() async {
    _setLoading(true);
    try {
      await _authService.reloadUser();
      _user = _authService.currentUser;
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Could not refresh account status. Please try again.';
      debugPrint('reloadUser error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateDisplayName(String displayName) async {
    _setLoading(true);
    try {
      await _authService.updateDisplayName(displayName);
      _user = _authService.currentUser;
      _errorMessage = null;
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Could not update display name. Please try again.';
      debugPrint('updateDisplayName error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCurrentUser() async {
    _setLoading(true);
    try {
      await _authService.deleteCurrentUser();
      _user = null;
      _status = AuthStatus.signedOut;
      _errorMessage = null;
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Could not delete account. Please try again.';
      debugPrint('deleteCurrentUser error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInAsGuest() async {
    _setLoading(true);
    try {
      await _authService.signInAsGuest();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Could not start a guest session.';
      debugPrint('signInAsGuest error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
    } finally {
      _setLoading(false);
    }
  }

  // ── Internals ─────────────────────────────────────────────────────────────────

  void _onUserChanged(User? user) {
    _user = user;
    if (user == null) {
      _status = AuthStatus.signedOut;
    } else if (user.isAnonymous) {
      _status = AuthStatus.guest;
    } else {
      _status = AuthStatus.signedIn;
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    final shouldClearError = value && _errorMessage != null;
    if (_isLoading == value && !shouldClearError) return;
    _isLoading = value;
    if (value) _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
