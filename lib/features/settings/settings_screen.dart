import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/gd_design.dart';
import '../../core/theme/theme_controller.dart';
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
    this.email = '',
    this.signedInWith = 'Guest',
    this.isGuest = false,
    this.emailVerified = false,
    this.providerIds = const <String>[],
    this.onSendEmailVerification,
    this.onRefreshEmailVerification,
    this.onSendPasswordReset,
    this.onDeleteAccount,
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
  final String email;
  final String signedInWith;
  final bool isGuest;
  final bool emailVerified;
  final List<String> providerIds;
  final Future<bool> Function()? onSendEmailVerification;
  final Future<bool> Function()? onRefreshEmailVerification;
  final Future<bool> Function()? onSendPasswordReset;
  final Future<bool> Function()? onDeleteAccount;

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

  Future<void> _sendVerificationEmail() async {
    final action = widget.onSendEmailVerification;
    if (action == null) {
      _showInfo(
        title: 'Verify email',
        message:
            'Connect this action from goal_digger_root.dart so Settings can send the verification email.',
      );
      return;
    }

    final sent = await action();
    if (!mounted) return;
    _showSnack(
      sent
          ? 'Verification email sent. Check your inbox or emulator logs.'
          : 'Could not send verification email.',
    );
  }

  Future<void> _refreshVerification() async {
    final action = widget.onRefreshEmailVerification;
    if (action == null) {
      _showInfo(
        title: 'Refresh verification',
        message:
            'Connect this action from goal_digger_root.dart so Settings can refresh Firebase email verification status.',
      );
      return;
    }

    final refreshed = await action();
    if (!mounted) return;
    _showSnack(
      refreshed
          ? 'Verification status refreshed.'
          : 'Could not refresh verification status.',
    );
  }

  Future<void> _sendPasswordReset() async {
    final action = widget.onSendPasswordReset;
    if (widget.email.trim().isEmpty) {
      _showSnack('No email address is attached to this account.');
      return;
    }
    if (action == null) {
      _showInfo(
        title: 'Reset password',
        message:
            'Connect this action from goal_digger_root.dart so Settings can send password reset instructions.',
      );
      return;
    }

    final sent = await action();
    if (!mounted) return;
    _showSnack(
      sent
          ? 'If this email uses password login, reset instructions were sent.'
          : 'Could not send password reset instructions.',
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final action = widget.onDeleteAccount;
    if (action == null) {
      _showInfo(
        title: 'Delete account',
        message:
            'Connect this action from goal_digger_root.dart so Settings can delete the Firebase Auth account.',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: gdError),
        title: const Text('Delete account?'),
        content: const Text(
          'This removes the Firebase Auth account from this project. This action may require a fresh login.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: gdError),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final deleted = await action();
    if (!mounted) return;
    if (deleted) {
      _showSnack('Account deleted.');
      Navigator.pop(context);
    } else {
      _showSnack('Could not delete account.');
    }
  }

  void _showInfo({required String title, required String message}) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

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
    // Pin the token resolver to the applied theme (and rebuild on change) so
    // toggling the selector below switches this whole page live.
    GdColors.setBrightness(Theme.of(context).brightness);
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
                  children: [
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
            const _AppearanceCard(),
            const SizedBox(height: 14),
            _AccountSecuritySettingsCard(
              email: widget.email,
              isGuest: widget.isGuest,
              emailVerified: widget.emailVerified,
              signedInWith: widget.signedInWith,
              providerIds: widget.providerIds,
              onSendEmailVerification: _sendVerificationEmail,
              onRefreshEmailVerification: _refreshVerification,
              onSendPasswordReset: _sendPasswordReset,
              onUnavailable: _showInfo,
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    value: goalReminders,
                    onChanged: onGoalRemindersChanged,
                    title: Text(
                      'Android notifications',
                      style: TextStyle(
                        color: gdInk,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    subtitle: Text(
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
                    title: Text(
                      'Friend progress sharing',
                      style: TextStyle(
                        color: gdInk,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    subtitle: Text(
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
            _AdvancedNotificationSettingsCard(
              goalReminders: goalReminders,
              notificationSettings: notificationSettings,
              onNotificationSettingsChanged: onNotificationSettingsChanged,
              onOpenNotificationSettings: onOpenNotificationSettings,
              onTestNotification: onTestNotification,
              onPickTime: _pickTime,
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
            _DangerZoneSettingsCard(
              isGuest: widget.isGuest,
              onSignOut: onSignOut,
              onDeleteAccount:
                  widget.isGuest ? null : _confirmDeleteAccount,
            ),
          ],
        ),
      ),
    );
  }
}


class _AccountSecuritySettingsCard extends StatelessWidget {
  const _AccountSecuritySettingsCard({
    required this.email,
    required this.isGuest,
    required this.emailVerified,
    required this.signedInWith,
    required this.providerIds,
    required this.onSendEmailVerification,
    required this.onRefreshEmailVerification,
    required this.onSendPasswordReset,
    required this.onUnavailable,
  });

  final String email;
  final bool isGuest;
  final bool emailVerified;
  final String signedInWith;
  final List<String> providerIds;
  final VoidCallback onSendEmailVerification;
  final VoidCallback onRefreshEmailVerification;
  final VoidCallback onSendPasswordReset;
  final void Function({required String title, required String message})
      onUnavailable;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: _SettingsSectionHeader(
              icon: Icons.shield_rounded,
              title: 'Account & security',
              subtitle: 'Manage login methods and account recovery.',
            ),
          ),
          const Divider(height: 1),
          _SettingsActionTile(
            icon: emailVerified ? Icons.verified_rounded : Icons.mark_email_read,
            title: emailVerified ? 'Email verified' : 'Verify email',
            subtitle: isGuest
                ? 'Guest accounts do not have an email to verify.'
                : email.trim().isEmpty
                    ? 'No email is attached to this account.'
                    : 'Use this to confirm ownership of $email.',
            actionLabel: emailVerified ? 'Refresh' : 'Send',
            onTap: isGuest || email.trim().isEmpty
                ? null
                : emailVerified
                    ? onRefreshEmailVerification
                    : onSendEmailVerification,
          ),
          const Divider(height: 1),
          _SettingsActionTile(
            icon: Icons.password_rounded,
            title: 'Reset password',
            subtitle: 'Password reset only applies to Goal Digger email login.',
            actionLabel: 'Send',
            onTap: isGuest || email.trim().isEmpty ? null : onSendPasswordReset,
          ),
          const Divider(height: 1),
          _SettingsActionTile(
            icon: Icons.hub_rounded,
            title: 'Linked providers',
            subtitle: _providerSummary,
            actionLabel: 'View',
            onTap: () => onUnavailable(
              title: 'Linked providers',
              message:
                  'Current login: $signedInWith. Future provider linking can let one account use both Google and email/password after a re-auth flow is added.',
            ),
          ),
          const Divider(height: 1),
          _SettingsActionTile(
            icon: Icons.alternate_email_rounded,
            title: 'Change email',
            subtitle: 'Changing email requires recent login verification.',
            actionLabel: 'Later',
            onTap: () => onUnavailable(
              title: 'Change email',
              message:
                  'This is a good production feature, but it needs a re-authentication flow first so account changes stay secure.',
            ),
          ),
        ],
      ),
    );
  }

  String get _providerSummary {
    if (isGuest) return 'Guest or anonymous preview account.';
    if (providerIds.isEmpty) return 'No provider data available.';
    return providerIds
        .map((id) => id == 'google.com'
            ? 'Google'
            : id == 'password'
                ? 'Email/password'
                : id)
        .join(', ');
  }
}

class _DangerZoneSettingsCard extends StatelessWidget {
  const _DangerZoneSettingsCard({
    required this.isGuest,
    required this.onSignOut,
    required this.onDeleteAccount,
  });

  final bool isGuest;
  final VoidCallback onSignOut;
  final VoidCallback? onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: gdErrorSoft,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: _SettingsSectionHeader(
              icon: Icons.warning_amber_rounded,
              title: 'Danger zone',
              subtitle: 'Session and account removal actions.',
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: gdSurface,
              child: Icon(Icons.logout_rounded, color: gdError),
            ),
            title: Text(
              'Sign out',
              style: TextStyle(color: gdError, fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              'Return to onboarding and stop syncing this session.',
              style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
            ),
            onTap: onSignOut,
          ),
          const Divider(height: 1),
          ListTile(
            enabled: !isGuest && onDeleteAccount != null,
            leading: CircleAvatar(
              backgroundColor: gdSurface,
              child: Icon(Icons.delete_forever_rounded, color: gdError),
            ),
            title: Text(
              'Delete account',
              style: TextStyle(color: gdError, fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              isGuest
                  ? 'Guest preview accounts can simply sign out.'
                  : 'Permanently delete the Firebase Auth account.',
              style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
            ),
            onTap: isGuest ? null : onDeleteAccount,
          ),
        ],
      ),
    );
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  const _SettingsSectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: gdPrimarySoft,
          child: Icon(icon, color: gdPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: gdInk,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: gdMuted,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  const _SettingsActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: onTap != null,
      leading: CircleAvatar(
        backgroundColor: gdPrimarySoft,
        child: Icon(icon, color: gdPrimary),
      ),
      title: Text(
        title,
        style: TextStyle(color: gdInk, fontWeight: FontWeight.w900),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
      ),
      trailing: TextButton(onPressed: onTap, child: Text(actionLabel)),
      onTap: onTap,
    );
  }
}

class _AdvancedNotificationSettingsCard extends StatelessWidget {
  const _AdvancedNotificationSettingsCard({
    required this.goalReminders,
    required this.notificationSettings,
    required this.onNotificationSettingsChanged,
    required this.onOpenNotificationSettings,
    required this.onTestNotification,
    required this.onPickTime,
  });

  final bool goalReminders;
  final NotificationSettings notificationSettings;
  final ValueChanged<NotificationSettings> onNotificationSettingsChanged;
  final VoidCallback onOpenNotificationSettings;
  final VoidCallback onTestNotification;
  final Future<void> Function({
    required BuildContext context,
    required TimeOfDay initialTime,
    required ValueChanged<TimeOfDay> onPicked,
  }) onPickTime;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
          leading: CircleAvatar(
            backgroundColor: gdPrimarySoft,
            child: Icon(
              Icons.notifications_active_rounded,
              color: gdPrimary,
            ),
          ),
          title: Text(
            'Advanced notification controls',
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
          children: [
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
              subtitle: Text(
                'Also used as the base time for deadline alerts.',
                style: TextStyle(
                  color: gdMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: OutlinedButton.icon(
                onPressed: goalReminders
                    ? () => onPickTime(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: notificationSettings.dailyPlanHour,
                            minute: notificationSettings.dailyPlanMinute,
                          ),
                          onPicked: (picked) => onNotificationSettingsChanged(
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
              subtitle: Text(
                'Only fires when today has no completed task.',
                style: TextStyle(
                  color: gdMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: OutlinedButton.icon(
                onPressed: goalReminders
                    ? () => onPickTime(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: notificationSettings.streakSaverHour,
                            minute: notificationSettings.streakSaverMinute,
                          ),
                          onPicked: (picked) => onNotificationSettingsChanged(
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
              subtitle: Text(
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
                    onPressed: goalReminders ? onTestNotification : null,
                    icon: const Icon(Icons.notification_add_rounded),
                    label: const Text('Send test notification'),
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

/// Light / Dark / System selector. Reads and writes the app-wide
/// [ThemeController] directly, so the choice applies instantly and persists.
class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: gdPrimarySoft,
                    borderRadius: BorderRadius.circular(GdRadius.sm),
                  ),
                  child: Icon(Icons.dark_mode_rounded,
                      color: gdPrimary, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appearance',
                        style: TextStyle(
                          color: gdInk,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Use light, dark, or match your device.',
                        style: TextStyle(
                          color: gdMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                style: SegmentedButton.styleFrom(
                  foregroundColor: gdMuted,
                  selectedForegroundColor: gdPrimary,
                  selectedBackgroundColor: gdPrimarySoft,
                  side: BorderSide(color: gdBorder),
                ),
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode_rounded),
                    label: Text('Light'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode_rounded),
                    label: Text('Dark'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.brightness_auto_rounded),
                    label: Text('System'),
                  ),
                ],
                selected: {controller.mode},
                onSelectionChanged: (selection) =>
                    controller.setMode(selection.first),
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
      title: Text(
        title,
        style: TextStyle(
          color: gdInk,
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: gdMuted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
