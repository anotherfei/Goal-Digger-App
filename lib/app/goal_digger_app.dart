import 'package:flutter/material.dart';

import '../core/theme/gd_theme.dart';
import 'goal_digger_root.dart';

class GoalDiggerApp extends StatelessWidget {
  const GoalDiggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goal Digger',
      debugShowCheckedModeBanner: false,
      theme: buildGoalDiggerTheme(),
      home: const GoalDiggerRoot(),
    );
  }
}
