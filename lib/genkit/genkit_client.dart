// lib/genkit/genkit_client.dart
//
// Wraps Firebase Cloud Functions callable + streaming calls.
//
// For callable functions (goalCoach, taskGenerator, moodAdvisor, focusInsight):
//   Uses the `cloud_functions` Flutter package, which automatically:
//     • Attaches the signed-in user's Firebase ID token
//     • Refreshes expired tokens
//     • Retries on network errors
//     • Throws typed FirebaseFunctionsException on errors
//   No manual HTTP, no manual auth headers, no JWT handling.
//
// For streaming (goalCoachStream):
//   Uses plain HTTP with a manually attached token since Firebase callable
//   functions do not support SSE streaming responses.

import 'dart:async';
import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'genkit_config.dart';
import 'models/ai_models.dart';

class GenkitClient {
  GenkitClient({
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
    http.Client? httpClient,
  })  : _functions = functions ??
            FirebaseFunctions.instanceFor(region: GenkitConfig.region),
        _auth = auth ?? FirebaseAuth.instance,
        _http = httpClient ?? http.Client();

  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;
  final http.Client _http;

  // ── Callable flow ─────────────────────────────────────────────────────────
  //
  // Calls a Firebase Cloud Function (onCall) and returns a FlowResponse.
  // The cloud_functions package handles auth token + retries automatically.

  Future<FlowResponse> callFlow(
    String functionName,
    Map<String, dynamic> payload,
  ) async {
    try {
      final callable = _functions.httpsCallable(
        functionName,
        options: HttpsCallableOptions(timeout: GenkitConfig.callTimeout),
      );

      debugPrint('▶️  Calling function: $functionName');
      final result = await callable.call<Map<Object?, Object?>>(payload);

      // Callable functions return data directly (no { result: ... } wrapper)
      final data = _deepCast(result.data);
      return FlowResponse(result: data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('❌  Function $functionName error [${e.code}]: ${e.message}');
      return FlowResponse(
        result: null,
        error: '${e.code}: ${e.message}',
      );
    } catch (e) {
      debugPrint('❌  Unexpected error calling $functionName: $e');
      return FlowResponse(result: null, error: e.toString());
    }
  }

  // ── Streaming (SSE) ───────────────────────────────────────────────────────
  //
  // Calls the goalCoachStream onRequest function with SSE.
  // Manually attaches the Firebase ID token because onCall doesn't
  // support streaming responses.

  Stream<String> streamFlow(
    String functionName,
    Map<String, dynamic> payload,
  ) async* {
    // Build the Cloud Functions URL manually for the onRequest endpoint.
    // Format: https://<region>-<projectId>.cloudfunctions.net/<functionName>
    final projectId = await _getProjectId();
    final url = Uri.parse(
      'https://${GenkitConfig.region}-$projectId.cloudfunctions.net/$functionName',
    );

    final token = await _auth.currentUser?.getIdToken();
    if (token == null) {
      throw GenkitStreamException('User is not signed in');
    }

    final request = http.Request('POST', url)
      ..headers['Content-Type']  = 'application/json'
      ..headers['Accept']        = 'text/event-stream'
      ..headers['Cache-Control'] = 'no-cache'
      ..headers['Authorization'] = 'Bearer $token'
      ..body = jsonEncode(payload);

    final streamed = await _http
        .send(request)
        .timeout(GenkitConfig.streamTimeout);

    if (streamed.statusCode == 401) {
      throw GenkitStreamException('Unauthorised — please sign in again');
    }
    if (streamed.statusCode != 200) {
      throw GenkitStreamException(
          'Stream request failed (HTTP ${streamed.statusCode})');
    }

    // Buffer partial SSE lines across TCP chunks
    final buf = StringBuffer();

    await for (final chunk in streamed.stream.transform(utf8.decoder)) {
      buf.write(chunk);
      final text  = buf.toString();
      final lines = text.split('\n');

      // Keep the last (possibly incomplete) line in the buffer
      buf
        ..clear()
        ..write(lines.last);

      for (final line in lines.sublist(0, lines.length - 1)) {
        if (!line.startsWith('data: ')) continue;
        final raw = line.substring(6).trim();
        if (raw.isEmpty || raw == '[DONE]') continue;

        try {
          final parsed = jsonDecode(raw) as Map<String, dynamic>;
          if (parsed.containsKey('error')) {
            throw GenkitStreamException(
                parsed['error']?.toString() ?? 'Unknown stream error');
          }
          final token = parsed['chunk'] as String? ?? '';
          if (token.isNotEmpty) yield token;
        } catch (e) {
          if (e is GenkitStreamException) rethrow;
        }
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  // Firebase callable returns Map<Object?, Object?> — recursively cast to
  // Map<String, dynamic> so FlowResponse.fromJson works correctly.
  Map<String, dynamic> _deepCast(Object? raw) {
    if (raw is Map) {
      return raw.map((k, v) {
        if (v is Map) return MapEntry(k.toString(), _deepCast(v));
        if (v is List) return MapEntry(k.toString(), _castList(v));
        return MapEntry(k.toString(), v);
      });
    }
    return {};
  }

  List<dynamic> _castList(List<dynamic> list) => list.map((item) {
        if (item is Map) return _deepCast(item);
        if (item is List) return _castList(item);
        return item;
      }).toList();

  // Cache project ID so we don't fetch it on every streaming call.
  String? _cachedProjectId;
  Future<String> _getProjectId() async {
    if (_cachedProjectId != null) return _cachedProjectId!;
    // The project ID is embedded in the current user's token or can be read
    // from the Firebase app options.
    final app = _auth.app;
    _cachedProjectId = app.options.projectId;
    return _cachedProjectId!;
  }
}

/// Thrown when the SSE stream endpoint returns an error event or bad status.
class GenkitStreamException implements Exception {
  const GenkitStreamException(this.message);
  final String message;
  @override
  String toString() => 'GenkitStreamException: $message';
}
