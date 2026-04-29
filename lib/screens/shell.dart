import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/ambient_background.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/profile_button.dart';
import '../widgets/settings_button.dart';
import 'planner_screen.dart';
import 'task_screen.dart';
import 'calendar_screen.dart';
import 'community_screen.dart';
import 'companion_screen.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  Widget _screenForTab(NavTab tab) {
    switch (tab) {
      case NavTab.task: return const TaskScreen();
      case NavTab.calendar: return const CalendarScreen();
      case NavTab.planner: return const PlannerScreen();
      case NavTab.community: return const CommunityScreen();
      case NavTab.companion: return const CompanionScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AmbientBackground()),
          Positioned.fill(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: topPadding + 12, left: 14, right: 14, bottom: 8),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [ProfileButton(), SettingsButton()],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(animation),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(state.activeTab),
                      child: _screenForTab(state.activeTab),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const BottomNav(),

          // ── GLOBAL FULL-SCREEN REMINDER ──
          if (state.activeReminder != null)
            const _GlobalReminder(),
        ],
      ),
    );
  }
}

class _GlobalReminder extends StatelessWidget {
  const _GlobalReminder();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final r = state.activeReminder!;
    final task = r.taskId == null
        ? null
        : state.allSubtasks.where((s) => s.id == r.taskId).fold<dynamic>(null, (prev, e) => prev ?? e);
    final goal = task == null ? null : state.goals.where((g) => g.id == task.goalId).fold<dynamic>(null, (prev, e) => prev ?? e);

    return Positioned.fill(
      child: GestureDetector(
        onTap: state.dismissReminder,
        child: Container(
          color: AppColors.dark.withValues(alpha: 0.7),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // prevent dismiss on inner tap
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(28),
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [BoxShadow(color: AppColors.dark.withValues(alpha: 0.4), blurRadius: 120, offset: const Offset(0, 40))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.teal.withValues(alpha: 0.1)),
                      child: const Center(child: Text('🔔', style: TextStyle(fontSize: 28))),
                    ),
                    const SizedBox(height: 16),
                    Text('SCHEDULED REMINDER', style: AppTextStyles.label),
                    const SizedBox(height: 12),
                    Text(r.title, textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1, color: AppColors.textPrimary)),
                    if (task != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.dark.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (goal != null)
                              Text((goal.title as String).toUpperCase(), style: AppTextStyles.label.copyWith(fontSize: 9)),
                            const SizedBox(height: 4),
                            Text(task.title as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text(task.duration as String, style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(r.time, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.teal)),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (r.taskId != null) state.toggleTask(r.taskId!);
                              state.dismissReminder();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.emerald, borderRadius: BorderRadius.circular(100),
                                boxShadow: [BoxShadow(color: AppColors.emerald.withValues(alpha: 0.3), blurRadius: 30, offset: const Offset(0, 14))],
                              ),
                              child: const Center(child: Text('Complete', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: state.dismissReminder,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(100)),
                              child: const Center(child: Text('Dismiss', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
