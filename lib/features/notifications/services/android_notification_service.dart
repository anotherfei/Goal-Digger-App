import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AndroidNotificationService {
  AndroidNotificationService({
    MethodChannel channel = const MethodChannel('goal_digger/notifications'),
  }) : _channel = channel;

  final MethodChannel _channel;

  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;
  bool get isSupported => _isAndroid;

  Future<bool> initialize() async {
    if (!_isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('initialize') ?? false;
    } catch (e) {
      debugPrint('Notification initialize failed: $e');
      return false;
    }
  }

  Future<bool> requestPermission() async {
    if (!_isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('requestPermission') ?? false;
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
      return false;
    }
  }

  Future<bool> areNotificationsEnabled() async {
    if (!_isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('areNotificationsEnabled') ??
          false;
    } catch (e) {
      debugPrint('Notification permission check failed: $e');
      return false;
    }
  }

  Future<void> openNotificationSettings() async {
    if (!_isAndroid) return;
    try {
      await _channel.invokeMethod<void>('openNotificationSettings');
    } catch (e) {
      debugPrint('Open notification settings failed: $e');
    }
  }

  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    required bool important,
    String payload = '',
  }) async {
    if (!_isAndroid) return;
    await _invokeNotificationMethod(
      'showNow',
      id: id,
      title: title,
      body: body,
      scheduledAt: DateTime.now(),
      important: important,
      payload: payload,
    );
  }

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required bool important,
    String payload = '',
  }) async {
    if (!_isAndroid) return;
    await _invokeNotificationMethod(
      'schedule',
      id: id,
      title: title,
      body: body,
      scheduledAt: scheduledAt,
      important: important,
      payload: payload,
    );
  }

  Future<void> cancel(int id) async {
    if (!_isAndroid) return;
    try {
      await _channel.invokeMethod<void>('cancel', {'id': id});
    } catch (e) {
      debugPrint('Notification cancel failed: $e');
    }
  }

  Future<void> cancelAll() async {
    if (!_isAndroid) return;
    try {
      await _channel.invokeMethod<void>('cancelAll');
    } catch (e) {
      debugPrint('Notification cancelAll failed: $e');
    }
  }

  Future<void> cancelScheduled() async {
    if (!_isAndroid) return;
    try {
      await _channel.invokeMethod<void>('cancelScheduled');
    } catch (e) {
      debugPrint('Notification cancelScheduled failed: $e');
    }
  }

  Future<void> _invokeNotificationMethod(
    String method, {
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required bool important,
    required String payload,
  }) async {
    try {
      await _channel.invokeMethod<void>(method, {
        'id': id,
        'title': title,
        'body': body,
        'scheduledAtMillis': scheduledAt.millisecondsSinceEpoch,
        'important': important,
        'payload': payload,
      });
    } catch (e) {
      debugPrint('Notification $method failed: $e');
    }
  }
}
