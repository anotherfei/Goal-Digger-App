import 'package:flutter/material.dart';

import '../../core/theme/gd_design.dart';
import '../../models/models.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../companion/companion_sprite.dart';

typedef GuestUpgradeCallback = Future<bool> Function({
  required String displayName,
  required String email,
  required String password,
});
typedef GuestGoogleUpgradeCallback = Future<GuestGoogleUpgradeResult?>
    Function();

class GuestGoogleUpgradeResult {
  const GuestGoogleUpgradeResult({
    required this.displayName,
    required this.email,
  });

  final String displayName;
  final String email;
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.signedInWith,
    required this.isGuest,
    required this.emailVerified,
    required this.providerIds,
    required this.coins,
    required this.streak,
    required this.petHappiness,
    required this.companion,
    required this.streakTier,
    required this.selectedMood,
    required this.goals,
    required this.tasks,
    required this.communities,
    required this.friends,
    required this.routines,
    required this.goalReminders,
    required this.friendProgressSharing,
    required this.onDisplayNameChanged,
    required this.onSendEmailVerification,
    required this.onRefreshEmailVerification,
    required this.onSendPasswordReset,
    required this.onUpgradeGuestWithEmail,
    required this.onUpgradeGuestWithGoogle,
    required this.onGoalRemindersChanged,
    required this.onFriendProgressSharingChanged,
    required this.onSignOut,
    required this.onDeleteAccount,
  });

  final String displayName;
  final String email;
  final String? photoUrl;
  final String signedInWith;
  final bool isGuest;
  final bool emailVerified;
  final List<String> providerIds;
  final int coins;
  final int streak;
  final int petHappiness;
  final CompanionKind companion;
  final CompanionStreakTier streakTier;
  final String selectedMood;
  final List<GoalProject> goals;
  final List<MicroTask> tasks;
  final List<CommunityGroup> communities;
  final List<String> friends;
  final List<RoutineItem> routines;
  final bool goalReminders;
  final bool friendProgressSharing;
  final Future<bool> Function(String displayName) onDisplayNameChanged;
  final Future<bool> Function() onSendEmailVerification;
  final Future<bool> Function() onRefreshEmailVerification;
  final Future<bool> Function(String email) onSendPasswordReset;
  final GuestUpgradeCallback onUpgradeGuestWithEmail;
  final GuestGoogleUpgradeCallback onUpgradeGuestWithGoogle;
  final ValueChanged<bool> onGoalRemindersChanged;
  final ValueChanged<bool> onFriendProgressSharingChanged;
  final VoidCallback onSignOut;
  final Future<bool> Function() onDeleteAccount;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _displayName;
  late String _email;
  late String _signedInWith;
  late bool _isGuest;
  late bool _emailVerified;
  late List<String> _providerIds;
  late bool _goalReminders;
  late bool _friendProgressSharing;
  late final TextEditingController _displayNameController;
  late final TextEditingController _upgradeNameController;
  late final TextEditingController _upgradeEmailController;
  late final TextEditingController _upgradePasswordController;
  late final TextEditingController _upgradeConfirmPasswordController;
  bool _isEditingDisplayName = false;
  bool _savingDisplayName = false;
  bool _upgradingGuestWithEmail = false;
  bool _upgradingGuestWithGoogle = false;
  bool _hideUpgradePassword = true;

  String get displayName => _displayName;
  String get email => _email;
  String? get photoUrl => widget.photoUrl;
  String get signedInWith => _signedInWith;
  bool get isGuest => _isGuest;
  bool get emailVerified => _emailVerified;
  List<String> get providerIds => _providerIds;
  int get coins => widget.coins;
  int get streak => widget.streak;
  int get petHappiness => widget.petHappiness;
  CompanionKind get companion => widget.companion;
  CompanionStreakTier get streakTier => widget.streakTier;
  String get selectedMood => widget.selectedMood;
  List<GoalProject> get goals => widget.goals;
  List<MicroTask> get tasks => widget.tasks;
  List<CommunityGroup> get communities => widget.communities;
  List<String> get friends => widget.friends;
  List<RoutineItem> get routines => widget.routines;
  bool get goalReminders => _goalReminders;
  bool get friendProgressSharing => _friendProgressSharing;
  Future<bool> Function(String displayName) get onDisplayNameChanged =>
      widget.onDisplayNameChanged;
  Future<bool> Function() get onSendEmailVerification =>
      widget.onSendEmailVerification;
  Future<bool> Function() get onRefreshEmailVerification =>
      widget.onRefreshEmailVerification;
  Future<bool> Function(String email) get onSendPasswordReset =>
      widget.onSendPasswordReset;
  GuestUpgradeCallback get onUpgradeGuestWithEmail =>
      widget.onUpgradeGuestWithEmail;
  GuestGoogleUpgradeCallback get onUpgradeGuestWithGoogle =>
      widget.onUpgradeGuestWithGoogle;
  ValueChanged<bool> get onGoalRemindersChanged =>
      widget.onGoalRemindersChanged;
  ValueChanged<bool> get onFriendProgressSharingChanged =>
      widget.onFriendProgressSharingChanged;
  VoidCallback get onSignOut => widget.onSignOut;
  Future<bool> Function() get onDeleteAccount => widget.onDeleteAccount;

  @override
  void initState() {
    super.initState();
    _displayName = widget.displayName;
    _email = widget.email;
    _signedInWith = widget.signedInWith;
    _isGuest = widget.isGuest;
    _emailVerified = widget.emailVerified;
    _providerIds = List<String>.of(widget.providerIds);
    _goalReminders = widget.goalReminders;
    _friendProgressSharing = widget.friendProgressSharing;
    _displayNameController = TextEditingController(text: _displayName);
    _upgradeNameController = TextEditingController(text: _displayName);
    _upgradeEmailController = TextEditingController();
    _upgradePasswordController = TextEditingController();
    _upgradeConfirmPasswordController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_displayName == oldWidget.displayName &&
        widget.displayName != oldWidget.displayName) {
      _displayName = widget.displayName;
      if (!_isEditingDisplayName) {
        _displayNameController.text = _displayName;
      }
    }
    if (widget.email != oldWidget.email) _email = widget.email;
    if (widget.signedInWith != oldWidget.signedInWith) {
      _signedInWith = widget.signedInWith;
    }
    if (widget.isGuest != oldWidget.isGuest) _isGuest = widget.isGuest;
    if (widget.emailVerified != oldWidget.emailVerified) {
      _emailVerified = widget.emailVerified;
    }
    if (widget.providerIds != oldWidget.providerIds) {
      _providerIds = List<String>.of(widget.providerIds);
    }
    if (widget.goalReminders != oldWidget.goalReminders) {
      _goalReminders = widget.goalReminders;
    }
    if (widget.friendProgressSharing != oldWidget.friendProgressSharing) {
      _friendProgressSharing = widget.friendProgressSharing;
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _upgradeNameController.dispose();
    _upgradeEmailController.dispose();
    _upgradePasswordController.dispose();
    _upgradeConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep the token resolver matched to the applied theme on this route.
    GdColors.setBrightness(Theme.of(context).brightness);
    final completedTasks = tasks.where((task) => task.done).length;
    final focusMinutes = tasks
        .where((task) => task.done)
        .fold<int>(0, (sum, task) => sum + task.durationMinutes);
    final completedGoals = goals
        .where((goal) => goal.tasks.isNotEmpty && goal.progress >= 1)
        .length;
    final progress = tasks.isEmpty ? 0.0 : completedTasks / tasks.length;

    return Scaffold(
      backgroundColor: gdBackground,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Profile'),
        leading: IconButton(
          tooltip: 'Close profile',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileHeader(
                      displayName: displayName,
                      email: email,
                      photoUrl: photoUrl,
                      signedInWith: signedInWith,
                      isGuest: isGuest,
                      emailVerified: emailVerified,
                      isEditingName: _isEditingDisplayName,
                      isSavingName: _savingDisplayName,
                      nameController: _displayNameController,
                      onEditName: _startDisplayNameEdit,
                      onCancelNameEdit: _cancelDisplayNameEdit,
                      onSaveName: () => _saveDisplayName(context),
                    ),
                    if (isGuest) ...[
                      const SizedBox(height: 14),
                      _GuestUpgradeSection(
                        nameController: _upgradeNameController,
                        emailController: _upgradeEmailController,
                        passwordController: _upgradePasswordController,
                        confirmPasswordController:
                            _upgradeConfirmPasswordController,
                        isEmailLoading: _upgradingGuestWithEmail,
                        isGoogleLoading: _upgradingGuestWithGoogle,
                        obscurePassword: _hideUpgradePassword,
                        onTogglePasswordVisibility: () => setState(
                          () => _hideUpgradePassword = !_hideUpgradePassword,
                        ),
                        onSubmitEmail: () => _upgradeGuestWithEmail(context),
                        onSubmitGoogle: () => _upgradeGuestWithGoogle(context),
                      ),
                    ],
                    const SizedBox(height: 14),
                    _ProgressSection(
                      coins: coins,
                      streak: streak,
                      completedGoals: completedGoals,
                      totalGoals: goals.length,
                      completedTasks: completedTasks,
                      totalTasks: tasks.length,
                      focusMinutes: focusMinutes,
                      progress: progress,
                    ),
                    const SizedBox(height: 14),
                    _CompanionSection(
                      companion: companion,
                      streakTier: streakTier,
                      happiness: petHappiness,
                      selectedMood: selectedMood,
                      title: _profileTitle,
                    ),
                    const SizedBox(height: 14),
                    _AchievementsSection(
                      streak: streak,
                      completedGoals: completedGoals,
                      completedTasks: completedTasks,
                      focusMinutes: focusMinutes,
                      friends: friends.length,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _profileTitle {
    if (streak >= 30) return 'Goal Crusher';
    if (streak >= 14) return 'Sprint Builder';
    if (streak >= 7) return 'Focused Starter';
    if (goals.where((goal) => goal.progress > 0).isNotEmpty) {
      return 'Momentum Maker';
    }
    return 'Goal Explorer';
  }

  void _startDisplayNameEdit() {
    setState(() {
      _displayNameController.text = displayName;
      _isEditingDisplayName = true;
    });
  }

  void _cancelDisplayNameEdit() {
    setState(() {
      _displayNameController.text = displayName;
      _isEditingDisplayName = false;
    });
  }

  // ignore: unused_element
  void _setGoalReminders(bool value) {
    setState(() => _goalReminders = value);
    onGoalRemindersChanged(value);
  }

  // ignore: unused_element
  void _setFriendProgressSharing(bool value) {
    setState(() => _friendProgressSharing = value);
    onFriendProgressSharingChanged(value);
  }

  Future<void> _saveDisplayName(BuildContext context) async {
    final cleaned = _displayNameController.text.trim();
    if (cleaned.isEmpty) {
      _showSnack(context, 'Display name cannot be empty.');
      return;
    }
    if (cleaned == displayName) {
      setState(() => _isEditingDisplayName = false);
      return;
    }

    setState(() => _savingDisplayName = true);
    final saved = await onDisplayNameChanged(cleaned);
    if (!mounted) return;
    setState(() {
      _savingDisplayName = false;
      if (saved) {
        _displayName = cleaned;
        _isEditingDisplayName = false;
      }
    });
    if (!context.mounted) return;
    _showSnack(
      context,
      saved ? 'Display name updated.' : 'Could not update display name.',
    );
  }

  Future<void> _upgradeGuestWithEmail(BuildContext context) async {
    if (_upgradingGuestWithGoogle) return;
    final cleanedName = _upgradeNameController.text.trim();
    final cleanedEmail = _upgradeEmailController.text.trim();
    final password = _upgradePasswordController.text;
    final confirmPassword = _upgradeConfirmPasswordController.text;

    if (cleanedName.isEmpty) {
      _showSnack(context, 'Enter a display name first.');
      return;
    }
    if (cleanedEmail.isEmpty || !cleanedEmail.contains('@')) {
      _showSnack(context, 'Enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      _showSnack(context, 'Use a password with at least 6 characters.');
      return;
    }
    if (password != confirmPassword) {
      _showSnack(context, 'Passwords do not match.');
      return;
    }

    setState(() => _upgradingGuestWithEmail = true);
    final upgraded = await onUpgradeGuestWithEmail(
      displayName: cleanedName,
      email: cleanedEmail,
      password: password,
    );
    if (!mounted) return;
    setState(() {
      _upgradingGuestWithEmail = false;
      if (upgraded) {
        _displayName = cleanedName;
        _displayNameController.text = cleanedName;
        _email = cleanedEmail;
        _signedInWith = 'Email';
        _isGuest = false;
        _emailVerified = false;
        _providerIds = const ['password'];
        _upgradePasswordController.clear();
        _upgradeConfirmPasswordController.clear();
      }
    });
    if (!context.mounted) return;
    _showSnack(
      context,
      upgraded
          ? 'Guest progress saved. Check your email to verify the account.'
          : 'Could not upgrade guest account.',
    );
  }

  Future<void> _upgradeGuestWithGoogle(BuildContext context) async {
    if (_upgradingGuestWithEmail) return;
    setState(() => _upgradingGuestWithGoogle = true);
    final result = await onUpgradeGuestWithGoogle();
    if (!mounted) return;
    setState(() {
      _upgradingGuestWithGoogle = false;
      if (result != null) {
        final googleName = result.displayName.trim();
        if (googleName.isNotEmpty) {
          _displayName = googleName;
          _displayNameController.text = googleName;
        }
        _email = result.email;
        _signedInWith = 'Google';
        _isGuest = false;
        _emailVerified = true;
        _providerIds = const ['google.com'];
        _upgradePasswordController.clear();
        _upgradeConfirmPasswordController.clear();
      }
    });
    if (!context.mounted) return;
    _showSnack(
      context,
      result != null
          ? 'Guest progress saved to your Google account.'
          : 'Could not bind Google to this guest account.',
    );
  }

  // ignore: unused_element
  Future<void> _sendVerificationEmail(BuildContext context) async {
    final sent = await onSendEmailVerification();
    if (!context.mounted) return;
    _showSnack(
      context,
      sent
          ? 'Verification email sent. Check your inbox or emulator logs.'
          : 'Could not send verification email.',
    );
  }

  // ignore: unused_element
  Future<void> _refreshVerification(BuildContext context) async {
    final refreshed = await onRefreshEmailVerification();
    if (!context.mounted) return;
    _showSnack(
      context,
      refreshed
          ? 'Verification status refreshed.'
          : 'Could not refresh verification status.',
    );
  }

  // ignore: unused_element
  Future<void> _sendPasswordReset(BuildContext context) async {
    if (email.trim().isEmpty) {
      _showSnack(context, 'No email address is attached to this account.');
      return;
    }
    final sent = await onSendPasswordReset(email);
    if (!context.mounted) return;
    _showSnack(
      context,
      sent
          ? 'If this email uses password login, reset instructions were sent.'
          : 'Could not send password reset instructions.',
    );
  }

  // ignore: unused_element
  Future<void> _confirmDeleteAccount(BuildContext context) async {
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
    if (confirmed != true || !context.mounted) return;
    final deleted = await onDeleteAccount();
    if (!context.mounted) return;
    if (deleted) {
      _showSnack(context, 'Account deleted.');
      Navigator.pop(context);
    }
  }

  // ignore: unused_element
  void _showInfo(
    BuildContext context, {
    required String title,
    required String message,
  }) {
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

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.signedInWith,
    required this.isGuest,
    required this.emailVerified,
    required this.isEditingName,
    required this.isSavingName,
    required this.nameController,
    required this.onEditName,
    required this.onCancelNameEdit,
    required this.onSaveName,
  });

  final String displayName;
  final String email;
  final String? photoUrl;
  final String signedInWith;
  final bool isGuest;
  final bool emailVerified;
  final bool isEditingName;
  final bool isSavingName;
  final TextEditingController nameController;
  final VoidCallback onEditName;
  final VoidCallback onCancelNameEdit;
  final VoidCallback onSaveName;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: gdPrimarySoft,
                  backgroundImage: photoUrl == null || photoUrl!.isEmpty
                      ? null
                      : NetworkImage(photoUrl!),
                  child: photoUrl == null || photoUrl!.isEmpty
                      ? Icon(
                          Icons.account_circle_rounded,
                          size: 48,
                          color: gdPrimary,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isEditingName)
                        TextField(
                          controller: nameController,
                          autofocus: true,
                          enabled: !isSavingName,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'Display name',
                            isDense: true,
                          ),
                          onSubmitted: (_) => onSaveName(),
                        )
                      else
                        Text(
                          displayName,
                          style: GdText.headlineMedium,
                        ),
                      const SizedBox(height: 6),
                      Text(
                        email.isEmpty ? 'Guest preview account' : email,
                        style: TextStyle(
                          color: gdMuted,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatusChip(
                            icon: Icons.login_rounded,
                            label: 'Signed in with $signedInWith',
                            color: gdPrimary,
                          ),
                          _StatusChip(
                            icon: isGuest
                                ? Icons.person_outline_rounded
                                : emailVerified
                                    ? Icons.verified_rounded
                                    : Icons.mark_email_unread_rounded,
                            label: isGuest
                                ? 'Guest'
                                : emailVerified
                                    ? 'Email verified'
                                    : 'Email not verified',
                            color: emailVerified ? Colors.green : gdWarning,
                          ),
                        ],
                      ),
                      if (isEditingName) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton(
                              onPressed: isSavingName ? null : onCancelNameEdit,
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: isSavingName ? null : onSaveName,
                              child: isSavingName
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Save'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit display name',
                  onPressed: isGuest || isEditingName ? null : onEditName,
                  icon: Icon(
                    isEditingName ? Icons.edit_off_rounded : Icons.edit_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestUpgradeSection extends StatelessWidget {
  const _GuestUpgradeSection({
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isEmailLoading,
    required this.isGoogleLoading,
    required this.obscurePassword,
    required this.onTogglePasswordVisibility,
    required this.onSubmitEmail,
    required this.onSubmitGoogle,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isEmailLoading;
  final bool isGoogleLoading;
  final bool obscurePassword;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onSubmitEmail;
  final VoidCallback onSubmitGoogle;

  bool get _isLoading => isEmailLoading || isGoogleLoading;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: gdPrimarySoft,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              icon: Icons.lock_person_rounded,
              title: 'Save guest progress',
              subtitle:
                  'Bind this guest session to email or Google without losing goals or tasks.',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : onSubmitGoogle,
                icon: isGoogleLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.g_mobiledata_rounded, size: 30),
                label: Text(
                  isGoogleLoading ? 'Connecting Google...' : 'Bind to Google',
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _InlineDivider(label: 'or use email'),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              enabled: !_isLoading,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Display name',
                prefixIcon: Icon(Icons.badge_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              enabled: !_isLoading,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              enabled: !_isLoading,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_rounded),
                suffixIcon: IconButton(
                  tooltip: obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: _isLoading ? null : onTogglePasswordVisibility,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              enabled: !_isLoading,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _isLoading ? null : onSubmitEmail(),
              decoration: const InputDecoration(
                labelText: 'Confirm password',
                prefixIcon: Icon(Icons.lock_reset_rounded),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : onSubmitEmail,
                icon: isEmailLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upgrade_rounded),
                label: Text(
                  isEmailLoading ? 'Saving progress...' : 'Bind to email',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineDivider extends StatelessWidget {
  const _InlineDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(
              color: gdMuted,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const Expanded(child: Divider(height: 1)),
      ],
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.coins,
    required this.streak,
    required this.completedGoals,
    required this.totalGoals,
    required this.completedTasks,
    required this.totalTasks,
    required this.focusMinutes,
    required this.progress,
  });

  final int coins;
  final int streak;
  final int completedGoals;
  final int totalGoals;
  final int completedTasks;
  final int totalTasks;
  final int focusMinutes;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              icon: Icons.insights_rounded,
              title: 'Progress',
              subtitle: 'A quick read on your current momentum.',
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 10,
              backgroundColor: gdPrimarySoft,
              color: gdPrimary,
              borderRadius: BorderRadius.circular(999),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetricTile(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Streak',
                  value: '$streak days',
                ),
                _MetricTile(
                  icon: Icons.paid_rounded,
                  label: 'Coins',
                  value: '$coins',
                ),
                _MetricTile(
                  icon: Icons.flag_rounded,
                  label: 'Goals',
                  value: '$completedGoals/$totalGoals',
                ),
                _MetricTile(
                  icon: Icons.check_circle_rounded,
                  label: 'Tasks',
                  value: '$completedTasks/$totalTasks',
                ),
                _MetricTile(
                  icon: Icons.timer_rounded,
                  label: 'Focus',
                  value: '$focusMinutes min',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanionSection extends StatelessWidget {
  const _CompanionSection({
    required this.companion,
    required this.streakTier,
    required this.happiness,
    required this.selectedMood,
    required this.title,
  });

  final CompanionKind companion;
  final CompanionStreakTier streakTier;
  final int happiness;
  final String selectedMood;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: gdPrimarySoft,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CompanionSprite(kind: companion, tier: streakTier, size: 92),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GdText.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    '${companion.label} companion. Mood: $selectedMood.',
                    style: TextStyle(
                      color: gdMuted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: happiness.clamp(0, 100) / 100,
                    minHeight: 8,
                    color: gdAccent,
                    backgroundColor: gdSurface,
                    borderRadius: BorderRadius.circular(999),
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

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection({
    required this.streak,
    required this.completedGoals,
    required this.completedTasks,
    required this.focusMinutes,
    required this.friends,
  });

  final int streak;
  final int completedGoals;
  final int completedTasks;
  final int focusMinutes;
  final int friends;

  @override
  Widget build(BuildContext context) {
    final badges = [
      _BadgeData(
        icon: Icons.local_fire_department_rounded,
        title: 'Streak starter',
        unlocked: streak >= 3,
      ),
      _BadgeData(
        icon: Icons.task_alt_rounded,
        title: 'Task finisher',
        unlocked: completedTasks >= 10,
      ),
      _BadgeData(
        icon: Icons.flag_rounded,
        title: 'Goal closer',
        unlocked: completedGoals >= 1,
      ),
      _BadgeData(
        icon: Icons.timer_rounded,
        title: 'Focus builder',
        unlocked: focusMinutes >= 120,
      ),
      _BadgeData(
        icon: Icons.groups_rounded,
        title: 'Accountable',
        unlocked: friends >= 3,
      ),
    ];

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              icon: Icons.workspace_premium_rounded,
              title: 'Achievements',
              subtitle: 'Badges unlock as you build consistency.',
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final badge in badges)
                  _BadgeChip(
                    icon: badge.icon,
                    title: badge.title,
                    unlocked: badge.unlocked,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _AccountSecuritySection extends StatelessWidget {
  const _AccountSecuritySection({
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
  final void Function(String title, String message) onUnavailable;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: _SectionHeader(
              icon: Icons.shield_rounded,
              title: 'Account & security',
              subtitle: 'Manage login methods and account recovery.',
            ),
          ),
          const Divider(height: 1),
          _ProfileActionTile(
            icon:
                emailVerified ? Icons.verified_rounded : Icons.mark_email_read,
            title: emailVerified ? 'Email verified' : 'Verify email',
            subtitle: isGuest
                ? 'Guest accounts do not have an email to verify.'
                : email.isEmpty
                    ? 'No email is attached to this account.'
                    : 'Use this to confirm ownership of $email.',
            actionLabel: emailVerified ? 'Refresh' : 'Send',
            onTap: isGuest || email.isEmpty
                ? null
                : emailVerified
                    ? onRefreshEmailVerification
                    : onSendEmailVerification,
          ),
          const Divider(height: 1),
          _ProfileActionTile(
            icon: Icons.password_rounded,
            title: 'Reset password',
            subtitle: 'Password reset only applies to Goal Digger email login.',
            actionLabel: 'Send',
            onTap: isGuest || email.isEmpty ? null : onSendPasswordReset,
          ),
          const Divider(height: 1),
          _ProfileActionTile(
            icon: Icons.hub_rounded,
            title: 'Linked providers',
            subtitle: _providerSummary,
            actionLabel: 'View',
            onTap: () => onUnavailable(
              'Linked providers',
              'Current login: $signedInWith. Future provider linking can let one account use both Google and email/password after a re-auth flow is added.',
            ),
          ),
          const Divider(height: 1),
          _ProfileActionTile(
            icon: Icons.alternate_email_rounded,
            title: 'Change email',
            subtitle: 'Changing email requires recent login verification.',
            actionLabel: 'Later',
            onTap: () => onUnavailable(
              'Change email',
              'This is a good production feature, but it needs a re-authentication flow first so account changes stay secure.',
            ),
          ),
        ],
      ),
    );
  }

  String get _providerSummary {
    if (providerIds.isEmpty) return 'Guest or anonymous preview account.';
    return providerIds
        .map((id) => id == 'google.com'
            ? 'Google'
            : id == 'password'
                ? 'Email/password'
                : id)
        .join(', ');
  }
}

// ignore: unused_element
class _SocialPrivacySection extends StatelessWidget {
  const _SocialPrivacySection({
    required this.friends,
    required this.joinedCommunities,
    required this.totalCommunities,
    required this.friendProgressSharing,
    required this.onFriendProgressSharingChanged,
  });

  final int friends;
  final int joinedCommunities;
  final int totalCommunities;
  final bool friendProgressSharing;
  final ValueChanged<bool> onFriendProgressSharingChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: _SectionHeader(
              icon: Icons.groups_rounded,
              title: 'Social & privacy',
              subtitle: 'Control what friends can see.',
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: gdPrimarySoft,
              child: Icon(Icons.person_add_alt_1_rounded, color: gdPrimary),
            ),
            title: Text(
              'Friends',
              style: TextStyle(fontWeight: FontWeight.w900, color: gdInk),
            ),
            subtitle: Text(
              '$friends friends. $joinedCommunities/$totalCommunities communities joined.',
              style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
            ),
          ),
          const Divider(height: 1),
          SwitchListTile.adaptive(
            value: friendProgressSharing,
            activeThumbColor: gdPrimary,
            onChanged: onFriendProgressSharingChanged,
            title: Text(
              'Share progress with friends',
              style: TextStyle(fontWeight: FontWeight.w900, color: gdInk),
            ),
            subtitle: Text(
              'Allow approved friends to see streak and progress signals.',
              style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: gdPrimarySoft,
              child: Icon(Icons.visibility_rounded, color: gdPrimary),
            ),
            title: Text(
              'Public profile preview',
              style: TextStyle(fontWeight: FontWeight.w900, color: gdInk),
            ),
            subtitle: Text(
              'Your public profile uses display name, title, badges, and allowed progress only.',
              style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _PreferencesSection extends StatelessWidget {
  const _PreferencesSection({
    required this.routines,
    required this.goalReminders,
    required this.onGoalRemindersChanged,
    required this.onUnavailable,
  });

  final int routines;
  final bool goalReminders;
  final ValueChanged<bool> onGoalRemindersChanged;
  final void Function(String title, String message) onUnavailable;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: _SectionHeader(
              icon: Icons.tune_rounded,
              title: 'Preferences',
              subtitle: 'Keep planning defaults close to your account.',
            ),
          ),
          const Divider(height: 1),
          SwitchListTile.adaptive(
            value: goalReminders,
            activeThumbColor: gdPrimary,
            onChanged: onGoalRemindersChanged,
            title: Text(
              'Goal reminders',
              style: TextStyle(fontWeight: FontWeight.w900, color: gdInk),
            ),
            subtitle: Text(
              'Nudge me before scheduled tasks and routines.',
              style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
            ),
          ),
          const Divider(height: 1),
          _ProfileActionTile(
            icon: Icons.timer_rounded,
            title: 'Default focus length',
            subtitle: 'Currently shown when creating a focus session.',
            actionLabel: 'Later',
            onTap: () => onUnavailable(
              'Default focus length',
              'This can be connected to Focus Mode once default session preferences are stored in the profile.',
            ),
          ),
          const Divider(height: 1),
          _ProfileActionTile(
            icon: Icons.event_repeat_rounded,
            title: 'Daily planning time',
            subtitle: '$routines saved routines are synced with your profile.',
            actionLabel: 'Later',
            onTap: () => onUnavailable(
              'Daily planning time',
              'Routine-specific reminder timing can be expanded from the Calendar page.',
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _DangerZoneSection extends StatelessWidget {
  const _DangerZoneSection({
    required this.isGuest,
    required this.onSignOut,
    required this.onDeleteAccount,
  });

  final bool isGuest;
  final VoidCallback onSignOut;
  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: gdErrorSoft,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: _SectionHeader(
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
              'Return to login and stop syncing this session.',
              style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
            ),
            onTap: onSignOut,
          ),
          const Divider(height: 1),
          ListTile(
            enabled: !isGuest,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
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
              Text(title, style: GdText.titleLarge),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: gdInk,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: gdCardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gdBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: gdPrimary),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: gdInk,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _BadgeData {
  const _BadgeData({
    required this.icon,
    required this.title,
    required this.unlocked,
  });

  final IconData icon;
  final String title;
  final bool unlocked;
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({
    required this.icon,
    required this.title,
    required this.unlocked,
  });

  final IconData icon;
  final String title;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: unlocked ? gdPrimarySoft : gdCardLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: unlocked ? gdPrimary : gdBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: unlocked ? gdPrimary : gdMuted, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: unlocked ? gdInk : gdMuted,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
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
