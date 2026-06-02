import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

class FirebaseInitializer {
  FirebaseInitializer._();

  static const bool _useEmulators =
      bool.fromEnvironment('USE_FIREBASE_EMULATORS');

  static const bool _forceAppCheckDebugProvider =
      bool.fromEnvironment('USE_FIREBASE_APP_CHECK_DEBUG_PROVIDER');

  static const int _authEmulatorPort = int.fromEnvironment(
    'FIREBASE_AUTH_EMULATOR_PORT',
    defaultValue: 9099,
  );

  static const int _firestoreEmulatorPort = int.fromEnvironment(
    'FIRESTORE_EMULATOR_PORT',
    defaultValue: 8080,
  );

  static const int _functionsEmulatorPort = int.fromEnvironment(
    'FIREBASE_FUNCTIONS_EMULATOR_PORT',
    defaultValue: 5001,
  );

  static Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase Core initialized');
    } on FirebaseException catch (e) {
      if (e.code == 'duplicate-app') {
        debugPrint('Firebase already initialized');
      } else {
        rethrow;
      }
    }

    if (_useEmulators) {
      await _connectToEmulators();
      return;
    }

    await _activateAppCheck();
    await _clearStaleTokenIfPresent();
  }

  static Future<void> _activateAppCheck() async {
    final useDebugProvider = !kReleaseMode || _forceAppCheckDebugProvider;

    const recaptchaSiteKey = String.fromEnvironment('RECAPTCHA_SITE_KEY');

    await FirebaseAppCheck.instance.activate(
      androidProvider: useDebugProvider
          ? AndroidProvider.debug
          : AndroidProvider.playIntegrity,
      appleProvider:
          useDebugProvider ? AppleProvider.debug : AppleProvider.deviceCheck,
      webProvider:
          recaptchaSiteKey.isEmpty ? null : ReCaptchaV3Provider(recaptchaSiteKey),
    );

    await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

    debugPrint(
      useDebugProvider
          ? 'Firebase App Check activated with DEBUG provider'
          : 'Firebase App Check activated with production provider',
    );
  }

  static Future<void> _clearStaleTokenIfPresent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await user.getIdToken(true);
    } catch (_) {
      await FirebaseAuth.instance.signOut();
      debugPrint('Stale auth token cleared — please sign in again.');
    }
  }

  static Future<void> _connectToEmulators() async {
    final host = kIsWeb
        ? 'localhost'
        : defaultTargetPlatform == TargetPlatform.android
            ? '10.0.2.2'
            : 'localhost';

    FirebaseFirestore.instance.useFirestoreEmulator(
      host,
      _firestoreEmulatorPort,
    );

    FirebaseFunctions.instanceFor(region: 'asia-east1')
        .useFunctionsEmulator(host, _functionsEmulatorPort);

    try {
      await FirebaseAuth.instance.useAuthEmulator(host, _authEmulatorPort);
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    await FirebaseFirestore.instance.enableNetwork();

    debugPrint(
      'Connected to Firebase emulators at $host '
      '(auth $_authEmulatorPort, firestore $_firestoreEmulatorPort, '
      'functions $_functionsEmulatorPort)',
    );
  }
}