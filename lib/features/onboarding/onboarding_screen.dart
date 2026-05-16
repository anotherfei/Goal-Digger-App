import 'package:flutter/material.dart';

import '../../core/theme/gd_colors.dart';
import '../../shared/widgets/shared_widgets.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({
    super.key,
    required this.onGoogle,
    required this.onLinkedIn,
    required this.onGuest,
  });

  final VoidCallback onGoogle;
  final VoidCallback onLinkedIn;
  final VoidCallback onGuest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const AmbientBackground(),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;
                final tutorial = const TutorialIntroPanel();
                final login = SimpleOnboardingCard(
                  onGoogle: onGoogle,
                  onLinkedIn: onLinkedIn,
                  onGuest: onGuest,
                );
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [Expanded(flex: 6, child: tutorial), const SizedBox(width: 24), Expanded(flex: 4, child: login)],
                            )
                          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [tutorial, const SizedBox(height: 18), login]),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TutorialIntroPanel extends StatelessWidget {
  const TutorialIntroPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      const _StepData(icon: Icons.login_rounded, title: '1. Log in or sign up', subtitle: 'Create an account first so goals, routines, coins, streaks, and friends can stay synced.'),
      const _StepData(icon: Icons.flag_rounded, title: '2. Add one goal', subtitle: 'Choose a category, priority, and deadline. You can chat with AI before subtasks are scheduled.'),
      const _StepData(icon: Icons.checklist_rounded, title: '3. Work from Home', subtitle: 'Finish today’s tasks, start Focus Mode, and earn coins for your companion.'),
      const _StepData(icon: Icons.groups_rounded, title: '4. Stay accountable', subtitle: 'Join recommended communities and manage friends from your profile.'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: gdPrimarySoft, borderRadius: BorderRadius.circular(999)),
                  child: const Text('Quick tutorial', style: TextStyle(color: gdPrimaryDark, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 18),
                Text('Welcome to Goal Digger', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 12),
                const Text('Here is how the app works before you enter: plan goals, review AI subtasks, schedule routines, focus without distractions, and grow with friends.', style: TextStyle(color: gdMuted, fontSize: 16, height: 1.5, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        ...steps.map((step) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: ListTile(
                  minVerticalPadding: 18,
                  leading: CircleAvatar(backgroundColor: gdPrimarySoft, child: Icon(step.icon, color: gdPrimary)),
                  title: Text(step.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(step.subtitle, style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w600)),
                ),
              ),
            )),
      ],
    );
  }
}

class SimpleOnboardingCard extends StatelessWidget {
  const SimpleOnboardingCard({
    super.key,
    required this.onGoogle,
    required this.onLinkedIn,
    required this.onGuest,
  });

  final VoidCallback onGoogle;
  final VoidCallback onLinkedIn;
  final VoidCallback onGuest;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Login or sign up', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text('Start with an account so your profile, friends, streaks, and routines are saved.', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            FilledButton.icon(onPressed: onGoogle, icon: const Icon(Icons.g_mobiledata_rounded, size: 30), label: const Text('Sign up with Google')),
            const SizedBox(height: 10),
            OutlinedButton.icon(onPressed: onLinkedIn, icon: const Icon(Icons.work_rounded), label: const Text('Continue with LinkedIn')),
            const SizedBox(height: 10),
            OutlinedButton.icon(onPressed: onGuest, icon: const Icon(Icons.person_outline_rounded), label: const Text('Preview as guest')),
            const Divider(height: 32),
            const HelpfulErrorBox(title: 'Tutorial first', message: 'The app now explains the main flow before users enter, then gives clear login/sign-up choices.', actionLabel: 'Got it', showAction: false),
          ],
        ),
      ),
    );
  }
}

class _StepData {
  const _StepData({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
}
