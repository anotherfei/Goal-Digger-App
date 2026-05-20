// ─────────────────────────────────────────────────────────────────────────────
// lib/firebase/firebase_options.dart
//
// ⚠️  THIS FILE IS AUTO-GENERATED.
//     Run the following command to regenerate with your real Firebase project:
//
//       dart pub global activate flutterfire_cli
//       flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
//
//     The CLI will overwrite this file with your actual API keys and IDs.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Returns the [FirebaseOptions] for the current platform.
FirebaseOptions get currentPlatformFirebaseOptions {
  if (kIsWeb) return web;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return android;
    case TargetPlatform.iOS:
      return ios;
    case TargetPlatform.macOS:
      return macos;
    case TargetPlatform.windows:
      return windows;
    default:
      throw UnsupportedError(
        'Goal Digger: Firebase is not configured for '
        '${defaultTargetPlatform.name}. '
        'Run `flutterfire configure` to generate options.',
      );
  }
}

// ── Replace every placeholder below with your real values ───────────────────

const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY',
  appId: 'YOUR_WEB_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  measurementId: 'YOUR_MEASUREMENT_ID',
);

const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',
  appId: 'YOUR_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);

const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'YOUR_IOS_API_KEY',
  appId: 'YOUR_IOS_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  iosClientId: 'YOUR_IOS_CLIENT_ID',
  iosBundleId: 'com.yourcompany.goalDigger',
);

const FirebaseOptions macos = FirebaseOptions(
  apiKey: 'YOUR_MACOS_API_KEY',
  appId: 'YOUR_MACOS_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  iosClientId: 'YOUR_MACOS_CLIENT_ID',
  iosBundleId: 'com.yourcompany.goalDigger',
);

const FirebaseOptions windows = FirebaseOptions(
  apiKey: 'YOUR_WINDOWS_API_KEY',
  appId: 'YOUR_WINDOWS_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);
