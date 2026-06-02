import 'package:flutter/material.dart';

import '../../core/theme/gd_design.dart';
import '../../core/utils/date_helpers.dart';
import '../../shared/widgets/shared_widgets.dart';
import 'models/notification_models.dart';

class NotificationInboxPage extends StatefulWidget {
  const NotificationInboxPage({
    super.key,
    required this.notifications,
    required this.onMarkRead,
    required this.onMarkAllRead,
    required this.onDelete,
    this.onOpenNotificationSettings,
  });

  final List<AppNotification> notifications;
  final ValueChanged<AppNotification> onMarkRead;
  final VoidCallback onMarkAllRead;
  final ValueChanged<AppNotification> onDelete;
  final VoidCallback? onOpenNotificationSettings;

  @override
  State<NotificationInboxPage> createState() => _NotificationInboxPageState();
}

class _NotificationInboxPageState extends State<NotificationInboxPage> {
  late List<AppNotification> _visibleNotifications;

  @override
  void initState() {
    super.initState();
    _visibleNotifications = List<AppNotification>.from(widget.notifications);
  }

  @override
  void didUpdateWidget(covariant NotificationInboxPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifications != widget.notifications) {
      _visibleNotifications = List<AppNotification>.from(widget.notifications);
    }
  }

  @override
  Widget build(BuildContext context) {
    final importantUnread = _visibleNotifications
        .where((notification) => notification.important && notification.isUnread)
        .toList();
    final regularNotifications = _visibleNotifications
        .where(
          (notification) =>
              !(notification.important && notification.isUnread),
        )
        .toList();
    final unreadCount =
        _visibleNotifications.where((item) => item.isUnread).length;

    return Scaffold(
      backgroundColor: gdBackground,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Notifications'),
        leading: IconButton(
          tooltip: 'Close notifications',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all'),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          children: [
            if (widget.onOpenNotificationSettings != null) ...[
              _NotificationSettingsSection(
                onOpen: widget.onOpenNotificationSettings!,
              ),
              const SizedBox(height: 14),
            ],
            if (_visibleNotifications.isEmpty)
              EmptyStateCard(
                icon: Icons.notifications_none_rounded,
                title: 'No notifications yet',
                message:
                    'Important updates, rewards, community activity, and AI nudges will appear here.',
                cta: 'Close',
                onPressed: () => Navigator.pop(context),
              )
            else ...[
              if (importantUnread.isNotEmpty) ...[
                SectionTitle(
                  title: 'Important',
                  trailing: '${importantUnread.length} unread',
                ),
                const SizedBox(height: 10),
                for (final notification in importantUnread)
                  _NotificationTile(
                    notification: notification,
                    highlight: true,
                    onMarkRead: () => _markRead(notification),
                    onDelete: () => _delete(notification),
                  ),
                const SizedBox(height: 12),
              ],
              SectionTitle(
                title: importantUnread.isEmpty
                    ? 'All notifications'
                    : 'Other notifications',
                trailing: unreadCount == 0 ? 'All read' : '$unreadCount unread',
              ),
              const SizedBox(height: 10),
              if (regularNotifications.isEmpty)
                const AppCard(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'No other notifications.',
                      style: TextStyle(
                        color: gdMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              for (final notification in regularNotifications)
                _NotificationTile(
                  notification: notification,
                  highlight: notification.important && notification.isUnread,
                  onMarkRead: () => _markRead(notification),
                  onDelete: () => _delete(notification),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _markRead(AppNotification notification) {
    if (!notification.isUnread) return;
    setState(() {
      _visibleNotifications = _visibleNotifications
          .map((item) => item.id == notification.id
              ? item.copyWith(readAt: DateTime.now())
              : item)
          .toList();
    });
    widget.onMarkRead(notification);
  }

  void _markAllRead() {
    final now = DateTime.now();
    setState(() {
      _visibleNotifications = _visibleNotifications
          .map((item) => item.isUnread ? item.copyWith(readAt: now) : item)
          .toList();
    });
    widget.onMarkAllRead();
  }

  void _delete(AppNotification notification) {
    setState(() {
      _visibleNotifications = _visibleNotifications
          .where((item) => item.id != notification.id)
          .toList();
    });
    widget.onDelete(notification);
  }
}

class _NotificationSettingsSection extends StatelessWidget {
  const _NotificationSettingsSection({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        minVerticalPadding: 12,
        leading: const CircleAvatar(
          backgroundColor: gdPrimarySoft,
          child: Icon(Icons.settings_applications_rounded, color: gdPrimary),
        ),
        title: const Text(
          'Android notification settings',
          style: TextStyle(color: gdInk, fontWeight: FontWeight.w900),
        ),
        subtitle: const Text(
          'Open system settings for sounds, permission, and notification bar behavior.',
          style: TextStyle(
            color: gdMuted,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
        trailing: IconButton(
          tooltip: 'Open Android notification settings',
          icon: const Icon(Icons.open_in_new_rounded),
          onPressed: onOpen,
        ),
        onTap: onOpen,
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.highlight,
    required this.onMarkRead,
    required this.onDelete,
  });

  final AppNotification notification;
  final bool highlight;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = notification.important ? gdWarning : gdPrimary;
    final background = highlight ? gdWarningSoft : gdSurface;

    return AppCard(
      color: background,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        minVerticalPadding: 12,
        leading: CircleAvatar(
          backgroundColor:
              notification.important ? gdWarningSoft : gdPrimarySoft,
          child: Icon(_iconFor(notification.type), color: color),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: const TextStyle(
                  color: gdInk,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (notification.isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.body,
                style: const TextStyle(
                  color: gdMuted,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(notification.type.label)),
                  if (notification.important &&
                      notification.type != AppNotificationType.important)
                    const Chip(label: Text('Important')),
                  Chip(label: Text(shortDate(notification.createdAt))),
                ],
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          tooltip: 'Notification actions',
          onSelected: (value) {
            if (value == 'read') onMarkRead();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            if (notification.isUnread)
              const PopupMenuItem(value: 'read', child: Text('Mark read')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: notification.isUnread ? onMarkRead : null,
      ),
    );
  }

  IconData _iconFor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.dailyPlan:
        return Icons.today_rounded;
      case AppNotificationType.taskReminder:
        return Icons.task_alt_rounded;
      case AppNotificationType.streakSaver:
        return Icons.local_fire_department_rounded;
      case AppNotificationType.deadlineWarning:
        return Icons.warning_amber_rounded;
      case AppNotificationType.routineReminder:
        return Icons.repeat_rounded;
      case AppNotificationType.focusComplete:
        return Icons.track_changes_rounded;
      case AppNotificationType.moodNudge:
        return Icons.psychology_rounded;
      case AppNotificationType.reward:
        return Icons.paid_rounded;
      case AppNotificationType.community:
        return Icons.groups_rounded;
      case AppNotificationType.important:
        return Icons.priority_high_rounded;
    }
  }
}
