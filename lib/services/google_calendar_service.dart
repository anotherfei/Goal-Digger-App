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

    final existingId = await _findExistingTaskEventId(headers, task, goal);
    if (existingId != null) {
      return existingId;
    }

    return _insertTaskEvent(headers, task, goal);
  }

  Future<int> deleteTaskEventsForGoal(GoalProject goal) async {
  final headers = await _authService.getGoogleCalendarAuthHeaders();
  final eventIds = <String>{};

  final goalEventIds = await _findEventIdsByPrivateProperty(
    headers,
    'goalId',
    goal.id.toString(),
  );

  eventIds.addAll(goalEventIds);

  for (final task in goal.tasks) {
    final taskEventIds = await _findEventIdsByPrivateProperty(
      headers,
      'taskId',
      task.id.toString(),
    );

    eventIds.addAll(taskEventIds);
  }

  var deleted = 0;

  for (final eventId in eventIds) {
    await _deleteEvent(headers, eventId);
    deleted++;
  }

  return deleted;
}

Future<List<String>> _findEventIdsByPrivateProperty(
  Map<String, String> headers,
  String key,
  String value,
) async {
  final ids = <String>[];
  String? pageToken;

  do {
    final query = {
      'privateExtendedProperty': '$key=$value',
      'maxResults': '250',
      'showDeleted': 'false',
      if (pageToken != null) 'pageToken': pageToken,
    };

    final uri = Uri.https(
      'www.googleapis.com',
      '/calendar/v3/calendars/primary/events',
      query,
    );

    final response = await http.get(uri, headers: headers);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to find Google Calendar events: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];

    for (final item in items) {
      final event = item as Map<String, dynamic>;
      final id = event['id']?.toString();

      if (id != null && id.isNotEmpty) {
        ids.add(id);
      }
    }

    pageToken = data['nextPageToken']?.toString();
  } while (pageToken != null && pageToken.isNotEmpty);

  return ids;
}

Future<void> _deleteEvent(
  Map<String, String> headers,
  String eventId,
) async {
  final response = await http.delete(
    Uri.parse(
      'https://www.googleapis.com/calendar/v3/calendars/primary/events/${Uri.encodeComponent(eventId)}',
    ),
    headers: headers,
  );

  if (response.statusCode == 404 || response.statusCode == 410) {
    return;
  }

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception('Failed to delete Google Calendar event: ${response.body}');
  }
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
        final goal = goalForTask(task);
        final existingId = await _findExistingTaskEventId(headers, task, goal);

        if (existingId != null) {
          skipped++;
          continue;
        }

        await _insertTaskEvent(headers, task, goal);
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

  String _taskSyncKey(MicroTask task, GoalProject goal) {
    return [
      'goal_digger',
      goal.id.toString(),
      task.id.toString(),
      task.title.trim(),
      task.scheduledDate.toUtc().toIso8601String(),
      task.durationMinutes.toString(),
    ].join('|');
  }

  Future<String?> _findExistingTaskEventId(
    Map<String, String> headers,
    MicroTask task,
    GoalProject goal,
  ) async {
    final taskId = task.id.toString();
    final syncKey = _taskSyncKey(task, goal);

    final uri = Uri.https(
      'www.googleapis.com',
      '/calendar/v3/calendars/primary/events',
      {
        'privateExtendedProperty': 'taskId=$taskId',
        'maxResults': '20',
        'showDeleted': 'false',
      },
    );

    final response = await http.get(uri, headers: headers);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to check existing event: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];

    for (final item in items) {
      final event = item as Map<String, dynamic>;

      final extendedProperties =
          event['extendedProperties'] as Map<String, dynamic>?;

      final privateProperties =
          extendedProperties?['private'] as Map<String, dynamic>?;

      final existingSyncKey = privateProperties?['syncKey']?.toString();

      if (existingSyncKey == syncKey) {
        return event['id'] as String?;
      }

      if (existingSyncKey == null && _legacyEventMatchesTask(event, task, goal)) {
        return event['id'] as String?;
      }
    }

    return null;
  }

  bool _legacyEventMatchesTask(
    Map<String, dynamic> event,
    MicroTask task,
    GoalProject goal,
  ) {
    final summary = event['summary']?.toString();
    if (summary != task.title) return false;

    final start = event['start'] as Map<String, dynamic>?;
    final startDateTime = start?['dateTime']?.toString();

    if (startDateTime == null) return false;

    final parsedStart = DateTime.tryParse(startDateTime);
    if (parsedStart == null) return false;

    return parsedStart.toUtc().toIso8601String() ==
        task.scheduledDate.toUtc().toIso8601String();
  }

  Future<String> _insertTaskEvent(
    Map<String, String> headers,
    MicroTask task,
    GoalProject goal,
  ) async {
    final start = task.scheduledDate;
    final duration = task.durationMinutes <= 0 ? 30 : task.durationMinutes;
    final end = start.add(Duration(minutes: duration));
    final syncKey = _taskSyncKey(task, goal);

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
            'syncKey': syncKey,
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