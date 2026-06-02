import 'dart:convert';

import 'package:http/http.dart' as http;

import '../firebase/auth/auth_service.dart';
import '../models/models.dart';

class GoogleCalendarSyncResult {
  const GoogleCalendarSyncResult({
    required this.created,
    required this.skipped,
    required this.failed,
    required this.errors,
  });

  final int created;
  final int skipped;
  final int failed;
  final List<String> errors;
}

class GoogleCalendarService {
  GoogleCalendarService({required AuthService authService})
      : _authService = authService;

  final AuthService _authService;

  Future<String> createTaskEvent(MicroTask task, GoalProject goal) async {
    final headers = await _authService.getGoogleCalendarAuthHeaders();

    final existingId = await _findExistingTaskEventId(headers, task);
    if (existingId != null) {
      return existingId;
    }

    return _insertTaskEvent(headers, task, goal);
  }

  Future<GoogleCalendarSyncResult> syncAllTaskEvents(
    List<MicroTask> tasks,
    GoalProject Function(MicroTask task) goalForTask,
  ) async {
    final headers = await _authService.getGoogleCalendarAuthHeaders();

    var created = 0;
    var skipped = 0;
    var failed = 0;
    final errors = <String>[];

    for (final task in tasks) {
      try {
        final existingId = await _findExistingTaskEventId(headers, task);

        if (existingId != null) {
          skipped++;
          continue;
        }

        await _insertTaskEvent(headers, task, goalForTask(task));
        created++;
      } catch (e) {
        failed++;
        errors.add('${task.title}: $e');
      }
    }

    return GoogleCalendarSyncResult(
      created: created,
      skipped: skipped,
      failed: failed,
      errors: errors,
    );
  }

  Future<String?> _findExistingTaskEventId(
    Map<String, String> headers,
    MicroTask task,
  ) async {
    final taskId = task.id.toString();

    final uri = Uri.https(
      'www.googleapis.com',
      '/calendar/v3/calendars/primary/events',
      {
        'privateExtendedProperty': 'taskId=$taskId',
        'maxResults': '10',
        'showDeleted': 'false',
      },
    );

    final response = await http.get(uri, headers: headers);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to check existing event: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];

    if (items.isEmpty) {
      return null;
    }

    final first = items.first as Map<String, dynamic>;
    return first['id'] as String?;
  }

  Future<String> _insertTaskEvent(
    Map<String, String> headers,
    MicroTask task,
    GoalProject goal,
  ) async {
    final start = task.scheduledDate;
    final duration = task.durationMinutes <= 0 ? 30 : task.durationMinutes;
    final end = start.add(Duration(minutes: duration));

    final response = await http.post(
      Uri.parse(
        'https://www.googleapis.com/calendar/v3/calendars/primary/events',
      ),
      headers: {
        ...headers,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'summary': task.title,
        'description': 'Goal Digger goal: ${goal.title}',
        'start': {
          'dateTime': start.toIso8601String(),
          'timeZone': 'Asia/Taipei',
        },
        'end': {
          'dateTime': end.toIso8601String(),
          'timeZone': 'Asia/Taipei',
        },
        'extendedProperties': {
          'private': {
            'source': 'goal_digger',
            'goalId': goal.id.toString(),
            'taskId': task.id.toString(),
          },
        },
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Google Calendar sync failed: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['id'] as String;
  }
}