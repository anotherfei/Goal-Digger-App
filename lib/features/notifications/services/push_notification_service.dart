import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'android_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AndroidNotificationService _androidNotifications =
      AndroidNotificationService();

  StreamSubscription<User?>? _authSub;
  StreamSubscription<String>? _tokenSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _androidNotifications.initialize();
    await _androidNotifications.requestPermission();

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await _saveCurrentToken();

    _authSub = _auth.authStateChanges().listen((user) {
      if (user != null) {
        unawaited(_saveCurrentToken());
      }
    });

    _tokenSub = _messaging.onTokenRefresh.listen((token) {
      unawaited(_saveToken(token));
    });

    _foregroundSub = FirebaseMessaging.onMessage.listen((message) {
      unawaited(_showForegroundNotification(message));
    });
  }

  Future<void> _saveCurrentToken() async {
    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) return;

    await _saveToken(token);
  }

  Future<void> _saveToken(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final tokenId = base64UrlEncode(utf8.encode(token)).replaceAll('=', '');

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('fcmTokens')
        .doc(tokenId)
        .set({
      'token': token,
      'platform': defaultTargetPlatform.name,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    if (message.data['type'] == 'reward') return;

    final title = message.notification?.title ?? message.data['title'];
    final body = message.notification?.body ?? message.data['body'];
    final important = message.data['important'] == 'true';

    if (title == null || body == null) return;

    await _androidNotifications.showNow(
      id: DateTime.now().millisecondsSinceEpoch.remainder(1000000000),
      title: title.toString(),
      body: body.toString(),
      important: important,
      payload: jsonEncode(message.data),
    );
  }

  Future<void> dispose() async {
    await _authSub?.cancel();
    await _tokenSub?.cancel();
    await _foregroundSub?.cancel();
  }
}
