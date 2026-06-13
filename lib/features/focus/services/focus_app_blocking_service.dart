import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FocusBlockedApp {
  const FocusBlockedApp({
    required this.packageName,
    required this.label,
  });

  final String packageName;
  final String label;

  factory FocusBlockedApp.fromMap(Map<Object?, Object?> map) {
    return FocusBlockedApp(
      packageName: map['packageName']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
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

  Future<bool> startBlocking({
    required Iterable<String> packages,
    required DateTime endsAt,
  }) async {
    if (!isSupported) return false;
    try {
      return await _channel.invokeMethod<bool>('startBlocking', {
            'packages': packages.toSet().toList(growable: false),
            'endsAtMillis': endsAt.millisecondsSinceEpoch,
          }) ??
          false;
    } catch (error) {
      debugPrint('Starting focus app blocking failed: $error');
      return false;
    }
  }

  Future<void> stopBlocking() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>('stopBlocking');
    } catch (error) {
      debugPrint('Stopping focus app blocking failed: $error');
    }
  }
}
