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
    // Keep the token resolver matched to the applied theme on this route.
    GdColors.setBrightness(Theme.of(context).brightness);
    final importantNotifications = _visibleNotifications
        .where(_isImportantNotification)
        .toList();
    final groupedNotifications = _notificationGroupsFor(
      _visibleNotifications
        .where(
          (notification) => !_isImportantNotification(notification),
        )
        .toList(),
    );
    final unreadCount =
        _visibleNotifications.where((item) => item.isUnread).length;
    final groupedUnreadCount = groupedNotifications.fold<int>(
      0,
      (total, group) => total + group.unreadCount,
    );

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
              if (importantNotifications.isNotEmpty) ...[
                SectionTitle(
                  title: 'Important',
                  trailing: importantNotifications.any((item) => item.isUnread)
                      ? '${importantNotifications.where((item) => item.isUnread).length} unread'
                      : 'All read',
                ),
                const SizedBox(height: 10),
                for (final notification in importantNotifications)
                  _NotificationTile(
                    notification: notification,
                    highlight: notification.isUnread,
                    onMarkRead: () => _markRead(notification),
                    onDelete: () => _delete(notification),
                  ),
                const SizedBox(height: 12),
              ],
              if (groupedNotifications.isNotEmpty) ...[
                SectionTitle(
                  title: 'All notifications',
                  trailing: groupedUnreadCount == 0
                      ? 'All read'
                      : '$groupedUnreadCount unread',
                ),
                const SizedBox(height: 10),
                for (final group in groupedNotifications)
                  _NotificationGroup(
                    group: group,
                    onMarkRead: _markRead,
                    onDelete: _delete,
                  ),
              ] else if (importantNotifications.isEmpty)
                AppCard(
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

  bool _isImportantNotification(AppNotification notification) {
    return notification.important ||
        notification.type == AppNotificationType.important;
  }

  List<_NotificationGroupData> _notificationGroupsFor(
    List<AppNotification> notifications,
  ) {
    final buckets = <String, List<AppNotification>>{};
    for (final notification in notifications) {
      final key = notification.isPetRelated
          ? _petRewardGroupKey
          : notification.type.name;
      buckets.putIfAbsent(key, () => <AppNotification>[]).add(notification);
    }

    final groups = buckets.entries.map((entry) {
      final items = List<AppNotification>.from(entry.value)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final first = items.first;
      return _NotificationGroupData(
        key: entry.key,
        title: _notificationGroupTitle(entry.key, first.type),
        icon: entry.key == _petRewardGroupKey
            ? Icons.pets_rounded
            : _notificationIconFor(first.type),
        notifications: items,
      );
    }).toList()
      ..sort((a, b) => b.newest.compareTo(a.newest));

    return groups;
  }
}

const String _petRewardGroupKey = 'pet_rewards';

class _NotificationGroupData {
  const _NotificationGroupData({
    required this.key,
    required this.title,
    required this.icon,
    required this.notifications,
  });

  final String key;
  final String title;
  final IconData icon;
  final List<AppNotification> notifications;

  DateTime get newest => notifications.first.createdAt;
  int get unreadCount => notifications.where((item) => item.isUnread).length;
}

class _NotificationGroup extends StatelessWidget {
  const _NotificationGroup({
    required this.group,
    required this.onMarkRead,
    required this.onDelete,
  });

  final _NotificationGroupData group;
  final ValueChanged<AppNotification> onMarkRead;
  final ValueChanged<AppNotification> onDelete;

  @override
  Widget build(BuildContext context) {
    final newest = group.newest;
    final updateLabel = group.notifications.length == 1
        ? '1 update'
        : '${group.notifications.length} updates';

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          leading: CircleAvatar(
            backgroundColor: gdPrimarySoft,
            child: Icon(group.icon, color: gdPrimary),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  group.title,
                  style: TextStyle(
                    color: gdInk,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (group.unreadCount > 0)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: gdPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Text(
            '$updateLabel - latest ${shortDate(newest)}',
            style: TextStyle(
              color: gdMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          children: List.generate(group.notifications.length, (index) {
            final notification = group.notifications[index];
            return _NotificationGroupRow(
              notification: notification,
              showTopBorder: index > 0,
              onMarkRead: () => onMarkRead(notification),
              onDelete: () => onDelete(notification),
            );
          }),
        ),
      ),
    );
  }
}

class _NotificationGroupRow extends StatelessWidget {
  const _NotificationGroupRow({
    required this.notification,
    required this.showTopBorder,
    required this.onMarkRead,
    required this.onDelete,
  });

  final AppNotification notification;
  final bool showTopBorder;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border:
            showTopBorder ? Border(top: BorderSide(color: gdBorder)) : null,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        minVerticalPadding: 10,
        leading: Icon(
          notification.isPetRelated
              ? Icons.card_giftcard_rounded
              : _notificationIconFor(notification.type),
          color: notification.isUnread ? gdPrimary : gdMuted,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  color: gdInk,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (notification.isUnread)
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: gdPrimary,
                  shape: BoxShape.circle,
                ),
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
                style: TextStyle(
                  color: gdMuted,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                shortDate(notification.createdAt),
                style: TextStyle(
                  color: gdMuted,
                  fontWeight: FontWeight.w700,
                ),
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
}

String _notificationGroupTitle(String key, AppNotificationType type) {
  if (key == _petRewardGroupKey) return 'Pet rewards';

  switch (type) {
    case AppNotificationType.dailyPlan:
      return 'Daily plans';
    case AppNotificationType.taskReminder:
      return 'Tasks';
    case AppNotificationType.streakSaver:
      return 'Streaks';
    case AppNotificationType.deadlineWarning:
      return 'Deadlines';
    case AppNotificationType.routineReminder:
      return 'Routines';
    case AppNotificationType.focusComplete:
      return 'Focus';
    case AppNotificationType.moodNudge:
      return 'Mood';
    case AppNotificationType.reward:
      return 'Rewards';
    case AppNotificationType.community:
      return 'Community';
    case AppNotificationType.friend:
      return 'Friends';
    case AppNotificationType.chat:
      return 'Chats';
    case AppNotificationType.important:
      return 'Important';
  }
}

IconData _notificationIconFor(AppNotificationType type) {
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
    case AppNotificationType.friend:
      return Icons.person_add_alt_1_rounded;
    case AppNotificationType.chat:
      return Icons.chat_bubble_rounded;
    case AppNotificationType.important:
      return Icons.priority_high_rounded;
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
        leading: CircleAvatar(
          backgroundColor: gdPrimarySoft,
          child: Icon(Icons.settings_applications_rounded, color: gdPrimary),
        ),
        title: Text(
          'Android notification settings',
          style: TextStyle(color: gdInk, fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
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
    final isImportant =
        notification.important || notification.type == AppNotificationType.important;
    final color = isImportant ? gdWarning : gdPrimary;
    final background = highlight ? gdWarningSoft : gdSurface;

    return AppCard(
      color: background,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        minVerticalPadding: 12,
        leading: CircleAvatar(
          backgroundColor: isImportant ? gdWarningSoft : gdPrimarySoft,
          child: Icon(_notificationIconFor(notification.type), color: color),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
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
                style: TextStyle(
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
}
