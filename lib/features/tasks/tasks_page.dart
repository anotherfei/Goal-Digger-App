import 'package:flutter/material.dart';

import '../../core/theme/gd_design.dart';
import '../../models/models.dart';
import '../../shared/widgets/shared_widgets.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({
    super.key,
    required this.mood,
    required this.todayTasks,
    required this.todayProgress,
    required this.todayCompleted,
    required this.todayTotal,
    required this.remainingMinutes,
    required this.goalForTask,
    required this.onMoodChanged,
    required this.onToggleTask,
    required this.onCreateGoal,
  });

  final String mood;
  final List<MicroTask> todayTasks;
  final double todayProgress;
  final int todayCompleted;
  final int todayTotal;
  final int remainingMinutes;
  final GoalProject Function(MicroTask task) goalForTask;
  final ValueChanged<String> onMoodChanged;
  final ValueChanged<MicroTask> onToggleTask;
  final VoidCallback onCreateGoal;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              GdMood.surface(mood).withValues(alpha: 0.46),
              GdMood.surface(mood).withValues(alpha: 0.14),
              Colors.transparent,
            ],
            stops: const [0, 0.36, 1],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            18,
            14,
            18,
            GoalShellInsets.bottomOf(context),
          ),
          children: [
            MoodCheckPanel(
              selectedMood: mood,
              onMoodChanged: onMoodChanged,
            ),
            const SizedBox(height: 18),
            TodayProgressCard(
              progress: todayProgress,
              completed: todayCompleted,
              total: todayTotal,
              remainingMinutes: remainingMinutes,
            ),
            const SizedBox(height: 12),
            MoodAdjustmentNotice(mood: mood),
            const SizedBox(height: 18),
            SectionTitle(
              title: 'Goals for today',
              trailing: todayTasks.isEmpty ? null : '${todayTasks.length}',
            ),
            const SizedBox(height: 10),
            if (todayTasks.isEmpty)
              EmptyStateCard(
                icon: Icons.today_rounded,
                title: 'No goals scheduled today',
                message:
                    'Create a goal first. Goal Digger will automatically break it into scheduled actions for each day.',
                cta: 'Create goal',
                onPressed: onCreateGoal,
              )
            else
              ...todayTasks.map(
                (task) => TaskCard(
                  task: task,
                  goal: goalForTask(task),
                  mood: mood,
                  onToggle: () => onToggleTask(task),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
