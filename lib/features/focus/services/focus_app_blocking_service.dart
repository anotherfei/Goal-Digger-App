import 'package:flutter/services.dart';

import '../models/focus_session_config.dart';

class FocusAppBlockingResult {
  const FocusAppBlockingResult({
    required this.nativeBlockingEnabled,
    required this.message,
  });

  final bool nativeBlockingEnabled;
  final String message;
}

abstract class FocusAppBlockingService {
  Future<FocusAppBlockingResult> start(FocusSessionConfig config);

  Future<void> stop(FocusSessionConfig? config);
}

class PlatformFocusAppBlockingService implements FocusAppBlockingService {
  const PlatformFocusAppBlockingService();

  static const MethodChannel _channel =
      MethodChannel('goal_digger/focus_app_block');

  @override
  Future<FocusAppBlockingResult> start(FocusSessionConfig config) async {
    if (!config.appPolicy.hasSelectedApps) {
      return const FocusAppBlockingResult(
        nativeBlockingEnabled: false,
        message: 'No app blocking list was selected.',
      );
    }

    try {
      final response = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'startBlocking',
        config.toJson(),
      );
      final data = Map<String, dynamic>.from(response ?? {});
      return FocusAppBlockingResult(
        nativeBlockingEnabled: data['nativeBlockingEnabled'] == true,
        message: data['message']?.toString() ?? 'App Block started.',
      );
    } on MissingPluginException {
      return const FocusAppBlockingResult(
        nativeBlockingEnabled: false,
        message: 'App Block is available on Android with system permission.',
      );
    } on PlatformException catch (e) {
      return FocusAppBlockingResult(
        nativeBlockingEnabled: false,
        message: e.message ?? 'App Block could not start.',
      );
    }
  }

  @override
  Future<void> stop(FocusSessionConfig? config) async {
    try {
      await _channel.invokeMethod<void>('stopBlocking', {
        'sessionId': config?.id,
      });
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }
}
