import 'package:flutter/material.dart';

import '../../core/theme/gd_colors.dart';
import '../notifications/models/notification_models.dart';
import '../../shared/widgets/shared_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.goalReminders,
    required this.friendProgressSharing,
    required this.notificationSettings,
    required this.onGoalRemindersChanged,
    required this.onFriendProgressSharingChanged,
    required this.onNotificationSettingsChanged,
    required this.onTestNotification,
    required this.onOpenNotificationSettings,
    required this.onSignOut,
  });

  final bool goalReminders;
  final bool friendProgressSharing;
  final NotificationSettings notificationSettings;
  final ValueChanged<bool> onGoalRemindersChanged;
  final ValueChanged<bool> onFriendProgressSharingChanged;
  final ValueChanged<NotificationSettings> onNotificationSettingsChanged;
  final VoidCallback onTestNotification;
  final VoidCallback onOpenNotificationSettings;
  final VoidCallback onSignOut;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool goalReminders;
  late bool friendProgressSharing;
  late NotificationSettings notificationSettings;

  @override
  void initState() {
    super.initState();
    _syncFromWidget();
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.goalReminders != widget.goalReminders ||
        oldWidget.friendProgressSharing != widget.friendProgressSharing ||
        oldWidget.notificationSettings != widget.notificationSettings) {
      _syncFromWidget();
    }
  }

  void _syncFromWidget() {
    goalReminders = widget.goalReminders;
    friendProgressSharing = widget.friendProgressSharing;
    notificationSettings = widget.notificationSettings;
  }

  void onGoalRemindersChanged(bool value) {
    setState(() {
      goalReminders = value;
      notificationSettings = notificationSettings.copyWith(
        systemNotificationsEnabled: value,
      );
    });
    widget.onGoalRemindersChanged(value);
  }

  void onFriendProgressSharingChanged(bool value) {
    setState(() => friendProgressSharing = value);
    widget.onFriendProgressSharingChanged(value);
  }

  void onNotificationSettingsChanged(NotificationSettings value) {
    setState(() {
      notificationSettings = value;
      goalReminders = value.systemNotificationsEnabled;
    });
    widget.onNotificationSettingsChanged(value);
  }

  VoidCallback get onTestNotification => widget.onTestNotification;
  VoidCallback get onOpenNotificationSettings =>
      widget.onOpenNotificationSettings;
  VoidCallback get onSignOut => widget.onSignOut;

  Future<void> _pickTime({
    required BuildContext context,
    required TimeOfDay initialTime,
    required ValueChanged<TimeOfDay> onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gdBackground,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Settings'),
        leading: IconButton(
          tooltip: 'Close settings',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          children: [
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'App preferences',
                      style: TextStyle(
                        color: gdInk,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Preferences are now saved to your Firebase profile, so they stay consistent after reloads and across devices.',
                      style: TextStyle(
                        color: gdMuted,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    value: goalReminders,
                    onChanged: onGoalRemindersChanged,
                    activeColor: gdPrimary,
                    title: const Text(
                      'Android notifications',
                      style: TextStyle(
                        color: gdInk,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    subtitle: const Text(
                      'Allow scheduled pop-ups for goals and routines.',
                      style: TextStyle(
                        color: gdMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: friendProgressSharing,
                    onChanged: onFriendProgressSharingChanged,
                    activeColor: gdPrimary,
                    title: const Text(
                      'Friend progress sharing',
                      style: TextStyle(
                        color: gdInk,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    subtitle: const Text(
                      'Show my streak to approved friends.',
                      style: TextStyle(
                        color: gdMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: Column(
                  children: [
                    const ListTile(
                      leading: CircleAvatar(
                        backgroundColor: gdPrimarySoft,
                        child: Icon(
                          Icons.notifications_active_rounded,
                          color: gdPrimary,
                        ),
                      ),
                      title: Text(
                        'Android reminders',
                        style: TextStyle(
                          color: gdInk,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      subtitle: Text(
                        'Daily plan, streak, deadline, routine, and focus pop-ups.',
                        style: TextStyle(
                          color: gdMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    _NotificationSwitch(
                      value: notificationSettings.dailyPlanEnabled,
                      enabled: goalReminders,
                      title: 'Daily plan',
                      subtitle: 'Morning summary for today\'s scheduled work.',
                      onChanged: (value) => onNotificationSettingsChanged(
                        notificationSettings.copyWith(
                          dailyPlanEnabled: value,
                        ),
                      ),
                    ),
                    _NotificationSwitch(
                      value: notificationSettings.streakSaverEnabled,
                      enabled: goalReminders,
                      title: 'Streak saver',
                      subtitle: 'Evening nudge if nothing is done yet.',
                      onChanged: (value) => onNotificationSettingsChanged(
                        notificationSettings.copyWith(
                          streakSaverEnabled: value,
                        ),
                      ),
                    ),
                    _NotificationSwitch(
                      value: notificationSettings.deadlineWarningsEnabled,
                      enabled: goalReminders,
                      title: 'Deadline warnings',
                      subtitle: 'Pop up when unfinished goals are close.',
                      onChanged: (value) => onNotificationSettingsChanged(
                        notificationSettings.copyWith(
                          deadlineWarningsEnabled: value,
                        ),
                      ),
                    ),
                    _NotificationSwitch(
                      value: notificationSettings.routineRemindersEnabled,
                      enabled: goalReminders,
                      title: 'Routine reminders',
                      subtitle: 'Use the date, time, and repeat from Calendar.',
                      onChanged: (value) => onNotificationSettingsChanged(
                        notificationSettings.copyWith(
                          routineRemindersEnabled: value,
                        ),
                      ),
                    ),
                    _NotificationSwitch(
                      value: notificationSettings.focusNotificationsEnabled,
                      enabled: goalReminders,
                      title: 'Focus complete',
                      subtitle: 'Pop up when a focus session finishes.',
                      onChanged: (value) => onNotificationSettingsChanged(
                        notificationSettings.copyWith(
                          focusNotificationsEnabled: value,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text(
                        'Daily plan time',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: const Text(
                        'Also used as the base time for deadline alerts.',
                        style: TextStyle(
                          color: gdMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      trailing: OutlinedButton.icon(
                        onPressed: goalReminders
                            ? () => _pickTime(
                                  context: context,
                                  initialTime: TimeOfDay(
                                    hour: notificationSettings.dailyPlanHour,
                                    minute:
                                        notificationSettings.dailyPlanMinute,
                                  ),
                                  onPicked: (picked) =>
                                      onNotificationSettingsChanged(
                                    notificationSettings.copyWith(
                                      dailyPlanHour: picked.hour,
                                      dailyPlanMinute: picked.minute,
                                    ),
                                  ),
                                )
                            : null,
                        icon: const Icon(Icons.schedule_rounded),
                        label: Text(
                          TimeOfDay(
                            hour: notificationSettings.dailyPlanHour,
                            minute: notificationSettings.dailyPlanMinute,
                          ).format(context),
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        'Streak saver time',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: const Text(
                        'Only fires when today has no completed task.',
                        style: TextStyle(
                          color: gdMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      trailing: OutlinedButton.icon(
                        onPressed: goalReminders
                            ? () => _pickTime(
                                  context: context,
                                  initialTime: TimeOfDay(
                                    hour: notificationSettings.streakSaverHour,
                                    minute:
                                        notificationSettings.streakSaverMinute,
                                  ),
                                  onPicked: (picked) =>
                                      onNotificationSettingsChanged(
                                    notificationSettings.copyWith(
                                      streakSaverHour: picked.hour,
                                      streakSaverMinute: picked.minute,
                                    ),
                                  ),
                                )
                            : null,
                        icon: const Icon(Icons.schedule_rounded),
                        label: Text(
                          TimeOfDay(
                            hour: notificationSettings.streakSaverHour,
                            minute: notificationSettings.streakSaverMinute,
                          ).format(context),
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        'Deadline warning',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: const Text(
                        'How early unfinished goals become urgent.',
                        style: TextStyle(
                          color: gdMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      trailing: DropdownButton<int>(
                        value: notificationSettings.deadlineWarningDays,
                        onChanged: goalReminders
                            ? (value) {
                                if (value == null) return;
                                onNotificationSettingsChanged(
                                  notificationSettings.copyWith(
                                    deadlineWarningDays: value,
                                  ),
                                );
                              }
                            : null,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1 day')),
                          DropdownMenuItem(value: 2, child: Text('2 days')),
                          DropdownMenuItem(value: 3, child: Text('3 days')),
                          DropdownMenuItem(value: 7, child: Text('1 week')),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OutlinedButton.icon(
                            onPressed: onOpenNotificationSettings,
                            icon: const Icon(Icons.settings_applications_rounded),
                            label: const Text('Open Android notification settings'),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed:
                                goalReminders ? onTestNotification : null,
                            icon: const Icon(Icons.notification_add_rounded),
                            label: const Text('Send test notification'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(
                children: [
                  _NotificationSwitch(
                    value: notificationSettings.inAppNotificationsEnabled,
                    title: 'In-app notifications',
                    subtitle: 'AI nudges, rewards, and community updates.',
                    onChanged: (value) => onNotificationSettingsChanged(
                      notificationSettings.copyWith(
                        inAppNotificationsEnabled: value,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _NotificationSwitch(
                    value: notificationSettings.importantInAppEnabled,
                    enabled: notificationSettings.inAppNotificationsEnabled,
                    title: 'Important inbox alerts',
                    subtitle: 'Keep crucial messages pinned and unread.',
                    onChanged: (value) => onNotificationSettingsChanged(
                      notificationSettings.copyWith(
                        importantInAppEnabled: value,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(
                children: [
                  const ListTile(
                    leading: CircleAvatar(
                      backgroundColor: gdPrimarySoft,
                      child: Icon(Icons.palette_rounded, color: gdPrimary),
                    ),
                    title: Text(
                      'Appearance',
                      style: TextStyle(
                        color: gdInk,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    subtitle: Text(
                      'Readable colors and calm contrast enabled.',
                      style: TextStyle(
                        color: gdMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: CircleAvatar(
                      backgroundColor: gdPrimarySoft,
                      child: Icon(Icons.notifications_active_rounded, color: gdPrimary),
                    ),
                    title: Text(
                      'Notifications',
                      style: TextStyle(
                        color: gdInk,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    subtitle: Text(
                      'Focus, routine, friend, and streak controls.',
                      style: TextStyle(
                        color: gdMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: gdErrorSoft,
                      child: Icon(Icons.logout_rounded, color: gdError),
                    ),
                    title: const Text(
                      'Sign out',
                      style: TextStyle(
                        color: gdError,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    subtitle: const Text(
                      'Return to onboarding and stop syncing this session.',
                      style: TextStyle(
                        color: gdMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: onSignOut,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationSwitch extends StatelessWidget {
  const _NotificationSwitch({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.onChanged,
    this.enabled = true,
  });

  final bool value;
  final bool enabled;
  final String title;
  final String subtitle;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: enabled ? onChanged : null,
      activeColor: gdPrimary,
      title: Text(
        title,
        style: const TextStyle(
          color: gdInk,
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: gdMuted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
