import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/gd_design.dart';
import '../../core/utils/date_helpers.dart';
import '../../models/models.dart';
import '../../shared/widgets/shared_widgets.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({
    super.key,
    required this.tasks,
    required this.routines,
    required this.goalForTask,
    required this.today,
    required this.onCreateGoal,
    required this.onAddRoutine,
    required this.onDeleteRoutine,
    required this.onSyncTaskToGoogle,
    required this.onSyncAllTasksToGoogle,
  });

  final List<MicroTask> tasks;
  final List<RoutineItem> routines;
  final GoalProject Function(MicroTask task) goalForTask;
  final DateTime today;
  final VoidCallback onCreateGoal;
  final ValueChanged<RoutineItem> onAddRoutine;
  final ValueChanged<RoutineItem> onDeleteRoutine;
  final Future<void> Function(MicroTask task, GoalProject goal)
      onSyncTaskToGoogle;
  final Future<void> Function() onSyncAllTasksToGoogle;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _visibleMonth;
  late DateTime _selectedDate;
  final TextEditingController _routineController = TextEditingController();
  DateTime _routineDate = DateTime.now();
  TimeOfDay _routineTime = const TimeOfDay(hour: 8, minute: 0);
  RoutineRepeat _routineRepeat = RoutineRepeat.daily;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(widget.today.year, widget.today.month);
    _selectedDate = widget.today;
    _routineDate = widget.today;
  }

  @override
  void dispose() {
    _routineController.dispose();
    super.dispose();
  }

  Future<void> _pickRoutineDate() async {
    final picked = await showDatePicker(
        context: context,
        initialDate: _routineDate,
        firstDate: DateTime(widget.today.year - 1),
        lastDate: DateTime(widget.today.year + 5));
    if (picked != null) setState(() => _routineDate = picked);
  }

  Future<void> _pickRoutineTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: _routineTime);
    if (picked != null) setState(() => _routineTime = picked);
  }

  void _addRoutine() {
    final routine = _routineController.text.trim();
    if (routine.isEmpty) return;
    widget.onAddRoutine(RoutineItem(
      title: routine,
      startsAt: DateTime(_routineDate.year, _routineDate.month,
          _routineDate.day, _routineTime.hour, _routineTime.minute),
      repeat: _routineRepeat,
    ));
    _routineController.clear();
  }

  void _viewAllRoutines() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RoutinesListPage(
          routines: widget.routines,
          onDeleteRoutine: widget.onDeleteRoutine,
        ),
      ),
    );
  }

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth =
          DateTime(_visibleMonth.year, _visibleMonth.month + offset);
      final daysInNewMonth =
          DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
      _selectedDate = DateTime(_visibleMonth.year, _visibleMonth.month,
          min(_selectedDate.day, daysInNewMonth));
    });
  }

  List<DateTime?> _buildMonthCells() {
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month);
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leadingEmptyCells = firstDay.weekday % 7;
    final cells = <DateTime?>[
      ...List<DateTime?>.filled(leadingEmptyCells, null),
      for (var day = 1; day <= daysInMonth; day++)
        DateTime(_visibleMonth.year, _visibleMonth.month, day)
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }

  List<MicroTask> _tasksForDay(DateTime date) {
    final day = dateOnly(date);
    return widget.tasks
        .where((task) => dateOnly(task.scheduledDate) == day)
        .toList()
      ..sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
  }

  List<RoutineItem> _routinesForDay(DateTime date) {
    final day = dateOnly(date);
    return widget.routines.where((routine) {
      final startDay = dateOnly(routine.startsAt);
      if (day.isBefore(startDay)) return false;
      switch (routine.repeat) {
        case RoutineRepeat.daily:
          return true;
        case RoutineRepeat.weekly:
          return routine.startsAt.weekday == date.weekday;
        case RoutineRepeat.monthly:
          return routine.startsAt.day == date.day;
        case RoutineRepeat.yearly:
          return routine.startsAt.month == date.month &&
              routine.startsAt.day == date.day;
        case RoutineRepeat.custom:
          return startDay == day;
      }
    }).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  }

  int _taskCountForDay(DateTime date) => _tasksForDay(date).length;
  int _routineCountForDay(DateTime date) => _routinesForDay(date).length;

  @override
  Widget build(BuildContext context) {
    final monthTasks = widget.tasks
        .where((task) =>
            task.scheduledDate.year == _visibleMonth.year &&
            task.scheduledDate.month == _visibleMonth.month)
        .toList();
    final completedThisMonth = monthTasks.where((task) => task.done).length;
    final selectedTasks = _tasksForDay(_selectedDate);
    final selectedRoutines = _routinesForDay(_selectedDate);

    return PageScaffold(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          18,
          14,
          18,
          GoalShellInsets.bottomOf(context),
        ),
        children: [
          //const PageHero(icon: Icons.calendar_month_rounded, title: 'Calendar', subtitle: 'View scheduled goal tasks and add flexible routines. Tasks are view-only here.', compact: true),
          const SizedBox(height: 18),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(children: [
                Row(children: [
                  IconButton.filledTonal(
                      onPressed: () => _changeMonth(-1),
                      icon: const Icon(Icons.chevron_left_rounded)),
                  Expanded(
                      child: Column(children: [
                    Text(
                        '${monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                        textAlign: TextAlign.center,
                        style: GdText.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                        '${monthTasks.length} tasks · $completedThisMonth done',
                        style: TextStyle(
                            color: gdMuted, fontWeight: FontWeight.w800))
                  ])),
                  IconButton.filledTonal(
                      onPressed: () => _changeMonth(1),
                      icon: const Icon(Icons.chevron_right_rounded)),
                ]),
                const SizedBox(height: 16),
                const Row(children: [
                  _WeekdayLabel('S'),
                  _WeekdayLabel('M'),
                  _WeekdayLabel('T'),
                  _WeekdayLabel('W'),
                  _WeekdayLabel('T'),
                  _WeekdayLabel('F'),
                  _WeekdayLabel('S')
                ]),
                const SizedBox(height: 8),
                GridView.builder(
                  itemCount: _buildMonthCells().length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8),
                  itemBuilder: (context, index) {
                    final date = _buildMonthCells()[index];
                    if (date == null) return const SizedBox.shrink();
                    return _CalendarDayCell(
                        date: date,
                        taskCount:
                            _taskCountForDay(date) + _routineCountForDay(date),
                        completedCount: _tasksForDay(date)
                            .where((task) => task.done)
                            .length,
                        selected: dateOnly(date) == dateOnly(_selectedDate),
                        today: dateOnly(date) == widget.today,
                        onTap: () => setState(() => _selectedDate = date));
                  },
                ),
              ]),
            ),
          ),
          const SizedBox(height: 18),
          AppCard(
            color: gdWarningSoft,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                CircleAvatar(
                    backgroundColor:
                        selectedTasks.isEmpty ? gdBorder : gdPrimarySoft,
                    child: Icon(
                        selectedTasks.isEmpty
                            ? Icons.event_available_rounded
                            : Icons.task_alt_rounded,
                        color: selectedTasks.isEmpty ? gdMuted : gdPrimary)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(longDate(_selectedDate),
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 16)),
                      const SizedBox(height: 3),
                      Text(
                          selectedTasks.isEmpty && selectedRoutines.isEmpty
                              ? 'No goals or routines scheduled on this date.'
                              : '${selectedTasks.length} task${selectedTasks.length == 1 ? '' : 's'} and ${selectedRoutines.length} routine${selectedRoutines.length == 1 ? '' : 's'} on this date.',
                          style: TextStyle(
                              color: gdMuted, fontWeight: FontWeight.w800))
                    ])),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          _CalendarDayAgenda(
            tasks: selectedTasks,
            routines: selectedRoutines,
            goalForTask: widget.goalForTask,
            onCreateGoal: widget.onCreateGoal,
            onSyncTaskToGoogle: widget.onSyncTaskToGoogle,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: widget.onSyncAllTasksToGoogle,
              icon: const Icon(Icons.sync_rounded),
              label: const Text('Sync all tasks to Google Calendar'),
            ),
          ),
          const SizedBox(height: 18),
          SectionTitle(
              title: 'Routines', trailing: '${widget.routines.length}'),
          const SizedBox(height: 10),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add a routine',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(
                        'Choose the name, date, time, and repeat pattern yourself.',
                        style: TextStyle(
                            color: gdMuted, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    TextField(
                        controller: _routineController,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                            labelText: 'Routine name',
                            hintText: 'Example: 25-minute coding review'),
                        onSubmitted: (_) => _addRoutine()),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      OutlinedButton.icon(
                          onPressed: _pickRoutineDate,
                          icon: const Icon(Icons.event_rounded),
                          label: Text(longDate(_routineDate))),
                      OutlinedButton.icon(
                          onPressed: _pickRoutineTime,
                          icon: const Icon(Icons.schedule_rounded),
                          label: Text(_routineTime.format(context))),
                      DropdownMenu<RoutineRepeat>(
                          initialSelection: _routineRepeat,
                          label: const Text('Repeat'),
                          onSelected: (value) {
                            if (value != null) {
                              setState(() => _routineRepeat = value);
                            }
                          },
                          dropdownMenuEntries: [
                            for (final repeat in RoutineRepeat.values)
                              DropdownMenuEntry(
                                  value: repeat, label: repeat.label)
                          ]),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: FilledButton.icon(
                              onPressed: _addRoutine,
                              icon: const Icon(Icons.add_task_rounded),
                              label: const Text('Add routine'))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: OutlinedButton.icon(
                              onPressed: _viewAllRoutines,
                              icon: const Icon(Icons.view_list_rounded),
                              label: const Text('View routines'))),
                    ]),
                    const SizedBox(height: 12),
                    for (final routine in widget.routines.take(3))
                      RoutineTile(
                        routine: routine,
                        onDelete: () => widget.onDeleteRoutine(routine),
                      ),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarDayAgenda extends StatefulWidget {
  const _CalendarDayAgenda({
    required this.tasks,
    required this.routines,
    required this.goalForTask,
    required this.onCreateGoal,
    required this.onSyncTaskToGoogle,
  });

  final List<MicroTask> tasks;
  final List<RoutineItem> routines;
  final GoalProject Function(MicroTask task) goalForTask;
  final VoidCallback onCreateGoal;
  final Future<void> Function(MicroTask task, GoalProject goal)
      onSyncTaskToGoogle;

  @override
  State<_CalendarDayAgenda> createState() => _CalendarDayAgendaState();
}

class _CalendarDayAgendaState extends State<_CalendarDayAgenda> {
  static const _collapsedGoalCount = 3;
  bool _showAllGoals = false;

  List<_CalendarGoalGroup> _groups() {
    final groups = <_CalendarGoalGroup>[];
    for (final task in widget.tasks) {
      final goal = widget.goalForTask(task);
      final existing = groups.where((group) => group.goal.id == goal.id);
      if (existing.isNotEmpty) {
        existing.first.tasks.add(task);
      } else {
        groups.add(_CalendarGoalGroup(goal: goal, tasks: [task]));
      }
    }
    groups.sort((a, b) => a.goal.deadline.compareTo(b.goal.deadline));
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty && widget.routines.isEmpty) {
      return EmptyStateCard(
        icon: Icons.event_available_rounded,
        title: 'No goals on this date',
        message:
            'Pick another date with a dot, or create a new goal and Goal Digger will schedule it for you.',
        cta: 'Create goal',
        onPressed: widget.onCreateGoal,
      );
    }

    final groups = _groups();
    final visibleGoalCount =
        _showAllGoals || groups.length <= _collapsedGoalCount
            ? groups.length
            : _collapsedGoalCount;
    final hiddenGoalCount = groups.length - visibleGoalCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Day agenda', style: GdText.headlineMedium)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: gdPrimarySoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${groups.length} goal${groups.length == 1 ? '' : 's'} · ${widget.routines.length} routine${widget.routines.length == 1 ? '' : 's'}',
                style: TextStyle(
                  color: gdPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (widget.routines.isNotEmpty) ...[
          _FixedCommitmentsCard(routines: widget.routines),
          const SizedBox(height: 10),
        ],
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              for (final group in groups.take(visibleGoalCount))
                _CalendarGoalAgendaCard(
                  group: group,
                  onSyncTaskToGoogle: widget.onSyncTaskToGoogle,
                ),
            ],
          ),
        ),
        if (groups.length > _collapsedGoalCount)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _showAllGoals = !_showAllGoals),
              icon: Icon(_showAllGoals
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded),
              label: Text(
                _showAllGoals
                    ? 'Show fewer goals'
                    : 'Show $hiddenGoalCount more goal${hiddenGoalCount == 1 ? '' : 's'}',
              ),
            ),
          ),
      ],
    );
  }
}

class _CalendarGoalGroup {
  _CalendarGoalGroup({required this.goal, required this.tasks});

  final GoalProject goal;
  final List<MicroTask> tasks;
}

class _FixedCommitmentsCard extends StatelessWidget {
  const _FixedCommitmentsCard({required this.routines});

  final List<RoutineItem> routines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: gdFocusSoft.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gdFocus.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: gdSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.event_busy_rounded, size: 18, color: gdFocus),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fixed commitments',
                      style: TextStyle(
                        color: gdInk,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tasks should be planned around these blocks.',
                      style: TextStyle(
                        color: gdMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final routine in routines) _RoutineCommitmentRow(routine),
        ],
      ),
    );
  }
}

class _RoutineCommitmentRow extends StatelessWidget {
  const _RoutineCommitmentRow(this.routine);

  final RoutineItem routine;

  @override
  Widget build(BuildContext context) {
    final time =
        TimeOfDay(hour: routine.startsAt.hour, minute: routine.startsAt.minute)
            .format(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: gdSurface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gdBorder.withValues(alpha: 0.72)),
      ),
      child: Row(
        children: [
          Icon(Icons.repeat_rounded, size: 18, color: gdFocus),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              routine.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: gdInk,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$time · ${routine.repeat.label}',
            style: TextStyle(
              color: gdMuted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarGoalAgendaCard extends StatelessWidget {
  const _CalendarGoalAgendaCard({
    required this.group,
    required this.onSyncTaskToGoogle,
  });

  final _CalendarGoalGroup group;
  final Future<void> Function(MicroTask task, GoalProject goal)
      onSyncTaskToGoogle;

  @override
  Widget build(BuildContext context) {
    final goal = group.goal;
    final completed = group.tasks.where((task) => task.done).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: gdSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gdBorderStrong.withValues(alpha: 0.50)),
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
                key: PageStorageKey('calendar-goal-${goal.id}'),
                initiallyExpanded: true,
                tilePadding: const EdgeInsets.fromLTRB(14, 10, 12, 8),
                childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                title: Text(
                  goal.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: gdInk,
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
                      _CalendarAgendaPill(
                        icon: GdCategory.iconFor(goal.category),
                        label: goal.category,
                        color: gdPrimary,
                        surface: gdPrimarySoft,
                      ),
                      _CalendarAgendaPill(
                        icon: Icons.task_alt_rounded,
                        label: '$completed/${group.tasks.length} done',
                        color: completed == group.tasks.length
                            ? gdSuccess
                            : gdMuted,
                        surface: completed == group.tasks.length
                            ? gdSuccessSoft
                            : gdCardLight,
                      ),
                      _CalendarAgendaPill(
                        icon: Icons.event_rounded,
                        label: 'Due ${shortDate(goal.deadline)}',
                        color: gdMuted,
                        surface: gdCardLight,
                      ),
                    ],
                  ),
                ),
                children: [
                  _CalendarAgendaTaskList(
                    tasks: group.tasks,
                    goal: goal,
                    onSyncTaskToGoogle: onSyncTaskToGoogle,
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

class _CalendarAgendaPill extends StatelessWidget {
  const _CalendarAgendaPill({
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

class _CalendarAgendaTaskList extends StatefulWidget {
  const _CalendarAgendaTaskList({
    required this.tasks,
    required this.goal,
    required this.onSyncTaskToGoogle,
  });

  final List<MicroTask> tasks;
  final GoalProject goal;
  final Future<void> Function(MicroTask task, GoalProject goal)
      onSyncTaskToGoogle;

  @override
  State<_CalendarAgendaTaskList> createState() =>
      _CalendarAgendaTaskListState();
}

class _CalendarAgendaTaskListState extends State<_CalendarAgendaTaskList> {
  static const _collapsedCount = 4;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final visibleCount = _showAll || widget.tasks.length <= _collapsedCount
        ? widget.tasks.length
        : _collapsedCount;
    final hiddenCount = widget.tasks.length - visibleCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              for (final task in widget.tasks.take(visibleCount))
                _CalendarAgendaTaskRow(
                  task: task,
                  goal: widget.goal,
                  onSyncTaskToGoogle: widget.onSyncTaskToGoogle,
                ),
            ],
          ),
        ),
        if (widget.tasks.length > _collapsedCount)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _showAll = !_showAll),
              icon: Icon(_showAll
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded),
              label: Text(
                _showAll
                    ? 'Show fewer tasks'
                    : 'Show $hiddenCount more task${hiddenCount == 1 ? '' : 's'}',
              ),
            ),
          ),
      ],
    );
  }
}

class _CalendarAgendaTaskRow extends StatelessWidget {
  const _CalendarAgendaTaskRow({
    required this.task,
    required this.goal,
    required this.onSyncTaskToGoogle,
  });

  final MicroTask task;
  final GoalProject goal;
  final Future<void> Function(MicroTask task, GoalProject goal)
      onSyncTaskToGoogle;

  @override
  Widget build(BuildContext context) {
    final done = task.done;
    final textColor = done ? gdMuted.withValues(alpha: 0.58) : gdInk;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 9, 8, 9),
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
          const SizedBox(width: 9),
          Icon(
            done ? Icons.check_circle_rounded : task.load.icon,
            color: done ? gdSuccess : task.load.color,
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
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
                    color: gdMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sync task to Google Calendar',
            onPressed: () => onSyncTaskToGoogle(task, goal),
            icon: Icon(Icons.calendar_month_rounded, color: gdPrimary),
          ),
        ],
      ),
    );
  }
}

class RoutinesListPage extends StatelessWidget {
  const RoutinesListPage({
    super.key,
    required this.routines,
    required this.onDeleteRoutine,
  });
  final List<RoutineItem> routines;
  final ValueChanged<RoutineItem> onDeleteRoutine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All routines')),
      body: PageScaffold(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          children: routines.isEmpty
              ? [
                  EmptyStateCard(
                      icon: Icons.repeat_rounded,
                      title: 'No routines yet',
                      message: 'Add routines from Calendar first.',
                      cta: 'Back to calendar',
                      onPressed: () => Navigator.of(context).pop())
                ]
              : [
                  for (final routine in routines)
                    RoutineTile(
                      routine: routine,
                      onDelete: () => onDeleteRoutine(routine),
                    ),
                ],
        ),
      ),
    );
  }
}

class RoutineTile extends StatelessWidget {
  const RoutineTile({super.key, required this.routine, this.onDelete});
  final RoutineItem routine;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final time =
        TimeOfDay(hour: routine.startsAt.hour, minute: routine.startsAt.minute)
            .format(context);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: gdPrimarySoft,
            child: Icon(Icons.repeat_rounded, color: gdPrimary)),
        title: Text(routine.title,
            style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(
            '${longDate(routine.startsAt)} · $time · ${routine.repeat.label}',
            style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
        trailing: onDelete == null
            ? null
            : IconButton(
                tooltip: 'Delete routine',
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline_rounded, color: gdError),
              ),
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: gdMuted,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CalendarDayCell extends StatefulWidget {
  const _CalendarDayCell({
    required this.date,
    required this.taskCount,
    required this.completedCount,
    required this.selected,
    required this.today,
    required this.onTap,
  });

  final DateTime date;
  final int taskCount;
  final int completedCount;
  final bool selected;
  final bool today;
  final VoidCallback onTap;

  @override
  State<_CalendarDayCell> createState() => _CalendarDayCellState();
}

class _CalendarDayCellState extends State<_CalendarDayCell> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final hasTasks = widget.taskCount > 0;
    final allDone = hasTasks && widget.completedCount == widget.taskCount;
    final lift = _hovered || widget.selected;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: AnimatedScale(
        scale: _pressed
            ? 0.94
            : _hovered
                ? 1.04
                : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: widget.selected
                  ? gdPrimary
                  : hasTasks
                      ? gdPrimarySoft
                      : _hovered
                          ? gdSurface
                          : gdCardLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.today
                    ? gdWarning
                    : widget.selected
                        ? gdPrimary
                        : _hovered
                            ? gdPrimary.withValues(alpha: 0.40)
                            : gdBorder,
                width: widget.today || widget.selected ? 2 : 1,
              ),
              boxShadow: lift
                  ? [
                      BoxShadow(
                        color: gdPrimary.withValues(
                            alpha: widget.selected ? 0.18 : 0.10),
                        blurRadius: widget.selected ? 18 : 12,
                        offset: Offset(0, widget.selected ? 8 : 5),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.date.day}',
                  style: TextStyle(
                    color: widget.selected ? gdOnDark : gdInk,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                if (hasTasks)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: widget.selected
                          ? gdOnDark
                          : allDone
                              ? gdPrimary
                              : gdWarning,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(height: 7),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
