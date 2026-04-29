import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/glass_card.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  int _focusSeconds = 0;
  bool _focusRunning = false;
  Timer? _timer;

  void _startFocus(int duration) {
    _stopFocus();
    setState(() { _focusSeconds = 0; _focusRunning = true; });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _focusSeconds++;
        if (_focusSeconds >= duration) _stopFocus();
      });
    });
  }

  void _stopFocus() {
    _timer?.cancel();
    setState(() => _focusRunning = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final remaining = state.focusDuration - _focusSeconds;
    final mins = (remaining.clamp(0, 99999)) ~/ 60;
    final secs = (remaining.clamp(0, 99999)) % 60;
    final tasks = state.todayTasks;
    final allDone = tasks.isNotEmpty && tasks.every((t) => t.done);
    final moreAvailable = state.hasMoreAvailableTasks;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DAILY PLAN · BUILT BY ATS', style: AppTextStyles.labelTeal),
          const SizedBox(height: 16),
          Text('Task', style: AppTextStyles.heading1),
          const SizedBox(height: 16),
          Text('These tasks were chosen for today based on your goal importance, deadlines, and current energy.', style: AppTextStyles.body),
          const SizedBox(height: 16),

          // Focus Mode toggle
          GestureDetector(
            onTap: state.toggleFocusMode,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.dark, borderRadius: BorderRadius.circular(100),
                boxShadow: [BoxShadow(color: AppColors.dark.withValues(alpha: 0.22), blurRadius: 45, offset: const Offset(0, 16))],
              ),
              child: Text(state.showFocusMode ? 'Close Focus' : '⏱ Focus Mode', style: AppTextStyles.buttonPrimary),
            ),
          ),

          if (state.showFocusMode) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.dark, borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: AppColors.dark.withValues(alpha: 0.3), blurRadius: 80, offset: const Offset(0, 28))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('FOCUS MODE', style: AppTextStyles.label.copyWith(color: Colors.white38)),
                        const SizedBox(height: 4),
                        const Text('Deep work session', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                      ]),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
                        Text('remaining', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.5))),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [15, 25, 45, 60].map((m) {
                      final isActive = state.focusDuration == m * 60;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => state.setFocusDuration(m * 60),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text('$m min', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isActive ? AppColors.dark : Colors.white60)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: state.focusApps.map((app) => GestureDetector(
                      onTap: () => state.toggleFocusApp(app.name),
                      child: Container(
                        width: 70, padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: app.allowed ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(children: [
                          Text(app.icon, style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(app.name, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: app.allowed ? Colors.white : Colors.white30)),
                          const SizedBox(height: 4),
                          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: app.allowed ? AppColors.emerald : Colors.red)),
                        ]),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _focusRunning ? _stopFocus() : _startFocus(state.focusDuration),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(color: _focusRunning ? Colors.red : Colors.white, borderRadius: BorderRadius.circular(100)),
                      child: Center(child: Text(_focusRunning ? 'End session' : 'Start focus session',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _focusRunning ? Colors.white : AppColors.dark))),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Progress orb
          GlassCard(
            child: Column(
              children: [
                Text("TODAY'S PROGRESS", style: AppTextStyles.label),
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    width: 160, height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.dark,
                      boxShadow: [BoxShadow(color: AppColors.dark.withValues(alpha: 0.22), blurRadius: 70, offset: const Offset(0, 28))],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${state.todayCompletionPercent}%', style: AppTextStyles.bigNumber.copyWith(fontSize: 40)),
                        const SizedBox(height: 4),
                        Text('${state.todayCompletedCount} of ${tasks.length} done',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.6))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Goal Tracker
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GOAL TRACKER', style: AppTextStyles.label),
                const SizedBox(height: 16),
                ...state.goals.map((g) {
                  final total = g.subtasks.length;
                  final done = g.subtasks.where((s) => s.done).length;
                  final pct = total == 0 ? 0 : ((done / total) * 100).round();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(g.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                        Text('$pct%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textTertiary)),
                      ]),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(color: AppColors.dark.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: pct / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [g.startColor, g.endColor]),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Today task list
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Today', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -1, color: AppColors.textPrimary)),
                    if (allDone && moreAvailable)
                      GestureDetector(
                        onTap: state.addAnotherTask,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.emerald, borderRadius: BorderRadius.circular(100),
                            boxShadow: [BoxShadow(color: AppColors.emerald.withValues(alpha: 0.3), blurRadius: 25, offset: const Offset(0, 10))],
                          ),
                          child: const Text("+ Add another (you're on fire!)",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
                        ),
                      ),
                  ],
                ),
                if (allDone) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.emerald.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                    child: const Column(children: [
                      Text('🎉', style: TextStyle(fontSize: 28)),
                      SizedBox(height: 4),
                      Text("All today's tasks complete!", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF047857))),
                      SizedBox(height: 4),
                      Text('Want to keep going? Pull more tasks from upcoming days.',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF059669))),
                    ]),
                  ),
                ],
                const SizedBox(height: 12),
                ...tasks.map((t) {
                  final goal = state.goals.firstWhere((g) => g.id == t.goalId);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: t.done ? AppColors.emerald.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => state.toggleTask(t.id),
                                child: Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: t.done ? AppColors.emerald : AppColors.dark.withValues(alpha: 0.05),
                                    border: Border.all(color: t.done ? AppColors.emerald : AppColors.dark.withValues(alpha: 0.1)),
                                  ),
                                  child: t.done ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => state.toggleTask(t.id),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(t.title, style: TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.w900,
                                        color: t.done ? AppColors.textTertiary : AppColors.textPrimary,
                                        decoration: t.done ? TextDecoration.lineThrough : null,
                                      )),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 6, runSpacing: 4,
                                        children: [
                                          Text(t.duration, style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(colors: [goal.startColor, goal.endColor]),
                                              borderRadius: BorderRadius.circular(100),
                                            ),
                                            child: Text(goal.title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.amberWarm.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(100),
                                            ),
                                            child: Text('+${t.points}pts',
                                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF92400E))),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (!t.done && moreAvailable) ...[
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => state.replaceTodayTask(t.id),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(color: AppColors.dark.withValues(alpha: 0.1)),
                                ),
                                child: const Center(child: Text('↻ Swap with another task',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textSecondary))),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
                if (tasks.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20)),
                    child: const Center(child: Text('No tasks scheduled. Add a goal in Planner.',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textTertiary))),
                  ),
                if (!allDone && moreAvailable) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: state.addAnotherTask,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppColors.dark.withValues(alpha: 0.2), style: BorderStyle.solid, width: 1.5),
                      ),
                      child: const Center(child: Text('+ Pull another task from upcoming days',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textSecondary))),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
