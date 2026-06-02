import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../features/notifications/models/notification_models.dart';
import '../firestore_paths.dart';
import '../firestore_service.dart';

class NotificationRepository {
  NotificationRepository({FirestoreService? service})
      : _svc = service ?? FirestoreService();

  final FirestoreService _svc;

  Stream<List<AppNotification>> watchNotifications(String uid) {
    return _svc
        .watchCol(
          FirestorePaths.notificationsCol(uid),
          queryBuilder: (col) => col.orderBy('createdAt', descending: true),
        )
        .map((snapshot) {
      final notifications = snapshot.docs
          .map(_notificationFromDoc)
          .whereType<AppNotification>()
          .toList();
      notifications.sort(_importantFirstSort);
      return notifications;
    });
  }

  Future<void> addNotification(
    String uid,
    AppNotification notification,
  ) async {
    await _svc.setDoc(
      FirestorePaths.notificationDoc(uid, notification.id),
      _notificationToMap(notification),
      merge: true,
    );
  }

  Future<void> markRead(
    String uid,
    String notificationId,
  ) async {
    await _svc.updateDoc(
      FirestorePaths.notificationDoc(uid, notificationId),
      {
        'readAt': FirestoreService.serverTimestamp,
        'updatedAt': FirestoreService.serverTimestamp,
      },
    );
  }

  Future<void> markAllRead(String uid) async {
    final snapshot = await _svc.colRef(FirestorePaths.notificationsCol(uid)).get();
    final unreadDocs = snapshot.docs.where((doc) {
      final data = doc.data();
      return data['readAt'] == null;
    }).toList();
    if (unreadDocs.isEmpty) return;

    final batch = _svc.batch;
    for (final doc in unreadDocs) {
      batch.update(doc.reference, {
        'readAt': FirestoreService.serverTimestamp,
        'updatedAt': FirestoreService.serverTimestamp,
      });
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String uid, String notificationId) async {
    await _svc.deleteDoc(FirestorePaths.notificationDoc(uid, notificationId));
  }

  Map<String, dynamic> _notificationToMap(AppNotification notification) {
    return {
      'id': notification.id,
      'title': notification.title,
      'body': notification.body,
      'type': notification.type.name,
      'delivery': notification.delivery.name,
      'createdAt': Timestamp.fromDate(notification.createdAt),
      'readAt': notification.readAt == null
          ? null
          : Timestamp.fromDate(notification.readAt!),
      'important': notification.important,
      'sourceId': notification.sourceId,
      'payload': notification.payload,
      'updatedAt': FirestoreService.serverTimestamp,
    };
  }

  AppNotification? _notificationFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    try {
      final data = doc.data()!;
      return AppNotification(
        id: data['id'] as String? ?? doc.id,
        title: data['title'] as String? ?? 'Notification',
        body: data['body'] as String? ?? '',
        type: _enumByName(
          AppNotificationType.values,
          data['type'] as String?,
          AppNotificationType.important,
        ),
        delivery: _enumByName(
          NotificationDelivery.values,
          data['delivery'] as String?,
          NotificationDelivery.inApp,
        ),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
            DateTime.fromMillisecondsSinceEpoch(0),
        readAt: (data['readAt'] as Timestamp?)?.toDate(),
        important: data['important'] as bool? ?? false,
        sourceId: data['sourceId'] as String?,
        payload: (data['payload'] as Map<String, dynamic>?) == null
            ? null
            : Map<String, dynamic>.from(data['payload'] as Map<String, dynamic>),
      );
    } catch (e) {
      debugPrint('Failed to parse notification ${doc.id}: $e');
      return null;
    }
  }

  T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
    if (name == null) return fallback;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }

  int _importantFirstSort(AppNotification a, AppNotification b) {
    if (a.important != b.important) return a.important ? -1 : 1;
    if (a.isUnread != b.isUnread) return a.isUnread ? -1 : 1;
    return b.createdAt.compareTo(a.createdAt);
  }
}
