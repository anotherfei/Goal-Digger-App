import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/constants/gd_constants.dart';
import '../../../core/theme/gd_design.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../models/models.dart';
import '../../../shared/widgets/shared_widgets.dart';

class FocusSessionConfig {
  const FocusSessionConfig({
    required this.task,
    required this.durationMinutes,
    required this.blockedApps,
    required this.blockUnrelatedApps,
  });

  final MicroTask? task;
  final int durationMinutes;
  final Set<String> blockedApps;
  final bool blockUnrelatedApps;

  String get title => task?.title ?? 'Custom focus session';

  String get blockingSummary {
    if (blockedApps.isEmpty) return 'No apps selected to block';
    if (blockUnrelatedApps && task != null) {
      return 'Blocking unrelated apps for this goal';
    }
    return 'Blocking selected apps';
  }
}

class FocusSetupSheet extends StatefulWidget {
  const FocusSetupSheet({
    super.key,
    required this.goals,
    required this.today,
  });

  final List<GoalProject> goals;
  final DateTime today;

  @override
  State<FocusSetupSheet> createState() => _FocusSetupSheetState();
}

class _FocusSetupSheetState extends State<FocusSetupSheet> {
  static const List<int> _durationPresets = [15, 25, 45, 60];
  static const List<String> _appOptions = [
    'Instagram',
    'TikTok',
    'YouTube',
    'Games',
    'Shopping',
    'Messages',
    'Browser',
    'Music',
  ];

  final TextEditingController _customDurationController = TextEditingController(text: '30');

  MicroTask? _selectedTask;
  int _selectedDuration = 25;
  bool _useCustomDuration = false;
  bool _blockUnrelatedApps = true;
  late Set<String> _blockedApps;

  @override
  void initState() {
    super.initState();
    final openTasks = _allOpenTasks();
    final todayTasks = openTasks
        .where((task) => dateOnly(task.scheduledDate) == dateOnly(widget.today))
        .toList();
    _selectedTask = todayTasks.isNotEmpty
        ? todayTasks.first
        : openTasks.isEmpty
            ? null
            : openTasks.first;
    _selectedDuration = _selectedTask?.durationMinutes ?? 25;
    _blockedApps = _selectedTask == null
        ? {'Instagram', 'TikTok', 'YouTube'}
        : {'Instagram', 'TikTok', 'YouTube', 'Games'};
  }

  @override
  void dispose() {
    _customDurationController.dispose();
    super.dispose();
  }

  int? get _durationMinutes {
    if (!_useCustomDuration) return _selectedDuration;
    final value = int.tryParse(_customDurationController.text.trim());
    if (value == null || value <= 0) return null;
    return value.clamp(1, 240).toInt();
  }

  List<MicroTask> _allOpenTasks() {
    return widget.goals
        .expand((goal) => goal.tasks)
        .where((task) => !task.done)
        .toList();
  }

  List<MicroTask> _openTasksForGoal(GoalProject goal) {
    return goal.tasks.where((task) => !task.done).toList()
      ..sort((a, b) {
        final aToday = dateOnly(a.scheduledDate) == dateOnly(widget.today);
        final bToday = dateOnly(b.scheduledDate) == dateOnly(widget.today);
        if (aToday != bToday) return aToday ? -1 : 1;
        return a.scheduledDate.compareTo(b.scheduledDate);
      });
  }

  void _selectTask(MicroTask task) {
    setState(() {
      _selectedTask = task;
      _selectedDuration = task.durationMinutes;
      _useCustomDuration = false;
      _blockUnrelatedApps = true;
    });
  }

  void _startFocus() {
    final duration = _durationMinutes;
    if (duration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid focus duration in minutes.')),
      );
      return;
    }

    Navigator.of(context).pop(
      FocusSessionConfig(
        task: _selectedTask,
        durationMinutes: duration,
        blockedApps: Set<String>.from(_blockedApps),
        blockUnrelatedApps: _selectedTask != null && _blockUnrelatedApps,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: ChipTheme(
        data: Theme.of(context).chipTheme.copyWith(
          backgroundColor: gdSurface,
          selectedColor: gdPrimary,
          labelStyle: const TextStyle(color: gdInk, fontWeight: FontWeight.w800),
          secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          side: const BorderSide(color: gdBorderStrong),
        ),
        child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: gdPrimarySoft,
                  child: Icon(Icons.track_changes_rounded, color: gdPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Focus mode', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      const Text(
                        'Choose a task, set a timer, and block distracting apps.',
                        style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('1. Choose focus task', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            AppCard(
              color: gdCardLight,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          selected: _selectedTask == null,
                          avatar: const Icon(Icons.edit_calendar_rounded, size: 18),
                          label: const Text('Custom focus'),
                          onSelected: (_) {
                            setState(() {
                              _selectedTask = null;
                              _blockUnrelatedApps = false;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_allOpenTasks().isEmpty) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'No unfinished subtasks yet, so this will start a custom focus session.',
                        style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
                      ),
                    ] else
                      for (final goal in widget.goals.where(
                        (goal) => _openTasksForGoal(goal).isNotEmpty,
                      ))
                        _GoalTaskExpansionTile(
                          goal: goal,
                          tasks: _openTasksForGoal(goal),
                          today: widget.today,
                          selectedTask: _selectedTask,
                          onSelectTask: _selectTask,
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('2. Select duration', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            AppCard(
              color: gdCardLight,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_selectedTask != null)
                          ChoiceChip(
                            selected: !_useCustomDuration && _selectedDuration == _selectedTask!.durationMinutes,
                            avatar: const Icon(Icons.schedule_rounded, size: 18),
                            label: Text('Task time · ${_selectedTask!.durationMinutes}m'),
                            onSelected: (_) {
                              setState(() {
                                _useCustomDuration = false;
                                _selectedDuration = _selectedTask!.durationMinutes;
                              });
                            },
                          ),
                        for (final minutes in _durationPresets)
                          ChoiceChip(
                            selected: !_useCustomDuration && _selectedDuration == minutes,
                            label: Text('$minutes min'),
                            onSelected: (_) {
                              setState(() {
                                _useCustomDuration = false;
                                _selectedDuration = minutes;
                              });
                            },
                          ),
                        ChoiceChip(
                          selected: _useCustomDuration,
                          avatar: const Icon(Icons.tune_rounded, size: 18),
                          label: const Text('Custom'),
                          onSelected: (_) => setState(() => _useCustomDuration = true),
                        ),
                      ],
                    ),
                    if (_useCustomDuration) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _customDurationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Custom time',
                          hintText: 'Example: 30',
                          suffixText: 'minutes',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('3. Block distractions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            AppCard(
              color: gdCardLight,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedTask != null)
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _blockUnrelatedApps,
                        title: const Text(
                          'Block apps unrelated to this goal',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: const Text(
                          'Goal Digger will use your selected list as the distraction blocklist during this session.',
                          style: TextStyle(color: gdMuted, fontWeight: FontWeight.w600),
                        ),
                        onChanged: (value) => setState(() => _blockUnrelatedApps = value),
                      )
                    else
                      const Text(
                        'Choose the apps you want to block during this custom session.',
                        style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
                      ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final app in _appOptions)
                          FilterChip(
                            selected: _blockedApps.contains(app),
                            label: Text(app),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _blockedApps.add(app);
                                } else {
                                  _blockedApps.remove(app);
                                }
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _startFocus,
                icon: const Icon(Icons.track_changes_rounded),
                label: const Text('Start focus session'),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _GoalTaskExpansionTile extends StatelessWidget {
  const _GoalTaskExpansionTile({
    required this.goal,
    required this.tasks,
    required this.today,
    required this.selectedTask,
    required this.onSelectTask,
  });

  final GoalProject goal;
  final List<MicroTask> tasks;
  final DateTime today;
  final MicroTask? selectedTask;
  final ValueChanged<MicroTask> onSelectTask;

  @override
  Widget build(BuildContext context) {
    final todayCount = tasks
        .where((task) => dateOnly(task.scheduledDate) == dateOnly(today))
        .length;
    final selectedInGoal = selectedTask != null && selectedTask!.goalId == goal.id;

    return ExpansionTile(
      initiallyExpanded: selectedInGoal || todayCount > 0,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      leading: CircleAvatar(
        backgroundColor: gdPrimarySoft,
        child: Icon(Icons.flag_rounded, color: goal.from),
      ),
      title: Text(
        goal.title,
        style: const TextStyle(fontWeight: FontWeight.w900, color: gdInk),
      ),
      subtitle: Text(
        '${tasks.length} open subtasks${todayCount == 0 ? '' : ' - $todayCount today'}',
        style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
      ),
      children: [
        for (final task in tasks)
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: 12, right: 4),
            leading: Icon(task.load.icon, color: task.load.color),
            title: Text(
              task.title,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              '${shortDate(task.scheduledDate)} - ${task.durationMinutes}m - ${task.load.label}',
              style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
            ),
            trailing: Icon(
              identical(selectedTask, task)
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: identical(selectedTask, task) ? gdPrimary : gdMuted,
            ),
            onTap: () => onSelectTask(task),
          ),
      ],
    );
  }
}

class FocusCountdownDialog extends StatefulWidget {
  const FocusCountdownDialog({
    super.key,
    required this.config,
    required this.remainingSecondsProvider,
    required this.pausedProvider,
    required this.onPauseToggle,
    required this.onMinimize,
    required this.onStop,
  });

  final FocusSessionConfig config;
  final int Function() remainingSecondsProvider;
  final bool Function() pausedProvider;
  final VoidCallback onPauseToggle;
  final VoidCallback onMinimize;
  final VoidCallback onStop;

  @override
  State<FocusCountdownDialog> createState() => _FocusCountdownDialogState();
}

class _FocusCountdownDialogState extends State<FocusCountdownDialog> {
  Timer? _refreshTimer;

  int get _totalSeconds => widget.config.durationMinutes * 60;
  int get _remainingSeconds => widget.remainingSecondsProvider();
  bool get _paused => widget.pausedProvider();
  bool get _isComplete => _remainingSeconds <= 0;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds == 0 ? 1.0 : 1 - (_remainingSeconds / _totalSeconds);
    return Material(
      color: gdBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(backgroundColor: gdPrimarySoft, child: Icon(Icons.track_changes_rounded, color: gdPrimary)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_isComplete ? 'Focus complete' : 'Focus mode', style: Theme.of(context).textTheme.headlineMedium)),
                  IconButton.filledTonal(tooltip: 'Minimize without stopping', onPressed: widget.onMinimize, icon: const Icon(Icons.keyboard_arrow_down_rounded)),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        PetAvatar(pet: defaultPet, size: 112),
                        const SizedBox(height: 20),
                        Text(widget.config.title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(widget.config.blockingSummary, textAlign: TextAlign.center, style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 230,
                          height: 230,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox.expand(child: CircularProgressIndicator(value: progress.clamp(0.0, 1.0).toDouble(), strokeWidth: 14, backgroundColor: gdPrimarySoft, strokeCap: StrokeCap.round)),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_isComplete ? Icons.check_circle_rounded : _paused ? Icons.pause_circle_filled_rounded : Icons.track_changes_rounded, size: 34, color: gdPrimary),
                                  const SizedBox(height: 8),
                                  Text(_formatTime(_remainingSeconds), style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1.5, color: gdInk)),
                                  Text(_isComplete ? 'Nice work' : _paused ? 'Paused' : 'Running', style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        AppCard(
                          color: gdSurface,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(children: [Icon(Icons.block_rounded, size: 20), SizedBox(width: 8), Text('Blocked during focus', style: TextStyle(fontWeight: FontWeight.w900, color: gdInk))]),
                                const SizedBox(height: 10),
                                if (widget.config.blockedApps.isEmpty)
                                  const Text('No apps selected.', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700))
                                else
                                  Wrap(spacing: 8, runSpacing: 8, children: [for (final app in widget.config.blockedApps) Chip(backgroundColor: gdPrimarySoft, avatar: const Icon(Icons.lock_rounded, size: 16, color: gdPrimary), label: Text(app, style: const TextStyle(color: gdInk, fontWeight: FontWeight.w800)))]),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(child: OutlinedButton.icon(onPressed: _isComplete ? null : widget.onPauseToggle, icon: Icon(_paused ? Icons.play_arrow_rounded : Icons.pause_rounded), label: Text(_paused ? 'Resume' : 'Pause'))),
                  const SizedBox(width: 10),
                  Expanded(child: FilledButton.icon(onPressed: widget.onStop, icon: Icon(_isComplete ? Icons.check_circle_rounded : Icons.stop_rounded), label: Text(_isComplete ? 'Finish' : 'Stop session'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
