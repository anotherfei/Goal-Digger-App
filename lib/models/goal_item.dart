import 'package:flutter/material.dart';
import 'sub_task.dart';

class GoalItem {
  final int id;
  final String title;
  int importance;
  String category;
  DateTime deadline;
  final Color startColor;
  final Color endColor;
  final List<SubTask> subtasks;

  GoalItem({
    required this.id,
    required this.title,
    required this.importance,
    required this.category,
    required this.deadline,
    required this.startColor,
    required this.endColor,
    required this.subtasks,
  });

  int get doneCount => subtasks.where((s) => s.done).length;
  int get percent => subtasks.isEmpty ? 0 : ((doneCount / subtasks.length) * 100).round();
}
