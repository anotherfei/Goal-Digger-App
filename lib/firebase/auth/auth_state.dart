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
  bool _disposed = false;

  static const Duration _authTimeout = Duration(seconds: 20);

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
    final currentUser = _user;
    if (currentUser == null) return 'Guest';
    if (currentUser.isAnonymous) return 'Guest';
    return currentUser.displayName ?? currentUser.email ?? 'User';
  }

  String get uid => _user?.uid ?? '';

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    _safeNotifyListeners();
  }

  // ── Auth actions ─────────────────────────────────────────────────────────────

  Future<void> signInWithGoogle() {
    return _runAuthAction(
      actionName: 'signInWithGoogle',
      fallbackError: 'Google sign-in failed. Please try again.',
      timeoutError:
          'Google sign-in is taking too long. Try again, or restart the app.',
      action: _authService.signInWithGoogle,
    );
  }

  Future<void> signInWithEmail(String email, String password) {
    return _runAuthAction(
      actionName: 'signInWithEmail',
      fallbackError: 'Email login failed. Please try again.',
      timeoutError:
          'Email login is taking too long. Check your connection and try again.',
      action: () => _authService.signInWithEmail(
        email: email.trim(),
        password: password,
      ),
    );
  }

  Future<void> createAccountWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) {
    return _runAuthAction(
      actionName: 'createAccountWithEmail',
      fallbackError: 'Could not create that account. Please try again.',
      timeoutError:
          'Account creation is taking too long. Check your connection and try again.',
      action: () => _authService.createAccountWithEmail(
        email: email.trim(),
        password: password,
        displayName: displayName?.trim().isEmpty == true
            ? null
            : displayName?.trim(),
      ),
    );
  }

  Future<void> signInAsGuest() {
    return _runAuthAction(
      actionName: 'signInAsGuest',
      fallbackError: 'Could not start a guest session.',
      timeoutError:
          'Guest sign-in is taking too long. Check your connection and try again.',
      action: _authService.signInAsGuest,
    );
  }

  Future<void> signOut() {
    return _runAuthAction(
      actionName: 'signOut',
      fallbackError: 'Could not sign out. Please try again.',
      timeoutError:
          'Sign out is taking too long. Restart the app if this keeps happening.',
      action: _authService.signOut,
    );
  }

  // ── Internals ─────────────────────────────────────────────────────────────────

  Future<void> _runAuthAction({
    required String actionName,
    required String fallbackError,
    required String timeoutError,
    required Future<void> Function() action,
  }) async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      await action().timeout(_authTimeout);
      _errorMessage = null;
    } on TimeoutException catch (e) {
      _errorMessage = timeoutError;
      debugPrint('$actionName timeout: $e');
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? e.code;
      debugPrint('$actionName FirebaseAuthException: ${e.code} ${e.message}');
    } catch (e, stackTrace) {
      _errorMessage = fallbackError;
      debugPrint('$actionName error: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  void _onUserChanged(User? user) {
    _user = user;

    if (user == null) {
      _status = AuthStatus.signedOut;
    } else if (user.isAnonymous) {
      _status = AuthStatus.guest;
    } else {
      _status = AuthStatus.signedIn;
    }

    // If Firebase emits an auth-state change while a button is still showing
    // a spinner, stop the spinner. This prevents the login screen from staying
    // dimmed after logout/login transitions.
    if (_isLoading) {
      _isLoading = false;
    }

    _safeNotifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value && value == false) {
      return;
    }

    _isLoading = value;

    if (value) {
      _errorMessage = null;
    }

    _safeNotifyListeners();
  }

  void _safeNotifyListeners() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _sub.cancel();
    super.dispose();
  }
}
