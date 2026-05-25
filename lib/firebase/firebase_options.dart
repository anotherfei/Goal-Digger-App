// Deprecated compatibility shim.
// The real FlutterFire configuration lives at lib/firebase_options.dart.
// New code should import '../firebase_options.dart' and use
// DefaultFirebaseOptions.currentPlatform directly.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

import '../firebase_options.dart';

FirebaseOptions get currentPlatformFirebaseOptions =>
    DefaultFirebaseOptions.currentPlatform;
