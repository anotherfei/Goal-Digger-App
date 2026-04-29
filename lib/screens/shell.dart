import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../widgets/ambient_background.dart';
import '../widgets/profile_button.dart';
import '../widgets/settings_button.dart';
import '../widgets/pet_widget.dart';
import 'home_screen.dart';
import 'task_screen.dart';
import 'calendar_screen.dart';
import 'community_screen.dart';
import 'shop_screen.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  Widget _screen(NavTab tab) {
    switch (tab) {
      case NavTab.task: return const TaskScreen();
      case NavTab.calendar: return const CalendarScreen();
      case NavTab.home: return const HomeScreen();
      case NavTab.community: return const CommunityScreen();
      case NavTab.shop: return const ShopScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AmbientBackground()),
          Positioned.fill(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: top + 12, left: 14, right: 14, bottom: 8),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [ProfileButton(), SettingsButton()],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(anim), child: child),
                    ),
                    child: KeyedSubtree(key: ValueKey(state.tab), child: _screen(state.tab)),
                  ),
                ),
              ],
            ),
          ),

          // Bottom nav
          Positioned(
            bottom: 12, left: 12, right: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
                boxShadow: [BoxShadow(color: const Color(0xFF2C271F).withValues(alpha: 0.18), blurRadius: 80, offset: const Offset(0, 24))],
              ),
              child: Row(
                children: [
                  _navItem(context, state, NavTab.task, '✅', 'Task'),
                  _navItem(context, state, NavTab.calendar, '🗓️', 'Calendar'),
                  _homeNavItem(context, state),
                  _navItem(context, state, NavTab.community, '👥', 'Community'),
                  _navItem(context, state, NavTab.shop, '🛍️', 'Customize'),
                ],
              ),
            ),
          ),

          // Global reminder overlay
          if (state.activeReminder != null) _reminderOverlay(context, state),
          // Breakdown chat overlay
          if (state.breakdownChat != null) _chatOverlay(context, state),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext ctx, AppState state, NavTab tab, String icon, String label) {
    final active = state.tab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => state.setTab(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.dark : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: active ? Colors.white : AppColors.textTertiary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _homeNavItem(BuildContext ctx, AppState state) {
    final active = state.tab == NavTab.home;
    return Expanded(
      child: GestureDetector(
        onTap: () => state.setTab(NavTab.home),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: active ? AppColors.dark : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: PetWidget(size: 52, from: state.activePet.from, to: state.activePet.to, accent: state.activePet.accent, animate: false),
          ),
        ),
      ),
    );
  }

  Widget _reminderOverlay(BuildContext ctx, AppState state) {
    final r = state.activeReminder!;
    return Positioned.fill(
      child: GestureDetector(
        onTap: state.dismissReminder,
        child: Container(
          color: AppColors.dark.withValues(alpha: 0.7),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24), padding: const EdgeInsets.all(28),
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(36)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('🔔', style: TextStyle(fontSize: 36)),
                const SizedBox(height: 12),
                Text(r.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text(r.time, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.teal)),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: GestureDetector(
                    onTap: () { if (r.taskId != null) state.toggleTask(r.taskId!); state.dismissReminder(); },
                    child: Container(padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: AppColors.emerald, borderRadius: BorderRadius.circular(100)),
                      child: const Center(child: Text('Complete', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)))),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: GestureDetector(
                    onTap: state.dismissReminder,
                    child: Container(padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(100)),
                      child: const Center(child: Text('Dismiss', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)))),
                  )),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chatOverlay(BuildContext ctx, AppState state) {
    final chat = state.breakdownChat!;
    final controller = TextEditingController();
    return Positioned.fill(
      child: GestureDetector(
        onTap: state.closeChat,
        child: Container(
          color: AppColors.dark.withValues(alpha: 0.7),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.all(24), padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(36)),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Text(chat.goal, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary))),
                    GestureDetector(onTap: state.closeChat, child: const Icon(Icons.close, size: 20)),
                  ]),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: chat.messages.length,
                      itemBuilder: (_, i) {
                        final m = chat.messages[i];
                        return Align(
                          alignment: m.role == 'user' ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(ctx).size.width * 0.7),
                            decoration: BoxDecoration(
                              color: m.role == 'ai' ? AppColors.dark.withValues(alpha: 0.05) : AppColors.dark,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(m.text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.5, color: m.role == 'ai' ? AppColors.textPrimary : Colors.white)),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextField(
                      controller: controller,
                      decoration: InputDecoration(hintText: 'Adjust the plan...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: AppColors.dark.withValues(alpha: 0.1))), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      onSubmitted: (v) { if (v.trim().isNotEmpty) { state.sendChatMsg(v); controller.clear(); } },
                    )),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () { if (controller.text.trim().isNotEmpty) { state.sendChatMsg(controller.text); controller.clear(); } },
                      child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(100)),
                        child: const Icon(Icons.send, color: Colors.white, size: 18)),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: state.closeChat,
                    child: Container(
                      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(color: AppColors.emerald, borderRadius: BorderRadius.circular(100)),
                      child: const Center(child: Text('Finalize', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white))),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
