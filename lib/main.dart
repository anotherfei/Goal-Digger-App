import 'package:flutter/material.dart';

import 'app/goal_digger_app.dart';
import 'services/firebase/firebase_config.dart';
import 'services/ai/gemma_service.dart';
import 'services/ai/goal_ai_assistant.dart';

// ── Global service singletons ─────────────────────────────────────────────────
late final GemmaService gemmaService;
late final GoalAiAssistant goalAI;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase (Firestore + Auth)
  await initFirebase();

  // 2. Gemma 4 via Vertex AI
  //    Replace 'YOUR_GCP_PROJECT_ID' and add assets/service_account.json.
  //    See docs/SETUP.md for full instructions.
  gemmaService = GemmaService(
    projectId: 'YOUR_GCP_PROJECT_ID',
    location: 'us-central1',
    modelId: 'gemma-4-27b-it',
  );
  await gemmaService.init();
  goalAI = GoalAiAssistant(gemmaService);

  runApp(const GoalDiggerApp());
}
