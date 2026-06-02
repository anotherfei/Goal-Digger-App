// ─────────────────────────────────────────────────────────────────────────────
// lib/main.dart  (replaces the original)
//
// Drop-in replacement for the existing main.dart.
// Adds Firebase initialisation before runApp().
// All original app logic remains untouched in GoalDiggerApp / GoalDiggerRoot.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/google_calendar_service.dart';

import 'app/goal_digger_app.dart';
import 'firebase/auth/auth_service.dart';
import 'firebase/auth/auth_state.dart';
import 'firebase/firebase_initializer.dart';
import 'genkit/genkit_service.dart';
import 'features/notifications/services/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Firebase (core + App Check)
  await FirebaseInitializer.init();

  await PushNotificationService.instance.init();

  // Wire services
  final authService = AuthService();

  runApp(
    MultiProvider(
      providers: [
        // Auth state – drives sign-in UI and guards Firestore/Genkit access
        ChangeNotifierProvider<AuthState>(
          create: (_) => AuthState(authService),
        ),

        // Genkit AI service – available anywhere in the tree
        Provider<GenkitService>(
          create: (_) => GenkitService(authService: authService),
        ),

        // Google Calendar service – available anywhere in the tree
        Provider<GoogleCalendarService>(
          create: (_) => GoogleCalendarService(authService: authService),
        ),

        // AuthService itself (for lower-level token access)
        Provider<AuthService>.value(value: authService),
      ],
      child: const GoalDiggerApp(),
    ),
  );
}
