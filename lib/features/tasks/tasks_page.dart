import 'package:flutter/material.dart';

import '../../core/theme/gd_design.dart';
import '../../core/utils/date_helpers.dart';
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
            _TodayGoalTaskSection(
              tasks: todayTasks,
              mood: mood,
              goalForTask: goalForTask,
              onToggleTask: onToggleTask,
              onCreateGoal: onCreateGoal,
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayGoalTaskSection extends StatefulWidget {
  const _TodayGoalTaskSection({
    required this.tasks,
    required this.mood,
    required this.goalForTask,
    required this.onToggleTask,
    required this.onCreateGoal,
  });

  final List<MicroTask> tasks;
  final String mood;
  final GoalProject Function(MicroTask task) goalForTask;
  final ValueChanged<MicroTask> onToggleTask;
  final VoidCallback onCreateGoal;

  @override
  State<_TodayGoalTaskSection> createState() => _TodayGoalTaskSectionState();
}

class _TodayGoalTaskSectionState extends State<_TodayGoalTaskSection> {
  static const _collapsedGoalCount = 3;
  bool _showAll = false;

  List<_GoalTaskGroup> _groups() {
    final groups = <_GoalTaskGroup>[];
    for (final task in widget.tasks) {
      final goal = widget.goalForTask(task);
      final existing = groups.where((group) => group.goal.id == goal.id);
      if (existing.isNotEmpty) {
        existing.first.tasks.add(task);
      } else {
        groups.add(_GoalTaskGroup(goal: goal, tasks: [task]));
      }
    }
    groups.sort((a, b) => a.goal.deadline.compareTo(b.goal.deadline));
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groups();
    final visibleCount = _showAll || groups.length <= _collapsedGoalCount
        ? groups.length
        : _collapsedGoalCount;
    final hiddenCount = groups.length - visibleCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Tasks for today',
          trailing: widget.tasks.isEmpty ? null : '${widget.tasks.length}',
        ),
        const SizedBox(height: 8),
        if (widget.tasks.isEmpty)
          EmptyStateCard(
            icon: Icons.today_rounded,
            title: 'No goals scheduled today',
            message:
                'Create a goal first. Goal Digger will automatically break it into scheduled actions for each day.',
            cta: 'Create goal',
            onPressed: widget.onCreateGoal,
          )
        else ...[
          Text(
            '${groups.length} goal${groups.length == 1 ? '' : 's'} need attention. Expand a goal to work through its tasks.',
            style: TextStyle(
              color: gdMuted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                for (var i = 0; i < visibleCount; i++)
                  _TodayGoalTaskCard(
                    group: groups[i],
                    mood: widget.mood,
                    initiallyExpanded: i == 0,
                    onToggleTask: widget.onToggleTask,
                  ),
              ],
            ),
          ),
          if (groups.length > _collapsedGoalCount)
            Align(
              child: TextButton.icon(
                onPressed: () => setState(() => _showAll = !_showAll),
                icon: Icon(_showAll
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded),
                label: Text(_showAll
                    ? 'Show fewer goals'
                    : 'Show $hiddenCount more goal${hiddenCount == 1 ? '' : 's'}'),
              ),
            ),
        ],
      ],
    );
  }
}

class _GoalTaskGroup {
  _GoalTaskGroup({required this.goal, required this.tasks});

  final GoalProject goal;
  final List<MicroTask> tasks;
}

class _TodayGoalTaskCard extends StatelessWidget {
  const _TodayGoalTaskCard({
    required this.group,
    required this.mood,
    required this.initiallyExpanded,
    required this.onToggleTask,
  });

  final _GoalTaskGroup group;
  final String mood;
  final bool initiallyExpanded;
  final ValueChanged<MicroTask> onToggleTask;

  @override
  Widget build(BuildContext context) {
    final goal = group.goal;
    final tasks = group.tasks;
    final completedToday = tasks.where((task) => task.done).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: gdSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gdBorderStrong.withValues(alpha: 0.50)),
        boxShadow: [
          BoxShadow(
            color: gdShadow.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: ColoredBox(
              color: goal.from.withValues(alpha: 0.42),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                key: PageStorageKey('today-goal-${goal.id}'),
                initiallyExpanded: initiallyExpanded,
                tilePadding: const EdgeInsets.fromLTRB(14, 10, 12, 8),
                childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                leading: CircularProgressBadge(
                  progress: goal.progress,
                  label: '${(goal.progress * 100).round()}%',
                  size: 54,
                  strokeWidth: 5,
                ),
                title: Text(
                  goal.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: gdInk,
                    fontSize: 16,
                    height: 1.16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _TaskGroupPill(
                        icon: GdCategory.iconFor(goal.category),
                        label: goal.category,
                        color: gdPrimary,
                        surface: gdPrimarySoft,
                      ),
                      _TaskGroupPill(
                        icon: Icons.today_rounded,
                        label: '$completedToday/${tasks.length} today',
                        color: completedToday == tasks.length
                            ? gdSuccess
                            : gdMuted,
                        surface: completedToday == tasks.length
                            ? gdSuccessSoft
                            : gdCardLight,
                      ),
                      _TaskGroupPill(
                        icon: Icons.event_rounded,
                        label: shortDate(goal.deadline),
                        color: gdMuted,
                        surface: gdCardLight,
                      ),
                    ],
                  ),
                ),
                children: [
                  for (final task in tasks)
                    _CompactTodayTaskRow(
                      task: task,
                      mood: mood,
                      onToggle: () => onToggleTask(task),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskGroupPill extends StatelessWidget {
  const _TaskGroupPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.surface,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactTodayTaskRow extends StatelessWidget {
  const _CompactTodayTaskRow({
    required this.task,
    required this.mood,
    required this.onToggle,
  });

  final MicroTask task;
  final String mood;
  final VoidCallback onToggle;

  String get _title {
    if (mood == 'Tired' && task.durationMinutes > 15) {
      return 'Start only: ${task.title}';
    }
    if (mood == 'Great' && task.load != TaskLoad.light) {
      return 'Deep work: ${task.title}';
    }
    return task.title;
  }

  @override
  Widget build(BuildContext context) {
    final done = task.done;
    final textColor = done ? gdMuted.withValues(alpha: 0.58) : gdInk;
    final metaColor = done ? gdMuted.withValues(alpha: 0.52) : gdMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: done ? null : onToggle,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
          decoration: BoxDecoration(
            color: done ? gdSuccessSoft.withValues(alpha: 0.42) : gdCardLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: done
                  ? gdSuccess.withValues(alpha: 0.18)
                  : gdBorder.withValues(alpha: 0.70),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 34,
                decoration: BoxDecoration(
                  color: done
                      ? gdSuccess.withValues(alpha: 0.52)
                      : task.load.color.withValues(alpha: 0.52),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 8),
              Checkbox(
                value: done,
                onChanged: done ? null : (_) => onToggle(),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        height: 1.18,
                        decoration: done ? TextDecoration.lineThrough : null,
                        fontWeight: done ? FontWeight.w800 : FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${task.durationMinutes} min · ${task.load.label}',
                      style: TextStyle(
                        color: metaColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                done ? Icons.check_circle_rounded : task.load.icon,
                color: done ? gdSuccess : task.load.color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
