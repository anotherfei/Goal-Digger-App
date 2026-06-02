import 'package:flutter/material.dart';

import '../core/theme/gd_design.dart';

enum TaskLoad { light, focus, stretch }

extension TaskLoadX on TaskLoad {
  String get label {
    switch (this) {
      case TaskLoad.light:
        return 'Light';
      case TaskLoad.focus:
        return 'Focus';
      case TaskLoad.stretch:
        return 'Stretch';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskLoad.light:
        return Icons.spa_rounded;
      case TaskLoad.focus:
        return Icons.track_changes_rounded;
      case TaskLoad.stretch:
        return Icons.local_fire_department_rounded;
    }
  }

  /// Colour mirrors the cognitive arousal a load implies: light work reads as
  /// calm/info, focused work as steady brand blue, a stretch task as
  /// high-energy warm — so effort is legible at a glance, not just by icon.
  Color get color {
    switch (this) {
      case TaskLoad.light:
        return GdColors.info;
      case TaskLoad.focus:
        return GdColors.brand;
      case TaskLoad.stretch:
        return GdColors.warm;
    }
  }

  /// Soft surface paired with [color] for chips and icon tiles.
  Color get softColor {
    switch (this) {
      case TaskLoad.light:
        return GdColors.infoSoft;
      case TaskLoad.focus:
        return GdColors.brandSoft;
      case TaskLoad.stretch:
        return GdColors.warmSoft;
    }
  }
}

class MicroTask {
  MicroTask({
    required this.id,
    required this.goalId,
    required this.title,
    required this.durationMinutes,
    required this.load,
    required this.scheduledDate,
    this.done = false,
    this.points = 15,
  });

  final int id;
  final int goalId;
  final String title;
  final int durationMinutes;
  final TaskLoad load;
  DateTime scheduledDate;
  bool done;
  final int points;
}

class GoalProject {
  GoalProject({
    required this.id,
    required this.title,
    required this.importance,
    required this.category,
    required this.deadline,
    required this.from,
    required this.to,
    double? progress,
    required this.tasks,
  }) : _savedProgress = progress;

  final int id;
  String title;
  int importance;
  String category;
  DateTime deadline;
  Color from;
  Color to;
  List<MicroTask> tasks;
  final double? _savedProgress;

  double get progress {
    if (tasks.isEmpty) return (_savedProgress ?? 0).clamp(0.0, 1.0).toDouble();
    return tasks.where((task) => task.done).length / tasks.length;
  }
}

class CommunityGroup {
  CommunityGroup({
    required this.name,
    required this.members,
    required this.tag,
    required this.description,
    this.similarity = 82,
    this.joined = false,
    this.backendId,
  });

  final String name;
  final int members;
  final String tag;
  final String description;
  final int similarity;
  bool joined;

  /// Firestore document id for persisted community groups.
  /// Seed/demo communities may keep this null and still work locally.
  final String? backendId;
}

enum RoutineRepeat { yearly, monthly, weekly, daily, custom }

extension RoutineRepeatX on RoutineRepeat {
  String get label {
    switch (this) {
      case RoutineRepeat.yearly:
        return 'Yearly';
      case RoutineRepeat.monthly:
        return 'Monthly';
      case RoutineRepeat.weekly:
        return 'Weekly';
      case RoutineRepeat.daily:
        return 'Daily';
      case RoutineRepeat.custom:
        return 'Custom';
    }
  }
}

class RoutineItem {
  RoutineItem({
    String? id,
    required this.title,
    required this.startsAt,
    required this.repeat,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  final String id;
  final String title;
  final DateTime startsAt;
  final RoutineRepeat repeat;
}

class PetSkin {
  const PetSkin({
    required this.name,
    required this.from,
    required this.to,
    required this.accent,
  });

  final String name;
  final Color from;
  final Color to;
  final Color accent;
}
