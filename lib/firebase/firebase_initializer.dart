// ─────────────────────────────────────────────────────────────────────────────
// lib/firebase/firebase_initializer.dart
//
// Single entry-point that initialises every Firebase service the app needs.
// Called once from main.dart before runApp().
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

/// Initialises Firebase Core, then activates App Check.
///
/// Call this in `main()` before `runApp()`:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await FirebaseInitializer.init();
///   runApp(const GoalDiggerApp());
/// }
/// ```
class FirebaseInitializer {
  FirebaseInitializer._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    // 1. Core
    await Firebase.initializeApp(
      options: currentPlatformFirebaseOptions,
    );

    // 2. App Check – protects your backend from abuse
    await FirebaseAppCheck.instance.activate(
      // Use debug provider only in debug builds; swap for reCAPTCHA / Play
      // Integrity / DeviceCheck in production.
      androidProvider: kDebugMode
          ? AndroidProvider.debug
          : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode
          ? AppleProvider.debug
          : AppleProvider.deviceCheck,
      webProvider: ReCaptchaV3Provider('YOUR_RECAPTCHA_SITE_KEY'),
    );

    _initialized = true;
    debugPrint('✅ Firebase initialised successfully');
  }
}
