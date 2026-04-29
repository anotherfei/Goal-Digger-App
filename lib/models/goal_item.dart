import 'package:flutter/material.dart';
import 'sub_task.dart';

class GoalItem {
  final int id;
  final String title;
  int importance; // 1..5
  int deadlineDay;
  final Color startColor;
  final Color endColor;
  final List<SubTask> subtasks;

  GoalItem({
    required this.id,
    required this.title,
    required this.importance,
    required this.deadlineDay,
    required this.startColor,
    required this.endColor,
    required this.subtasks,
  });
}
