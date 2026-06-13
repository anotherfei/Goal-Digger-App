import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FocusBlockedApp {
  const FocusBlockedApp({
    required this.packageName,
    required this.label,
    this.iconBytes,
  });

  final String packageName;
  final String label;
  final Uint8List? iconBytes;

  factory FocusBlockedApp.fromMap(Map<Object?, Object?> map) {
    final icon = map['icon'];
    return FocusBlockedApp(
      packageName: map['packageName']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
      iconBytes: icon is Uint8List ? icon : null,
    );
  }
}

class FocusSessionStartResult {
  const FocusSessionStartResult({
    required this.started,
    required this.accessibilityRequired,
    required this.notificationShown,
  });

  final bool started;
  final bool accessibilityRequired;
  final bool notificationShown;

  factory FocusSessionStartResult.fromMap(Map<Object?, Object?> map) {
    return FocusSessionStartResult(
      started: map['started'] == true,
      accessibilityRequired: map['accessibilityRequired'] == true,
      notificationShown: map['notificationShown'] == true,
    );
  }
}

class FocusAppBlockingService {
  FocusAppBlockingService({
    MethodChannel channel =
        const MethodChannel('goal_digger/focus_blocking'),
  }) : _channel = channel;

  final MethodChannel _channel;

  bool get isSupported => defaultTargetPlatform == TargetPlatform.android;

  Future<bool> isAccessibilityServiceEnabled() async {
    if (!isSupported) return false;
    try {
      return await _channel.invokeMethod<bool>(
            'isAccessibilityServiceEnabled',
          ) ??
          false;
    } catch (error) {
      debugPrint('Focus blocker permission check failed: $error');
      return false;
    }
  }

  Future<void> openAccessibilitySettings() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>('openAccessibilitySettings');
    } catch (error) {
      debugPrint('Opening accessibility settings failed: $error');
    }
  }

  Future<List<FocusBlockedApp>> getLaunchableApps() async {
    if (!isSupported) return const [];
    try {
      final result =
          await _channel.invokeMethod<List<Object?>>('getLaunchableApps');
      return result
              ?.whereType<Map<Object?, Object?>>()
              .map(FocusBlockedApp.fromMap)
              .where(
                (app) =>
                    app.packageName.isNotEmpty && app.label.trim().isNotEmpty,
              )
              .toList(growable: false) ??
          const [];
    } catch (error) {
      debugPrint('Loading apps for focus blocking failed: $error');
      return const [];
    }
  }

  Future<FocusSessionStartResult> startFocusSession({
    required Iterable<String> packages,
    required DateTime endsAt,
    required String title,
  }) async {
    if (!isSupported) {
      return const FocusSessionStartResult(
        started: false,
        accessibilityRequired: false,
        notificationShown: false,
      );
    }
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'startFocusSession',
        {
          'packages': packages.toSet().toList(growable: false),
          'endsAtMillis': endsAt.millisecondsSinceEpoch,
          'title': title,
        },
      );
      return result == null
          ? const FocusSessionStartResult(
              started: false,
              accessibilityRequired: false,
              notificationShown: false,
            )
          : FocusSessionStartResult.fromMap(result);
    } catch (error) {
      debugPrint('Starting native focus session failed: $error');
      return const FocusSessionStartResult(
        started: false,
        accessibilityRequired: false,
        notificationShown: false,
      );
    }
  }

  Future<void> stopFocusSession() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>('stopFocusSession');
    } catch (error) {
      debugPrint('Stopping native focus session failed: $error');
    }
  }
}
