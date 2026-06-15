import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/gd_design.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../models/models.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../companion/companion_sprite.dart';
import '../services/focus_app_blocking_service.dart';

class FocusSessionConfig {
  const FocusSessionConfig({
    required this.task,
    required this.durationMinutes,
    this.blockedPackages = const [],
  });

  final MicroTask? task;
  final int durationMinutes;
  final List<String> blockedPackages;

  String get title => task?.title ?? 'Custom focus session';

  String get focusSummary =>
      task == null ? 'Custom focus timer' : 'Goal task focus';

  bool get blocksApps => blockedPackages.isNotEmpty;
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

class _FocusSetupSheetState extends State<FocusSetupSheet>
    with WidgetsBindingObserver {
  static const List<int> _durationPresets = [15, 25, 45, 60];

  final TextEditingController _customDurationController =
      TextEditingController(text: '30');
  final FocusAppBlockingService _appBlocking = FocusAppBlockingService();

  MicroTask? _selectedTask;
  int _selectedDuration = 25;
  bool _useCustomDuration = false;
  bool _blockApps = false;
  bool _accessibilityEnabled = false;
  bool _loadingApps = false;
  List<FocusBlockedApp> _availableApps = const [];
  Set<String> _selectedBlockedPackages = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final todayTasks = _todayOpenTasks();
    _selectedTask = todayTasks.isEmpty ? null : todayTasks.first;
    _selectedDuration = _selectedTask?.durationMinutes ?? 25;
    unawaited(_refreshAppBlockingStatus());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _customDurationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _blockApps) {
      unawaited(_refreshAppBlockingStatus(loadAppsWhenEnabled: true));
    }
  }

  int? get _durationMinutes {
    if (!_useCustomDuration) return _selectedDuration;
    final value = int.tryParse(_customDurationController.text.trim());
    if (value == null || value <= 0) return null;
    return value.clamp(1, 240).toInt();
  }

  List<MicroTask> _todayOpenTasks() {
    return widget.goals
        .expand((goal) => goal.tasks)
        .where(
          (task) =>
              !task.done &&
              dateOnly(task.scheduledDate) == dateOnly(widget.today),
        )
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  List<MicroTask> _openTasksForGoal(GoalProject goal) {
    return goal.tasks
        .where(
          (task) =>
              !task.done &&
              dateOnly(task.scheduledDate) == dateOnly(widget.today),
        )
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  void _selectTask(MicroTask task) {
    setState(() {
      _selectedTask = task;
      _selectedDuration = task.durationMinutes;
      _useCustomDuration = false;
    });
  }

  Future<void> _refreshAppBlockingStatus({
    bool loadAppsWhenEnabled = false,
  }) async {
    if (!_appBlocking.isSupported) return;
    final enabled = await _appBlocking.isAccessibilityServiceEnabled();
    if (!mounted) return;
    setState(() => _accessibilityEnabled = enabled);
    if (enabled &&
        loadAppsWhenEnabled &&
        _availableApps.isEmpty &&
        !_loadingApps) {
      await _loadAvailableApps();
    }
  }

  Future<void> _loadAvailableApps() async {
    if (_loadingApps) return;
    setState(() => _loadingApps = true);
    final apps = await _appBlocking.getLaunchableApps();
    if (!mounted) return;
    setState(() {
      _availableApps = apps;
      _loadingApps = false;
      final availablePackages = apps.map((app) => app.packageName).toSet();
      _selectedBlockedPackages =
          _selectedBlockedPackages.intersection(availablePackages);
    });
  }

  Future<void> _toggleAppBlocking(bool enabled) async {
    setState(() => _blockApps = enabled);
    if (!enabled || !_appBlocking.isSupported) return;

    await _refreshAppBlockingStatus(loadAppsWhenEnabled: true);
    if (!mounted || _accessibilityEnabled) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Enable Goal Digger App Block, then return to choose apps.',
        ),
      ),
    );
    await _appBlocking.openAccessibilitySettings();
  }

  Future<void> _chooseBlockedApps() async {
    if (!_accessibilityEnabled) {
      await _appBlocking.openAccessibilitySettings();
      return;
    }
    if (_availableApps.isEmpty) await _loadAvailableApps();
    if (!mounted || _availableApps.isEmpty) return;

    final selected = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: gdSurface,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.88,
        child: _BlockedAppPicker(
          apps: _availableApps,
          initiallySelected: _selectedBlockedPackages,
        ),
      ),
    );
    if (!mounted || selected == null) return;
    setState(() => _selectedBlockedPackages = selected);
  }

  Future<void> _startFocus() async {
    final duration = _durationMinutes;
    if (duration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid focus duration in minutes.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_blockApps) {
      if (!_appBlocking.isSupported) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('App blocking is currently available on Android.'),
          ),
        );
        return;
      }
      final enabled = await _appBlocking.isAccessibilityServiceEnabled();
      if (!mounted) return;
      setState(() => _accessibilityEnabled = enabled);
      if (!enabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Enable Goal Digger App Block before starting this session.',
            ),
          ),
        );
        await _appBlocking.openAccessibilitySettings();
        return;
      }
      if (_selectedBlockedPackages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Choose at least one app to block.'),
          ),
        );
        return;
      }
    }

    Navigator.of(context).pop(
      FocusSessionConfig(
        task: _selectedTask,
        durationMinutes: duration,
        blockedPackages: _blockApps
            ? _selectedBlockedPackages.toList(growable: false)
            : const [],
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
              labelStyle: TextStyle(color: gdInk, fontWeight: FontWeight.w800),
              secondaryLabelStyle: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800),
              side: BorderSide(color: gdBorderStrong),
            ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: gdPrimarySoft,
                    child: Icon(Icons.track_changes_rounded, color: gdPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Focus mode', style: GdText.headlineMedium),
                        const SizedBox(height: 4),
                        Text(
                          'Choose a task, set a timer, and block distractions.',
                          style: TextStyle(
                              color: gdMuted, fontWeight: FontWeight.w700),
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
              Text('1. Choose focus task', style: GdText.titleMedium),
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
                            avatar: const Icon(Icons.edit_calendar_rounded,
                                size: 18),
                            label: const Text('Custom focus'),
                            onSelected: (_) {
                              setState(() {
                                _selectedTask = null;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_todayOpenTasks().isEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          'No unfinished tasks scheduled for today, so this will start a custom focus session.',
                          style: TextStyle(
                              color: gdMuted, fontWeight: FontWeight.w700),
                        ),
                      ] else
                        for (final goal in widget.goals.where(
                          (goal) => _openTasksForGoal(goal).isNotEmpty,
                        ))
                          _GoalTaskExpansionTile(
                            goal: goal,
                            tasks: _openTasksForGoal(goal),
                            selectedTask: _selectedTask,
                            onSelectTask: _selectTask,
                          ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('2. Select duration', style: GdText.titleMedium),
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
                              selected: !_useCustomDuration &&
                                  _selectedDuration ==
                                      _selectedTask!.durationMinutes,
                              avatar:
                                  const Icon(Icons.schedule_rounded, size: 18),
                              label: Text(
                                  'Task time · ${_selectedTask!.durationMinutes}m'),
                              onSelected: (_) {
                                setState(() {
                                  _useCustomDuration = false;
                                  _selectedDuration =
                                      _selectedTask!.durationMinutes;
                                });
                              },
                            ),
                          for (final minutes in _durationPresets)
                            ChoiceChip(
                              selected: !_useCustomDuration &&
                                  _selectedDuration == minutes,
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
                            onSelected: (_) =>
                                setState(() => _useCustomDuration = true),
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
              Text('3. Block distracting apps', style: GdText.titleMedium),
              const SizedBox(height: 10),
              AppCard(
                color: gdCardLight,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _blockApps,
                        onChanged: (value) => unawaited(
                          _toggleAppBlocking(value),
                        ),
                        secondary: const Icon(Icons.app_blocking_rounded),
                        title: const Text(
                          'Block selected apps',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: Text(
                          _appBlocking.isSupported
                              ? 'Uses Android Accessibility with your explicit permission.'
                              : 'Available on Android devices.',
                          style: TextStyle(
                            color: gdMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (_blockApps) ...[
                        const SizedBox(height: 8),
                        if (!_appBlocking.isSupported)
                          Text(
                            'This device does not support Goal Digger app blocking.',
                            style: TextStyle(
                              color: gdMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        else if (!_accessibilityEnabled)
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonalIcon(
                              onPressed: _appBlocking.openAccessibilitySettings,
                              icon: const Icon(Icons.settings_accessibility),
                              label: const Text('Enable in Android settings'),
                            ),
                          )
                        else ...[
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed:
                                  _loadingApps ? null : _chooseBlockedApps,
                              icon: _loadingApps
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.checklist_rounded),
                              label: Text(
                                _selectedBlockedPackages.isEmpty
                                    ? 'Choose apps to block'
                                    : '${_selectedBlockedPackages.length} app(s) selected',
                              ),
                            ),
                          ),
                          if (_selectedBlockedPackages.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              _availableApps
                                  .where(
                                    (app) => _selectedBlockedPackages
                                        .contains(app.packageName),
                                  )
                                  .map((app) => app.label)
                                  .join(', '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: gdMuted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ],
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

class _BlockedAppPicker extends StatefulWidget {
  const _BlockedAppPicker({
    required this.apps,
    required this.initiallySelected,
  });

  final List<FocusBlockedApp> apps;
  final Set<String> initiallySelected;

  @override
  State<_BlockedAppPicker> createState() => _BlockedAppPickerState();
}

class _BlockedAppPickerState extends State<_BlockedAppPicker> {
  late final Set<String> _selected = {...widget.initiallySelected};
  String _query = '';

  List<FocusBlockedApp> get _filteredApps {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.apps;
    return widget.apps
        .where(
          (app) =>
              app.label.toLowerCase().contains(query) ||
              app.packageName.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final apps = _filteredApps;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Choose blocked apps', style: GdText.titleLarge),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Search installed apps',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '${_selected.length} selected',
                  style: TextStyle(
                    color: gdMuted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _selected.isEmpty
                      ? null
                      : () => setState(_selected.clear),
                  child: const Text('Clear all'),
                ),
              ],
            ),
            Expanded(
              child: apps.isEmpty
                  ? Center(
                      child: Text(
                        'No matching apps found.',
                        style: TextStyle(
                          color: gdMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: apps.length,
                      itemBuilder: (context, index) {
                        final app = apps[index];
                        final selected = _selected.contains(app.packageName);
                        return CheckboxListTile(
                          value: selected,
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selected.add(app.packageName);
                              } else {
                                _selected.remove(app.packageName);
                              }
                            });
                          },
                          secondary: _BlockedAppIcon(app: app),
                          title: Text(
                            app.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          subtitle: Text(
                            app.packageName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(
                  Set<String>.unmodifiable(_selected),
                ),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Block selected apps'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockedAppIcon extends StatelessWidget {
  const _BlockedAppIcon({required this.app});

  final FocusBlockedApp app;

  @override
  Widget build(BuildContext context) {
    final iconBytes = app.iconBytes;
    if (iconBytes == null || iconBytes.isEmpty) {
      return CircleAvatar(
        backgroundColor: gdPrimarySoft,
        child: Icon(
          Icons.apps_rounded,
          color: gdPrimary,
          size: 20,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.memory(
        iconBytes,
        width: 42,
        height: 42,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => CircleAvatar(
          backgroundColor: gdPrimarySoft,
          child: Icon(
            Icons.apps_rounded,
            color: gdPrimary,
            size: 20,
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
    required this.selectedTask,
    required this.onSelectTask,
  });

  final GoalProject goal;
  final List<MicroTask> tasks;
  final MicroTask? selectedTask;
  final ValueChanged<MicroTask> onSelectTask;

  @override
  Widget build(BuildContext context) {
    final selectedInGoal =
        selectedTask != null && selectedTask!.goalId == goal.id;
    final taskCountLabel =
        tasks.length == 1 ? '1 task today' : '${tasks.length} tasks today';

    return ExpansionTile(
      initiallyExpanded: selectedInGoal,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      leading: CircleAvatar(
        backgroundColor: gdPrimarySoft,
        child: Icon(Icons.flag_rounded, color: goal.from),
      ),
      title: Text(
        goal.title,
        style: TextStyle(fontWeight: FontWeight.w900, color: gdInk),
      ),
      subtitle: Text(
        taskCountLabel,
        style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
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
              style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
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
    required this.activeCompanion,
    required this.remainingSecondsProvider,
    required this.pausedProvider,
    required this.onPauseToggle,
    required this.onMinimize,
    required this.onStop,
  });

  final FocusSessionConfig config;
  final CompanionKind activeCompanion;
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
    final progress =
        _totalSeconds == 0 ? 1.0 : 1 - (_remainingSeconds / _totalSeconds);
    return Material(
      color: gdBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                      backgroundColor: gdPrimarySoft,
                      child:
                          Icon(Icons.track_changes_rounded, color: gdPrimary)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(_isComplete ? 'Focus complete' : 'Focus mode',
                          style: GdText.headlineMedium)),
                  IconButton.filledTonal(
                      tooltip: 'Minimize without stopping',
                      onPressed: widget.onMinimize,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded)),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _FocusCompanionAnimation(
                          companion: widget.activeCompanion,
                        ),
                        const SizedBox(height: 20),
                        Text(widget.config.title,
                            textAlign: TextAlign.center,
                            style: GdText.titleLarge),
                        const SizedBox(height: 8),
                        Text(widget.config.focusSummary,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: gdMuted, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 230,
                          height: 230,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox.expand(
                                  child: CircularProgressIndicator(
                                      value:
                                          progress.clamp(0.0, 1.0).toDouble(),
                                      strokeWidth: 14,
                                      backgroundColor: gdPrimarySoft,
                                      strokeCap: StrokeCap.round)),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                      _isComplete
                                          ? Icons.check_circle_rounded
                                          : _paused
                                              ? Icons
                                                  .pause_circle_filled_rounded
                                              : Icons.track_changes_rounded,
                                      size: 34,
                                      color: gdPrimary),
                                  const SizedBox(height: 8),
                                  Text(_formatTime(_remainingSeconds),
                                      style: TextStyle(
                                          fontSize: 42,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -1.5,
                                          color: gdInk)),
                                  Text(
                                      _isComplete
                                          ? 'Nice work'
                                          : _paused
                                              ? 'Paused'
                                              : 'Running',
                                      style: TextStyle(
                                          color: gdMuted,
                                          fontWeight: FontWeight.w800)),
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
                                Row(children: [
                                  Icon(Icons.center_focus_strong_rounded,
                                      size: 20),
                                  SizedBox(width: 8),
                                  Text('Stay in focus',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: gdInk))
                                ]),
                                const SizedBox(height: 10),
                                Text(
                                  widget.config.blocksApps
                                      ? '${widget.config.blockedPackages.length} selected app(s) stay blocked while this timer runs.'
                                      : 'The timer keeps running accurately when Goal Digger is in the background.',
                                  style: TextStyle(
                                      color: gdMuted,
                                      fontWeight: FontWeight.w700),
                                ),
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
                  Expanded(
                      child: OutlinedButton.icon(
                          onPressed: _isComplete ? null : widget.onPauseToggle,
                          icon: Icon(_paused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded),
                          label: Text(_paused ? 'Resume' : 'Pause'))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: FilledButton.icon(
                          onPressed: widget.onStop,
                          icon: Icon(_isComplete
                              ? Icons.check_circle_rounded
                              : Icons.stop_rounded),
                          label:
                              Text(_isComplete ? 'Finish' : 'Stop session'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusCompanionAnimation extends StatelessWidget {
  const _FocusCompanionAnimation({required this.companion});

  final CompanionKind companion;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: '${companion.label} companion focusing with you',
      child: SpriteSheetAnimation(
        assetPath: 'assets/${companion.assetFolder}/high_interacted.png',
        size: 132,
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }
}
