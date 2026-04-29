import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';

class _NavItem {
  final NavTab tab;
  final String label;
  final IconData icon;

  const _NavItem({
    required this.tab,
    required this.label,
    required this.icon,
  });
}

const List<_NavItem> _navItems = [
  _NavItem(tab: NavTab.task, label: 'Task', icon: Icons.check_box_rounded),
  _NavItem(
      tab: NavTab.calendar,
      label: 'Calendar',
      icon: Icons.calendar_month_rounded),
  _NavItem(tab: NavTab.planner, label: 'Planner', icon: Icons.auto_awesome),
  _NavItem(tab: NavTab.community, label: 'Community', icon: Icons.people_alt_rounded),
  _NavItem(
      tab: NavTab.companion, label: 'Companion', icon: Icons.pets_rounded),
];

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Positioned(
      bottom: 12,
      left: 12,
      right: 12,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.7),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2C271F).withValues(alpha: 0.18),
                  blurRadius: 80,
                  offset: const Offset(0, 24),
                ),
              ],
            ),
            child: Row(
              children: _navItems.map((item) {
                final isActive = state.activeTab == item.tab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => state.setActiveTab(item.tab),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.dark : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: AppColors.dark.withValues(alpha: 0.28),
                                  blurRadius: 45,
                                  offset: const Offset(0, 16),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 22,
                            color:
                                isActive ? Colors.white : AppColors.textTertiary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
