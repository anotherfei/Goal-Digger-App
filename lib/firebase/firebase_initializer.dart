// ─────────────────────────────────────────────────────────────────────────────
// lib/firebase/firebase_initializer.dart
//
// Single entry-point that initialises every Firebase service the app needs.
// Called once from main.dart before runApp().
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  static Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: currentPlatformFirebaseOptions,
      );

      debugPrint('✅ Firebase Core initialized');
    } on FirebaseException catch (e) {
      if (e.code == 'duplicate-app') {
        debugPrint(
          'ℹ️ Firebase already initialized',
        );
      } else {
        rethrow;
      }
    }

    if (!kReleaseMode) {
      String host;

      if (kIsWeb) {
        host = 'localhost';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        host = '10.0.2.2';
      } else {
        host = 'localhost';
      }

      FirebaseFirestore.instance.useFirestoreEmulator(
        host,
        8080,
      );

      FirebaseFunctions.instanceFor(
        region: 'us-central1',
      ).useFunctionsEmulator(
        host,
        5001,
      );

      try {
        await FirebaseAuth.instance.useAuthEmulator(
          host,
          9099,
        );
      } catch (_) {}

      await FirebaseFirestore.instance.enableNetwork();

      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );

      debugPrint(
        '🧪 Connected to Firebase emulators',
      );
    } else {
      await FirebaseAppCheck.instance.activate(
        androidProvider:
            AndroidProvider.playIntegrity,
        appleProvider:
            AppleProvider.deviceCheck,
        webProvider: ReCaptchaV3Provider(
          const String.fromEnvironment(
            'RECAPTCHA_SITE_KEY',
          ),
        ),
      );

      debugPrint(
        '✅ Firebase App Check activated',
      );
    }
  }
}