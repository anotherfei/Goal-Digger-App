// ─────────────────────────────────────────────────────────────────────────────
// genkit_backend/lib/genkit_server.dart
//
// FIX (Security): The original _verifyFirebaseToken only decoded the JWT
//   payload without verifying the cryptographic signature — any forged token
//   with valid-looking claims would have been accepted.
//   Now uses the `jose` package against Firebase's JWKS endpoint so the RS256
//   signature is actually verified.
//
// FIX: Added `iss` (issuer) claim check, not just `aud` and `exp`.
//
// ENHANCE: JWKS key-store is cached in memory (refreshes after 1 hour) so we
//   don't fetch Google's public-key endpoint on every request.
//
// ENHANCE: Added streamingFlowHandler for SSE (text/event-stream) responses
//   so the UI can stream partial tokens for a live "typing" effect.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:convert';

import 'package:genkit/genkit.dart';
import 'package:http/http.dart' as http;
import 'package:jose/jose.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';

final _log = Logger('GenkitServer');

// ── JWKS cache ────────────────────────────────────────────────────────────────
// Firebase publishes its RS256 public keys at this JWKS endpoint.
// Keys rotate roughly every 6 hours; caching for 1 hour is safe.
const _jwksUrl =
    'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com';

JsonWebKeyStore? _cachedKeyStore;
DateTime _keyStoreExpiry = DateTime.fromMillisecondsSinceEpoch(0);

/// Fetches (or returns a cached) [JsonWebKeyStore] backed by Firebase's public keys.
Future<JsonWebKeyStore> _getKeyStore() async {
  if (_cachedKeyStore != null && DateTime.now().isBefore(_keyStoreExpiry)) {
    return _cachedKeyStore!;
  }

  final response = await http.get(Uri.parse(_jwksUrl));
  if (response.statusCode != 200) {
    throw Exception(
        'Failed to fetch Firebase JWKS (HTTP ${response.statusCode})');
  }

  final jwks = json.decode(response.body) as Map<String, dynamic>;
  _cachedKeyStore = JsonWebKeyStore()
    ..addKeySet(JsonWebKeySet.fromJson(jwks));
  // Cache-Control header usually says max-age; we conservatively use 1 hour.
  _keyStoreExpiry = DateTime.now().add(const Duration(hours: 1));
  _log.info('🔑  JWKS refreshed — next refresh after $_keyStoreExpiry');
  return _cachedKeyStore!;
}

// ─────────────────────────────────────────────────────────────────────────────

class GenkitServer {
  GenkitServer._();

  // ── Auth middleware ────────────────────────────────────────────────────────

  static Middleware authMiddleware(String? firebaseProjectId) {
    return (Handler inner) {
      return (Request request) async {
        // Health check is public (liveness probe from Cloud Run)
        if (request.url.path == 'health') return inner(request);

        final authHeader = request.headers['authorization'] ?? '';
        if (!authHeader.startsWith('Bearer ')) {
          _log.warning('❌  Missing or malformed Authorization header');
          return _unauthorised('Missing Bearer token');
        }

        final token = authHeader.substring(7);

        try {
          final uid =
              await _verifyFirebaseToken(token, firebaseProjectId);
          final updatedRequest = request.change(
            context: {...request.context, 'uid': uid},
          );
          return inner(updatedRequest);
        } catch (e) {
          _log.warning('❌  Token verification failed: $e');
          return _unauthorised('Invalid or expired token');
        }
      };
    };
  }

  // ── Standard (non-streaming) flow handler ─────────────────────────────────

  static Handler flowHandler(Genkit ai, GenkitFlow flow) {
    return (Request request) async {
      try {
        final bodyStr = await request.readAsString();
        final body    = json.decode(bodyStr) as Map<String, dynamic>;
        final input   = body['data'] as Map<String, dynamic>? ?? {};

        _log.info('▶️   Running flow: ${flow.name}');
        final result = await ai.runFlow(flow, input);

        return Response.ok(
          json.encode({'result': result}),
          headers: {'Content-Type': 'application/json'},
        );
      } on FormatException catch (e) {
        _log.warning('💬  Bad request body for ${flow.name}: $e');
        return Response(
          400,
          body: json.encode({'error': 'Invalid JSON: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e, st) {
        _log.severe('💥  Flow error in ${flow.name}: $e', e, st);
        return Response.internalServerError(
          body: json.encode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    };
  }

  // ── Streaming flow handler (SSE) ─────────────────────────────────────────
  //
  // ENHANCE: Clients can hit /flow/<name>/stream and receive Server-Sent
  // Events so the UI can display partial tokens as they arrive.
  // Each event has the form:  data: {"chunk": "..."}\n\n
  // The final event is:       data: [DONE]\n\n

  static Handler streamingFlowHandler(Genkit ai, GenkitFlow flow) {
    return (Request request) async {
      try {
        final bodyStr = await request.readAsString();
        final body    = json.decode(bodyStr) as Map<String, dynamic>;
        final input   = body['data'] as Map<String, dynamic>? ?? {};

        _log.info('🌊  Streaming flow: ${flow.name}');

        final controller = StreamController<List<int>>();

        // Run flow in background and emit SSE events
        () async {
          try {
            await for (final chunk in ai.streamFlow(flow, input)) {
              final event =
                  'data: ${json.encode({'chunk': chunk})}\n\n';
              controller.add(utf8.encode(event));
            }
            controller.add(utf8.encode('data: [DONE]\n\n'));
          } catch (e) {
            final errEvent =
                'data: ${json.encode({'error': e.toString()})}\n\n';
            controller.add(utf8.encode(errEvent));
          } finally {
            await controller.close();
          }
        }();

        return Response.ok(
          controller.stream,
          headers: {
            'Content-Type': 'text/event-stream',
            'Cache-Control': 'no-cache',
            'X-Accel-Buffering': 'no', // disable Nginx buffering
          },
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    };
  }

  // ── Health check ────────────────────────────────────────────────────────────

  static Response healthHandler(Request _) => Response.ok(
        json.encode({
          'status': 'ok',
          'service': 'goal-digger-genkit',
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static Response _unauthorised(String message) => Response(
        401,
        body: json.encode({'error': message}),
        headers: {'Content-Type': 'application/json'},
      );

  // ── JWT verification ────────────────────────────────────────────────────────
  //
  // FIX: Previously only decoded the payload without verifying the RS256
  //      signature, which meant any tampered token would be accepted.
  //
  // Now:
  //   1. Fetches Firebase's JWKS endpoint (cached for 1 hour).
  //   2. Verifies the RS256 signature using the `jose` package.
  //   3. Checks `exp`, `aud`, and `iss` claims.

  static Future<String> _verifyFirebaseToken(
      String token, String? projectId) async {
    final keyStore = await _getKeyStore();

    // Parse and verify signature
    final jws = JsonWebSignature.fromCompactSerialization(token);
    final verified = await jws.verify(keyStore);
    if (!verified) throw Exception('Token signature verification failed');

    // Decode payload (safe to use after signature check)
    final payload =
        jws.unverifiedPayload.jsonContent as Map<String, dynamic>;

    final sub = payload['sub'] as String?;
    final aud = payload['aud'] as String?;
    final iss = payload['iss'] as String?;
    final exp = payload['exp'] as int?;
    final iat = payload['iat'] as int?;

    if (sub == null || sub.isEmpty) throw Exception('Missing sub claim');

    // Expiry
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (exp != null && nowSec > exp) throw Exception('Token expired');
    // Issued-at should not be in the future (allow 60-second clock skew)
    if (iat != null && iat > nowSec + 60) {
      throw Exception('Token issued in the future');
    }

    // Audience + issuer (only validated when project ID is configured)
    if (projectId != null && projectId.isNotEmpty) {
      if (aud != projectId) {
        throw Exception('Token audience "$aud" ≠ project "$projectId"');
      }
      final expectedIss = 'https://securetoken.google.com/$projectId';
      if (iss != expectedIss) {
        throw Exception('Token issuer "$iss" ≠ expected "$expectedIss"');
      }
    }

    return sub;
  }
}
