// ─────────────────────────────────────────────────────────────────────────────
// lib/genkit/genkit_client.dart
//
// FIX: Retry back-off was linear (500ms × attempt).  Changed to exponential
//      (500ms, 1000ms, 2000ms …) so the server isn't hammered on a slow day.
//
// FIX: A 401 response (expired Firebase ID token) now triggers one forced
//      token refresh and a single retry before giving up.  Previously a 401
//      was surfaced as an error with no automatic recovery.
//
// ENHANCE: `_safeBody` now surfaces the HTTP status in the error message so
//          callers can distinguish a 503 from a 400.
//
// ENHANCE: `callFlow` records how long each request took (debug builds only)
//          so performance regressions are visible in the Flutter console.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../firebase/auth/auth_service.dart';
import 'genkit_config.dart';
import 'models/ai_models.dart';

class GenkitClient {
  GenkitClient({
    required AuthService authService,
    http.Client? httpClient,
  })  : _auth = authService,
        _http = httpClient ?? http.Client();

  final AuthService _auth;
  final http.Client _http;

  // ── Core call ──────────────────────────────────────────────────────────────

  /// Calls a Genkit flow endpoint and returns the decoded [FlowResponse].
  ///
  /// [endpoint] must be one of the [GenkitConfig.flow*] constants.
  /// [payload]  is the flow's input data (will be wrapped in `{ data: ... }`).
  Future<FlowResponse> callFlow(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    final uri  = Uri.parse('${GenkitConfig.baseUrl}$endpoint');
    final body = json.encode(FlowRequest(data: payload).toJson());

    final sw = Stopwatch()..start();

    int attempt    = 0;
    bool didRefresh = false; // ensure we only force-refresh the token once
    http.Response? response;
    Object? lastError;

    while (attempt <= GenkitConfig.maxRetries) {
      attempt++;
      try {
        // FIX: force-refresh token if we previously got a 401
        final token = await _auth.getIdToken(forceRefresh: didRefresh);

        final headers = _buildHeaders(token);
        response = await _http
            .post(uri, headers: headers, body: body)
            .timeout(GenkitConfig.requestTimeout);

        // FIX: on 401 — refresh token and retry once
        if (response.statusCode == 401 && !didRefresh) {
          debugPrint('🔄  Genkit 401 — refreshing Firebase token and retrying…');
          didRefresh = true;
          response   = null; // force retry loop
          continue;
        }

        break; // any non-401 response ends the loop
      } catch (e) {
        lastError = e;
        debugPrint(
            '⚠️   Genkit attempt $attempt/${GenkitConfig.maxRetries + 1} failed: $e');
        if (attempt <= GenkitConfig.maxRetries) {
          // FIX: exponential back-off (500ms, 1s, 2s …) instead of linear
          final delay = Duration(
              milliseconds: (500 * math.pow(2, attempt - 1)).toInt());
          await Future<void>.delayed(delay);
        }
      }
    }

    debugPrint(
        '⏱   Genkit $endpoint took ${sw.elapsedMilliseconds}ms (attempt $attempt)');

    if (response == null) {
      return FlowResponse(
        result: null,
        error:
            'Network error after ${GenkitConfig.maxRetries + 1} attempts: $lastError',
      );
    }

    if (response.statusCode != 200) {
      debugPrint('❌  Genkit HTTP ${response.statusCode}: ${response.body}');
      return FlowResponse(
        result: null,
        // ENHANCE: include the HTTP status code in the error
        error: 'Server error ${response.statusCode}: ${_safeBody(response)}',
      );
    }

    try {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      return FlowResponse.fromJson(decoded);
    } catch (e) {
      return FlowResponse(result: null, error: 'Response parse error: $e');
    }
  }

  // ── Streaming call (SSE) ──────────────────────────────────────────────────

  /// Streams tokens from a Genkit streaming flow endpoint.
  /// Expects the server to respond with SSE (text/event-stream).
  /// Each emitted [String] is a partial token chunk.
  Stream<String> streamFlow(
    String endpoint,
    Map<String, dynamic> payload,
  ) async* {
    final uri   = Uri.parse('${GenkitConfig.baseUrl}$endpoint/stream');
    final token = await _auth.getIdToken();

    final request = http.Request('POST', uri)
      ..headers['Content-Type']  = 'application/json'
      ..headers['Accept']        = 'text/event-stream'
      ..headers['Cache-Control'] = 'no-cache';

    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (GenkitConfig.apiKey.isNotEmpty) {
      request.headers['X-Genkit-Api-Key'] = GenkitConfig.apiKey;
    }
    request.body = json.encode(FlowRequest(data: payload).toJson());

    try {
      final streamed = await _http.send(request);
      // Buffer partial SSE lines across chunks
      final buffer = StringBuffer();

      await for (final chunk in streamed.stream.transform(utf8.decoder)) {
        buffer.write(chunk);
        final text = buffer.toString();
        final lines = text.split('\n');

        // Keep the last (possibly incomplete) line in the buffer
        buffer
          ..clear()
          ..write(lines.last);

        for (final line in lines.sublist(0, lines.length - 1)) {
          if (line.startsWith('data: ')) {
            final raw = line.substring(6).trim();
            if (raw.isEmpty || raw == '[DONE]') continue;
            try {
              final parsed = json.decode(raw) as Map<String, dynamic>;
              if (parsed.containsKey('error')) {
                throw GenkitStreamException(
                    parsed['error']?.toString() ?? 'Unknown stream error');
              }
              final text = parsed['chunk'] as String? ?? '';
              if (text.isNotEmpty) yield text;
            } catch (e) {
              if (e is GenkitStreamException) rethrow;
              // Non-JSON SSE line — yield raw text as fallback
              if (raw.isNotEmpty) yield raw;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('❌  Genkit stream error: $e');
      rethrow;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Map<String, String> _buildHeaders(String? token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        if (GenkitConfig.apiKey.isNotEmpty)
          'X-Genkit-Api-Key': GenkitConfig.apiKey,
      };

  String _safeBody(http.Response r) {
    try {
      final decoded = json.decode(r.body) as Map<String, dynamic>;
      return decoded['error']?.toString() ?? r.body;
    } catch (_) {
      final truncated = r.body.length > 200
          ? '${r.body.substring(0, 200)}…'
          : r.body;
      return truncated;
    }
  }
}

/// Thrown when the streaming SSE response contains an error event.
class GenkitStreamException implements Exception {
  const GenkitStreamException(this.message);
  final String message;
  @override
  String toString() => 'GenkitStreamException: $message';
}
