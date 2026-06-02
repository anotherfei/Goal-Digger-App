import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/gd_design.dart';
import '../core/theme/gd_theme.dart';
import '../core/theme/theme_controller.dart';
import 'goal_digger_root.dart';

class GoalDiggerApp extends StatelessWidget {
  const GoalDiggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ThemeController>().mode;

    // Build each theme with the token resolver pinned to that brightness, so
    // ThemeData captures the correct colour snapshot for light and dark.
    GdColors.setBrightness(Brightness.light);
    final lightTheme = buildGoalDiggerTheme();
    GdColors.setBrightness(Brightness.dark);
    final darkTheme = buildGoalDiggerTheme();

    return MaterialApp(
      title: 'Goal Digger',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: mode,
      // Switch in a single frame: our tokens snap instantly, so the default
      // crossfade would otherwise leave theme-inherited text lerping grey.
      themeAnimationDuration: Duration.zero,
      // The content (GoalDiggerRoot) pins the token resolver to the *resolved*
      // theme via Theme.of — that's the only context genuinely inside the
      // applied theme, and it also rebuilds the app when the theme changes.
      home: const GoalDiggerRoot(),
    );
  }
}
