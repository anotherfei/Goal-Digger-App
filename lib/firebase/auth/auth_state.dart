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
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
