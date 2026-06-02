import 'package:flutter/material.dart';

import '../../core/theme/gd_design.dart';
import '../../shared/widgets/shared_widgets.dart';

/// Calm, monochrome chrome buttons for the app bar. Utility actions (profile,
/// notifications, settings) stay neutral so they don't compete with the title;
/// colour up here is reserved for the notification badge alone.
final ButtonStyle _chromeIconButtonStyle = IconButton.styleFrom(
  backgroundColor: gdCardLight,
  foregroundColor: gdInk,
  hoverColor: gdBorder,
  highlightColor: gdBorder,
  shape: const CircleBorder(),
);

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
    required this.onNotifications,
    required this.unreadNotifications,
    required this.importantUnreadNotifications,
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
  final VoidCallback onNotifications;
  final int unreadNotifications;
  final int importantUnreadNotifications;
  final bool hasActiveFocus;
  final String? focusLabel;

  static const labels = ['Goals', 'Calendar', 'Home', 'Social', 'Pet'];
  static const icons = [
    Icons.flag_rounded,
    Icons.calendar_month_rounded,
    Icons.home_rounded,
    Icons.groups_rounded,
    Icons.pets_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final isHome = selectedIndex == 2;
    final contentBottomPadding = bottomInset + (hasActiveFocus ? 232.0 : 208.0);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            style: _chromeIconButtonStyle,
            tooltip: 'Profile and friends',
            onPressed: onProfile,
            icon: const Icon(Icons.account_circle_rounded),
          ),
        ),
        centerTitle: true,
        title: const Text('Goal Digger'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _NotificationIconButton(
              unreadCount: unreadNotifications,
              importantUnreadCount: importantUnreadNotifications,
              onPressed: onNotifications,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              style: _chromeIconButtonStyle,
              tooltip: 'Settings',
              onPressed: onSettings,
              icon: const Icon(Icons.settings_rounded),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: GoalShellInsets(
              bottom: contentBottomPadding,
              child: SafeArea(
                top: false,
                bottom: false,
                child: pages[selectedIndex],
              ),
            ),
          ),
          if (hasActiveFocus)
            Positioned(
              left: 18,
              right: 18,
              bottom: bottomInset + 126,
              child: _ActiveFocusBanner(
                focusLabel: focusLabel,
                onTap: onFocusMode,
              ),
            )
          else
            Positioned(
              right: 22,
              bottom: bottomInset + 124,
              child: _FocusActionButton(
                extended: isHome,
                onPressed: onFocusMode,
              ),
            ),
          Positioned(
            left: 14,
            right: 14,
            bottom: bottomInset + 4,
            child: _GoalBottomNavigation(
              labels: labels,
              icons: icons,
              selectedIndex: selectedIndex,
              onSelect: onSelect,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveFocusBanner extends StatelessWidget {
  const _ActiveFocusBanner({
    required this.focusLabel,
    required this.onTap,
  });

  final String? focusLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gdPrimary.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: AppCard(
        color: gdSurface.withValues(alpha: 0.98),
        child: ListTile(
          dense: true,
          minVerticalPadding: 12,
          leading: const CircleAvatar(
            backgroundColor: gdPrimarySoft,
            child: Icon(Icons.track_changes_rounded, color: gdPrimary),
          ),
          title: const Text(
            'Focus session running',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Text(
            focusLabel == null || focusLabel!.isEmpty
                ? 'Tap to reopen'
                : 'Tap to reopen - $focusLabel',
            style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
          ),
          trailing: const Icon(Icons.open_in_full_rounded),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _FocusActionButton extends StatelessWidget {
  const _FocusActionButton({
    required this.extended,
    required this.onPressed,
  });

  final bool extended;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 280);
    final borderRadius = BorderRadius.circular(28);

    return Tooltip(
      message: 'Focus mode',
      child: Semantics(
        button: true,
        label: 'Focus mode',
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          width: extended ? 132 : 56,
          height: 56,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: gdPrimary,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: gdPrimary.withValues(alpha: extended ? 0.28 : 0.20),
                blurRadius: extended ? 20 : 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: borderRadius,
              onTap: onPressed,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.track_changes_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: extended ? 1 : 0),
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          'Focus',
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          softWrap: false,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      builder: (context, value, child) {
                        return ClipRect(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            widthFactor: value,
                            child: Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: child,
                            ),
                          ),
                        );
                      },
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

class _NotificationIconButton extends StatelessWidget {
  const _NotificationIconButton({
    required this.unreadCount,
    required this.importantUnreadCount,
    required this.onPressed,
  });

  final int unreadCount;
  final int importantUnreadCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final badgeText = unreadCount > 9 ? '9+' : '$unreadCount';
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          style: _chromeIconButtonStyle,
          tooltip: 'Notifications',
          onPressed: onPressed,
          icon: Icon(
            importantUnreadCount > 0
                ? Icons.notification_important_rounded
                : Icons.notifications_rounded,
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: importantUnreadCount > 0 ? gdWarning : gdPrimary,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: gdSurface, width: 2),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  color: gdOnDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _GoalBottomNavigation extends StatelessWidget {
  const _GoalBottomNavigation({
    required this.labels,
    required this.icons,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> labels;
  final List<IconData> icons;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Container(
          height: 88,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            // Fully opaque, elegant surface — clear separation comes from the
            // layered shadow and a hairline border, not from a blur.
            color: gdSurface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: gdBorder),
            boxShadow: [
              // Soft ambient lift — floats the island clear of the page.
              BoxShadow(
                color: gdShadow.withValues(alpha: 0.16),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
              // Tight contact shadow — gives a crisp, defined edge.
              BoxShadow(
                color: gdShadow.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(
                  child: _BottomNavItem(
                    label: labels[i],
                    icon: icons[i],
                    selected: selectedIndex == i,
                    highlighted: selectedIndex == i && i == 2,
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.highlighted,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = highlighted
        ? gdOnDark
        : selected
            ? gdPrimary
            : gdMuted;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: SizedBox(
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: highlighted ? 48 : 38,
              height: highlighted ? 48 : 38,
              decoration: BoxDecoration(
                color: highlighted
                    ? gdPrimary
                    : selected
                        ? gdPrimarySoft
                        : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: highlighted
                    ? [
                        BoxShadow(
                          color: gdPrimary.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Icon(icon, color: color, size: highlighted ? 28 : 23),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: highlighted
                    ? gdPrimaryDark
                    : selected
                        ? gdPrimary
                        : gdMuted,
                fontSize: 11,
                fontWeight:
                    highlighted || selected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
