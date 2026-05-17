/// gemma_service.dart
/// -------------------
/// Low-level client for Google Cloud Vertex AI – Gemma 4 model.
///
/// Gemma 4 is served via the Vertex AI "generateContent" endpoint.
/// Model ID: gemma-4-12b-it  (or gemma-4-27b-it for the larger variant)
///
/// Authentication is handled by the google_auth_library package using
/// a service-account JSON stored in assets (see docs/SETUP.md).
/// In production use Workload Identity or Firebase App Check instead.
///
/// Folder: lib/services/ai/

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

import 'ai_models.dart';

class GemmaService {
  GemmaService({
    required this.projectId,
    required this.location,
    this.modelId = 'gemma-4-27b-it', // change to gemma-4-12b-it for faster/cheaper
    this.defaultMaxTokens = 1024,
    this.defaultTemperature = 0.7,
  });

  final String projectId;
  final String location;
  final String modelId;
  final int defaultMaxTokens;
  final double defaultTemperature;

  /// Scopes required for Vertex AI.
  static const _scopes = ['https://www.googleapis.com/auth/cloud-platform'];

  http.Client? _client;

  // ── Initialization ────────────────────────────────────────────────────────

  /// Call once before using [generate] or [generateStream].
  /// Loads the service-account JSON from assets/service_account.json.
  Future<void> init() async {
    final jsonStr =
        await rootBundle.loadString('assets/service_account.json');
    final credentials = ServiceAccountCredentials.fromJson(jsonStr);
    _client = await clientViaServiceAccount(credentials, _scopes);
  }

  void dispose() {
    _client?.close();
    _client = null;
  }

  // ── Core endpoint ─────────────────────────────────────────────────────────

  String get _endpointUrl =>
      'https://$location-aiplatform.googleapis.com/v1/'
      'projects/$projectId/locations/$location/'
      'publishers/google/models/$modelId:generateContent';

  String get _streamEndpointUrl =>
      'https://$location-aiplatform.googleapis.com/v1/'
      'projects/$projectId/locations/$location/'
      'publishers/google/models/$modelId:streamGenerateContent?alt=sse';

  // ── Public API ────────────────────────────────────────────────────────────

  /// Single-turn generation. Returns the full response text.
  Future<GemmaResponse> generate(GemmaRequest request) async {
    _assertInitialized();

    final body = _buildRequestBody(request);
    final response = await _client!.post(
      Uri.parse(_endpointUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw GemmaException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return GemmaResponse.fromVertexJson(json);
  }

  /// Server-sent events stream for token-by-token output.
  Stream<String> generateStream(GemmaRequest request) async* {
    _assertInitialized();

    final body = _buildRequestBody(request);
    final httpRequest = http.Request(
      'POST',
      Uri.parse(_streamEndpointUrl),
    )
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode(body);

    final streamedResponse = await _client!.send(httpRequest);
    if (streamedResponse.statusCode != 200) {
      final body = await streamedResponse.stream.bytesToString();
      throw GemmaException(
        statusCode: streamedResponse.statusCode,
        message: body,
      );
    }

    await for (final line in streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (line.startsWith('data: ')) {
        final data = line.substring(6).trim();
        if (data == '[DONE]') break;
        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final token = _extractTokenFromJson(json);
          if (token != null && token.isNotEmpty) yield token;
        } catch (_) {
          // Skip malformed SSE lines.
        }
      }
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Map<String, dynamic> _buildRequestBody(GemmaRequest request) {
    return {
      'contents': [
        if (request.systemInstruction != null)
          {
            'role': 'user',
            'parts': [
              {'text': '<system>\n${request.systemInstruction}\n</system>'},
            ],
          },
        ...request.messages.map((m) => {
              'role': m.role == GemmaRole.user ? 'user' : 'model',
              'parts': [
                {'text': m.content},
              ],
            }),
      ],
      'generationConfig': {
        'maxOutputTokens': request.maxTokens ?? defaultMaxTokens,
        'temperature': request.temperature ?? defaultTemperature,
        'topP': 0.95,
        'topK': 40,
      },
      if (request.safetySettings != null)
        'safetySettings': request.safetySettings,
    };
  }

  String? _extractTokenFromJson(Map<String, dynamic> json) {
    try {
      final candidates =
          (json['candidates'] as List?)?.cast<Map<String, dynamic>>();
      if (candidates == null || candidates.isEmpty) return null;
      final parts =
          (candidates.first['content']?['parts'] as List?)?.cast<Map>();
      if (parts == null || parts.isEmpty) return null;
      return parts.first['text'] as String?;
    } catch (_) {
      return null;
    }
  }

  void _assertInitialized() {
    if (_client == null) {
      throw StateError(
        'GemmaService not initialized. Call await gemmaService.init() first.',
      );
    }
  }
}

/// Thrown when the Vertex AI endpoint returns a non-200 status.
class GemmaException implements Exception {
  const GemmaException({required this.statusCode, required this.message});

  final int statusCode;
  final String message;

  @override
  String toString() => 'GemmaException($statusCode): $message';
}
