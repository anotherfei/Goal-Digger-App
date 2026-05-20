// ─────────────────────────────────────────────────────────────────────────────
// genkit_backend/lib/main.dart
//
// Goal Digger – Genkit Dart backend entry point.
//
// FIX: main.dart previously imported focus_insight_flow.dart and
//      mood_advisor_flow.dart as separate files, but those functions were
//      defined inside task_generator_flow.dart — causing compile errors.
//      All four flows now have their own file.
//
// ENHANCE: Added structured startup error reporting and a SIGTERM handler
//          for graceful Cloud Run shutdown.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

// FIX: Each flow is now in its own file (previously mood/focus were missing)
import 'flows/focus_insight_flow.dart';
import 'flows/goal_coach_flow.dart';
import 'flows/mood_advisor_flow.dart';
import 'flows/task_generator_flow.dart';
import 'genkit_server.dart';

void main() async {
  // ── 1. Logging ────────────────────────────────────────────────────────────
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('[${record.level.name}] ${record.loggerName}: ${record.message}');
  });

  final log = Logger('main');

  // ── 2. Environment ────────────────────────────────────────────────────────
  final env = DotEnv(includePlatformEnvironment: true)..load();
  final apiKey        = env['GOOGLE_API_KEY'] ?? '';
  final firebaseProject = env['FIREBASE_PROJECT'];
  final port          = int.tryParse(env['PORT'] ?? '') ?? 3400;
  final isProduction  = _isProduction();

  if (apiKey.isEmpty) {
    log.severe('❌  GOOGLE_API_KEY is not set — AI calls will fail immediately.');
    if (isProduction) exit(1); // Hard fail in prod; allow local dev to continue.
  }
  if (firebaseProject == null || firebaseProject.isEmpty) {
    log.warning('⚠️  FIREBASE_PROJECT is not set — token verification will skip audience check.');
  }

  // ── 3. Initialise Genkit ──────────────────────────────────────────────────
  final ai = Genkit(
    plugins: [
      googleGenAI(
        apiKey: apiKey,
        // Gemma 4 on Google AI Studio.  For Vertex AI change to:
        //   genkit_google_vertexai  +  model string 'google/gemma-4-27b-it'
        defaultModel: env['GEMMA4_MODEL_ID'] ?? 'gemma-4-it',
      ),
    ],
    logLevel: isProduction ? Level.WARNING : Level.INFO,
    enableDevUI: !isProduction,
  );

  // ── 4. Register flows ─────────────────────────────────────────────────────
  final goalCoachFlow     = registerGoalCoachFlow(ai);
  final taskGeneratorFlow = registerTaskGeneratorFlow(ai);
  final moodAdvisorFlow   = registerMoodAdvisorFlow(ai);
  final focusInsightFlow  = registerFocusInsightFlow(ai);

  final allFlows = [goalCoachFlow, taskGeneratorFlow, moodAdvisorFlow, focusInsightFlow];
  log.info('✅  Registered ${allFlows.length} Genkit flows: '
      '${allFlows.map((f) => f.name).join(', ')}');

  // ── 5. HTTP server ────────────────────────────────────────────────────────
  final router = Router()
    ..post('/flow/goalCoach',     GenkitServer.flowHandler(ai, goalCoachFlow))
    ..post('/flow/taskGenerator', GenkitServer.flowHandler(ai, taskGeneratorFlow))
    ..post('/flow/moodAdvisor',   GenkitServer.flowHandler(ai, moodAdvisorFlow))
    ..post('/flow/focusInsight',  GenkitServer.flowHandler(ai, focusInsightFlow))
    // ENHANCE: Streaming endpoints for live typing in the UI
    ..post('/flow/goalCoach/stream', GenkitServer.streamingFlowHandler(ai, goalCoachFlow))
    ..get('/health',              GenkitServer.healthHandler);

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addMiddleware(GenkitServer.authMiddleware(firebaseProject))
      .addHandler(router.call);

  final server = await shelf_io.serve(handler, '0.0.0.0', port);
  server.autoCompress = true;
  log.info('🚀  Goal Digger Genkit backend listening on port ${server.port}');
  if (!isProduction) {
    log.info('🛠   Genkit Dev UI: http://localhost:4000');
  }

  // ── 6. Graceful shutdown (Cloud Run sends SIGTERM before killing) ─────────
  ProcessSignal.sigterm.watch().listen((_) async {
    log.info('🛑  SIGTERM received — shutting down gracefully…');
    await server.close(force: false);
    exit(0);
  });
}

bool _isProduction() => Platform.environment['K_SERVICE'] != null;
