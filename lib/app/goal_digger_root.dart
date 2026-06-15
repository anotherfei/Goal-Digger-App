import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/theme/gd_design.dart';
import '../core/utils/date_helpers.dart';
import '../data/seed_data.dart';
import '../features/calendar/calendar_page.dart';
import '../features/community/community_page.dart';
import '../features/companion/companion_page.dart';
import '../features/companion/companion_sprite.dart';
import '../features/focus/services/focus_app_blocking_service.dart';
import '../features/focus/widgets/focus_widgets.dart';
import '../features/notifications/models/notification_models.dart';
import '../features/notifications/notification_inbox_page.dart';
import '../features/notifications/services/android_notification_service.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/planner/planner_page.dart';
import '../features/profile/profile_screen.dart';
import '../features/responsive/responsive_goal_shell.dart';
import '../features/settings/settings_screen.dart';
import '../features/tasks/tasks_page.dart';
import '../firebase/auth/auth_service.dart';
import '../firebase/auth/auth_state.dart';
import '../firebase/firestore/repositories/user_repository.dart';
import '../firebase/sync/app_sync_service.dart';
import '../genkit/genkit_service.dart';
import '../models/models.dart';
import '../shared/widgets/shared_widgets.dart';
import '../services/google_calendar_service.dart';

class _DraftTaskSpec {
  const _DraftTaskSpec({
    required this.title,
    required this.durationMinutes,
    required this.load,
    required this.dayOffset,
  });

  final String title;
  final int durationMinutes;
  final TaskLoad load;
  final int dayOffset;
}

class _GoalPlanApprovalResult {
  const _GoalPlanApprovalResult({
    required this.title,
    required this.tasks,
  });

  final String title;
  final List<_DraftTaskSpec> tasks;
}

class _AiContextUsedStrip extends StatelessWidget {
  const _AiContextUsedStrip({required this.chips});

  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      decoration: BoxDecoration(
        color: gdPrimarySoft.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: gdPrimary.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_rounded, size: 16, color: gdPrimary),
              const SizedBox(width: 7),
              Text(
                'AI used this context',
                style: TextStyle(
                  color: gdInk,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final chip in chips) _AiContextChip(label: chip),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiContextChip extends StatelessWidget {
  const _AiContextChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: gdSurface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: gdBorder.withValues(alpha: 0.70)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: gdMuted,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PlanPreviewSection extends StatelessWidget {
  const _PlanPreviewSection({
    required this.tasks,
    this.contextChips = const [],
  });

  final List<_DraftTaskSpec> tasks;
  final List<String> contextChips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: gdSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gdBorder),
        boxShadow: [
          BoxShadow(
            color: gdShadow.withValues(alpha: GdAlpha.faint),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: gdPrimarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Icon(Icons.view_agenda_rounded, size: 17, color: gdPrimary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan Preview',
                      style: TextStyle(
                        color: gdInk,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tasks.length} generated task${tasks.length == 1 ? '' : 's'}',
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
          const SizedBox(height: 14),
          if (contextChips.isNotEmpty) ...[
            _AiContextUsedStrip(chips: contextChips),
            const SizedBox(height: 14),
          ],
          for (var i = 0; i < tasks.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == tasks.length - 1 ? 0 : 12),
              child: _StaggeredTaskEntrance(
                index: i,
                child: _GeneratedTaskBlock(
                  task: tasks[i],
                  index: i,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StaggeredTaskEntrance extends StatefulWidget {
  const _StaggeredTaskEntrance({
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<_StaggeredTaskEntrance> createState() => _StaggeredTaskEntranceState();
}

class _StaggeredTaskEntranceState extends State<_StaggeredTaskEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;
  Timer? _delay;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(curved);
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curved);
    _delay = Timer(Duration(milliseconds: min(widget.index * 70, 420)), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _delay?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
    );
  }
}

class _GeneratedTaskBlock extends StatefulWidget {
  const _GeneratedTaskBlock({
    required this.task,
    required this.index,
  });

  final _DraftTaskSpec task;
  final int index;

  @override
  State<_GeneratedTaskBlock> createState() => _GeneratedTaskBlockState();
}

class _GeneratedTaskBlockState extends State<_GeneratedTaskBlock> {
  bool _expanded = false;

  _DraftTaskSpec get task => widget.task;

  String get _whyText {
    if (task.dayOffset == 0) {
      return 'This gives the plan a clear first action and helps you build momentum today.';
    }
    switch (task.load) {
      case TaskLoad.light:
        return 'This keeps progress moving without adding too much load.';
      case TaskLoad.focus:
        return 'This is a focused study block that turns the goal into measurable progress.';
      case TaskLoad.stretch:
        return 'This is the deeper work that helps lock in the most important part of the plan.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: _expanded ? gdCardLight : gdSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _expanded ? gdPrimary.withValues(alpha: 0.28) : gdBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: gdPrimarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.index + 1}',
                        style: TextStyle(
                          color: gdPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            maxLines: _expanded ? 4 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: gdInk,
                              fontSize: 15,
                              height: 1.22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: [
                              _detailPill(
                                icon: Icons.timer_rounded,
                                label: '${task.durationMinutes} min',
                              ),
                              _detailPill(
                                icon: task.load.icon,
                                label: task.load.label,
                              ),
                              _detailPill(
                                icon: Icons.event_rounded,
                                label: 'Day ${task.dayOffset + 1}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          color: gdPrimary),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 210),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: _expanded
                      ? Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: gdSurface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: gdBorder),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.lightbulb_rounded,
                                    size: 17, color: gdPrimary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _whyText,
                                    style: TextStyle(
                                      color: gdMuted,
                                      fontSize: 13,
                                      height: 1.45,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailPill({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: gdPrimarySoft.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: gdPrimary),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: gdMuted,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiThinkingIndicator extends StatefulWidget {
  const _AiThinkingIndicator();

  @override
  State<_AiThinkingIndicator> createState() => _AiThinkingIndicatorState();
}

class _AiThinkingIndicatorState extends State<_AiThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: gdCardLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: gdBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 17, color: gdPrimary),
            const SizedBox(width: 10),
            Text(
              'Thinking through the plan',
              style: TextStyle(
                color: gdMuted,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final pulse = (sin(
                              (_controller.value * 2 * pi) + (index * 0.85),
                            ) +
                            1) /
                        2;
                    return Container(
                      width: 6 + pulse * 2,
                      height: 6 + pulse * 2,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: gdPrimary.withValues(alpha: 0.28 + pulse * 0.45),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingStatusFeed extends StatefulWidget {
  const _LoadingStatusFeed({required this.lines});

  final List<String> lines;

  @override
  State<_LoadingStatusFeed> createState() => _LoadingStatusFeedState();
}

class _LoadingStatusFeedState extends State<_LoadingStatusFeed> {
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _LoadingStatusFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lines.join('|') == widget.lines.join('|')) return;
    _index = 0;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.lines.length < 2) return;
    _timer = Timer.periodic(const Duration(milliseconds: 1150), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % widget.lines.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.lines.isEmpty
        ? const ['AI is checking timing and workload']
        : widget.lines;
    final line = lines[_index % lines.length];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: gdPrimarySoft.withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gdPrimary.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Icon(Icons.manage_search_rounded, color: gdPrimary, size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final offset = Tween<Offset>(
                  begin: const Offset(0, 0.25),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: offset, child: child),
                );
              },
              child: Text(
                line,
                key: ValueKey(line),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: gdPrimary,
                  fontSize: 12.5,
                  height: 1.25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SproutLoadingMark extends StatefulWidget {
  const _SproutLoadingMark();

  @override
  State<_SproutLoadingMark> createState() => _SproutLoadingMarkState();
}

class _SproutLoadingMarkState extends State<_SproutLoadingMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1550),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86,
      height: 66,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _SproutLoadingPainter(_controller.value),
          );
        },
      ),
    );
  }
}

class _SproutLoadingPainter extends CustomPainter {
  const _SproutLoadingPainter(this.progress);

  final double progress;

  double _segment(double start, double end) {
    return ((progress - start) / (end - start)).clamp(0.0, 1.0).toDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.68);
    final drop = Curves.easeInCubic.transform(_segment(0.0, 0.32));
    final grow = Curves.easeOutBack.transform(_segment(0.28, 0.74));
    final settle = Curves.easeInCubic.transform(_segment(0.78, 1.0));
    final sprout = (grow * (1 - settle)).clamp(0.0, 1.0).toDouble();
    final seedAlpha = (1 - _segment(0.30, 0.56)).clamp(0.0, 1.0).toDouble();

    final soilPaint = Paint()
      ..color = gdPrimarySoft.withValues(alpha: 0.95)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx - 30, center.dy + 4),
      Offset(center.dx + 30, center.dy + 4),
      soilPaint,
    );

    final soilDotPaint = Paint()
      ..color = gdPrimary.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    for (final offset in [-22.0, -10.0, 12.0, 24.0]) {
      canvas.drawCircle(
          Offset(center.dx + offset, center.dy + 9), 2.2, soilDotPaint);
    }

    final seedY = size.height * 0.24 + (center.dy - size.height * 0.24) * drop;
    final seedPaint = Paint()
      ..color = gdStarGold.withValues(alpha: seedAlpha)
      ..style = PaintingStyle.fill;
    if (seedAlpha > 0) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, seedY),
          width: 13,
          height: 10,
        ),
        seedPaint,
      );
    }

    if (sprout <= 0) return;

    final stemPaint = Paint()
      ..color = gdSuccess.withValues(alpha: 0.92)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final stemTop = Offset(center.dx, center.dy - 28 * sprout);
    canvas.drawLine(center, stemTop, stemPaint);

    final leafPaint = Paint()
      ..color = gdSuccess.withValues(alpha: 0.78 * sprout)
      ..style = PaintingStyle.fill;
    final leftLeaf = Path()
      ..moveTo(stemTop.dx, stemTop.dy + 8)
      ..quadraticBezierTo(stemTop.dx - 19 * sprout, stemTop.dy - 2,
          stemTop.dx - 7 * sprout, stemTop.dy + 14 * sprout)
      ..quadraticBezierTo(
          stemTop.dx - 2, stemTop.dy + 12, stemTop.dx, stemTop.dy + 8);
    final rightLeaf = Path()
      ..moveTo(stemTop.dx, stemTop.dy + 4)
      ..quadraticBezierTo(stemTop.dx + 20 * sprout, stemTop.dy - 8,
          stemTop.dx + 8 * sprout, stemTop.dy + 10 * sprout)
      ..quadraticBezierTo(
          stemTop.dx + 2, stemTop.dy + 8, stemTop.dx, stemTop.dy + 4);
    canvas.drawPath(leftLeaf, leafPaint);
    canvas.drawPath(rightLeaf, leafPaint);

    final shinePaint = Paint()
      ..color = gdPrimary.withValues(alpha: 0.18 * sprout)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: center, width: 70, height: 48),
      pi * 1.05,
      pi * 0.9 * sprout,
      false,
      shinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SproutLoadingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _PlanCommitAnimation extends StatelessWidget {
  const _PlanCommitAnimation({
    required this.title,
    required this.tasks,
  });

  final String title;
  final List<_DraftTaskSpec> tasks;

  @override
  Widget build(BuildContext context) {
    final previewTasks = tasks.take(4).toList();

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1350),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          final titleT = (value / 0.28).clamp(0.0, 1.0).toDouble();
          final sinkT = ((value - 0.70) / 0.30).clamp(0.0, 1.0).toDouble();

          return Material(
            color: Colors.transparent,
            child: Container(
              width: min(MediaQuery.of(context).size.width - 40, 440.0),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              decoration: BoxDecoration(
                color: gdSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: gdBorder),
                boxShadow: [
                  BoxShadow(
                    color: gdShadow.withValues(alpha: 0.18),
                    blurRadius: 32,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Opacity(
                    opacity: titleT,
                    child: Transform.translate(
                      offset: Offset(0, (1 - titleT) * 10),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: gdPrimarySoft,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(Icons.auto_awesome_rounded,
                                color: gdPrimary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: gdInk,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Building your schedule',
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
                  ),
                  const SizedBox(height: 18),
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Column(
                        children: [
                          for (var i = 0; i < previewTasks.length; i++)
                            _PlanCommitTaskRow(
                              task: previewTasks[i],
                              index: i,
                              progress: value,
                              sinkProgress: sinkT,
                            ),
                        ],
                      ),
                      IgnorePointer(
                        child: Opacity(
                          opacity: sinkT,
                          child: Transform.scale(
                            scale: 0.86 + sinkT * 0.14,
                            child: Container(
                              margin: const EdgeInsets.only(top: 16),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: gdPrimary,
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
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.calendar_month_rounded,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Scheduled',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlanCommitTaskRow extends StatelessWidget {
  const _PlanCommitTaskRow({
    required this.task,
    required this.index,
    required this.progress,
    required this.sinkProgress,
  });

  final _DraftTaskSpec task;
  final int index;
  final double progress;
  final double sinkProgress;

  @override
  Widget build(BuildContext context) {
    final start = 0.18 + index * 0.10;
    final appear = ((progress - start) / 0.22).clamp(0.0, 1.0).toDouble();
    final opacity =
        (appear * (1 - sinkProgress * 0.55)).clamp(0.0, 1.0).toDouble();

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, (1 - appear) * 16 + sinkProgress * 24),
        child: Container(
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: gdCardLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: gdBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: gdPrimarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: gdPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: gdInk,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down_rounded, color: gdMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _SystemNotificationRequest {
  const _SystemNotificationRequest({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.important,
    required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final bool important;
  final String payload;
}

class GoalDiggerRoot extends StatefulWidget {
  const GoalDiggerRoot({super.key});

  @override
  State<GoalDiggerRoot> createState() => _GoalDiggerRootState();
}

class _GoalDiggerRootState extends State<GoalDiggerRoot>
    with WidgetsBindingObserver {
  final DateTime today = dateOnly(DateTime.now());
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _communityController = TextEditingController();

  bool _onboarded = false;
  String? _profileDisplayName;
  String _signedInWith = 'Guest';
  int _selectedIndex = 2;
  late List<GoalProject> _goals;
  late List<CommunityGroup> _communities;

  final UserRepository _userRepository = UserRepository();
  AppSyncService? _sync;
  StreamSubscription<List<GoalProject>>? _goalsSub;
  StreamSubscription<UserProfile?>? _profileSub;
  StreamSubscription<List<CommunityGroup>>? _communitiesSub;
  StreamSubscription<Set<String>>? _joinedCommunitiesSub;
  StreamSubscription<List<RoutineItem>>? _routinesSub;
  StreamSubscription<List<AppNotification>>? _notificationsSub;
  String? _activeUid;
  bool _syncedGoalsLoaded = false;
  bool _profileLoaded = false;
  Set<String> _joinedCommunityIds = {};
  List<RoutineItem> _routines = [];
  List<AppNotification> _notifications = [];
  final Set<String> _locallyReadNotificationIds = {};
  final AndroidNotificationService _androidNotifications =
      AndroidNotificationService();
  NotificationSettings _notificationSettings =
      const NotificationSettings.defaults();
  Timer? _notificationScheduleDebounce;
  bool _notificationBridgeReady = false;
  bool _notificationPermissionPrompted = false;
  Future<bool>? _notificationPermissionRequest;

  // Auth listener wiring — avoids calling side-effecting _bindAuthState
  // inside build(), which can trigger setState-during-build violations.
  AuthState? _watchedAuthState;

  DateTime _newGoalDeadline = addDays(DateTime.now(), 14);
  int _newGoalPriority = 3;
  String _newGoalCategory = 'Study';

  bool _isProcessing = false;
  double _processingProgress = 0;
  Timer? _processingTimer;
  Timer? _moodAdviceTimer;
  bool _moodAdvisorAvailable = true;
  int _moodAdviceRequestSerial = 0;

  // Task Reassignment Agent (§6.4) — fires when mood/routines change.
  bool _reassignAgentAvailable = true;
  int _reassignRequestSerial = 0;
  // Blocking loader shown while the reassignment agent runs. Ref-counted so
  // overlapping requests share one dialog; the route reference lets us remove
  // exactly our loader even if other dialogs were opened meanwhile.
  int _reassignLoaderDepth = 0;
  DialogRoute<void>? _reassignLoaderRoute;

  String _selectedMood = 'Okay';
  Map<CompanionKind, int> _companionHappiness = {
    CompanionKind.lumi: defaultCompanionHappiness,
  };
  String? _lastHappinessDecayDateKey;
  int _coins = 140;
  int _streak = 0;
  String? _lastStreakDateKey;
  bool _goalReminders = true;
  bool _friendProgressSharing = true;
  List<String> _friends = ['Maya Chen', 'Leo Tan', 'Ari Putra'];
  final List<String> _friendSuggestions = [
    'Nina Rahman',
    'Jay Lim',
    'Sofia Hart'
  ];
  CompanionKind _activeCompanion = CompanionKind.lumi;
  Set<CompanionKind> _unlockedCompanions = {CompanionKind.lumi};

  int get _petHappiness =>
      _companionHappiness[_activeCompanion] ?? defaultCompanionHappiness;

  FocusSessionConfig? _activeFocusConfig;
  int _focusRemainingSeconds = 0;
  DateTime? _focusEndsAt;
  bool _focusPaused = false;
  bool _focusCompletionHandled = false;
  bool _focusDialogOpen = false;
  Timer? _focusTimer;
  final FocusAppBlockingService _focusAppBlocking = FocusAppBlockingService();
  final Set<String> _sentDeadlineSystemNoticeIds = {};

  bool get _hasActiveFocus =>
      _activeFocusConfig != null && _focusRemainingSeconds > 0;
  bool get _focusComplete =>
      _activeFocusConfig != null && _focusRemainingSeconds <= 0;

  Future<void> _syncTaskToGoogleCalendar(
    MicroTask task,
    GoalProject goal,
  ) async {
    final user = context.read<AuthService>().currentUser;

    if (user == null || user.isAnonymous) {
      _showHelpfulError(
        title: 'Account required',
        message: 'Sign in before syncing tasks to Google Calendar.',
        actionLabel: 'OK',
        onAction: () {},
      );
      return;
    }

    try {
      await context.read<GoogleCalendarService>().createTaskEvent(task, goal);
      _showMessage('Task synced to Google Calendar.');
    } on AuthException catch (e) {
      _showHelpfulError(
        title: 'Connect Google Calendar',
        message: e.message,
        actionLabel: 'OK',
        onAction: () {},
      );
    } catch (e) {
      _showHelpfulError(
        title: 'Calendar sync failed',
        message: '$e',
        actionLabel: 'OK',
        onAction: () {},
      );
    }
  }

  Future<void> _syncAllTasksToGoogleCalendar() async {
    final user = context.read<AuthService>().currentUser;

    if (user == null || user.isAnonymous) {
      _showHelpfulError(
        title: 'Account required',
        message: 'Sign in before syncing tasks to Google Calendar.',
        actionLabel: 'OK',
        onAction: () {},
      );
      return;
    }

    if (_allTasks.isEmpty) {
      _showMessage('No tasks available to sync.');
      return;
    }

    try {
      final result = await context
          .read<GoogleCalendarService>()
          .syncAllTaskEvents(_allTasks, _goalForTask);

      _showMessage(
        'Calendar sync complete: ${result.created} created, ${result.skipped} already synced, ${result.failed} failed.',
      );
    } on AuthException catch (e) {
      _showHelpfulError(
        title: 'Connect Google Calendar',
        message: e.message,
        actionLabel: 'OK',
        onAction: () {},
      );
    } catch (e) {
      _showHelpfulError(
        title: 'Calendar sync failed',
        message: '$e',
        actionLabel: 'OK',
        onAction: () {},
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _goals = seedGoals(today);
    _routines = _defaultRoutines();
    _communities = _defaultCommunities();
    unawaited(_initializeNotificationBridge());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Attach a listener to AuthState so auth-change side effects (sync
    // activation, Firestore writes) never run inside build().
    final newAuth = context.read<AuthState>();
    if (_watchedAuthState != newAuth) {
      _watchedAuthState?.removeListener(_onAuthStateChanged);
      _watchedAuthState = newAuth;
      newAuth.addListener(_onAuthStateChanged);
      // Handle the state that is already current on first attach.
      _onAuthStateChanged();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _activeFocusConfig != null) {
      _refreshFocusCountdown();
    }
  }

  // Called by AuthState whenever the Firebase user changes.
  void _onAuthStateChanged() {
    if (!mounted) return;
    final authState = _watchedAuthState;
    if (authState == null) return;

    final uid = authState.uid;
    if (uid.isEmpty) {
      if (_activeUid != null) {
        _resetForSignedOutState();
      }
      return;
    }

    if (_activeUid == uid) return;
    _activeUid = uid;
    _moodAdvisorAvailable = true;
    _reassignAgentAvailable = true;
    _activateSync(uid);
    unawaited(_ensureUserProfile(authState));
  }

  List<RoutineItem> _defaultRoutines() => [
        RoutineItem(
          title: 'Morning goal review',
          startsAt: DateTime(today.year, today.month, today.day, 8),
          repeat: RoutineRepeat.daily,
        ),
        RoutineItem(
          title: 'Evening reflection',
          startsAt: DateTime(today.year, today.month, today.day, 20),
          repeat: RoutineRepeat.weekly,
        ),
      ];

  List<CommunityGroup> _defaultCommunities() => [
        CommunityGroup(
          name: 'Study Sprint Club',
          members: 89,
          tag: 'Exam prep',
          similarity: 94,
          communityStreak: 5,
          description:
              'Short daily sprints for students who want accountability.',
        ),
        CommunityGroup(
          name: 'Portfolio Builders',
          members: 142,
          tag: 'Career',
          similarity: 88,
          communityStreak: 2,
          description:
              'Share portfolio progress and get feedback from builders.',
        ),
        CommunityGroup(
          name: 'Calm Wellness Crew',
          members: 76,
          tag: 'Wellness',
          similarity: 81,
          communityStreak: 1,
          description:
              'Build low-pressure routines around sleep, movement, and reflection.',
        ),
      ];

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _watchedAuthState?.removeListener(_onAuthStateChanged);
    _processingTimer?.cancel();
    _moodAdviceTimer?.cancel();
    _focusTimer?.cancel();
    _notificationScheduleDebounce?.cancel();
    _disposeSync();
    _goalController.dispose();
    _communityController.dispose();
    unawaited(_focusAppBlocking.stopFocusSession());
    super.dispose();
  }

  void _disposeSync() {
    _goalsSub?.cancel();
    _profileSub?.cancel();
    _communitiesSub?.cancel();
    _joinedCommunitiesSub?.cancel();
    _routinesSub?.cancel();
    _notificationsSub?.cancel();
    _goalsSub = null;
    _profileSub = null;
    _communitiesSub = null;
    _joinedCommunitiesSub = null;
    _routinesSub = null;
    _notificationsSub = null;
    _sync?.dispose();
    _sync = null;
    _syncedGoalsLoaded = false;
    _profileLoaded = false;
  }

  void _resetForSignedOutState() {
    _activeUid = null;
    _focusTimer?.cancel();
    _moodAdviceTimer?.cancel();
    _moodAdviceRequestSerial++;
    _moodAdvisorAvailable = true;
    _reassignRequestSerial++;
    _reassignAgentAvailable = true;
    _notificationPermissionRequest = null;
    _disposeSync();
    setState(() {
      _onboarded = false;
      _profileDisplayName = null;
      _signedInWith = 'Guest';
      _selectedIndex = 2;
      _goals = seedGoals(today);
      _routines = _defaultRoutines();
      _notifications = [];
      _locallyReadNotificationIds.clear();
      _sentDeadlineSystemNoticeIds.clear();
      _coins = 140;
      _companionHappiness = {
        CompanionKind.lumi: defaultCompanionHappiness,
      };
      _lastHappinessDecayDateKey = null;
      _streak = 0;
      _lastStreakDateKey = null;
      _activeCompanion = CompanionKind.lumi;
      _unlockedCompanions = {CompanionKind.lumi};
      _notificationSettings = const NotificationSettings.defaults();
      _goalReminders = _notificationSettings.systemNotificationsEnabled;
      _friends = ['Maya Chen', 'Leo Tan', 'Ari Putra'];
      _activeFocusConfig = null;
      _focusRemainingSeconds = 0;
      _focusEndsAt = null;
      _focusPaused = false;
      _focusCompletionHandled = false;
    });
    unawaited(_androidNotifications.cancelAll());
    unawaited(_focusAppBlocking.stopFocusSession());
  }

  Future<void> _ensureUserProfile(AuthState authState) async {
    final user = authState.user ?? context.read<AuthService>().currentUser;
    if (user == null) return;
    try {
      await _userRepository.createOrUpdateProfile(
        uid: user.uid,
        displayName: user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : user.isAnonymous
                ? 'Guest User'
                : 'Goal Digger User',
        email: user.email,
        photoUrl: user.photoURL,
      );
    } catch (e) {
      debugPrint('Could not ensure user profile: $e');
    }
  }

  void _activateSync(String uid) {
    _disposeSync();
    final sync = AppSyncService(uid: uid);
    _sync = sync;
    _syncedGoalsLoaded = false;

    _goalsSub = sync.goalsStream.listen(
      (goals) {
        if (!mounted) return;
        setState(() {
          _goals = goals;
          _syncedGoalsLoaded = true;
        });
        _restoreTodayStreakFromCompletedTask();
        _applyDailyHappinessDecay();
        _queueNotificationScheduleSync();
        _ensureImportantDeadlineNotifications();
      },
      onError: (Object error) => debugPrint('Goal sync error: $error'),
    );

    _profileSub = sync.profileStream.listen(
      (profile) {
        if (!mounted || profile == null) return;
        final user = context.read<AuthService>().currentUser;
        final authDisplayName = user?.displayName?.trim();
        final syncedDisplayName = authDisplayName?.isNotEmpty == true
            ? authDisplayName!
            : profile.displayName.trim();
        final currentStreak = _streakForToday(
          profile.streak,
          profile.lastStreakDateKey,
        );
        setState(() {
          _coins = profile.coins;
          _streak = currentStreak;
          _lastStreakDateKey = profile.lastStreakDateKey;
          _lastHappinessDecayDateKey = profile.lastHappinessDecayDateKey;
          _activeCompanion = profile.activeCompanion;
          _unlockedCompanions = {
            CompanionKind.lumi,
            ...profile.unlockedCompanions,
          };
          _companionHappiness =
              Map<CompanionKind, int>.from(profile.companionHappiness);
          _ensureCompanionState();
          _selectedMood = profile.selectedMood;
          _profileDisplayName = syncedDisplayName.isNotEmpty
              ? syncedDisplayName
              : _profileDisplayName;
          _goalReminders = profile.goalReminders;
          _notificationSettings =
              _normalizedNotificationSettings(profile.notificationSettings);
          _friendProgressSharing = profile.friendProgressSharing;
          _friends = profile.friends.isEmpty
              ? ['Maya Chen', 'Leo Tan', 'Ari Putra']
              : List<String>.from(profile.friends);
          _onboarded = profile.onboarded;
          _profileLoaded = true;
          final providerId = user?.providerData.isNotEmpty == true
              ? user!.providerData.first.providerId
              : null;
          _signedInWith = user?.isAnonymous == true
              ? 'Guest'
              : providerId == 'google.com'
                  ? 'Google'
                  : providerId == 'password'
                      ? 'Email'
                      : 'Firebase';
        });
        if (currentStreak != profile.streak) {
          unawaited(
            sync.updateStreak(
              currentStreak,
              lastStreakDateKey: profile.lastStreakDateKey,
            ),
          );
        }
        _restoreTodayStreakFromCompletedTask();
        _applyDailyHappinessDecay();
        _queueNotificationScheduleSync();
        _syncStreakFromCompletedTasks();
      },
      onError: (Object error) => debugPrint('Profile sync error: $error'),
    );

    _communitiesSub = sync.communitiesStream.listen(
      (communities) {
        if (!mounted || communities.isEmpty) return;
        setState(() => _communities = _withJoinedCommunityState(communities));
      },
      onError: (Object error) => debugPrint('Community sync error: $error'),
    );

    _joinedCommunitiesSub = sync.joinedCommunityIdsStream.listen(
      (ids) {
        if (!mounted) return;
        setState(() {
          _joinedCommunityIds = ids;
          _communities = _withJoinedCommunityState(_communities);
        });
      },
      onError: (Object error) => debugPrint('Membership sync error: $error'),
    );

    _routinesSub = sync.routinesStream.listen(
      (routines) {
        if (!mounted) return;
        setState(() => _routines = routines);
        _queueNotificationScheduleSync();
      },
      onError: (Object error) => debugPrint('Routine sync error: $error'),
    );

    _notificationsSub = sync.notificationsStream.listen(
      (notifications) {
        if (!mounted) return;
        final now = DateTime.now();
        final mergedNotifications = notifications
            .map(
              (notification) =>
                  _locallyReadNotificationIds.contains(notification.id) &&
                          notification.isUnread
                      ? notification.copyWith(readAt: now)
                      : notification,
            )
            .toList();
        setState(() => _notifications = mergedNotifications);
        _ensureImportantDeadlineNotifications();
      },
      onError: (Object error) => debugPrint('Notification sync error: $error'),
    );
  }

  List<CommunityGroup> _withJoinedCommunityState(List<CommunityGroup> groups) {
    for (final group in groups) {
      final id = group.backendId;
      if (id != null) group.joined = _joinedCommunityIds.contains(id);
    }
    return groups;
  }

  int _clampCompanionHappiness(int happiness) {
    return max(0, min(100, happiness));
  }

  int _happinessFor(CompanionKind companion) {
    return _companionHappiness[companion] ?? defaultCompanionHappiness;
  }

  Map<CompanionKind, int> _companionHappinessForPersistence() {
    final companions = {CompanionKind.lumi, ..._unlockedCompanions};
    return {
      for (final companion in companions)
        companion: _clampCompanionHappiness(_happinessFor(companion)),
    };
  }

  void _ensureCompanionState() {
    _unlockedCompanions = {CompanionKind.lumi, ..._unlockedCompanions};
    _companionHappiness.removeWhere((companion, happiness) {
      if (companion == CompanionKind.lumi) return false;
      final shouldLock =
          happiness <= 0 || !_unlockedCompanions.contains(companion);
      if (shouldLock) _unlockedCompanions.remove(companion);
      return shouldLock;
    });
    _companionHappiness.putIfAbsent(
      CompanionKind.lumi,
      () => defaultCompanionHappiness,
    );
    for (final companion in _unlockedCompanions) {
      _companionHappiness.putIfAbsent(
        companion,
        () => defaultCompanionHappiness,
      );
    }
    if (!_unlockedCompanions.contains(_activeCompanion)) {
      _activeCompanion = CompanionKind.lumi;
    }
  }

  void _setCompanionHappiness(CompanionKind companion, int happiness) {
    final clamped = _clampCompanionHappiness(happiness);
    if (companion != CompanionKind.lumi && clamped <= 0) {
      _unlockedCompanions.remove(companion);
      _companionHappiness.remove(companion);
      if (_activeCompanion == companion) {
        _activeCompanion = CompanionKind.lumi;
      }
      _ensureCompanionState();
      return;
    }
    _companionHappiness[companion] = clamped;
    _ensureCompanionState();
  }

  void _adjustActiveCompanionHappiness(int delta) {
    _setCompanionHappiness(
      _activeCompanion,
      _happinessFor(_activeCompanion) + delta,
    );
  }

  void _applyCompanionSwitchPenalty(CompanionKind companion) {
    final current = _happinessFor(companion);
    if (current < companionSwitchHappinessFloor) return;
    _setCompanionHappiness(
      companion,
      max(
        companionSwitchHappinessFloor,
        current - companionSwitchHappinessPenalty,
      ),
    );
  }

  void _unlockCompanion(CompanionKind companion) {
    _unlockedCompanions = {
      CompanionKind.lumi,
      ..._unlockedCompanions,
      companion,
    };
    _companionHappiness[companion] = defaultCompanionHappiness;
    _ensureCompanionState();
  }

  Future<void> _persistProfileStats() async {
    final sync = _sync;
    if (sync == null) return;
    final coins = _coins;
    final streak = _streak;
    final lastStreakDateKey = _lastStreakDateKey;
    final selectedMood = _selectedMood;
    final petHappiness = _petHappiness;
    final companionHappiness = _companionHappinessForPersistence();
    final lastHappinessDecayDateKey = _lastHappinessDecayDateKey;
    final activeCompanion = _activeCompanion;
    final unlockedCompanions = Set<CompanionKind>.from(_unlockedCompanions)
      ..add(CompanionKind.lumi);
    try {
      await sync.updateProfileStats(
        coins: coins,
        streak: streak,
        lastStreakDateKey: lastStreakDateKey,
        selectedMood: selectedMood,
        petHappiness: petHappiness,
        companionHappiness: companionHappiness,
        lastHappinessDecayDateKey: lastHappinessDecayDateKey,
        activeCompanion: activeCompanion,
        unlockedCompanions: unlockedCompanions,
      );
    } catch (e) {
      debugPrint('Profile write failed: $e');
    }
  }

  Future<void> _persistMood(String mood) async {
    final sync = _sync;
    if (sync == null) return;
    try {
      await sync.updateMood(mood);
    } catch (e) {
      debugPrint('Mood write failed: $e');
    }
  }

  Future<void> _persistPreferences() async {
    final sync = _sync;
    if (sync == null) return;
    try {
      await sync.updatePreferences(
        goalReminders: _goalReminders,
        friendProgressSharing: _friendProgressSharing,
        notificationSettings: _notificationSettings,
      );
    } catch (e) {
      debugPrint('Preference write failed: $e');
    }
  }

  void _setGoalReminders(bool value) {
    setState(() {
      _goalReminders = value;
      _notificationSettings = _notificationSettings.copyWith(
        systemNotificationsEnabled: value,
      );
    });
    unawaited(_persistPreferences());
    _queueNotificationScheduleSync();
  }

  void _setFriendProgressSharing(bool value) {
    setState(() => _friendProgressSharing = value);
    unawaited(_persistPreferences());
  }

  NotificationSettings _normalizedNotificationSettings(
    NotificationSettings settings,
  ) {
    return settings.inAppNotificationsEnabled
        ? settings
        : settings.copyWith(importantInAppEnabled: false);
  }

  void _setNotificationSettings(NotificationSettings settings) {
    final normalizedSettings = _normalizedNotificationSettings(settings);

    setState(() {
      _notificationSettings = normalizedSettings;
      _goalReminders = normalizedSettings.systemNotificationsEnabled;
    });

    if (!normalizedSettings.inAppNotificationsEnabled) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }

    unawaited(_persistPreferences());
    _queueNotificationScheduleSync();
  }

  Future<void> _handleSignOut() async {
    unawaited(Navigator.of(context).maybePop());
    try {
      await context.read<AuthState>().signOut();
    } catch (e) {
      debugPrint('Sign out failed: $e');
    }
    if (!mounted) return;
    _resetForSignedOutState();
  }

  Future<void> _completeOnboardingWithAuth(String provider) async {
    final authState = context.read<AuthState>();
    try {
      if (provider == 'Google') {
        await authState.signInWithGoogle();
      } else {
        await authState.signInAsGuest();
      }
      await _finishAuthenticatedOnboarding(provider, authState);
    } catch (e) {
      _showAuthFailure(provider, e);
    }
  }

  Future<void> _completeOnboardingWithEmail({
    required String email,
    required String password,
    required bool isSignUp,
    String? displayName,
  }) async {
    final authState = context.read<AuthState>();
    try {
      if (isSignUp) {
        await authState.createAccountWithEmail(
          email: email,
          password: password,
          displayName: displayName,
        );
      } else {
        await authState.signInWithEmail(email, password);
      }
      await _finishAuthenticatedOnboarding('Email', authState);
    } catch (e) {
      _showAuthFailure('Email', e);
    }
  }

  Future<void> _finishAuthenticatedOnboarding(
    String provider,
    AuthState authState,
  ) async {
    final user = context.read<AuthService>().currentUser ?? authState.user;
    if (user == null) {
      if (authState.errorMessage != null) return;
      throw StateError('Firebase did not return a signed-in user.');
    }

    final displayName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : provider == 'Guest'
            ? 'Guest User'
            : 'Goal Digger User';

    await _userRepository.createOrUpdateProfile(
      uid: user.uid,
      displayName: displayName,
      email: user.email,
      photoUrl: user.photoURL,
    );
    await _userRepository.markOnboarded(user.uid);
    _activeUid = user.uid;
    _activateSync(user.uid);

    if (!mounted) return;
    authState.clearError();
    setState(() {
      _profileDisplayName = displayName;
      _signedInWith = provider;
      _onboarded = true;
    });
    _queueNotificationScheduleSync();
    _showMessage('Welcome! You signed in with $provider.');
  }

  void _showAuthFailure(String provider, Object error) {
    if (!mounted) return;
    _showHelpfulError(
      title: '$provider sign-in failed',
      message:
          'Firebase could not complete sign-in. Check that Firebase Auth is enabled and your app uses the correct Firebase project. Details: $error',
      actionLabel: 'Continue as guest',
      onAction: () => unawaited(_completeOnboardingWithAuth('Guest')),
    );
  }

  List<MicroTask> get _allTasks => _goals.expand((goal) => goal.tasks).toList();

  List<MicroTask> get _todayTasks =>
      _allTasks.where((task) => dateOnly(task.scheduledDate) == today).toList();

  GoalProject _goalForTask(MicroTask task) {
    return _goals.firstWhere((goal) => goal.id == task.goalId);
  }

  int get _todayCompleted => _todayTasks.where((task) => task.done).length;

  double get _todayProgress =>
      _todayTasks.isEmpty ? 0 : _todayCompleted / _todayTasks.length;

  int get _calculatedCurrentStreak {
    final completedDays = _allTasks
        .where((task) => task.done)
        .map((task) => dateOnly(task.scheduledDate))
        .where((day) => !day.isAfter(today))
        .map(dateKey)
        .toSet();

    if (completedDays.isEmpty) return 0;

    var day =
        completedDays.contains(dateKey(today)) ? today : addDays(today, -1);
    if (!completedDays.contains(dateKey(day))) return 0;

    var streak = 0;
    while (completedDays.contains(dateKey(day))) {
      streak++;
      day = addDays(day, -1);
    }

    return streak;
  }

  void _syncStreakFromCompletedTasks() {
    if (_sync != null && !_syncedGoalsLoaded) return;

    final nextStreak = _calculatedCurrentStreak;
    if (nextStreak == _streak) return;

    setState(() => _streak = nextStreak);

    final sync = _sync;
    if (sync == null) return;
    unawaited(sync.updateStreak(nextStreak).catchError((Object e) {
      debugPrint('Streak sync failed: $e');
    }));
  }

  int get _remainingMinutes => _todayTasks
      .where((task) => !task.done)
      .fold(0, (sum, task) => sum + task.durationMinutes);

  Map<String, dynamic> _socialSuggestionContext() {
    final activeGoals = _goals
        .where((goal) => goal.progress < 1)
        .take(8)
        .map((goal) => goal.title)
        .toList();
    final categories = _goals
        .map((goal) => goal.category)
        .where((category) => category.trim().isNotEmpty)
        .toSet()
        .take(8)
        .toList();
    final todayTasks = _todayTasks
        .take(10)
        .map((task) => task.title)
        .where((title) => title.trim().isNotEmpty)
        .toList();
    final taskLoads = _todayTasks
        .map((task) => task.load.label.toLowerCase())
        .toSet()
        .toList();

    return {
      'mood': _selectedMood,
      'streak': _streak,
      'completedToday': _todayCompleted,
      'totalToday': _todayTasks.length,
      'remainingMinutes': _remainingMinutes,
      'goals': activeGoals,
      'categories': categories,
      'todayTasks': todayTasks,
      'taskLoads': taskLoads,
    };
  }

  DateTime? _dateFromKey(String? key) {
    if (key == null || key.trim().isEmpty) return null;
    final parts = key.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    return dateOnly(DateTime(year, month, day));
  }

  int _streakForToday(int streak, String? lastStreakDateKey) {
    final lastStreakDay = _dateFromKey(lastStreakDateKey);
    if (lastStreakDay == null) return streak;

    final gap = daysBetween(lastStreakDay, dateOnly(DateTime.now()));
    return gap > 1 ? 0 : streak;
  }

  bool _awardTaskCompletionStreak() {
    final streakDay = dateOnly(DateTime.now());
    final streakDayKey = dateKey(streakDay);
    if (_lastStreakDateKey == streakDayKey) return false;

    final lastStreakDay = _dateFromKey(_lastStreakDateKey);
    final daysSinceLast =
        lastStreakDay == null ? null : daysBetween(lastStreakDay, streakDay);

    if (daysSinceLast == null) {
      _streak = max(1, _streak + 1);
    } else if (daysSinceLast == 1) {
      _streak += 1;
    } else if (daysSinceLast == 0) {
      return false;
    } else {
      _streak = 1;
    }

    _lastStreakDateKey = streakDayKey;
    return true;
  }

  void _restoreTodayStreakFromCompletedTask() {
    if (!_syncedGoalsLoaded || !_profileLoaded) return;
    if (_todayCompleted == 0) return;
    if (_lastStreakDateKey == dateKey(DateTime.now())) return;

    var streakAwarded = false;
    setState(() {
      streakAwarded = _awardTaskCompletionStreak();
    });
    if (streakAwarded) {
      unawaited(_persistProfileStats());
    }
  }

  void _applyDailyHappinessDecay() {
    if (!_syncedGoalsLoaded || !_profileLoaded) return;

    final currentDay = dateOnly(DateTime.now());
    final currentDayKey = dateKey(currentDay);
    final lastDecayDay = _dateFromKey(_lastHappinessDecayDateKey);

    if (lastDecayDay == null) {
      setState(() => _lastHappinessDecayDateKey = currentDayKey);
      unawaited(_persistProfileStats());
      return;
    }

    if (!lastDecayDay.isBefore(currentDay)) {
      if (lastDecayDay.isAfter(currentDay)) {
        setState(() => _lastHappinessDecayDateKey = currentDayKey);
        unawaited(_persistProfileStats());
      }
      return;
    }

    var day = addDays(lastDecayDay, 1);
    var decay = 0;
    while (!day.isAfter(currentDay)) {
      final previousDay = addDays(day, -1);
      final completedYesterday = _completedTaskCountOn(previousDay);
      decay += completedYesterday == 0 ? 20 : 10;
      day = addDays(day, 1);
    }

    setState(() {
      final companions = List<CompanionKind>.from(_unlockedCompanions);
      for (final companion in companions) {
        _setCompanionHappiness(companion, _happinessFor(companion) - decay);
      }
      _lastHappinessDecayDateKey = currentDayKey;
    });
    unawaited(_persistProfileStats());
  }

  int _completedTaskCountOn(DateTime day) {
    final target = dateOnly(day);
    return _allTasks
        .where((task) => dateOnly(task.scheduledDate) == target && task.done)
        .length;
  }

  bool _routineOccursOn(RoutineItem routine, DateTime date) {
    final day = dateOnly(date);
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
  }

  int _routineCountForDate(DateTime date) =>
      _routines.where((routine) => _routineOccursOn(routine, date)).length;

  List<String> _goalGenerationStatusLines(int deadlineDays) {
    final routinesToday = _routineCountForDate(today);
    return [
      'Reading deadline: ${shortDate(_newGoalDeadline)}',
      'Checking workload: $_remainingMinutes min today',
      'Factoring mood: $_selectedMood',
      routinesToday == 0
          ? 'Checking saved routines'
          : 'Reviewing $routinesToday routine${routinesToday == 1 ? '' : 's'} today',
      'Building milestones across $deadlineDays day${deadlineDays == 1 ? '' : 's'}',
    ];
  }

  List<String> _goalAiContextChips(int deadlineDays) {
    final routinesToday = _routineCountForDate(today);
    return [
      'Mood: $_selectedMood',
      'Deadline: ${shortDate(_newGoalDeadline)}',
      '$deadlineDays day${deadlineDays == 1 ? '' : 's'} left',
      'Workload: $_remainingMinutes min today',
      'Routines: $routinesToday today',
      'Priority: $_newGoalPriority/5',
    ];
  }

  List<String> _reassignmentStatusLines(String trigger) {
    final unfinished = _allTasks.where((task) => !task.done).length;
    final routinesToday = _routineCountForDate(today);
    final triggerLine = switch (trigger) {
      'moodChanged' => 'Mood changed to $_selectedMood',
      'routineAdded' => 'New routine added',
      _ => 'Context changed',
    };

    return [
      triggerLine,
      'Checking $unfinished unfinished task${unfinished == 1 ? '' : 's'}',
      'Reading $routinesToday routine${routinesToday == 1 ? '' : 's'} today',
      'Looking for lighter days',
      'Moving flexible tasks only',
    ];
  }

  String _formatFocusTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }

  void _showMessage(String message) {
    if (!mounted) return;
    if (!_notificationSettings.inAppNotificationsEnabled) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _showCoinRewardPrompt(int coins, String reason) {
    if (coins <= 0) return;
    _showMessage('${_activeCompanion.label} says: +$coins coins $reason.');
  }

  void _showHelpfulError({
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Icon(Icons.error_outline_rounded, color: gdError),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                onAction();
              },
              child: Text(actionLabel),
            ),
          ],
        );
      },
    );
  }

  Future<void> _initializeNotificationBridge() async {
    _notificationBridgeReady = await _androidNotifications.initialize();
    _queueNotificationScheduleSync();
  }

  void _queueNotificationScheduleSync() {
    _notificationScheduleDebounce?.cancel();
    _notificationScheduleDebounce =
        Timer(const Duration(milliseconds: 350), () {
      unawaited(_syncSystemNotifications());
    });
  }

  Future<void> _syncSystemNotifications() async {
    if (!_onboarded) return;
    if (!_androidNotifications.isSupported) return;
    if (!_notificationBridgeReady) {
      _notificationBridgeReady = await _androidNotifications.initialize();
    }

    if (!_notificationSettings.hasAnySystemNotification) {
      await _androidNotifications.cancelAll();
      return;
    }

    final allowed = await _ensureAndroidNotificationPermission();
    if (!allowed) {
      await _androidNotifications.cancelAll();
      _addInAppNotification(
        id: 'important_android_notifications_disabled',
        title: 'Android notifications are off',
        body:
            'Goal Digger cannot show routine, streak, deadline, or focus pop-ups until notification permission is enabled.',
        type: AppNotificationType.important,
        important: true,
        sourceId: 'android_permission',
      );
      return;
    }

    await _androidNotifications.cancelScheduled();
    final requests = _buildSystemNotificationRequests();
    for (final request in requests.take(80)) {
      await _androidNotifications.schedule(
        id: request.id,
        title: request.title,
        body: request.body,
        scheduledAt: request.scheduledAt,
        important: request.important,
        payload: request.payload,
      );
    }
  }

  Future<bool> _ensureAndroidNotificationPermission() async {
    if (await _androidNotifications.areNotificationsEnabled()) return true;
    final pendingRequest = _notificationPermissionRequest;
    if (pendingRequest != null) return pendingRequest;
    if (_notificationPermissionPrompted) return false;
    _notificationPermissionPrompted = true;
    final request = () async {
      final granted = await _androidNotifications.requestPermission();
      if (!granted) return false;
      return _androidNotifications.areNotificationsEnabled();
    }();
    _notificationPermissionRequest = request;
    try {
      return await request;
    } finally {
      _notificationPermissionRequest = null;
    }
  }

  Future<void> _showSystemNotificationNow({
    required String key,
    required String title,
    required String body,
    required AppNotificationType type,
    bool important = false,
    String? sourceId,
  }) async {
    if (!_androidNotifications.isSupported) return;
    if (!_notificationBridgeReady) {
      _notificationBridgeReady = await _androidNotifications.initialize();
    }
    final allowed = await _ensureAndroidNotificationPermission();
    if (!allowed) return;

    final id = _stableNotificationId(key);
    await _androidNotifications.cancel(id);
    await _androidNotifications.showNow(
      id: id,
      title: title,
      body: body,
      important: important,
      payload: '${type.name}:${sourceId ?? key}',
    );
  }

  List<_SystemNotificationRequest> _buildSystemNotificationRequests() {
    final now = DateTime.now();
    final start = dateOnly(now);
    final horizon = addDays(start, 30);
    final requests = <_SystemNotificationRequest>[];

    void addRequest({
      required String key,
      required String title,
      required String body,
      required DateTime scheduledAt,
      required AppNotificationType type,
      bool important = false,
      String? sourceId,
    }) {
      if (!scheduledAt.isAfter(now)) return;
      if (!scheduledAt.isBefore(horizon)) return;
      requests.add(
        _SystemNotificationRequest(
          id: _stableNotificationId(key),
          title: title,
          body: body,
          scheduledAt: scheduledAt,
          important: important,
          payload: '${type.name}:${sourceId ?? key}',
        ),
      );
    }

    if (_notificationSettings.dailyPlanEnabled) {
      for (var offset = 0; offset < 7; offset++) {
        final day = addDays(start, offset);
        final tasks = _unfinishedTasksForDay(day);
        if (tasks.isEmpty) continue;
        final minutes = tasks.fold<int>(
          0,
          (sum, task) => sum + task.durationMinutes,
        );
        addRequest(
          key: 'daily_plan_${dateKey(day)}',
          title: 'Today in Goal Digger',
          body:
              '${tasks.length} goal action${tasks.length == 1 ? '' : 's'} are waiting, about $minutes minutes total.',
          scheduledAt: _dateAtNotificationTime(
            day,
            _notificationSettings.dailyPlanHour,
            _notificationSettings.dailyPlanMinute,
          ),
          type: AppNotificationType.dailyPlan,
          sourceId: dateKey(day),
        );
      }
    }

    if (_notificationSettings.streakSaverEnabled) {
      for (var offset = 0; offset < 7; offset++) {
        final day = addDays(start, offset);
        final tasks = _unfinishedTasksForDay(day);
        if (tasks.isEmpty) continue;
        if (dateOnly(day) == start && _todayCompleted > 0) continue;
        addRequest(
          key: 'streak_${dateKey(day)}',
          title: 'Protect your streak',
          body: 'One small completed task keeps your momentum alive.',
          scheduledAt: _dateAtNotificationTime(
            day,
            _notificationSettings.streakSaverHour,
            _notificationSettings.streakSaverMinute,
          ),
          type: AppNotificationType.streakSaver,
          important: offset == 0,
          sourceId: dateKey(day),
        );
      }
    }

    if (_notificationSettings.deadlineWarningsEnabled) {
      for (final goal in _goals.where((goal) => goal.progress < 1)) {
        final deadlineDay = dateOnly(goal.deadline);
        final daysLeft = daysBetween(start, deadlineDay);
        final warningDay =
            addDays(deadlineDay, -_notificationSettings.deadlineWarningDays);
        final candidateDays = <String, DateTime>{
          'warning': warningDay,
          'deadline': deadlineDay,
          if (daysLeft < 0) 'overdue': start,
        };

        for (final entry in candidateDays.entries) {
          final day = entry.value;
          if (day.isBefore(start)) continue;
          addRequest(
            key: 'deadline_${goal.id}_${entry.key}_${dateKey(day)}',
            title: daysLeft < 0 ? 'Goal overdue' : 'Deadline coming up',
            body:
                '${goal.title} is ${daysLeft < 0 ? 'overdue' : 'due in $daysLeft day${daysLeft == 1 ? '' : 's'}'}.',
            scheduledAt: _dateAtNotificationTime(
              day,
              _notificationSettings.dailyPlanHour,
              _notificationSettings.dailyPlanMinute,
            ).add(const Duration(minutes: 45)),
            type: AppNotificationType.deadlineWarning,
            important: daysLeft <= 1,
            sourceId: goal.id.toString(),
          );
        }
      }
    }

    if (_notificationSettings.routineRemindersEnabled) {
      for (final routine in _routines) {
        for (final occurrence in _routineOccurrences(routine, now, horizon)) {
          addRequest(
            key: 'routine_${routine.id}_${occurrence.millisecondsSinceEpoch}',
            title: routine.title,
            body: '${routine.repeat.label} routine in Goal Digger.',
            scheduledAt: occurrence,
            type: AppNotificationType.routineReminder,
            sourceId: routine.id,
          );
        }
      }
    }

    final focusConfig = _activeFocusConfig;
    if (_notificationSettings.focusNotificationsEnabled &&
        focusConfig != null &&
        _focusRemainingSeconds > 0 &&
        !_focusPaused) {
      addRequest(
        key: 'focus_complete',
        title: 'Focus session complete',
        body: '${focusConfig.title} is ready to wrap up.',
        scheduledAt: now.add(Duration(seconds: _focusRemainingSeconds)),
        type: AppNotificationType.focusComplete,
        important: true,
        sourceId: focusConfig.title,
      );
    }

    requests.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return requests;
  }

  List<MicroTask> _unfinishedTasksForDay(DateTime day) {
    final target = dateOnly(day);
    return _allTasks
        .where(
          (task) => dateOnly(task.scheduledDate) == target && !task.done,
        )
        .toList()
      ..sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
  }

  DateTime _dateAtNotificationTime(DateTime day, int hour, int minute) {
    final date = dateOnly(day);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  Iterable<DateTime> _routineOccurrences(
    RoutineItem routine,
    DateTime now,
    DateTime horizon,
  ) sync* {
    var current = routine.startsAt;
    while (current.isBefore(now)) {
      final next = _nextRoutineOccurrence(current, routine.repeat);
      if (!next.isAfter(current)) return;
      current = next;
    }

    var emitted = 0;
    while (current.isBefore(horizon) && emitted < 40) {
      yield current;
      emitted++;
      if (routine.repeat == RoutineRepeat.custom) return;
      current = _nextRoutineOccurrence(current, routine.repeat);
    }
  }

  DateTime _nextRoutineOccurrence(DateTime from, RoutineRepeat repeat) {
    switch (repeat) {
      case RoutineRepeat.daily:
        return from.add(const Duration(days: 1));
      case RoutineRepeat.weekly:
        return from.add(const Duration(days: 7));
      case RoutineRepeat.monthly:
        final month = DateTime(from.year, from.month + 1);
        final day = min(from.day, DateTime(month.year, month.month + 1, 0).day);
        return DateTime(
          month.year,
          month.month,
          day,
          from.hour,
          from.minute,
        );
      case RoutineRepeat.yearly:
        final year = from.year + 1;
        final day = min(from.day, DateTime(year, from.month + 1, 0).day);
        return DateTime(year, from.month, day, from.hour, from.minute);
      case RoutineRepeat.custom:
        return from.add(const Duration(days: 3650));
    }
  }

  int _stableNotificationId(String key) {
    var hash = 0x811c9dc5;
    for (final codeUnit in key.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash == 0 ? 1 : hash;
  }

  bool _addInAppNotification({
    String? id,
    required String title,
    required String body,
    required AppNotificationType type,
    bool important = false,
    String? sourceId,
    Map<String, dynamic>? payload,
  }) {
    if (!_notificationSettings.inAppNotificationsEnabled) {
      return false;
    }
    if (important && !_notificationSettings.importantInAppEnabled) {
      return false;
    }

    final notificationId =
        id ?? 'local_${DateTime.now().microsecondsSinceEpoch}';
    if (_notifications.any((item) => item.id == notificationId)) return false;

    final notification = AppNotification(
      id: notificationId,
      title: title,
      body: body,
      type: type,
      delivery: NotificationDelivery.inApp,
      createdAt: DateTime.now(),
      important: important,
      sourceId: sourceId,
      payload: payload,
    );

    if (mounted) {
      setState(() => _notifications = [notification, ..._notifications]);
    }

    final sync = _sync;
    if (sync != null) {
      unawaited(sync.addNotification(notification).catchError((Object e) {
        debugPrint('Notification save failed: $e');
      }));
    }

    if (important) _showImportantNotificationSnack(notification);
    return true;
  }

  void _showImportantNotificationSnack(AppNotification notification) {
    if (!mounted) return;
    final isPermissionNotice = notification.sourceId == 'android_permission';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Important: ${notification.title}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: isPermissionNotice ? 'Settings' : 'Inbox',
          onPressed: isPermissionNotice
              ? _openAndroidNotificationSettings
              : _openNotifications,
        ),
      ),
    );
  }

  void _ensureImportantDeadlineNotifications() {
    final todayKey = dateKey(today);
    for (final goal in _goals.where((goal) => goal.progress < 1)) {
      final daysLeft = daysBetween(today, goal.deadline);
      if (daysLeft > 1) continue;
      final id = 'important_deadline_${goal.id}_$todayKey';
      final title = daysLeft < 0 ? 'Goal is overdue' : 'Goal deadline is near';
      final body = daysLeft < 0
          ? '${goal.title} is overdue. Pick one unfinished task to regain control.'
          : '${goal.title} is due ${daysLeft == 0 ? 'today' : 'tomorrow'}.';
      _addInAppNotification(
        id: id,
        title: title,
        body: body,
        type: AppNotificationType.important,
        important: true,
        sourceId: goal.id.toString(),
      );
      if (_notificationSettings.systemNotificationsEnabled &&
          _notificationSettings.deadlineWarningsEnabled &&
          _sentDeadlineSystemNoticeIds.add(id)) {
        unawaited(
          _showSystemNotificationNow(
            key: 'system_$id',
            title: title,
            body: body,
            type: AppNotificationType.deadlineWarning,
            important: true,
            sourceId: goal.id.toString(),
          ),
        );
      }
    }
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => NotificationInboxPage(
          notifications: _notifications,
          onMarkRead: _markNotificationRead,
          onMarkAllRead: _markAllNotificationsRead,
          onDelete: _deleteNotification,
          onOpenNotificationSettings: _openAndroidNotificationSettings,
        ),
      ),
    );
  }

  void _openAndroidNotificationSettings() {
    if (!_androidNotifications.isSupported) {
      _openSettings();
      return;
    }
    unawaited(_androidNotifications.openNotificationSettings());
  }

  void _markNotificationRead(AppNotification notification) {
    if (!notification.isUnread) return;
    setState(() {
      _locallyReadNotificationIds.add(notification.id);
      _notifications = _notifications
          .map((item) => item.id == notification.id
              ? item.copyWith(readAt: DateTime.now())
              : item)
          .toList();
    });
    final sync = _sync;
    if (sync != null) {
      unawaited(
        sync.markNotificationRead(notification.id).catchError((Object e) {
          debugPrint('Notification read sync failed: $e');
        }),
      );
    }
  }

  void _markAllNotificationsRead() {
    final now = DateTime.now();
    setState(() {
      _locallyReadNotificationIds
          .addAll(_notifications.map((notification) => notification.id));
      _notifications = _notifications
          .map((item) => item.isUnread ? item.copyWith(readAt: now) : item)
          .toList();
    });
    final sync = _sync;
    if (sync != null) {
      unawaited(sync.markAllNotificationsRead().catchError((Object e) {
        debugPrint('Notification mark-all sync failed: $e');
      }));
    }
  }

  void _deleteNotification(AppNotification notification) {
    setState(() {
      _notifications =
          _notifications.where((item) => item.id != notification.id).toList();
    });
    final sync = _sync;
    if (sync != null) {
      unawaited(sync.deleteNotification(notification.id).catchError((Object e) {
        debugPrint('Notification delete sync failed: $e');
      }));
    }
  }

  Future<void> _sendTestNotification() async {
    if (!_androidNotifications.isSupported) {
      _showMessage('Android notifications are only available on Android.');
      return;
    }
    final allowed = await _ensureAndroidNotificationPermission();
    if (!allowed) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Android notification permission is not enabled.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: _openAndroidNotificationSettings,
          ),
        ),
      );
      return;
    }
    await _androidNotifications.showNow(
      id: _stableNotificationId(
          'test_${DateTime.now().millisecondsSinceEpoch}'),
      title: 'Goal Digger test',
      body: 'Android notifications are ready.',
      important: true,
      payload: 'test',
    );
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _newGoalDeadline,
      firstDate: today,
      lastDate: DateTime(today.year + 5),
    );
    if (picked != null) setState(() => _newGoalDeadline = picked);
  }

  String _goalGuardReplyFromPlan(AgentPlannerResponse plan) {
    final reason = plan.goalRejectionReason?.trim();
    final prompt = plan.goalRefinementPrompt?.trim();
    final parts = [
      if (reason != null && reason.isNotEmpty) reason,
      if (prompt != null && prompt.isNotEmpty) prompt,
    ];
    if (parts.isEmpty) {
      // §9.1: a failed positive-goal check gets a positivity-specific ask.
      return plan.positiveGoal
          ? "I can't generate todos for this goal as written. Please redefine it as a clear, constructive, achievable outcome."
          : 'This goal is framed around something negative to avoid rather than a positive outcome to reach. Please re-enter it as a positive outcome you want to achieve.';
    }
    return parts.join('\n\n');
  }

  void _createGoalWithProgress() {
    final title = _goalController.text.trim();
    if (title.isEmpty) {
      _showHelpfulError(
        title: 'Goal name is missing',
        message:
            'Please write one clear goal first. Example: "Prepare for midterm" or "Build my portfolio".',
        actionLabel: 'Write goal',
        onAction: () {},
      );
      return;
    }
    _openGoalBreakdownDialog(title);
  }

  Future<void> _openGoalBreakdownDialog(String title) async {
    // Create the controller here and dispose it reliably when the dialog closes.
    final chatController = TextEditingController();

    try {
      await _runGoalBreakdownDialog(title, chatController);
    } finally {
      FocusManager.instance.primaryFocus?.unfocus();
      await WidgetsBinding.instance.endOfFrame;
      // Guaranteed disposal after the dialog route has torn down its frame.
      chatController.dispose();
    }
  }

  // Loose yes/no detection for the "are you sure?" feasibility confirmation.
  bool _isAffirmativeReply(String text) {
    final s = text.trim().toLowerCase();
    return RegExp(
      r"^(y|ya|yes|yeah|yep|yup|sure|ok|okay|confirm|confirmed|do it|go ahead|proceed|absolutely|definitely|i'?m sure|still want|keep all)\b",
    ).hasMatch(s);
  }

  bool _isNegativeReply(String text) {
    final s = text.trim().toLowerCase();
    return RegExp(
      r"^(n|no|nope|nah|cancel|stop|never mind|nevermind|don'?t|do not|keep it|leave it|that'?s fine|fewer|less)\b",
    ).hasMatch(s);
  }

  // Centered, non-dismissible loading card shown while the AI generates a plan.
  Widget _buildGeneratingLoader(
    String label, {
    List<String> statusLines = const [],
  }) {
    final adjusting = label.toLowerCase().contains('adjust');
    final title = adjusting ? 'Rebalancing your schedule' : 'Growing your plan';
    final message = adjusting
        ? 'Moving unfinished tasks into a calmer timeline.'
        : 'Planting your goal into small, realistic steps.';
    final effectiveStatusLines = statusLines.isNotEmpty
        ? statusLines
        : [
            adjusting ? 'Checking unfinished tasks' : 'Reading your deadline',
            adjusting
                ? 'Looking for lighter days'
                : 'Checking current workload',
            adjusting
                ? 'Moving flexible tasks only'
                : 'Building realistic milestones',
          ];

    return PopScope(
      canPop: false,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
            decoration: BoxDecoration(
              color: gdSurface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: gdBorder),
              boxShadow: [
                BoxShadow(
                  color: gdShadow.withValues(alpha: 0.16),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _SproutLoadingMark(),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: gdInk,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: gdMuted,
                    fontSize: 13.5,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _LoadingStatusFeed(lines: effectiveStatusLines),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _runGoalBreakdownDialog(
      String title, TextEditingController chatController) async {
    final ai = context.read<GenkitService>();
    // Mutable: the agent can propose a different deadline and, if the user
    // agrees, the dialog re-plans against the adjusted horizon.
    var deadlineDays =
        max(1, dateOnly(_newGoalDeadline).difference(today).inDays);
    var currentTitle = title;
    // Set while the agent's deadline suggestion awaits a yes/no answer.
    int? pendingDeadlineDays;
    var draftSpecs = <_DraftTaskSpec>[];
    var aiAvailable = false;
    var fromAgent = false;
    var awaitingGoalRefinement = false;
    String? guardReply;
    String? agentStrategy;
    String? agentHabitInsight;
    String? agentRecommendation;
    String? agentScheduleNote;
    String? agentBurnoutRisk;
    var agentDegraded = false;
    List<_DraftTaskSpec> agentSpecs = const [];
    const guardUnavailableReply =
        "I can't verify this goal right now, so I won't generate todos for it.\n\nPlease try again, or rewrite it as a clear, constructive, achievable real-world outcome.";

    // Minutes already booked by existing (incomplete) tasks for each day
    // between today and the deadline (capped at 30 entries). Lets the agent
    // judge a deadline as unrealistic when the runway is already full.
    List<int> existingDailyMinutes() {
      final horizon = min(deadlineDays, 30);
      final minutes = List<int>.filled(horizon, 0);
      for (final task in _allTasks) {
        if (task.done) continue;
        final offset = dateOnly(task.scheduledDate).difference(today).inDays;
        if (offset >= 0 && offset < horizon) {
          minutes[offset] += task.durationMinutes;
        }
      }
      return minutes;
    }

    Map<String, dynamic> agentContext(
        {String? specialRequest, bool force = false}) {
      return {
        'category': _newGoalCategory,
        'priority': _newGoalPriority,
        'deadlineDays': deadlineDays,
        'existingDailyMinutes': existingDailyMinutes(),
        'completedToday': _todayCompleted,
        'totalToday': _todayTasks.length,
        'mood': _selectedMood,
        'streak': _streak,
        if (specialRequest != null) 'specialRequest': specialRequest,
        if (force) 'force': true,
      };
    }

    List<String> goalContextChips() => _goalAiContextChips(deadlineDays);

    Future<AgentPlannerResponse> requestAgentPlan(
      String goal, {
      String? specialRequest,
      bool force = false,
    }) {
      return ai.agentPlanner.plan(
        AgentPlannerRequest(
          goal: goal,
          context: agentContext(specialRequest: specialRequest, force: force),
        ),
      );
    }

    void closeGoalDialog(
      BuildContext dialogContext, [
      _GoalPlanApprovalResult? result,
    ]) {
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.of(dialogContext, rootNavigator: true)
          .pop<_GoalPlanApprovalResult>(result);
    }

    Future<List<_DraftTaskSpec>> generatedOrLocalSpecs(String goal) async {
      try {
        final generated = await ai.taskGenerator.generate(
          TaskGeneratorRequest(
            goalTitle: goal,
            category: _newGoalCategory,
            priority: _newGoalPriority,
            deadlineDays: deadlineDays,
          ),
        );
        final aiSpecs = _draftSpecsFromGeneratedTasks(generated.tasks).toList();
        if (aiSpecs.isNotEmpty) return aiSpecs;
      } catch (e) {
        debugPrint('AI task generation fallback used: $e');
      }
      return _draftSpecsFromTitles(_generateTaskTitles(goal)).toList();
    }

    void captureAgentMetadata(AgentPlannerResponse plan) {
      agentStrategy = plan.strategy;
      agentDegraded = plan.degraded;
      agentHabitInsight = plan.habitInsight;
      agentRecommendation = plan.primaryInsight;
      agentBurnoutRisk = plan.burnoutRisk;
      agentScheduleNote = plan.schedule['scheduleNote']?.toString();
    }

    // The agent flagged the chosen deadline as unrealistic: remember the
    // proposal and build the reasoning + yes/no question for the chat. The
    // deadline is only changed if the user agrees; "no" keeps it as chosen.
    String? captureDeadlineSuggestion(AgentPlannerResponse plan) {
      final suggested = plan.suggestedDeadlineDays;
      if (suggested == null || suggested == deadlineDays) return null;
      pendingDeadlineDays = suggested;
      final reason = plan.deadlineSuggestionReason?.trim();
      final suggestedDate = shortDate(addDays(today, suggested));
      final buffer = StringBuffer('⏳ ');
      buffer.write((reason == null || reason.isEmpty)
          ? 'Your deadline of ${shortDate(_newGoalDeadline)} looks unrealistic for this goal given a normal schedule.'
          : reason);
      buffer.write(
          '\n\nWould you like me to move the deadline to $suggestedDate ($suggested days from today)? (yes / no)');
      return buffer.toString();
    }

    // Snapshot of the current draft in the wire format the modification
    // agent expects.
    List<GeneratedTask> draftTasksPayload() => draftSpecs
        .map((spec) => GeneratedTask(
              title: spec.title,
              durationMinutes: spec.durationMinutes,
              load: spec.load.name,
              dayOffset: spec.dayOffset,
            ))
        .toList();

    // Block the UI with a non-dismissible loader while the agent generates the
    // first plan, so the user can't tap other things mid-generation.
    var loaderOpen = false;
    if (mounted) {
      loaderOpen = true;
      // ignore: unawaited_futures
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (_) => _buildGeneratingLoader(
          'Generating your plan...',
          statusLines: _goalGenerationStatusLines(deadlineDays),
        ),
      );
    }

    // Step 1: Run the planning agent. Its first backend step is goal_guard.ts;
    // without that AI guard result, this dialog must not create tasks.
    String? deadlineQuestion;
    try {
      final agentPlan = await requestAgentPlan(currentTitle);
      if (!agentPlan.goalGuardEvaluated) {
        awaitingGoalRefinement = true;
        guardReply = guardUnavailableReply;
        draftSpecs = [];
      } else if (agentPlan.goalRejected) {
        awaitingGoalRefinement = true;
        guardReply = _goalGuardReplyFromPlan(agentPlan);
        draftSpecs = [];
      } else {
        captureAgentMetadata(agentPlan);
        deadlineQuestion = captureDeadlineSuggestion(agentPlan);
        if (agentPlan.milestones.isNotEmpty) {
          agentSpecs = _draftSpecsFromTitles(agentPlan.milestones).toList();
        }
      }
    } catch (e) {
      debugPrint(
          'Agent planner unavailable before goal guard verification: $e');
      awaitingGoalRefinement = true;
      guardReply = guardUnavailableReply;
      draftSpecs = [];
    }

    if (awaitingGoalRefinement) {
      draftSpecs = [];
    } else if (agentSpecs.isNotEmpty) {
      draftSpecs = agentSpecs;
      aiAvailable = true;
      fromAgent = true;
    } else {
      // Step 2 (fallback): the agent produced no milestones — try the task
      // generator, then fall back to the local heuristic plan.
      draftSpecs = await generatedOrLocalSpecs(currentTitle);
      aiAvailable = true;
    }

    // Compose the opening message from the agent's REAL output, not a cosmetic
    // suffix. Surface the habit insight, schedule note, and top recommendation.
    final intro = StringBuffer();
    if (awaitingGoalRefinement) {
      intro.write(guardReply ??
          "I can't generate todos for this goal as written. Please redefine it as a clear, constructive, achievable outcome.");
    } else if (fromAgent && !agentDegraded) {
      final strategy = agentStrategy?.trim();
      intro.write('I ran the planning agent');
      if (strategy != null && strategy.isNotEmpty) intro.write(' ($strategy)');
      intro.write(
          ' and broke "$currentTitle" into ${draftSpecs.length} milestones.');
    } else if (aiAvailable) {
      intro.write(
          'I used the AI task generator to break "$currentTitle" into ${draftSpecs.length} tasks.');
    } else {
      intro.write(
          "I couldn't verify this goal with the AI planner, so I won't generate todos for it yet.");
    }
    if (!awaitingGoalRefinement) {
      final habit = agentHabitInsight?.trim();
      if (habit != null && habit.isNotEmpty) {
        final risk = agentBurnoutRisk?.trim();
        final riskTag =
            (risk != null && risk.isNotEmpty) ? ' (burnout risk: $risk)' : '';
        intro.write('\n\n🧠 $habit$riskTag');
      }
      final note = agentScheduleNote?.trim();
      if (note != null && note.isNotEmpty) intro.write('\n📅 $note');
      final rec = agentRecommendation?.trim();
      if (rec != null && rec.isNotEmpty) intro.write('\n👉 $rec');
      if (deadlineQuestion != null) {
        intro.write('\n\n$deadlineQuestion');
      } else {
        intro.write(
            '\n\nYou can ask me to make the plan easier, more detailed, or reorder it before scheduling.');
      }
    }

    final firstMessage = <String, dynamic>{
      'role': 'assistant',
      'text': intro.toString(),
    };
    if (!awaitingGoalRefinement) {
      firstMessage['tasks'] = _draftPreviewTasks(draftSpecs);
      firstMessage['contextChips'] = goalContextChips();
    }
    final messages = <Map<String, dynamic>>[firstMessage];

    // Generation done — close the blocking loader before showing the plan.
    if (loaderOpen && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      loaderOpen = false;
    }
    if (!mounted) return;

    final result = await showDialog<_GoalPlanApprovalResult>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) {
        var isAiThinking = false;
        // When the agent scales back an unrealistic request, it asks "are you
        // sure?". We stash the original request here so a "yes" re-issues it as
        // a confirmed (forced) request, and a "no" keeps the scaled-back plan.
        String? pendingForceRequest;
        return StatefulBuilder(
          builder: (dialogContext, setLocalState) {
            Future<void> sendMessage() async {
              final request = chatController.text.trim();
              if (request.isEmpty || isAiThinking) return;

              // Deadline suggestion (agree → adjust + re-plan, decline →
              // keep the chosen deadline). Answered before any other pending
              // question because it is always asked first.
              final suggestedDeadline = pendingDeadlineDays;
              if (!awaitingGoalRefinement && suggestedDeadline != null) {
                if (_isNegativeReply(request)) {
                  setLocalState(() {
                    messages.add({'role': 'user', 'text': request});
                    messages.add({
                      'role': 'assistant',
                      'text':
                          "No problem — I'll keep your deadline at ${shortDate(_newGoalDeadline)} and the plan will stay within it.",
                      'tasks': _draftPreviewTasks(draftSpecs),
                    });
                    chatController.clear();
                    pendingDeadlineDays = null;
                  });
                  return;
                }
                if (_isAffirmativeReply(request)) {
                  final newDeadline = addDays(today, suggestedDeadline);
                  setLocalState(() {
                    isAiThinking = true;
                    messages.add({'role': 'user', 'text': request});
                    chatController.clear();
                    pendingDeadlineDays = null;
                  });
                  deadlineDays = suggestedDeadline;
                  if (mounted) {
                    // The goal is created with _newGoalDeadline, so the
                    // agreed adjustment must land on the parent state too.
                    setState(() => _newGoalDeadline = newDeadline);
                  }
                  var replanNote =
                      'Done — I moved the deadline to ${shortDate(newDeadline)} and re-planned the milestones across the new timeline.';
                  try {
                    final replan = await requestAgentPlan(currentTitle);
                    if (replan.goalGuardEvaluated &&
                        !replan.goalRejected &&
                        replan.milestones.isNotEmpty) {
                      captureAgentMetadata(replan);
                      draftSpecs =
                          _draftSpecsFromTitles(replan.milestones).toList();
                    }
                  } catch (e) {
                    debugPrint('Replan after deadline change failed: $e');
                    replanNote =
                        'Done — I moved the deadline to ${shortDate(newDeadline)}. The current plan is kept; you can still ask me to adjust it.';
                  }
                  if (!dialogContext.mounted) return;
                  setLocalState(() {
                    messages.add({
                      'role': 'assistant',
                      'text': replanNote,
                      'tasks': _draftPreviewTasks(draftSpecs),
                    });
                    isAiThinking = false;
                  });
                  return;
                }
                // Neither yes nor no — drop the question and treat the text
                // as a regular plan request.
                pendingDeadlineDays = null;
              }

              final pending = pendingForceRequest;

              // User declined the "are you sure?" question — keep current plan.
              if (!awaitingGoalRefinement &&
                  pending != null &&
                  _isNegativeReply(request)) {
                setLocalState(() {
                  messages.add({'role': 'user', 'text': request});
                  messages.add({
                    'role': 'assistant',
                    'text': "Got it — I'll keep the plan as it is.",
                    'tasks': _draftPreviewTasks(draftSpecs),
                  });
                  chatController.clear();
                  pendingForceRequest = null;
                });
                return;
              }

              // User confirmed — re-issue the original request, forced this time.
              final useForce = !awaitingGoalRefinement &&
                  pending != null &&
                  _isAffirmativeReply(request);
              final effectiveRequest = useForce ? pending : request;
              final wasAwaitingGoalRefinement = awaitingGoalRefinement;
              final goalToPlan =
                  wasAwaitingGoalRefinement ? request : currentTitle;

              setLocalState(() {
                isAiThinking = true;
                messages.add({'role': 'user', 'text': request});
                chatController.clear();
              });

              // Plan adjustments go through the Task Modification Agent
              // (§6.3): it sees the CURRENT draft plus the request, so edits
              // are incremental and earlier adjustments are preserved. It
              // applies, clarifies, asks for confirmation, or rejects with a
              // personalised explanation (§9.2–§9.4). Goal refinements (after
              // a rejection) still go through the Planning Agent below.
              if (!wasAwaitingGoalRefinement) {
                try {
                  final modification = await ai.agentModify.modify(
                    TaskModificationRequest(
                      goal: currentTitle,
                      request: effectiveRequest,
                      currentTasks: draftTasksPayload(),
                      context: agentContext(),
                      force: useForce,
                    ),
                  );

                  if (!dialogContext.mounted) return;
                  setLocalState(() {
                    if (modification.applied && modification.tasks.isNotEmpty) {
                      draftSpecs =
                          _draftSpecsFromGeneratedTasks(modification.tasks)
                              .toList();
                    }
                    // §9.4: remember the request only while the agent is
                    // waiting on a yes/no answer to its risk question.
                    pendingForceRequest = modification.needsConfirmation
                        ? effectiveRequest
                        : null;
                    final replyParts = [
                      modification.explanation.trim(),
                      modification.question?.trim() ?? '',
                    ].where((part) => part.isNotEmpty);
                    messages.add({
                      'role': 'assistant',
                      'text': replyParts.isEmpty
                          ? 'I reviewed your request against the current plan.'
                          : replyParts.join('\n\n'),
                      // Show the plan unless the agent is mid-question.
                      if (modification.applied ||
                          modification.status == 'rejected')
                        'tasks': _draftPreviewTasks(draftSpecs),
                    });
                    isAiThinking = false;
                  });
                  return;
                } on GenkitFlowException catch (e) {
                  // Modification agent unreachable (e.g. not deployed yet) —
                  // fall back to a full replan with the request attached.
                  debugPrint('agentModify unavailable, replanning: $e');
                } catch (e) {
                  debugPrint('agentModify failed, replanning: $e');
                }
              }

              try {
                final refinedPlan = await requestAgentPlan(
                  goalToPlan,
                  specialRequest:
                      wasAwaitingGoalRefinement ? null : effectiveRequest,
                  force: useForce,
                );

                if (!refinedPlan.goalGuardEvaluated ||
                    refinedPlan.goalRejected) {
                  final replyText = refinedPlan.goalGuardEvaluated
                      ? _goalGuardReplyFromPlan(refinedPlan)
                      : guardUnavailableReply;

                  if (!dialogContext.mounted) return;
                  setLocalState(() {
                    awaitingGoalRefinement = true;
                    pendingForceRequest = null;
                    draftSpecs = [];
                    messages.add({
                      'role': 'assistant',
                      'text': replyText,
                    });
                    isAiThinking = false;
                  });
                  return;
                }

                captureAgentMetadata(refinedPlan);
                final refinedTitles = refinedPlan.milestones
                    .map((task) => task.trim())
                    .where((task) => task.isNotEmpty)
                    .toList();
                if (refinedTitles.isNotEmpty) {
                  draftSpecs = _draftSpecsFromTitles(refinedTitles).toList();
                } else if (wasAwaitingGoalRefinement) {
                  draftSpecs = await generatedOrLocalSpecs(goalToPlan);
                }
                if (wasAwaitingGoalRefinement) {
                  currentTitle = goalToPlan;
                  aiAvailable = true;
                  fromAgent = refinedTitles.isNotEmpty;
                }

                // Prefer the agent's feasibility note (e.g. "…Are you sure you
                // still want all 30? (yes / no)"); otherwise confirm the count.
                final note = refinedPlan.milestoneNote?.trim();
                var replyText = (note != null && note.isNotEmpty)
                    ? note
                    : (wasAwaitingGoalRefinement
                        ? 'That goal is clear enough to plan. I broke "$currentTitle" into ${draftSpecs.length} milestones.'
                        : refinedTitles.isNotEmpty
                            ? 'Updated the plan to ${refinedTitles.length} milestones.'
                            : 'I refined the plan based on your request.');
                final refinedDeadlineQuestion =
                    captureDeadlineSuggestion(refinedPlan);
                if (refinedDeadlineQuestion != null) {
                  replyText = '$replyText\n\n$refinedDeadlineQuestion';
                }

                if (!dialogContext.mounted) return;
                setLocalState(() {
                  awaitingGoalRefinement = false;
                  // Remember the request only while a confirmation is pending.
                  pendingForceRequest = refinedPlan.milestoneNeedsConfirmation
                      ? effectiveRequest
                      : null;
                  messages.add({
                    'role': 'assistant',
                    'text': replyText,
                    'tasks': _draftPreviewTasks(draftSpecs),
                  });
                  isAiThinking = false;
                });
              } catch (e) {
                if (!dialogContext.mounted) return;
                setLocalState(() {
                  awaitingGoalRefinement = wasAwaitingGoalRefinement;
                  pendingForceRequest = null;
                  if (wasAwaitingGoalRefinement) {
                    draftSpecs = [];
                  }
                  messages.add({
                    'role': 'assistant',
                    'text': wasAwaitingGoalRefinement
                        ? "I can't verify this revised goal right now, so I won't generate todos for it. Please try again, or rewrite it as a clear, constructive, achievable goal."
                        : 'The AI planner is unavailable right now, so I cannot safely apply that change. The existing draft is unchanged.',
                    if (!wasAwaitingGoalRefinement)
                      'tasks': _draftPreviewTasks(draftSpecs),
                  });
                  isAiThinking = false;
                });
              }
            }

            Widget buildMessageBubble(Map<String, dynamic> message) {
              final isUser = message['role'] == 'user';
              final bubbleColor = isUser ? gdPrimary : gdCardLight;
              final textColor = isUser ? Colors.white : gdInk;
              final tasks = (message['tasks'] as List?)
                      ?.whereType<_DraftTaskSpec>()
                      .toList() ??
                  const <_DraftTaskSpec>[];
              final contextChips = (message['contextChips'] as List?)
                      ?.whereType<String>()
                      .toList() ??
                  const <String>[];
              final effectiveContextChips = tasks.isNotEmpty && !isUser
                  ? (contextChips.isEmpty ? goalContextChips() : contextChips)
                  : const <String>[];
              final width = MediaQuery.of(context).size.width;
              final compact = width < 620;
              final bubbleMaxWidth =
                  compact ? min(width * 0.74, 360.0) : (isUser ? 520.0 : 560.0);
              final planMaxWidth = compact ? min(width * 0.88, 430.0) : 620.0;

              return Align(
                alignment:
                    isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
                      child: Container(
                        margin: EdgeInsets.only(
                          left: isUser ? (compact ? 54 : 70) : 0,
                          right: isUser ? 0 : (compact ? 42 : 70),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
                        decoration: BoxDecoration(
                          color: bubbleColor,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(isUser ? 18 : 7),
                            bottomRight: Radius.circular(isUser ? 7 : 18),
                          ),
                          border: !isUser ? Border.all(color: gdBorder) : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isUser)
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: gdPrimarySoft,
                                    child: Icon(Icons.auto_awesome_rounded,
                                        size: 15, color: gdPrimary),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'AI Assistant',
                                    style: TextStyle(
                                      color: gdMuted,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            if (!isUser) const SizedBox(height: 12),
                            Text(
                              message['text'] as String,
                              style: TextStyle(
                                color: textColor,
                                fontSize: isUser ? 14.5 : 14,
                                height: isUser ? 1.48 : 1.68,
                                fontWeight:
                                    isUser ? FontWeight.w700 : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (tasks.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: planMaxWidth),
                        child: _PlanPreviewSection(
                          tasks: tasks,
                          contextChips: effectiveContextChips,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }

            final dialogSize = MediaQuery.of(dialogContext).size;
            final isCompactDialog = dialogSize.width < 620;

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(
                horizontal: isCompactDialog ? 10 : 18,
                vertical: isCompactDialog ? 14 : 22,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 840,
                  maxHeight: dialogSize.height * 0.88,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: gdSurface,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 28,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isCompactDialog ? 18 : 24,
                      20,
                      isCompactDialog ? 18 : 24,
                      22,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'GOAL BREAKDOWN',
                                    style: TextStyle(
                                      color: gdHint,
                                      fontSize: 13,
                                      letterSpacing: 3,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    title,
                                    style: TextStyle(
                                      color: gdInk,
                                      fontSize: isCompactDialog ? 20 : 22,
                                      height: 1.22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: gdCardLight,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: IconButton(
                                tooltip: 'Close',
                                onPressed: () => closeGoalDialog(dialogContext),
                                icon: Icon(Icons.close_rounded, color: gdMuted),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: gdSurface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: gdBorder),
                            ),
                            padding: EdgeInsets.all(isCompactDialog ? 12 : 16),
                            child: ListView.separated(
                              itemCount:
                                  messages.length + (isAiThinking ? 1 : 0),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 18),
                              itemBuilder: (context, index) {
                                if (index < messages.length) {
                                  return buildMessageBubble(messages[index]);
                                }
                                return const _AiThinkingIndicator();
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: chatController,
                                enabled: !isAiThinking,
                                minLines: 1,
                                maxLines: 4,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => sendMessage(),
                                decoration: InputDecoration(
                                  hintText: isAiThinking
                                      ? 'AI is thinking…'
                                      : awaitingGoalRefinement
                                          ? 'Rewrite the goal...'
                                          : 'Adjust the AI plan...',
                                  filled: true,
                                  fillColor: gdCardLight,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(color: gdBorder),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(
                                        color: gdPrimary, width: 1.6),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              height: 54,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: gdPrimary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 22),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18)),
                                ),
                                onPressed: isAiThinking ? null : sendMessage,
                                child: const Text('Send'),
                              ),
                            ),
                          ],
                        ),
                        if (!awaitingGoalRefinement) ...[
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(58),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18)),
                              ),
                              onPressed: isAiThinking || draftSpecs.isEmpty
                                  ? null
                                  : () => closeGoalDialog(
                                        dialogContext,
                                        _GoalPlanApprovalResult(
                                          title: currentTitle,
                                          tasks: List<_DraftTaskSpec>.from(
                                              draftSpecs),
                                        ),
                                      ),
                              child: const Text('Looks good, finalize!'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null && mounted) {
      await _showPlanCommitAnimation(result.title, result.tasks);
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      await _finishCreateGoal(result.title, approvedTaskSpecs: result.tasks);
    }
  }

  Future<void> _showPlanCommitAnimation(
    String title,
    List<_DraftTaskSpec> tasks,
  ) async {
    if (!mounted) return;
    final animation = showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _PlanCommitAnimation(title: title, tasks: tasks);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      Navigator.of(context, rootNavigator: true).maybePop();
    }
    await animation;
  }

  Future<void> _finishCreateGoal(String title,
      {List<_DraftTaskSpec>? approvedTaskSpecs}) async {
    final goalId = DateTime.now().microsecondsSinceEpoch;
    final colors = _categoryColors(_newGoalCategory);
    final steps = approvedTaskSpecs == null
        ? _generateMicroTasks(title, goalId)
        : _generateMicroTasksFromSpecs(approvedTaskSpecs, goalId);
    final goal = GoalProject(
      id: goalId,
      title: title,
      importance: _newGoalPriority,
      category: _newGoalCategory,
      deadline: _newGoalDeadline,
      from: colors[0],
      to: colors[1],
      tasks: steps,
    );

    setState(() {
      _goals.insert(0, goal);
      _isProcessing = false;
      _processingProgress = 0;
      _goalController.clear();
      _newGoalPriority = 3;
      _newGoalCategory = 'Study';
      _newGoalDeadline = addDays(today, 14);
    });

    final sync = _sync;
    if (sync != null) {
      try {
        await sync.createGoal(goal);
      } catch (e) {
        debugPrint('Goal persistence failed: $e');
        _showMessage(
            'Goal created locally, but Firebase save failed. Check Firestore rules/network.');
        return;
      }
    }
    _syncStreakFromCompletedTasks();
    _queueNotificationScheduleSync();
    _ensureImportantDeadlineNotifications();
    _showMessage('Goal created. AI subtasks are scheduled and synced.');
  }

  List<Color> _categoryColors(String category) =>
      GdCategory.colorsFor(category);

  List<String> _generateTaskTitles(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('exam') ||
        lower.contains('midterm') ||
        lower.contains('study')) {
      return [
        'List topics to review',
        'Study the hardest topic for 20 minutes',
        'Solve practice questions',
        'Review mistakes and make flashcards'
      ];
    } else if (lower.contains('portfolio') || lower.contains('project')) {
      return [
        'Define the project outcome',
        'Create the first rough draft',
        'Improve one visible section',
        'Share for feedback'
      ];
    }
    return [
      'Write the desired outcome',
      'Break the goal into 3 milestones',
      'Do the smallest first action',
      'Review progress and adjust tomorrow'
    ];
  }

  List<_DraftTaskSpec> _draftPreviewTasks(List<_DraftTaskSpec> specs) {
    return List<_DraftTaskSpec>.from(specs);
  }

  List<_DraftTaskSpec> _draftSpecsFromGeneratedTasks(
      List<GeneratedTask> tasks) {
    final deadlineDays =
        max(1, dateOnly(_newGoalDeadline).difference(today).inDays);
    return tasks.where((task) => task.title.trim().isNotEmpty).map((task) {
      final duration = task.durationMinutes.clamp(5, 90).toInt();
      return _DraftTaskSpec(
        title: task.title.trim(),
        durationMinutes: duration,
        load: _taskLoadFromAi(task.load, duration),
        dayOffset: task.dayOffset.clamp(0, deadlineDays).toInt(),
      );
    }).toList();
  }

  List<_DraftTaskSpec> _draftSpecsFromTitles(Iterable<String> titles) {
    final cleaned = titles
        .map((title) => title.trim())
        .where((title) => title.isNotEmpty)
        .toList();

    return List.generate(cleaned.length, (index) {
      final duration = index == 0 ? 10 : 15 + index * 5;
      final load = index == 0
          ? TaskLoad.light
          : index == cleaned.length - 1
              ? TaskLoad.stretch
              : TaskLoad.focus;
      return _DraftTaskSpec(
        title: cleaned[index],
        durationMinutes: duration,
        load: load,
        dayOffset: index,
      );
    });
  }

  TaskLoad _taskLoadFromAi(String load, int durationMinutes) {
    switch (load.toLowerCase().trim()) {
      case 'light':
        return TaskLoad.light;
      case 'stretch':
        return TaskLoad.stretch;
      case 'focus':
        return TaskLoad.focus;
    }
    if (durationMinutes <= 15) return TaskLoad.light;
    if (durationMinutes > 30) return TaskLoad.stretch;
    return TaskLoad.focus;
  }

  List<MicroTask> _generateMicroTasks(String title, int goalId) {
    return _generateMicroTasksFromTitles(_generateTaskTitles(title), goalId);
  }

  List<MicroTask> _generateMicroTasksFromTitles(
      List<String> taskTitles, int goalId) {
    return _generateMicroTasksFromSpecs(
        _draftSpecsFromTitles(taskTitles), goalId);
  }

  List<MicroTask> _generateMicroTasksFromSpecs(
      List<_DraftTaskSpec> taskSpecs, int goalId) {
    final baseTaskId = DateTime.now().microsecondsSinceEpoch;
    return List.generate(taskSpecs.length, (index) {
      final spec = taskSpecs[index];
      return MicroTask(
        id: baseTaskId + index,
        goalId: goalId,
        title: spec.title,
        durationMinutes: spec.durationMinutes,
        load: spec.load,
        scheduledDate: addDays(today, spec.dayOffset),
        points: max(8, (spec.durationMinutes / 2).round() + index * 3),
      );
    });
  }

  void _completeTask(MicroTask task) {
    if (task.done) return;
    final goal = _goalForTask(task);
    final completedAt = DateTime.now();
    var streakAwarded = false;
    setState(() {
      task.done = true;
      task.completedAt = completedAt;
      _coins += task.points;
      _adjustActiveCompanionHappiness(5);
      streakAwarded = _awardTaskCompletionStreak();
    });
    _showCoinRewardPrompt(
      task.points,
      streakAwarded
          ? 'for completing "${task.title}" and keeping a $_streak day streak'
          : 'for completing "${task.title}"',
    );
    unawaited(_persistTaskToggle(goal, task));
    unawaited(_markCommunityTaskCompleted(completedAt));
    _syncStreakFromCompletedTasks();
    unawaited(_persistProfileStats());
    _queueNotificationScheduleSync();
  }

  Future<void> _persistTaskToggle(GoalProject goal, MicroTask task) async {
    final sync = _sync;
    if (sync == null) return;
    try {
      await sync.toggleTask(
        goal.id.toString(),
        task.id.toString(),
        task.done,
        completedAt: task.completedAt,
      );
      await sync.updateGoal(goal);
    } catch (e) {
      debugPrint('Task sync failed: $e');
    }
  }

  Future<void> _markCommunityTaskCompleted(DateTime completedAt) async {
    final sync = _sync;
    if (sync == null) return;

    try {
      await sync.markCommunityTaskCompleted(completedAt);
    } on FirebaseException catch (e) {
      final details = e.message ?? e.code;
      debugPrint('Community streak sync failed: ${e.code} $details');
      if (mounted) {
        _showMessage('Community streak sync failed: $details');
      }
    } catch (e) {
      debugPrint('Community streak sync failed: $e');
      if (mounted) {
        _showMessage(
          'Task saved, but community streak sync failed. Check Firestore rules.',
        );
      }
    }
  }

  void _deleteGoal(GoalProject goal) {
    setState(() => _goals.removeWhere((item) => item.id == goal.id));
    unawaited(_deleteGoalEverywhere(goal));
    _queueNotificationScheduleSync();
    _showMessage('Removed ${goal.title}.');
  }

  Future<void> _deleteGoalEverywhere(GoalProject goal) async {
    final sync = _sync;
    if (sync != null) {
      try {
        await sync.deleteGoal(goal.id.toString());
      } catch (e) {
        debugPrint('Delete goal sync failed: $e');
        if (mounted) {
          _showMessage('Goal removed locally, but Firebase delete failed.');
        }
      }
    }
  }

  void _addCommunity() {
    final title = _communityController.text.trim();
    if (title.isEmpty) {
      _showHelpfulError(
        title: 'Community name is missing',
        message:
            'Write a short community name first, then you can invite people later.',
        actionLabel: 'Try again',
        onAction: () {},
      );
      return;
    }

    final community = CommunityGroup(
      name: title,
      members: 1,
      tag: 'Created by you',
      similarity: 100,
      joined: true,
      description:
          'A new accountability group for people working on similar goals.',
    );
    setState(() {
      _communities.insert(0, community);
      _communityController.clear();
    });

    final sync = _sync;
    if (sync != null) {
      unawaited(sync.createCommunity(community).then((persisted) {
        if (!mounted) return;
        setState(() {
          _communities.remove(community);
          _communities.insert(0, persisted);
        });
      }).catchError((Object e) {
        debugPrint('Create community sync failed: $e');
        _showMessage('Community created locally, but Firebase save failed.');
      }));
    }
    _addInAppNotification(
      title: 'Community created',
      body: '${community.name} is ready for accountability.',
      type: AppNotificationType.community,
      sourceId: community.name,
    );
    _showMessage('Community created.');
  }

  void _joinCommunity(CommunityGroup group) {
    setState(() => group.joined = true);
    final id = group.backendId;
    final sync = _sync;
    if (sync != null && id != null) {
      unawaited(sync.joinCommunity(id).catchError((Object e) {
        debugPrint('Join community sync failed: $e');
      }));
    }
    _addInAppNotification(
      title: 'Community joined',
      body: 'You joined ${group.name}.',
      type: AppNotificationType.community,
      sourceId: id ?? group.name,
    );
    _showMessage('Joined ${group.name}.');
  }

  void _deleteCommunity(CommunityGroup group) {
    setState(() => group.joined = false);
    final id = group.backendId;
    final sync = _sync;
    if (sync != null && id != null) {
      unawaited(sync.leaveCommunity(id).catchError((Object e) {
        debugPrint('Leave community sync failed: $e');
      }));
    }
    _showMessage('Left ${group.name}.');
  }

  void _persistFriends() {
    final sync = _sync;
    if (sync == null) return;
    unawaited(sync.updateFriends(_friends).catchError((Object e) {
      debugPrint('Friend sync failed: $e');
    }));
  }

  void _addFriend(String name) {
    final cleaned = name.trim();
    if (cleaned.isEmpty || _friends.contains(cleaned)) return;
    setState(() => _friends.add(cleaned));
    _persistFriends();
    _addInAppNotification(
      title: 'Friend added',
      body: '$cleaned can now be part of your accountability circle.',
      type: AppNotificationType.community,
      sourceId: cleaned,
    );
    _showMessage('$cleaned added as a friend.');
  }

  void _deleteFriend(String name) {
    setState(() => _friends.remove(name));
    _persistFriends();
    _showMessage('Removed $name from friends.');
  }

  void _selectCompanion(CompanionKind companion) {
    if (!_unlockedCompanions.contains(companion)) {
      _showMessage('Unlock ${companion.label} before switching.');
      return;
    }
    if (_activeCompanion == companion) return;
    final previousCompanion = _activeCompanion;
    setState(() {
      _applyCompanionSwitchPenalty(previousCompanion);
      _activeCompanion = companion;
      _ensureCompanionState();
    });
    unawaited(_persistProfileStats());
    _showMessage('${companion.label} is now your companion.');
  }

  Future<CompanionGachaResult?> _pullCompanionGacha() async {
    final allGachaCompanionsUnlocked = gachaCompanions.every(
      _unlockedCompanions.contains,
    );
    if (allGachaCompanionsUnlocked) {
      _showMessage('All companions are already unlocked.');
      return null;
    }

    if (_coins < companionGachaCost) {
      _showHelpfulError(
        title: 'Not enough coins',
        message:
            'A companion capsule costs $companionGachaCost coins. Complete a few tasks first, then try again.',
        actionLabel: 'Got it',
        onAction: () {},
      );
      return null;
    }

    final companion = _rollCompanionGacha();
    final rarity = companion.rarity!;
    final duplicate = _unlockedCompanions.contains(companion);
    final refund = duplicate ? companionDuplicateRefund : 0;

    setState(() {
      _coins -= companionGachaCost - refund;
      if (!duplicate) {
        _applyCompanionSwitchPenalty(_activeCompanion);
        _unlockCompanion(companion);
        _activeCompanion = companion;
        _ensureCompanionState();
      }
    });
    unawaited(_persistProfileStats());
    _addInAppNotification(
      title: duplicate ? 'Duplicate companion pull' : 'Companion unlocked',
      body: duplicate
          ? '${companion.label} was already in your roster. $refund coins were refunded.'
          : '${companion.label} joined your companion roster as a ${rarity.label} pull.',
      type: AppNotificationType.reward,
      sourceId: 'companion_${companion.id}',
    );

    final result = CompanionGachaResult(
      companion: companion,
      rarity: rarity,
      duplicate: duplicate,
      cost: companionGachaCost,
      refund: refund,
    );
    _showMessage(
      duplicate
          ? 'Duplicate ${companion.label}: $refund coins refunded.'
          : '${rarity.label} pull: ${companion.label} unlocked!',
    );
    return result;
  }

  CompanionKind _rollCompanionGacha() {
    final totalWeight = gachaCompanions.fold<double>(
      0,
      (total, companion) => total + companion.rarity!.gachaWeight,
    );
    var roll = Random().nextDouble() * totalWeight;
    for (final companion in gachaCompanions) {
      roll -= companion.rarity!.gachaWeight;
      if (roll <= 0) return companion;
    }
    return gachaCompanions.last;
  }

  void _feedPet() {
    if (_coins < 10) {
      _showHelpfulError(
        title: 'Not enough coins',
        message:
            'Complete one task first. Each completed task gives coins you can use for your companion.',
        actionLabel: 'Go to home',
        onAction: () => setState(() => _selectedIndex = 2),
      );
      return;
    }
    setState(() {
      _coins -= 10;
      _adjustActiveCompanionHappiness(10);
    });
    unawaited(_persistProfileStats());
  }

  void _interactWithPet() {
    final reactions = [
      '${_activeCompanion.label} is cheering for you!',
      '${_activeCompanion.label} did a happy little bounce.',
      '${_activeCompanion.label} says: one tiny step counts!',
      '${_activeCompanion.label} feels closer to you.',
    ];
    _showMessage(reactions[Random().nextInt(reactions.length)]);
  }

  Future<void> _openFocusMode() async {
    if (_hasActiveFocus || _focusComplete) {
      _openActiveFocusDialog();
      return;
    }
    final config = await showModalBottomSheet<FocusSessionConfig>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: gdSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => FocusSetupSheet(goals: _goals, today: today),
    );
    if (!mounted || config == null) return;
    await _startFocusSession(config);
  }

  void _handleMoodChanged(String value) {
    if (value == _selectedMood) return;

    setState(() => _selectedMood = value);
    unawaited(_persistMood(value));

    _moodAdviceTimer?.cancel();
    _moodAdviceTimer = Timer(const Duration(milliseconds: 450), () {
      if (_moodAdvisorAvailable) unawaited(_requestMoodAdvice(value));
      // §8: a mood change is a context change — let the Task Reassignment
      // Agent decide whether today's schedule still fits the user's capacity.
      unawaited(_requestTaskReassignment('moodChanged'));
    });
  }

  Future<void> _requestMoodAdvice(String mood) async {
    final requestSerial = ++_moodAdviceRequestSerial;
    try {
      final advice = await context.read<GenkitService>().moodAdvisor.advise(
            MoodAdvisorRequest(
              mood: mood,
              completedToday: _todayCompleted,
              totalToday: _todayTasks.length,
              streak: _streak,
            ),
          );
      if (!mounted ||
          requestSerial != _moodAdviceRequestSerial ||
          mood != _selectedMood) {
        return;
      }
      _addInAppNotification(
        title: 'AI mood plan',
        body: advice.message,
        type: AppNotificationType.moodNudge,
        important: mood == 'Tired' || mood == 'Stressed',
        sourceId: mood,
      );
      _showMessage('AI mood plan: ${advice.message}');
    } catch (e) {
      if (e.toString().contains('not-found')) {
        _moodAdvisorAvailable = false;
      }
      debugPrint('Mood advisor unavailable: $e');
    }
  }

  // Show/hide the "agent is working" loader. Ref-counted: the dialog opens on
  // the first in-flight request and closes when the last one finishes.
  void _showReassignmentLoader(String trigger) {
    if (!mounted) return;
    _reassignLoaderDepth++;
    if (_reassignLoaderRoute != null) return;
    final route = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _buildGeneratingLoader(
        'AI is adjusting your schedule...',
        statusLines: _reassignmentStatusLines(trigger),
      ),
    );
    _reassignLoaderRoute = route;
    unawaited(Navigator.of(context, rootNavigator: true).push(route));
  }

  void _hideReassignmentLoader() {
    if (_reassignLoaderDepth > 0) _reassignLoaderDepth--;
    if (_reassignLoaderDepth > 0) return;
    final route = _reassignLoaderRoute;
    _reassignLoaderRoute = null;
    if (route != null && mounted && route.isActive) {
      Navigator.of(context, rootNavigator: true).removeRoute(route);
    }
  }

  /// Task Reassignment Agent (§6.4): asks the backend whether the current
  /// schedule should adapt to a context change (mood shift, new routine, …).
  /// The agent enforces the deadline rule, human-capability limits, and
  /// importance weighting server-side; we only apply the validated changes.
  Future<void> _requestTaskReassignment(String trigger) async {
    if (!_reassignAgentAvailable) return;

    final pendingTasks = _allTasks.where((task) => !task.done).toList();
    if (pendingTasks.isEmpty) return;

    final requestSerial = ++_reassignRequestSerial;

    final taskInfos = pendingTasks
        .map((task) => ReassignableTaskInfo(
              id: task.id.toString(),
              goalId: task.goalId.toString(),
              title: task.title,
              durationMinutes: task.durationMinutes,
              load: task.load.name,
              dayOffset:
                  max(0, dateOnly(task.scheduledDate).difference(today).inDays),
              done: task.done,
            ))
        .toList();

    final goalInfos = _goals
        .map((goal) => ReassignGoalInfo(
              id: goal.id.toString(),
              title: goal.title,
              importance: goal.importance,
              deadlineDays:
                  max(0, dateOnly(goal.deadline).difference(today).inDays),
            ))
        .toList();

    final routineInfos = _routines
        .map((routine) => RoutineInfo(
              title: routine.title,
              startsAt: routine.startsAt.toIso8601String(),
              repeat: routine.repeat.label,
            ))
        .toList();

    _showReassignmentLoader(trigger);
    try {
      final result = await context.read<GenkitService>().agentReassign.reassign(
            TaskReassignmentRequest(
              trigger: trigger,
              tasks: taskInfos,
              goals: goalInfos,
              mood: _selectedMood,
              routines: routineInfos,
              context: {
                'completedToday': _todayCompleted,
                'totalToday': _todayTasks.length,
                'streak': _streak,
              },
            ),
          );
      // A newer reassignment request superseded this one — drop it.
      if (!mounted || requestSerial != _reassignRequestSerial) return;
      if (!result.changed) {
        // Still tell the user the agent ran and decided to keep the plan.
        _showMessage('AI checked your schedule: ${result.explanation}');
        return;
      }
      _applyReassignment(result);
    } catch (e) {
      if (e.toString().contains('not-found')) {
        _reassignAgentAvailable = false;
      }
      debugPrint('Task reassignment unavailable: $e');
    } finally {
      _hideReassignmentLoader();
    }
  }

  void _applyReassignment(TaskReassignmentResponse result) {
    final moved = <MicroTask>[];
    setState(() {
      for (final change in result.changes) {
        for (final goal in _goals) {
          if (goal.id.toString() != change.goalId) continue;
          for (final task in goal.tasks) {
            if (task.id.toString() != change.taskId) continue;
            task.scheduledDate = addDays(today, change.toDayOffset);
            moved.add(task);
          }
        }
      }
    });
    if (moved.isEmpty) return;

    final sync = _sync;
    if (sync != null) {
      for (final task in moved) {
        unawaited(
          sync.upsertTask(task.goalId.toString(), task).catchError((Object e) {
            debugPrint('Reassigned task sync failed: $e');
          }),
        );
      }
    }
    _syncStreakFromCompletedTasks();
    _queueNotificationScheduleSync();

    // §6.4: always explain WHY the schedule changed.
    _addInAppNotification(
      title: 'AI rescheduled ${moved.length} task(s)',
      body: result.explanation,
      type: AppNotificationType.taskReminder,
      important: false,
      sourceId: 'agent-reassignment',
    );
    _showMessage('AI adjusted your schedule: ${result.explanation}');
  }

  Future<void> _startFocusSession(FocusSessionConfig config) async {
    _focusTimer?.cancel();
    final endsAt =
        DateTime.now().add(Duration(minutes: config.durationMinutes));

    if (_focusAppBlocking.isSupported) {
      if (!_notificationBridgeReady) {
        _notificationBridgeReady = await _androidNotifications.initialize();
      }
      final notificationsAllowed = await _ensureAndroidNotificationPermission();
      if (!mounted) return;
      if (!notificationsAllowed) {
        _showMessage(
          'Enable Goal Digger notifications to show the focus timer.',
        );
        await _androidNotifications.openNotificationSettings();
        return;
      }

      final nativeSession = await _focusAppBlocking.startFocusSession(
        packages: config.blockedPackages,
        endsAt: endsAt,
        title: config.title,
      );
      if (!mounted) return;
      if (!nativeSession.started) {
        if (!nativeSession.accessibilityRequired) {
          _showMessage(
            'Enable the Focus timer notification channel to start focus.',
          );
          await _androidNotifications.openNotificationSettings();
          return;
        }
        _showMessage(
          'Enable Goal Digger App Block in Android Accessibility settings.',
        );
        await _focusAppBlocking.openAccessibilitySettings();
        return;
      }
    }

    setState(() {
      _activeFocusConfig = config;
      _focusRemainingSeconds = config.durationMinutes * 60;
      _focusEndsAt = endsAt;
      _focusPaused = false;
      _focusCompletionHandled = false;
    });
    _focusTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _refreshFocusCountdown(),
    );
    _queueNotificationScheduleSync();
    _openActiveFocusDialog();
  }

  void _refreshFocusCountdown() {
    if (!mounted || _activeFocusConfig == null || _focusPaused) return;
    final endsAt = _focusEndsAt;
    if (endsAt == null) return;

    final remainingMilliseconds =
        endsAt.difference(DateTime.now()).inMilliseconds;
    final remainingSeconds = max(0, (remainingMilliseconds + 999) ~/ 1000);
    if (remainingSeconds != _focusRemainingSeconds) {
      setState(() => _focusRemainingSeconds = remainingSeconds);
    }
    if (remainingSeconds == 0) {
      _focusTimer?.cancel();
      _handleFocusSessionCompleted();
    }
  }

  void _handleFocusSessionCompleted() {
    final config = _activeFocusConfig;
    if (_focusCompletionHandled || config == null) return;
    _focusCompletionHandled = true;
    _focusTimer?.cancel();
    unawaited(_focusAppBlocking.stopFocusSession());
    unawaited(SystemSound.play(SystemSoundType.alert));
    _showMessage('Focus session complete. Nice work.');
    if (_notificationSettings.systemNotificationsEnabled &&
        _notificationSettings.focusNotificationsEnabled) {
      unawaited(_showFocusCompleteSystemNotification(config));
    }
    _queueNotificationScheduleSync();
  }

  Future<void> _showFocusCompleteSystemNotification(
    FocusSessionConfig config,
  ) {
    return _showSystemNotificationNow(
      key: 'focus_complete',
      title: 'Focus session complete',
      body: '${config.title} is ready to wrap up.',
      type: AppNotificationType.focusComplete,
      important: true,
      sourceId: config.title,
    );
  }

  void _openActiveFocusDialog() {
    final config = _activeFocusConfig;
    if (config == null) return;
    if (_focusDialogOpen) return;
    _focusDialogOpen = true;
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FocusCountdownDialog(
          config: config,
          remainingSecondsProvider: () => _focusRemainingSeconds,
          pausedProvider: () => _focusPaused,
          onPauseToggle: () => unawaited(_toggleFocusPause()),
          onMinimize: () => Navigator.of(context).pop(),
          onStop: _stopFocusSession,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
                scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
                child: child));
      },
    ).whenComplete(() {
      _focusDialogOpen = false;
    });
  }

  Future<void> _toggleFocusPause() async {
    final config = _activeFocusConfig;
    if (config == null) return;

    if (_focusPaused) {
      final endsAt =
          DateTime.now().add(Duration(seconds: _focusRemainingSeconds));
      if (_focusAppBlocking.isSupported) {
        final nativeSession = await _focusAppBlocking.startFocusSession(
          packages: config.blockedPackages,
          endsAt: endsAt,
          title: config.title,
        );
        if (!mounted) return;
        if (!nativeSession.started) {
          if (!nativeSession.accessibilityRequired) {
            _showMessage(
              'Enable the Focus timer notification channel before resuming.',
            );
            await _androidNotifications.openNotificationSettings();
            return;
          }
          _showMessage(
            'App blocking is disabled. Enable it before resuming focus.',
          );
          await _focusAppBlocking.openAccessibilitySettings();
          return;
        }
      }
      setState(() {
        _focusPaused = false;
        _focusEndsAt = endsAt;
      });
    } else {
      _refreshFocusCountdown();
      if (!mounted || _activeFocusConfig == null) return;
      setState(() {
        _focusPaused = true;
        _focusEndsAt = null;
      });
      await _focusAppBlocking.stopFocusSession();
      if (!mounted) return;
    }
    _queueNotificationScheduleSync();
  }

  void _stopFocusSession() {
    final config = _activeFocusConfig;
    final completed = _focusRemainingSeconds <= 0;
    if (completed) _handleFocusSessionCompleted();
    _focusTimer?.cancel();
    unawaited(_focusAppBlocking.stopFocusSession());

    if (completed && config?.task != null && config!.task!.done == false) {
      _completeTask(config.task!);
    }

    setState(() {
      _activeFocusConfig = null;
      _focusRemainingSeconds = 0;
      _focusEndsAt = null;
      _focusPaused = false;
      _focusCompletionHandled = false;
    });
    _queueNotificationScheduleSync();
    Navigator.of(context, rootNavigator: true).maybePop();

    if (config != null) {
      unawaited(_requestFocusInsight(config, completed: completed));
    }
  }

  Future<void> _requestFocusInsight(
    FocusSessionConfig config, {
    required bool completed,
  }) async {
    try {
      final task = config.task;
      final goal = task == null ? null : _goalForTask(task);
      final insight = await context.read<GenkitService>().focusInsight.analyse(
            FocusInsightRequest(
              taskTitle: config.title,
              goalTitle: goal?.title ?? 'Custom focus session',
              durationMinutes: config.durationMinutes,
              completed: completed,
            ),
          );
      if (!mounted) return;
      if (completed && insight.coinsEarned > 0) {
        setState(() {
          _coins += insight.coinsEarned;
        });
        unawaited(_persistProfileStats());
        _showMessage(
          '${_activeCompanion.label} says: +${insight.coinsEarned} coins for finishing ${config.durationMinutes} focused minutes. AI focus insight: ${insight.insight}',
        );
      } else {
        _showMessage('AI focus insight: ${insight.insight}');
      }
    } catch (e) {
      debugPrint('Focus insight unavailable: $e');
    }
  }

  void _openProfile() {
    final authState = context.read<AuthState>();
    final user = context.read<AuthService>().currentUser ?? authState.user;
    final displayName = _currentProfileDisplayName(user, authState);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => ProfileScreen(
          displayName: displayName,
          email: user?.email ?? '',
          photoUrl: user?.photoURL,
          signedInWith: _signedInWith,
          isGuest: user?.isAnonymous ?? authState.isGuest,
          emailVerified: authState.emailVerified,
          providerIds: authState.providerIds,
          coins: _coins,
          streak: _streak,
          petHappiness: _petHappiness,
          companion: _activeCompanion,
          streakTier: companionStreakTierFor(_streak),
          selectedMood: _selectedMood,
          goals: _goals,
          tasks: _allTasks,
          communities: _communities,
          friends: _friends,
          routines: _routines,
          goalReminders: _goalReminders,
          friendProgressSharing: _friendProgressSharing,
          onDisplayNameChanged: _updateDisplayName,
          onSendEmailVerification: authState.sendEmailVerification,
          onRefreshEmailVerification: authState.reloadUser,
          onSendPasswordReset: authState.sendPasswordResetEmail,
          onUpgradeGuestWithEmail: _upgradeGuestWithEmail,
          onUpgradeGuestWithGoogle: _upgradeGuestWithGoogle,
          onGoalRemindersChanged: _setGoalReminders,
          onFriendProgressSharingChanged: _setFriendProgressSharing,
          onSignOut: () => unawaited(_handleSignOut()),
          onDeleteAccount: _deleteCurrentAccount,
        ),
      ),
    );
  }

  String _currentProfileDisplayName(
    firebase_auth.User? user,
    AuthState authState,
  ) {
    if (_profileDisplayName?.trim().isNotEmpty == true) {
      return _profileDisplayName!.trim();
    }
    if (user?.displayName?.trim().isNotEmpty == true) {
      return user!.displayName!.trim();
    }
    return authState.displayName;
  }

  Future<bool> _updateDisplayName(String displayName) async {
    final authService = context.read<AuthService>();
    try {
      final cleaned = displayName.trim();
      await authService.updateDisplayName(displayName);
      final user = authService.currentUser;
      if (user == null) return false;
      if (mounted) {
        setState(() => _profileDisplayName = cleaned);
      }
      try {
        await _userRepository.createOrUpdateProfile(
          uid: user.uid,
          displayName: cleaned,
          email: user.email,
          photoUrl: user.photoURL,
        );
      } catch (e) {
        debugPrint('Display name profile sync failed: $e');
      }
      return true;
    } catch (e) {
      debugPrint('Display name update failed: $e');
      return false;
    }
  }

  Future<bool> _upgradeGuestWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final authState = context.read<AuthState>();
    final authService = context.read<AuthService>();
    final upgraded = await authState.upgradeGuestWithEmail(
      displayName: displayName,
      email: email,
      password: password,
    );
    final user = authService.currentUser ?? authState.user;
    if (!upgraded || user == null) return false;

    try {
      await _userRepository.createOrUpdateProfile(
        uid: user.uid,
        displayName: displayName.trim(),
        email: user.email ?? email.trim(),
        photoUrl: user.photoURL,
      );
      await _userRepository.markOnboarded(user.uid);
      if (mounted) {
        setState(() {
          _profileDisplayName = displayName.trim();
          _signedInWith = 'Email';
        });
      }
      return true;
    } catch (e) {
      debugPrint('Guest upgrade profile sync failed: $e');
      if (mounted) {
        setState(() {
          _profileDisplayName = displayName.trim();
          _signedInWith = 'Email';
        });
      }
      return true;
    }
  }

  Future<GuestGoogleUpgradeResult?> _upgradeGuestWithGoogle() async {
    final authState = context.read<AuthState>();
    final authService = context.read<AuthService>();
    final upgraded = await authState.upgradeGuestWithGoogle();
    final user = authService.currentUser ?? authState.user;
    if (!upgraded || user == null) return null;

    final displayName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : _profileDisplayName?.trim().isNotEmpty == true
            ? _profileDisplayName!.trim()
            : 'Goal Digger User';
    final email = user.email ?? '';

    try {
      await _userRepository.createOrUpdateProfile(
        uid: user.uid,
        displayName: displayName,
        email: email,
        photoUrl: user.photoURL,
      );
      await _userRepository.markOnboarded(user.uid);
    } catch (e) {
      debugPrint('Guest Google upgrade profile sync failed: $e');
    }

    if (mounted) {
      setState(() {
        _profileDisplayName = displayName;
        _signedInWith = 'Google';
      });
    }

    return GuestGoogleUpgradeResult(displayName: displayName, email: email);
  }

  Future<bool> _deleteCurrentAccount() async {
    final authState = context.read<AuthState>();

    var deleted = await authState.deleteCurrentUser();

    if (!deleted && authState.needsPasswordReauth && mounted) {
      final password = await _promptDeletePassword();
      if (password == null) return false;
      deleted = await authState.deleteCurrentUser(password: password);
    }

    if (deleted) {
      if (mounted) _resetForSignedOutState();
      return true;
    }

    if (mounted) {
      _showHelpfulError(
        title: 'Delete account failed',
        message: authState.errorMessage ??
            'Could not delete account. Please try again.',
        actionLabel: 'OK',
        onAction: () {},
      );
    }
    return false;
  }

  Future<String?> _promptDeletePassword() async {
    final controller = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            icon: Icon(Icons.lock_outline_rounded, color: gdError),
            title: const Text('Confirm your password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'For security, re-enter your password to permanently delete this account.',
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  obscureText: true,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  onSubmitted: (value) =>
                      Navigator.pop(dialogContext, value.trim()),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: gdError),
                onPressed: () =>
                    Navigator.pop(dialogContext, controller.text.trim()),
                child: const Text('Delete account'),
              ),
            ],
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }

  void _addRoutine(RoutineItem routine) {
    setState(() => _routines.add(routine));
    final sync = _sync;
    if (sync != null) {
      unawaited(sync.createRoutine(routine).catchError((Object e) {
        debugPrint('Routine sync failed: $e');
        _showMessage('Routine added locally, but Firebase save failed.');
        return routine;
      }));
    }
    _queueNotificationScheduleSync();
    _showMessage('Routine added.');
    // §8: a new fixed commitment may collide with scheduled tasks — let the
    // Task Reassignment Agent rebalance around it.
    unawaited(_requestTaskReassignment('routineAdded'));
  }

  void _deleteRoutine(RoutineItem routine) {
    setState(() => _routines.removeWhere((item) => item.id == routine.id));
    final sync = _sync;
    if (sync != null) {
      unawaited(sync.deleteRoutine(routine.id).catchError((Object e) {
        debugPrint('Routine delete sync failed: $e');
      }));
    }
    _queueNotificationScheduleSync();
    _showMessage('Routine deleted.');
  }

  void _openSettings() {
    final authState = context.read<AuthState>();
    final user = context.read<AuthService>().currentUser ?? authState.user;
    final email = user?.email ?? '';

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => SettingsScreen(
          goalReminders: _goalReminders,
          friendProgressSharing: _friendProgressSharing,
          notificationSettings: _notificationSettings,
          onGoalRemindersChanged: _setGoalReminders,
          onFriendProgressSharingChanged: _setFriendProgressSharing,
          onNotificationSettingsChanged: _setNotificationSettings,
          onTestNotification: () => unawaited(_sendTestNotification()),
          onOpenNotificationSettings: _openAndroidNotificationSettings,
          onSignOut: () => unawaited(_handleSignOut()),
          email: email,
          signedInWith: _signedInWith,
          isGuest: user?.isAnonymous ?? authState.isGuest,
          emailVerified: authState.emailVerified,
          providerIds: authState.providerIds,
          onSendEmailVerification: authState.sendEmailVerification,
          onRefreshEmailVerification: authState.reloadUser,
          onSendPasswordReset: () => authState.sendPasswordResetEmail(email),
          onDeleteAccount: _deleteCurrentAccount,
        ),
      ),
    );
  }

  Future<void> _editGoalDeadline(GoalProject goal) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: goal.deadline.isBefore(today) ? today : goal.deadline,
      firstDate: today,
      lastDate: DateTime(today.year + 5),
    );
    if (picked == null) return;
    setState(() => goal.deadline = picked);
    final sync = _sync;
    if (sync != null) {
      unawaited(sync.updateGoal(goal).catchError((Object e) {
        debugPrint('Deadline sync failed: $e');
      }));
    }
    _queueNotificationScheduleSync();
    _ensureImportantDeadlineNotifications();
    _showMessage('Deadline updated to ${shortDate(picked)}.');
  }

  Future<void> _editGoalPriority(GoalProject goal) async {
    var draftPriority = goal.importance;
    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          backgroundColor: gdSurface,
          title: const Text('Edit priority'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(goal.title,
                  style:
                      TextStyle(color: gdMuted, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              PrioritySelector(
                value: draftPriority,
                onChanged: (value) =>
                    setLocalState(() => draftPriority = value),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(context, draftPriority),
                child: const Text('Save priority')),
          ],
        ),
      ),
    );
    if (result == null) return;
    setState(() => goal.importance = result);
    final sync = _sync;
    if (sync != null) {
      unawaited(sync.updateGoal(goal).catchError((Object e) {
        debugPrint('Priority sync failed: $e');
      }));
    }
    _queueNotificationScheduleSync();
    _showMessage('Priority updated.');
  }

  @override
  Widget build(BuildContext context) {
    // Pin the token resolver to the theme MaterialApp actually resolved (this
    // context is inside the applied theme). Reading Theme.of also makes the
    // shell rebuild on any theme change, so every screen repaints in the
    // active light/dark palette, consistently with the themed text styles.
    GdColors.setBrightness(Theme.of(context).brightness);

    // Rebuild the root only when the auth status itself changes. Loading and
    // error changes are only needed by onboarding, and rebuilding the signed-in
    // shell during modal cleanup can upset Flutter's inherited-widget tree.
    final authStatus =
        context.select<AuthState, AuthStatus>((authState) => authState.status);

    // All side effects (sync activation, Firestore writes) are handled
    // in _onAuthStateChanged via the addListener wired in didChangeDependencies.
    if (authStatus == AuthStatus.unknown) {
      return Scaffold(
        backgroundColor: gdBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_onboarded) {
      return Consumer<AuthState>(
        builder: (context, authState, _) => OnboardingScreen(
          isLoading: authState.isLoading,
          errorMessage: authState.errorMessage,
          onClearError: authState.clearError,
          onPasswordReset: authState.sendPasswordResetEmail,
          onEmailAuth: (email, password, displayName, isSignUp) =>
              _completeOnboardingWithEmail(
            email: email,
            password: password,
            displayName: displayName,
            isSignUp: isSignUp,
          ),
          onGoogle: () => unawaited(_completeOnboardingWithAuth('Google')),
          onGuest: () => unawaited(_completeOnboardingWithAuth('Guest')),
        ),
      );
    }

    final pages = [
      PlannerPage(
        goals: _goals,
        today: today,
        goalController: _goalController,
        deadline: _newGoalDeadline,
        priority: _newGoalPriority,
        category: _newGoalCategory,
        isProcessing: _isProcessing,
        processingProgress: _processingProgress,
        onDeadlinePick: _pickDeadline,
        onPriorityChanged: (value) => setState(() => _newGoalPriority = value),
        onCategoryChanged: (value) => setState(() => _newGoalCategory = value),
        onCreateGoal: _createGoalWithProgress,
        onDeleteGoal: _deleteGoal,
        onEditGoalDeadline: _editGoalDeadline,
        onEditGoalPriority: _editGoalPriority,
        onCreateFirstGoal: () => setState(() => _selectedIndex = 0),
      ),
      CalendarPage(
        tasks: _allTasks,
        routines: _routines,
        goalForTask: _goalForTask,
        today: today,
        onCreateGoal: () => setState(() => _selectedIndex = 0),
        onAddRoutine: _addRoutine,
        onDeleteRoutine: _deleteRoutine,
        onSyncTaskToGoogle: _syncTaskToGoogleCalendar,
        onSyncAllTasksToGoogle: _syncAllTasksToGoogleCalendar,
      ),
      TasksPage(
        mood: _selectedMood,
        todayTasks: _todayTasks,
        todayProgress: _todayProgress,
        todayCompleted: _todayCompleted,
        todayTotal: _todayTasks.length,
        remainingMinutes: _remainingMinutes,
        goalForTask: _goalForTask,
        onMoodChanged: _handleMoodChanged,
        onCompleteTask: _completeTask,
        onCreateGoal: () => setState(() => _selectedIndex = 0),
      ),
      CommunityPage(
        controller: _communityController,
        communities: _communities,
        friends: _friends,
        friendSuggestions: _friendSuggestions,
        streak: _streak,
        lastStreakDateKey: _lastStreakDateKey,
        aiSuggestionContext: _socialSuggestionContext(),
        onAddCommunity: _addCommunity,
        onJoinCommunity: _joinCommunity,
        onDeleteCommunity: _deleteCommunity,
        onAddFriend: _addFriend,
        onDeleteFriend: _deleteFriend,
      ),
      CompanionPage(
        coins: _coins,
        happiness: _petHappiness,
        companionHappiness: _companionHappinessForPersistence(),
        streakTier: companionStreakTierFor(_streak),
        activeCompanion: _activeCompanion,
        unlockedCompanions: _unlockedCompanions,
        onCompanionSelected: _selectCompanion,
        onGachaPull: _pullCompanionGacha,
        onFeed: _feedPet,
        onPetInteract: _interactWithPet,
      ),
    ];

    return ResponsiveGoalShell(
      selectedIndex: _selectedIndex,
      signedInWith: _signedInWith,
      pages: pages,
      onSelect: (index) => setState(() => _selectedIndex = index),
      onFocusMode: _openFocusMode,
      onProfile: _openProfile,
      onSettings: _openSettings,
      onNotifications: _openNotifications,
      unreadNotifications:
          _notifications.where((notification) => notification.isUnread).length,
      importantUnreadNotifications: _notifications
          .where(
              (notification) => notification.important && notification.isUnread)
          .length,
      hasActiveFocus: _hasActiveFocus || _focusComplete,
      focusLabel: _activeFocusConfig == null
          ? null
          : (_focusComplete
              ? 'Done'
              : _formatFocusTime(_focusRemainingSeconds)),
    );
  }
}
