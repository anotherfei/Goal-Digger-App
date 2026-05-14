part of goal_digger;

class _TasksPage extends StatelessWidget {
  const _TasksPage({
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
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 112),
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
    );
  }
}
