// ─────────────────────────────────────────────────────────────────────────────
// lib/firebase/firebase_initializer.dart
//
// Single entry-point that initialises every Firebase service the app needs.
// Uses the real FlutterFire-generated options in lib/firebase_options.dart.
//
// Local emulators are opt-in:
//   flutter run --dart-define=USE_FIREBASE_EMULATORS=true
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

class FirebaseInitializer {
  FirebaseInitializer._();

  static const bool _useEmulators =
      bool.fromEnvironment('USE_FIREBASE_EMULATORS');

  static Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase Core initialized');
    } on FirebaseException catch (e) {
      if (e.code == 'duplicate-app') {
        debugPrint('ℹ️ Firebase already initialized');
      } else {
        rethrow;
      }
    }

    if (_useEmulators) {
      await _connectToEmulators();
      return;
    }

    // Validate any cached credential against production Firebase.
    // An emulator-issued token stored from a previous dev session will be
    // rejected, causing INVALID_REFRESH_TOKEN floods. Clearing it here lets
    // the user sign in cleanly on the next screen.
    await _clearStaleTokenIfPresent();
    await _activateAppCheckWhenConfigured();
  }

  static Future<void> _clearStaleTokenIfPresent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await user.getIdToken(true);
    } catch (_) {
      await FirebaseAuth.instance.signOut();
      debugPrint('⚠️ Stale auth token cleared — please sign in again.');
    }
  }

  static Future<void> _connectToEmulators() async {
    final host = kIsWeb
        ? 'localhost'
        : defaultTargetPlatform == TargetPlatform.android
            ? '10.0.2.2'
            : 'localhost';

    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseFunctions.instanceFor(region: 'asia-east1')
        .useFunctionsEmulator(host, 5001);

    try {
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      // Clear any cached production token — the emulator won't recognise it.
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // Firebase Auth emulator can only be attached once per process.
    }

    await FirebaseFirestore.instance.enableNetwork();

    if (!kIsWeb) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    }

    debugPrint('🧪 Connected to Firebase emulators at $host');
  }

  static Future<void> _activateAppCheckWhenConfigured() async {
    // Do not force App Check during normal debug runs. This keeps Firebase Auth,
    // Firestore, and Functions usable for classroom demos without emulator setup.
    if (!kReleaseMode) return;

    const recaptchaSiteKey = String.fromEnvironment('RECAPTCHA_SITE_KEY');

    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.deviceCheck,
      webProvider: recaptchaSiteKey.isEmpty
          ? null
          : ReCaptchaV3Provider(recaptchaSiteKey),
    );

    debugPrint('✅ Firebase App Check activated');
  }
}
