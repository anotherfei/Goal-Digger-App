// lib/genkit/genkit_client.dart
//
// Wraps Firebase Cloud Functions callable + streaming calls.
// Uses AuthService as the single auth dependency.

import 'dart:async';
import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../firebase/auth/auth_service.dart';
import 'genkit_config.dart';
import 'models/ai_models.dart';

class GenkitClient {
  GenkitClient({
    required AuthService authService,
    FirebaseFunctions? functions,
    http.Client? httpClient,
  })  : _authService = authService,
        _functions =
            functions ?? FirebaseFunctions.instanceFor(region: GenkitConfig.region),
        _http = httpClient ?? http.Client();

  final AuthService _authService;
  final FirebaseFunctions _functions;
  final http.Client _http;

  // ── Callable flow ─────────────────────────────────────────────────────────
  //
  // Calls a Firebase Cloud Function (onCall) and returns a FlowResponse.
  // cloud_functions automatically attaches the Firebase Auth token,
  // but we still check AuthService first so auth behavior is centralized.
  Future<FlowResponse> callFlow(
    String functionName,
    Map<String, dynamic> payload,
  ) async {
    try {
      if (_authService.currentUser == null) {
        return const FlowResponse(
          result: null,
          error: 'User is not signed in',
        );
      }

      // Ensures the current Firebase user has a usable token before calling.
      await _authService.getIdToken();

      final callable = _functions.httpsCallable(
        functionName,
        options: HttpsCallableOptions(timeout: GenkitConfig.callTimeout),
      );

      debugPrint('▶️ Calling function: $functionName');

      final result = await callable.call<Map<String, dynamic>>(payload);
      final data = _deepCast(result.data);

      return FlowResponse(result: data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('❌ Function $functionName error [${e.code}]: ${e.message}');
      return FlowResponse(
        result: null,
        error: '${e.code}: ${e.message}',
      );
    } catch (e) {
      debugPrint('❌ Unexpected error calling $functionName: $e');
      return FlowResponse(result: null, error: e.toString());
    }
  }

  // ── Streaming / SSE ───────────────────────────────────────────────────────
  //
  // Calls the goalCoachStream onRequest function with SSE.
  // Here we manually attach the token from AuthService.
  Stream<String> streamFlow(
    String functionName,
    Map<String, dynamic> payload,
  ) async* {
    final projectId = await _getProjectId();

    final url = Uri.parse(
      'https://${GenkitConfig.region}-$projectId.cloudfunctions.net/$functionName',
    );

    final token = await _authService.getIdToken();

    if (token == null) {
      throw const GenkitStreamException('User is not signed in');
    }

    final request = http.Request('POST', url)
      ..headers['Content-Type'] = 'application/json'
      ..headers['Accept'] = 'text/event-stream'
      ..headers['Cache-Control'] = 'no-cache'
      ..headers['Authorization'] = 'Bearer $token'
      ..body = jsonEncode(payload);

    final streamed = await _http.send(request).timeout(GenkitConfig.streamTimeout);

    if (streamed.statusCode == 401) {
      throw const GenkitStreamException('Unauthorised — please sign in again');
    }

    if (streamed.statusCode != 200) {
      throw GenkitStreamException(
        'Stream request failed (HTTP ${streamed.statusCode})',
      );
    }

    final buffer = StringBuffer();

    await for (final chunk in streamed.stream.transform(utf8.decoder)) {
      buffer.write(chunk);

      final text = buffer.toString();
      final lines = text.split('\n');

      buffer
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
              parsed['error']?.toString() ?? 'Unknown stream error',
            );
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

  Map<String, dynamic> _deepCast(Object? raw) {
    if (raw is Map) {
      return raw.map((key, value) {
        if (value is Map) {
          return MapEntry(key.toString(), _deepCast(value));
        }

        if (value is List) {
          return MapEntry(key.toString(), _castList(value));
        }

        return MapEntry(key.toString(), value);
      });
    }

    return <String, dynamic>{};
  }

  List<dynamic> _castList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map) return _deepCast(item);
      if (item is List) return _castList(item);
      return item;
    }).toList();
  }

  String? _cachedProjectId;

  Future<String> _getProjectId() async {
    if (_cachedProjectId != null) return _cachedProjectId!;

    _cachedProjectId = Firebase.app().options.projectId;
    return _cachedProjectId!;
  }
}

class GenkitStreamException implements Exception {
  const GenkitStreamException(this.message);

  final String message;

  @override
  String toString() => 'GenkitStreamException: $message';
}