library goal_digger;

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

part 'core/theme/design_tokens.dart';
part 'models/models.dart';
part 'core/utils/date_helpers.dart';
part 'data/seed_data.dart';
part 'app/goal_digger_app.dart';
part 'app/goal_digger_root.dart';
part 'features/onboarding/onboarding_screen.dart';
part 'features/focus/focus_mode.dart';
part 'features/settings/settings_screen.dart';
part 'shared/widgets/responsive_navigation.dart';
part 'features/planner/planner_page.dart';
part 'features/tasks/tasks_page.dart';
part 'features/calendar/calendar_page.dart';
part 'features/community/community_page.dart';
part 'features/companion/companion_page.dart';
part 'shared/widgets/shared_widgets.dart';

void main() {
  runApp(const GoalDiggerApp());
}
