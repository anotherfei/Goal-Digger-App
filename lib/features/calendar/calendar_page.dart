import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/gd_design.dart';
import '../../core/utils/date_helpers.dart';
import '../../models/models.dart';
import '../../shared/widgets/shared_widgets.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({
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
  final Future<void> Function(MicroTask task, GoalProject goal) onSyncTaskToGoogle;
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
    while (cells.length % 7 != 0) cells.add(null);
    return cells;
  }

  List<MicroTask> _tasksForDay(DateTime date) {
    final day = dateOnly(date);
    return widget.tasks
        .where((task) => dateOnly(task.scheduledDate) == day)
        .toList()
      ..sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
  }

  int _taskCountForDay(DateTime date) => _tasksForDay(date).length;

  @override
  Widget build(BuildContext context) {
    final monthTasks = widget.tasks
        .where((task) =>
            task.scheduledDate.year == _visibleMonth.year &&
            task.scheduledDate.month == _visibleMonth.month)
        .toList();
    final completedThisMonth = monthTasks.where((task) => task.done).length;
    final selectedTasks = _tasksForDay(_selectedDate);

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
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                        '${monthTasks.length} tasks · $completedThisMonth done',
                        style: const TextStyle(
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
                        taskCount: _taskCountForDay(date),
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
                    backgroundColor: selectedTasks.isEmpty
                        ? gdBorder
                        : gdPrimarySoft,
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
                          selectedTasks.isEmpty
                              ? 'No goals scheduled on this date.'
                              : '${selectedTasks.length} scheduled goal actions. Open Home to check them off.',
                          style: const TextStyle(
                              color: gdMuted, fontWeight: FontWeight.w800))
                    ])),
              ]),
            ),
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
          const SizedBox(height: 12),
          if (selectedTasks.isEmpty)
            EmptyStateCard(
                icon: Icons.event_available_rounded,
                title: 'No goals on this date',
                message:
                    'Pick another date with a dot, or create a new goal and Goal Digger will schedule it for you.',
                cta: 'Create goal',
                onPressed: widget.onCreateGoal)
          else
            ...selectedTasks.map((task) {
              final goal = widget.goalForTask(task);

              return _CalendarTaskDetailTile(
                task: task,
                goal: goal,
              );
            }),
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
                    const Text(
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
                            if (value != null)
                              setState(() => _routineRepeat = value);
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

class _CalendarTaskDetailTile extends StatelessWidget {
  const _CalendarTaskDetailTile({
    required this.task,
    required this.goal,
  });

  final MicroTask task;
  final GoalProject goal;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        minVerticalPadding: 12,
        leading: CircleAvatar(
          backgroundColor: task.load.softColor,
          child: Icon(task.load.icon, color: task.load.color),
        ),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${goal.title} · ${shortDate(task.scheduledDate)} · ${task.durationMinutes} min · ${task.load.label}',
          style: const TextStyle(
            color: gdMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
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
        leading: const CircleAvatar(
            backgroundColor: gdPrimarySoft,
            child: Icon(Icons.repeat_rounded, color: gdPrimary)),
        title: Text(routine.title,
            style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(
            '${longDate(routine.startsAt)} · $time · ${routine.repeat.label}',
            style:
                const TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
        trailing: onDelete == null
            ? null
            : IconButton(
                tooltip: 'Delete routine',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, color: gdError),
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
          style: const TextStyle(
            color: gdMuted,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final hasTasks = taskCount > 0;
    final allDone = hasTasks && completedCount == taskCount;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: selected
              ? gdPrimary
              : hasTasks
                  ? gdPrimarySoft
                  : gdCardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: today
                ? gdWarning
                : selected
                    ? gdPrimary
                    : gdBorder,
            width: today || selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                color: selected ? gdOnDark : gdInk,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            if (hasTasks)
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: selected
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
    );
  }
}

class _CalendarStatCard extends StatelessWidget {
  const _CalendarStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: gdPrimarySoft,
              child: Icon(icon, color: gdPrimary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                        color: gdMuted, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
