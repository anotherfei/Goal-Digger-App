part of goal_digger;

/* -------------------------------------------------------------------------- */
/* PAGES                                                                      */
/* -------------------------------------------------------------------------- */

class _PlannerPage extends StatelessWidget {
  const _PlannerPage({
    required this.goals,
    required this.today,
    required this.goalController,
    required this.deadline,
    required this.priority,
    required this.category,
    required this.isProcessing,
    required this.processingProgress,
    required this.onDeadlinePick,
    required this.onPriorityChanged,
    required this.onCategoryChanged,
    required this.onCreateGoal,
    required this.onDeleteGoal,
    required this.onEditGoalDeadline,
    required this.onEditGoalPriority,
    required this.onCreateFirstGoal,
  });

  final List<GoalProject> goals;
  final DateTime today;
  final TextEditingController goalController;
  final DateTime deadline;
  final int priority;
  final String category;
  final bool isProcessing;
  final double processingProgress;
  final VoidCallback onDeadlinePick;
  final ValueChanged<int> onPriorityChanged;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onCreateGoal;
  final ValueChanged<GoalProject> onDeleteGoal;
  final ValueChanged<GoalProject> onEditGoalDeadline;
  final ValueChanged<GoalProject> onEditGoalPriority;
  final VoidCallback onCreateFirstGoal;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 112),
        children: [
          AppCard(
            color: const Color(0xFFEAF1FF),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: const [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Create a goal', style: TextStyle(color: gdInk, fontSize: 26, height: 1.1, fontWeight: FontWeight.w900)),
                      SizedBox(height: 8),
                      Text('Pick a clear category, then review AI subtasks before they are scheduled.', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
                    ])),
                  ]),
                  const SizedBox(height: 18),
                  Theme(
                    data: Theme.of(context).copyWith(inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(fillColor: gdSurface)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(controller: goalController, textInputAction: TextInputAction.done, decoration: const InputDecoration(labelText: 'Goal', hintText: 'Example: Prepare for midterm'), onSubmitted: (_) => onCreateGoal()),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(style: OutlinedButton.styleFrom(backgroundColor: gdSurface), onPressed: onDeadlinePick, icon: const Icon(Icons.event_rounded), label: Text('Deadline: ${shortDate(deadline)}')),
                        const SizedBox(height: 14),
                        CategorySelector(selected: category, onChanged: onCategoryChanged),
                        const SizedBox(height: 12),
                        PrioritySelector(value: priority, onChanged: onPriorityChanged),
                        const SizedBox(height: 14),
                        FilledButton.icon(onPressed: isProcessing ? null : onCreateGoal, icon: const Icon(Icons.auto_awesome_rounded), label: const Text('Break down my goal')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isProcessing) ...[
            const SizedBox(height: 14),
            ProcessingProgressCard(progress: processingProgress, label: 'Creating your task plan'),
          ],
          const SizedBox(height: 22),
          SectionTitle(title: 'Active goals', trailing: '${goals.length}'),
          const SizedBox(height: 10),
          if (goals.isEmpty)
            EmptyStateCard(icon: Icons.flag_circle_rounded, title: 'No goals yet', message: 'Create your first project and Goal Digger will turn it into small, scheduled actions.', cta: 'Create your first project', onPressed: onCreateFirstGoal)
          else
            ...goals.map((goal) => GoalCard(
                  goal: goal,
                  today: today,
                  onDelete: () => onDeleteGoal(goal),
                  onEditDeadline: () => onEditGoalDeadline(goal),
                  onEditPriority: () => onEditGoalPriority(goal),
                )),
        ],
      ),
    );
  }
}
