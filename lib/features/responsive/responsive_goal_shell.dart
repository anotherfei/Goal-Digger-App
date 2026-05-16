import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/gd_colors.dart';
import '../../shared/widgets/shared_widgets.dart';

class ResponsiveGoalShell extends StatelessWidget {
  const ResponsiveGoalShell({
    super.key,
    required this.selectedIndex,
    required this.signedInWith,
    required this.pages,
    required this.onSelect,
    required this.onFocusMode,
    required this.onProfile,
    required this.onSettings,
    required this.hasActiveFocus,
    required this.focusLabel,
  });

  final int selectedIndex;
  final String signedInWith;
  final List<Widget> pages;
  final ValueChanged<int> onSelect;
  final VoidCallback onFocusMode;
  final VoidCallback onProfile;
  final VoidCallback onSettings;
  final bool hasActiveFocus;
  final String? focusLabel;

  static const labels = ['Goals', 'Calendar', 'Home', 'Social', 'Pet'];
  static const icons = [Icons.flag_rounded, Icons.calendar_month_rounded, Icons.home_rounded, Icons.groups_rounded, Icons.pets_rounded];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton.filledTonal(
            tooltip: 'Profile and friends',
            onPressed: onProfile,
            icon: const Icon(Icons.account_circle_rounded),
          ),
        ),
        centerTitle: true,
        title: const Text('Goal Digger'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton.filledTonal(
              tooltip: 'Settings',
              onPressed: onSettings,
              icon: const Icon(Icons.settings_rounded),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: SafeArea(top: false, bottom: false, child: pages[selectedIndex])),
          if (hasActiveFocus)
            Positioned(
              left: 22,
              right: 22,
              bottom: bottomInset + 126,
              child: AppCard(
                child: ListTile(
                  dense: true,
                  leading: const CircleAvatar(backgroundColor: gdPrimarySoft, child: Icon(Icons.track_changes_rounded, color: gdPrimary)),
                  title: const Text('Focus session running', style: TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text('Tap to reopen · ${focusLabel ?? ''}', style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
                  trailing: const Icon(Icons.open_in_full_rounded),
                  onTap: onFocusMode,
                ),
              ),
            ),
          Positioned(
            right: 22,
            bottom: bottomInset + (hasActiveFocus ? 220 : 124),
            child: FloatingActionButton.extended(
              tooltip: 'Focus mode',
              onPressed: onFocusMode,
              backgroundColor: gdPrimary,
              foregroundColor: Colors.white,
              elevation: 8,
              icon: const Icon(Icons.track_changes_rounded),
              label: const Text('Focus'),
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: bottomInset + 4,
            child: _GoalBottomNavigation(labels: labels, icons: icons, selectedIndex: selectedIndex, onSelect: onSelect),
          ),
        ],
      ),
    );
  }
}

class _GoalBottomNavigation extends StatelessWidget {
  const _GoalBottomNavigation({required this.labels, required this.icons, required this.selectedIndex, required this.onSelect});
  final List<String> labels;
  final List<IconData> icons;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Container(
              height: 88,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(color: gdSurface.withOpacity(0.96), borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 24, offset: const Offset(0, 12))], border: Border.all(color: gdBorder)),
              child: Row(children: [for (var i = 0; i < labels.length; i++) Expanded(child: _BottomNavItem(label: labels[i], icon: icons[i], selected: selectedIndex == i, highlighted: i == 2, onTap: () => onSelect(i)))]),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({required this.label, required this.icon, required this.selected, required this.highlighted, required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? gdOnDark : selected ? gdPrimary : gdMuted;
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: SizedBox(
        height: 70,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: highlighted ? 48 : 38,
            height: highlighted ? 48 : 38,
            decoration: BoxDecoration(color: highlighted ? gdPrimary : selected ? gdPrimarySoft : Colors.transparent, shape: BoxShape.circle, boxShadow: highlighted ? [BoxShadow(color: gdPrimary.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 6))] : null),
            child: Icon(icon, color: color, size: highlighted ? 28 : 23),
          ),
          const SizedBox(height: 4),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: highlighted ? gdPrimaryDark : selected ? gdPrimary : gdMuted, fontSize: 11, fontWeight: highlighted || selected ? FontWeight.w900 : FontWeight.w700)),
        ]),
      ),
    );
  }
}
