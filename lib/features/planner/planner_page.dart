import 'package:flutter/material.dart';

import '../../core/constants/gd_constants.dart';
import '../../core/theme/gd_design.dart';
import '../../core/utils/date_helpers.dart';
import '../../models/models.dart';
import '../../shared/widgets/shared_widgets.dart';

class PlannerPage extends StatelessWidget {
  const PlannerPage({
    super.key,
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
        padding: EdgeInsets.fromLTRB(
          14,
          8,
          14,
          GoalShellInsets.bottomOf(context),
        ),
        children: [
          _CreateGoalCard(
            today: today,
            goalController: goalController,
            deadline: deadline,
            priority: priority,
            category: category,
            isProcessing: isProcessing,
            onDeadlinePick: onDeadlinePick,
            onPriorityChanged: onPriorityChanged,
            onCategoryChanged: onCategoryChanged,
            onCreateGoal: onCreateGoal,
          ),
          if (isProcessing) ...[
            const SizedBox(height: 14),
            ProcessingProgressCard(
                progress: processingProgress, label: 'Creating your task plan'),
          ],
          const SizedBox(height: 22),
          _ActiveGoalsSection(
            goals: goals,
            today: today,
            onDeleteGoal: onDeleteGoal,
            onEditGoalDeadline: onEditGoalDeadline,
            onEditGoalPriority: onEditGoalPriority,
            onCreateFirstGoal: onCreateFirstGoal,
          ),
        ],
      ),
    );
  }
}

class _CreateGoalCard extends StatelessWidget {
  const _CreateGoalCard({
    required this.today,
    required this.goalController,
    required this.deadline,
    required this.priority,
    required this.category,
    required this.isProcessing,
    required this.onDeadlinePick,
    required this.onPriorityChanged,
    required this.onCategoryChanged,
    required this.onCreateGoal,
  });

  final DateTime today;
  final TextEditingController goalController;
  final DateTime deadline;
  final int priority;
  final String category;
  final bool isProcessing;
  final VoidCallback onDeadlinePick;
  final ValueChanged<int> onPriorityChanged;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onCreateGoal;

  String get _priorityLabel {
    if (priority <= 2) return 'Low';
    if (priority >= 4) return 'High';
    return 'Medium';
  }

  @override
  Widget build(BuildContext context) {
    final deadlineDays = daysBetween(today, deadline).clamp(1, 3650).toInt();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gdPrimarySoft.withValues(alpha: 0.86),
            gdSurface,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: gdBorder),
        boxShadow: [
          BoxShadow(
            color: gdShadow.withValues(alpha: 0.10),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: gdSurface.withValues(alpha: 0.82),
                    shape: BoxShape.circle,
                    border: Border.all(color: gdBorder),
                    boxShadow: [
                      BoxShadow(
                        color: gdPrimary.withValues(alpha: 0.10),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.track_changes_rounded,
                          color: gdPrimary, size: 34),
                      Positioned(
                        top: 8,
                        left: 10,
                        child: Icon(Icons.auto_awesome_rounded,
                            color: gdPrimary.withValues(alpha: 0.38), size: 10),
                      ),
                      Positioned(
                        bottom: 9,
                        right: 9,
                        child: Icon(Icons.auto_awesome_rounded,
                            color: gdPrimary.withValues(alpha: 0.42), size: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create a goal',
                        style: TextStyle(
                          color: gdInk,
                          fontSize: 26,
                          height: 1.04,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Choose a deadline first. The planner will break your goal into realistic tasks you can review before scheduling.',
                        style: TextStyle(
                          color: gdMuted,
                          fontSize: 13,
                          height: 1.32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _FieldLabel('Deadline'),
            const SizedBox(height: 7),
            _GoalInputShell(
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onDeadlinePick,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_available_rounded,
                          color: gdPrimary, size: 21),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Deadline: ${shortDate(deadline)}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: gdPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const _FieldLabel('Goal'),
            const SizedBox(height: 7),
            _GoalInputShell(
              child: TextField(
                controller: goalController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onCreateGoal(),
                style: TextStyle(
                  color: gdInk,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: 'Example: Prepare for physics final',
                  hintStyle: TextStyle(
                    color: gdHint,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const _FieldLabel('Category'),
            const SizedBox(height: 7),
            _CategoryTileGrid(
              selected: category,
              onChanged: onCategoryChanged,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const _FieldLabel('Priority'),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: gdPrimarySoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _priorityLabel,
                    style: TextStyle(
                      color: gdPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _GoalPriorityStars(
              value: priority,
              onChanged: onPriorityChanged,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
              decoration: BoxDecoration(
                color: gdPrimarySoft.withValues(alpha: 0.58),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: gdPrimary.withValues(alpha: 0.18)),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: gdPrimary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Suggested breakdown',
                          style: TextStyle(
                            color: gdInk,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '5-6 focused tasks over $deadlineDays day${deadlineDays == 1 ? '' : 's'}',
                          style: TextStyle(
                            color: gdMuted,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _GeneratePlanButton(
              isProcessing: isProcessing,
              onPressed: onCreateGoal,
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: gdInk,
        fontSize: 15,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _GoalInputShell extends StatelessWidget {
  const _GoalInputShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: gdSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gdBorderStrong.withValues(alpha: 0.58)),
        boxShadow: [
          BoxShadow(
            color: gdShadow.withValues(alpha: 0.055),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CategoryTileGrid extends StatelessWidget {
  const _CategoryTileGrid({
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 330
            ? 3
            : constraints.maxWidth >= 250
                ? 2
                : 1;
        final gap = columns == 1 ? 8.0 : 8.0;
        final tileWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - (gap * (columns - 1))) / columns;
        final compactTile = tileWidth < 132;
        return Wrap(
          spacing: gap,
          runSpacing: 8,
          children: [
            for (final item in categories)
              SizedBox(
                width: tileWidth,
                child: _CategoryTile(
                  label: item,
                  selected: selected == item,
                  compact: compactTile,
                  onTap: () => onChanged(item),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon =
        selected ? Icons.check_circle_rounded : GdCategory.iconFor(label);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          height: compact ? 50 : 52,
          padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 16),
          decoration: BoxDecoration(
            color: selected ? gdPrimary : gdSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  selected ? gdPrimary : gdBorderStrong.withValues(alpha: 0.62),
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? gdPrimary.withValues(alpha: 0.22)
                    : gdShadow.withValues(alpha: 0.045),
                blurRadius: selected ? 16 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: compact
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: selected ? Colors.white : gdPrimary,
                      size: 19,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white : gdInk,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Icon(
                      icon,
                      color: selected ? Colors.white : gdPrimary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selected ? Colors.white : gdInk,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
        ),
      ),
    );
  }
}

class _GeneratePlanButton extends StatelessWidget {
  const _GeneratePlanButton({
    required this.isProcessing,
    required this.onPressed,
  });

  final bool isProcessing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = !isProcessing;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: enabled ? 1 : 0.62,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: enabled ? onPressed : null,
          child: Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [gdPrimary, gdPrimaryDark],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: gdPrimary.withValues(alpha: 0.24),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  isProcessing ? 'Generating...' : 'Generate my plan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalPriorityStars extends StatelessWidget {
  const _GoalPriorityStars({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final star = index + 1;
        final selected = star <= value;
        return IconButton(
          tooltip: 'Priority $star',
          onPressed: () => onChanged(star),
          constraints: const BoxConstraints(minWidth: 46, minHeight: 46),
          padding: EdgeInsets.zero,
          icon: Icon(
            selected ? Icons.star_rounded : Icons.star_border_rounded,
            color: selected ? gdStarGold : gdHint.withValues(alpha: 0.68),
            size: 33,
          ),
        );
      }),
    );
  }
}

class _ActiveGoalsSection extends StatefulWidget {
  const _ActiveGoalsSection({
    required this.goals,
    required this.today,
    required this.onDeleteGoal,
    required this.onEditGoalDeadline,
    required this.onEditGoalPriority,
    required this.onCreateFirstGoal,
  });

  final List<GoalProject> goals;
  final DateTime today;
  final ValueChanged<GoalProject> onDeleteGoal;
  final ValueChanged<GoalProject> onEditGoalDeadline;
  final ValueChanged<GoalProject> onEditGoalPriority;
  final VoidCallback onCreateFirstGoal;

  @override
  State<_ActiveGoalsSection> createState() => _ActiveGoalsSectionState();
}

class _ActiveGoalsSectionState extends State<_ActiveGoalsSection> {
  static const _collapsedCount = 4;
  final TextEditingController _searchController = TextEditingController();
  bool _showAll = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesGoalSearch(GoalProject goal, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;
    return goal.title.toLowerCase().contains(normalizedQuery) ||
        goal.category.toLowerCase().contains(normalizedQuery);
  }

  @override
  Widget build(BuildContext context) {
    final allGoals = [...widget.goals]..sort((a, b) {
        final aDone = a.progress >= 1;
        final bDone = b.progress >= 1;
        if (aDone != bDone) return aDone ? 1 : -1;
        return a.deadline.compareTo(b.deadline);
      });
    final query = _searchQuery.trim().toLowerCase();
    final goals = query.isEmpty
        ? allGoals
        : allGoals
            .where((goal) => _matchesGoalSearch(goal, query))
            .toList(growable: false);
    final activeCount = allGoals.where((goal) => goal.progress < 1).length;
    final visibleCount = _showAll || goals.length <= _collapsedCount
        ? goals.length
        : _collapsedCount;
    final hiddenCount = goals.length - visibleCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Active goals', style: GdText.headlineMedium)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: gdPrimarySoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$activeCount active',
                style: TextStyle(
                  color: gdPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          allGoals.length <= _collapsedCount
              ? 'Tap a goal to review its schedule.'
              : 'Showing the nearest goals first. Expand only the ones you need.',
          style: TextStyle(
            color: gdMuted,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _showAll = false;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search goals',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _showAll = false;
                      });
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        if (allGoals.isEmpty)
          EmptyStateCard(
            icon: Icons.flag_circle_rounded,
            title: 'No goals yet',
            message:
                'Create your first project and Goal Digger will turn it into small, scheduled actions.',
            cta: 'Create your first project',
            onPressed: widget.onCreateFirstGoal,
          )
        else if (goals.isEmpty)
          AppCard(
            color: gdCardLight,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: gdPrimarySoft,
                    child: Icon(Icons.search_off_rounded, color: gdPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('No matching goals', style: GdText.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          'Try a different goal title or category.',
                          style: TextStyle(
                            color: gdMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                for (final goal in goals.take(visibleCount))
                  _ActiveGoalTile(
                    key: ValueKey(goal.id),
                    goal: goal,
                    today: widget.today,
                    onDelete: () => widget.onDeleteGoal(goal),
                    onEditDeadline: () => widget.onEditGoalDeadline(goal),
                    onEditPriority: () => widget.onEditGoalPriority(goal),
                  ),
              ],
            ),
          ),
          if (goals.length > _collapsedCount)
            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                onPressed: () => setState(() => _showAll = !_showAll),
                icon: Icon(_showAll
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded),
                label: Text(
                  _showAll
                      ? 'Show fewer goals'
                      : 'Show $hiddenCount more goal${hiddenCount == 1 ? '' : 's'}',
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _ActiveGoalTile extends StatelessWidget {
  const _ActiveGoalTile({
    super.key,
    required this.goal,
    required this.today,
    required this.onDelete,
    required this.onEditDeadline,
    required this.onEditPriority,
  });

  final GoalProject goal;
  final DateTime today;
  final VoidCallback onDelete;
  final VoidCallback onEditDeadline;
  final VoidCallback onEditPriority;

  String get _priorityLabel {
    if (goal.importance >= 4) return 'High priority';
    if (goal.importance <= 2) return 'Low priority';
    return 'Medium priority';
  }

  IconData get _priorityIcon {
    if (goal.importance >= 4) return Icons.priority_high_rounded;
    if (goal.importance <= 2) return Icons.low_priority_rounded;
    return Icons.star_half_rounded;
  }

  Color get _priorityColor {
    if (goal.importance >= 4) return gdWarning;
    if (goal.importance <= 2) return gdMuted;
    return gdPrimary;
  }

  Color get _prioritySurface {
    if (goal.importance >= 4) return gdWarningSoft;
    if (goal.importance <= 2) return gdCardLight;
    return gdPrimarySoft;
  }

  @override
  Widget build(BuildContext context) {
    final completed = goal.tasks.where((task) => task.done).length;
    final daysLeft = daysBetween(today, goal.deadline);
    final overdue = daysLeft < 0;
    final dueSoon = !overdue && daysLeft <= 2;
    final complete = goal.progress >= 1;
    final previewTasks = goal.tasks.take(5).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: gdSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: complete
              ? gdSuccess.withValues(alpha: 0.22)
              : gdBorderStrong.withValues(alpha: 0.54),
        ),
        boxShadow: [
          BoxShadow(
            color: gdShadow.withValues(alpha: 0.055),
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
                key: PageStorageKey('goal-${goal.id}'),
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
                    color: complete ? gdMuted : gdInk,
                    height: 1.16,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _GoalMetaPill(
                        icon: GdCategory.iconFor(goal.category),
                        label: goal.category,
                        color: gdPrimary,
                        surface: gdPrimarySoft,
                      ),
                      _GoalMetaPill(
                        icon: _priorityIcon,
                        label: _priorityLabel,
                        color: _priorityColor,
                        surface: _prioritySurface,
                      ),
                      _GoalMetaPill(
                        icon: overdue
                            ? Icons.warning_amber_rounded
                            : Icons.event_rounded,
                        label: overdue ? 'Overdue' : '$daysLeft days left',
                        color: overdue || dueSoon ? gdWarning : gdMuted,
                        surface:
                            overdue || dueSoon ? gdWarningSoft : gdCardLight,
                      ),
                      _GoalMetaPill(
                        icon: Icons.task_alt_rounded,
                        label: '$completed/${goal.tasks.length}',
                        color: complete ? gdSuccess : gdMuted,
                        surface: complete ? gdSuccessSoft : gdCardLight,
                      ),
                    ],
                  ),
                ),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: onEditDeadline,
                        icon: const Icon(Icons.event_rounded, size: 18),
                        label: const Text('Deadline'),
                      ),
                      OutlinedButton.icon(
                        onPressed: onEditPriority,
                        icon: const Icon(Icons.star_rounded, size: 18),
                        label: const Text('Priority'),
                      ),
                      OutlinedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Remove'),
                        style:
                            OutlinedButton.styleFrom(foregroundColor: gdError),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (previewTasks.isEmpty)
                    Text(
                      'No tasks scheduled yet.',
                      style: TextStyle(
                          color: gdMuted, fontWeight: FontWeight.w700),
                    )
                  else
                    Column(
                      children: [
                        for (final task in previewTasks)
                          _GoalTaskPreviewRow(task: task),
                        if (goal.tasks.length > previewTasks.length)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '+${goal.tasks.length - previewTasks.length} more tasks',
                              style: TextStyle(
                                color: gdMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
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

class _GoalMetaPill extends StatelessWidget {
  const _GoalMetaPill({
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

class _GoalTaskPreviewRow extends StatelessWidget {
  const _GoalTaskPreviewRow({required this.task});

  final MicroTask task;

  @override
  Widget build(BuildContext context) {
    final done = task.done;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: done ? gdSuccessSoft.withValues(alpha: 0.46) : gdCardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: done
              ? gdSuccess.withValues(alpha: 0.18)
              : task.load.color.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 26,
            decoration: BoxDecoration(
              color: done
                  ? gdSuccess.withValues(alpha: 0.52)
                  : task.load.color.withValues(alpha: 0.52),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            done ? Icons.check_circle_rounded : task.load.icon,
            color: done ? gdSuccess : task.load.color,
            size: 17,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: done ? gdMuted.withValues(alpha: 0.70) : gdInk,
                decoration: done ? TextDecoration.lineThrough : null,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            shortDate(task.scheduledDate),
            style: TextStyle(
              color: gdMuted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
