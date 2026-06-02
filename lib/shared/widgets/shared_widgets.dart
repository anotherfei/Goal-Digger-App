import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/constants/gd_constants.dart';
import '../../core/theme/gd_colors.dart';
import '../../core/utils/date_helpers.dart';
import '../../models/models.dart';

class GoalShellInsets extends InheritedWidget {
  const GoalShellInsets({
    super.key,
    required this.bottom,
    required super.child,
  });

  final double bottom;

  static double bottomOf(BuildContext context, {double fallback = 112}) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<GoalShellInsets>();
    final bottom = inherited?.bottom ?? fallback;
    return bottom > fallback ? bottom : fallback;
  }

  @override
  bool updateShouldNotify(covariant GoalShellInsets oldWidget) {
    return bottom != oldWidget.bottom;
  }
}

class PageScaffold extends StatelessWidget {
  const PageScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AmbientBackground(),
        child,
      ],
    );
  }
}

class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gdBackground,
                const Color(0xFFE0F2FE).withValues(alpha: 0.7),
                const Color(0xFFFCE7F3).withValues(alpha: 0.45),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.margin, this.color});

  final Widget child;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? gdSurface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class PageHero extends StatelessWidget {
  const PageHero({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: EdgeInsets.all(compact ? 0 : 20),
        child: Row(
          children: [
            CircleAvatar(
              radius: compact ? 22 : 28,
              backgroundColor: gdPrimarySoft,
              child: Icon(icon, color: gdPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        color: gdMuted, fontWeight: FontWeight.w600),
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

class MoodCheckPanel extends StatelessWidget {
  const MoodCheckPanel({
    super.key,
    required this.selectedMood,
    required this.onMoodChanged,
  });

  final String selectedMood;
  final ValueChanged<String> onMoodChanged;

  static const _moods = [
    _MoodOption(
      label: 'Tired',
      icon: Icons.spa_rounded,
      color: gdGradientWellnessTo,
      softColor: gdAccentSoft,
      subtitle: 'Light pace',
    ),
    _MoodOption(
      label: 'Okay',
      icon: Icons.tune_rounded,
      color: gdPrimary,
      softColor: gdPrimarySoft,
      subtitle: 'Balanced',
    ),
    _MoodOption(
      label: 'Great',
      icon: Icons.bolt_rounded,
      color: gdGradientStudyFrom,
      softColor: Color(0xFFFFF7ED),
      subtitle: 'Stretch',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const spacing = 12.0;

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: gdPrimarySoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: gdPrimary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mood check',
                        style: TextStyle(
                          color: gdInk,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Match today's plan to your energy.",
                        style: TextStyle(
                          color: gdMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: spacing),
            Row(
              children: [
                for (final mood in _moods)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: mood == _moods.last ? 0 : spacing,
                      ),
                      child: _MoodButton(
                        option: mood,
                        selected: selectedMood == mood.label,
                        onTap: () => onMoodChanged(mood.label),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodOption {
  const _MoodOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.softColor,
    required this.subtitle,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color softColor;
  final String subtitle;
}

class _MoodButton extends StatelessWidget {
  const _MoodButton({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _MoodOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${option.label} mood',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        height: 118,
        decoration: BoxDecoration(
          color: selected ? option.softColor : gdCardLight,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? option.color : gdBorder,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: option.color.withValues(alpha: 0.14),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: selected
                          ? option.color.withValues(alpha: 0.14)
                          : gdSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? option.color.withValues(alpha: 0.24)
                            : gdBorder,
                      ),
                    ),
                    child: Icon(
                      option.icon,
                      color: selected ? option.color : gdMuted,
                      size: 23,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    option.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? gdInk : gdMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    option.subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: gdMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProcessingProgressCard extends StatelessWidget {
  const ProcessingProgressCard({
    super.key,
    required this.progress,
    required this.label,
  });

  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0).toDouble();
    final percent = (safeProgress * 100).round();
    final secondsRemaining = max(0, ((1 - safeProgress) * 3).ceil());

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircularProgressBadge(
              progress: safeProgress,
              label: '$percent%',
              size: 82,
              strokeWidth: 8,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.hourglass_top_rounded),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(label,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    secondsRemaining == 0
                        ? 'Almost ready...'
                        : 'About $secondsRemaining seconds remaining',
                    style: const TextStyle(
                        color: gdMuted, fontWeight: FontWeight.w700),
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

class TodayProgressCard extends StatelessWidget {
  const TodayProgressCard({
    super.key,
    required this.progress,
    required this.completed,
    required this.total,
    required this.remainingMinutes,
  });

  final double progress;
  final int completed;
  final int total;
  final int remainingMinutes;

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0).toDouble();
    final percent = (safeProgress * 100).round();

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircularProgressBadge(
              progress: safeProgress,
              label: '$percent%',
              size: 112,
              strokeWidth: 10,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$completed/$total done',
                    style: const TextStyle(
                      color: gdInk,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'About $remainingMinutes minutes left',
                    style: const TextStyle(
                        color: gdMuted, fontWeight: FontWeight.w800),
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

class CircularProgressBadge extends StatelessWidget {
  const CircularProgressBadge({
    super.key,
    required this.progress,
    required this.label,
    this.size = 96,
    this.strokeWidth = 9,
  });

  final double progress;
  final String label;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0).toDouble();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: safeProgress,
              strokeWidth: strokeWidth,
              backgroundColor: const Color(0xFFE2E8F0),
              color: gdPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: gdPrimaryDark,
              fontSize: size >= 100 ? 22 : 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class HelpfulErrorBox extends StatelessWidget {
  const HelpfulErrorBox({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    this.onAction,
    this.showAction = true,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool showAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gdErrorSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gdError.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: gdError),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: gdError, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(message,
                    style: const TextStyle(color: gdInk, height: 1.4)),
                if (showAction) ...[
                  const SizedBox(height: 8),
                  TextButton(onPressed: onAction, child: Text(actionLabel)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.cta,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String cta;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: gdPrimarySoft,
              child: Icon(icon, color: gdPrimary, size: 48),
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: gdMuted, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add_rounded),
              label: Text(cta),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child:
                Text(title, style: Theme.of(context).textTheme.headlineMedium)),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              color: gdMuted,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
      ],
    );
  }
}

class CategorySelector extends StatelessWidget {
  const CategorySelector(
      {super.key, required this.selected, required this.onChanged});
  final String selected;
  final ValueChanged<String> onChanged;

  IconData _iconFor(String category) {
    switch (category) {
      case 'Career':
        return Icons.work_rounded;
      case 'Wellness':
        return Icons.favorite_rounded;
      case 'Finance':
        return Icons.savings_rounded;
      case 'Creative':
        return Icons.palette_rounded;
      case 'Study':
        return Icons.school_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Category',
          style: TextStyle(color: gdInk, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final item in categories)
          Builder(builder: (context) {
            final isSelected = selected == item;
            return ChoiceChip(
              selected: isSelected,
              selectedColor: gdPrimary,
              backgroundColor: gdSurface,
              side: BorderSide(color: isSelected ? gdPrimary : gdBorderStrong),
              avatar: Icon(_iconFor(item),
                  size: 18, color: isSelected ? Colors.white : gdPrimary),
              label: Text(item,
                  style: TextStyle(
                      color: isSelected ? Colors.white : gdInk,
                      fontWeight: FontWeight.w900)),
              onSelected: (_) => onChanged(item),
            );
          }),
      ]),
    ]);
  }
}

class StatMiniCard extends StatelessWidget {
  const StatMiniCard(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: gdCardLight,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: gdPrimary),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label,
              style:
                  const TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class PrioritySelector extends StatelessWidget {
  const PrioritySelector(
      {super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Priority',
          style: TextStyle(color: gdInk, fontWeight: FontWeight.w900),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: List.generate(5, (index) {
              final star = index + 1;
              return Expanded(
                child: IconButton(
                  tooltip: 'Priority $star',
                  onPressed: () => onChanged(star),
                  icon: Icon(
                    star <= value
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: star <= value
                        ? gdStarGold
                        : gdMuted.withValues(alpha: 0.55),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class GoalCard extends StatelessWidget {
  const GoalCard({
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

  void _showTaskDetail(BuildContext context, MicroTask task) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: gdSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              Text(goal.title,
                  style: const TextStyle(
                      color: gdMuted, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              AppCard(
                  color: gdCardLight,
                  child: ListTile(
                      leading: Icon(task.load.icon),
                      title: Text(
                          '${task.durationMinutes} minutes · ${task.load.label}',
                          style: const TextStyle(fontWeight: FontWeight.w900)),
                      subtitle: Text(
                          'Scheduled on ${longDate(task.scheduledDate)}',
                          style: const TextStyle(
                              color: gdMuted, fontWeight: FontWeight.w700)))),
              const SizedBox(height: 12),
              Text(
                  task.done ? 'Status: completed' : 'Status: not completed yet',
                  style: const TextStyle(
                      color: gdInk, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed = goal.tasks.where((task) => task.done).length;
    final daysLeft = daysBetween(today, goal.deadline);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            height: 8,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              goal.from.withValues(alpha: 0.72),
              goal.to.withValues(alpha: 0.72)
            ]))),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Text(goal.title,
                      style: Theme.of(context).textTheme.titleLarge)),
              Chip(
                  backgroundColor: gdPrimarySoft,
                  label: Text(goal.category,
                      style: const TextStyle(
                          color: gdPrimary, fontWeight: FontWeight.w900))),
              IconButton(
                  tooltip: 'Remove goal',
                  onPressed: onDelete,
                  icon: const Icon(Icons.close_rounded, color: gdError)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              CircularProgressBadge(
                  progress: goal.progress,
                  label: '${(goal.progress * 100).round()}%',
                  size: 72,
                  strokeWidth: 7),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('$completed/${goal.tasks.length} tasks done',
                        style: const TextStyle(
                            color: gdMuted, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(
                          daysLeft <= 2
                              ? Icons.warning_amber_rounded
                              : Icons.event_rounded,
                          size: 18,
                          color: daysLeft <= 2 ? gdWarning : gdPrimary),
                      const SizedBox(width: 4),
                      Text(daysLeft < 0 ? 'Overdue' : '$daysLeft days left',
                          style: TextStyle(
                              color: daysLeft <= 2 ? gdWarning : gdMuted,
                              fontWeight: FontWeight.w900))
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.star_rounded,
                          size: 18, color: gdStarGold),
                      const SizedBox(width: 4),
                      Text('Priority ${goal.importance}/5',
                          style: const TextStyle(
                              color: gdMuted, fontWeight: FontWeight.w900)),
                    ]),
                  ])),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              OutlinedButton.icon(
                onPressed: onEditDeadline,
                icon: const Icon(Icons.event_rounded, size: 18),
                label: const Text('Edit deadline'),
              ),
              OutlinedButton.icon(
                onPressed: onEditPriority,
                icon: const Icon(Icons.star_rounded, size: 18),
                label: const Text('Edit priority'),
              ),
            ]),
            const Divider(height: 26),
            const Text('Subtasks',
                style: TextStyle(color: gdInk, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (var i = 0; i < goal.tasks.length; i++)
                ActionChip(
                  avatar:
                      Icon(goal.tasks[i].load.icon, size: 18, color: gdPrimary),
                  label: Text('Step ${i + 1}',
                      style: const TextStyle(
                          color: gdInk, fontWeight: FontWeight.w900)),
                  backgroundColor: goal.tasks[i].done
                      ? gdPrimarySoft
                      : const Color(0xFFF1F5F9),
                  side: const BorderSide(color: gdBorder),
                  onPressed: () => _showTaskDetail(context, goal.tasks[i]),
                ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class MoodAdjustmentNotice extends StatelessWidget {
  const MoodAdjustmentNotice({super.key, required this.mood});

  final String mood;

  @override
  Widget build(BuildContext context) {
    final icon = mood == 'Tired'
        ? Icons.spa_rounded
        : mood == 'Great'
            ? Icons.local_fire_department_rounded
            : Icons.tune_rounded;
    final title = mood == 'Tired'
        ? 'Tasks softened for low energy'
        : mood == 'Great'
            ? 'Stretch mode is available today'
            : 'Balanced task plan';
    final message = mood == 'Tired'
        ? 'Goal Digger shortens today’s actions and turns heavy tasks into smaller first steps.'
        : mood == 'Great'
            ? 'Goal Digger keeps the plan ambitious and suggests deeper work where it fits.'
            : 'Goal Digger keeps today’s tasks at their normal size.';

    return AppCard(
      color: mood == 'Tired'
          ? const Color(0xFFF0FDF4)
          : mood == 'Great'
              ? const Color(0xFFFFF7ED)
              : gdCardLight,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: gdSurface,
              child: Icon(icon, color: gdPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, color: gdInk)),
                  const SizedBox(height: 3),
                  Text(
                    message,
                    style: const TextStyle(
                        color: gdMuted,
                        fontWeight: FontWeight.w700,
                        height: 1.35),
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

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.goal,
    required this.mood,
    required this.onToggle,
  });

  final MicroTask task;
  final GoalProject goal;
  final String mood;
  final VoidCallback onToggle;

  String get _adjustedTitle {
    if (mood == 'Tired') {
      if (task.load == TaskLoad.stretch) return 'Tiny version: ${task.title}';
      if (task.durationMinutes > 15) return 'Start only: ${task.title}';
      return task.title;
    }
    if (mood == 'Great' && task.load != TaskLoad.light) {
      return 'Deep work: ${task.title}';
    }
    return task.title;
  }

  int get _adjustedMinutes {
    if (mood == 'Tired') {
      return min(task.durationMinutes, task.load == TaskLoad.stretch ? 12 : 15);
    }
    if (mood == 'Great' && task.load == TaskLoad.stretch) {
      return task.durationMinutes + 10;
    }
    return task.durationMinutes;
  }

  String get _moodTip {
    if (mood == 'Tired') {
      return task.load == TaskLoad.stretch
          ? 'Mood adjusted: do only the smallest useful part. You can finish the rest later.'
          : 'Mood adjusted: keep this light and stop after the first clear win.';
    }
    if (mood == 'Great') {
      return task.load == TaskLoad.light
          ? 'Warm-up task. Finish this quickly, then move to a deeper step.'
          : 'Mood adjusted: good energy today, so this can become a focused stretch block.';
    }
    return task.load == TaskLoad.light
        ? 'Start here when energy is low. This task is intentionally small.'
        : task.load == TaskLoad.focus
            ? 'Block distractions and work on this single step first.'
            : 'This is a higher-effort step. Do it when you have enough time.';
  }

  Color get _moodChipColor {
    if (mood == 'Tired') return const Color(0xFFDCFCE7);
    if (mood == 'Great') return const Color(0xFFFFEDD5);
    return gdPrimarySoft;
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(value: task.done, onChanged: (_) => onToggle()),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _adjustedTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            decoration:
                                task.done ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        if (mood != 'Okay')
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: _moodChipColor,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: gdBorder),
                            ),
                            child: Text(
                              mood == 'Tired'
                                  ? 'Adjusted lighter'
                                  : 'Stretch option',
                              style: const TextStyle(
                                color: gdInk,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${goal.title} · ${shortDate(task.scheduledDate)} · $_adjustedMinutes min · ${task.load.label}',
                      style: const TextStyle(
                          color: gdMuted, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(task.load.icon, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _moodTip,
                            style: const TextStyle(
                                color: gdMuted, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Chip(label: Text('+${task.points}')),
            ],
          ),
        ),
      ),
    );
  }
}

class PetAvatar extends StatelessWidget {
  const PetAvatar({super.key, required this.pet, this.size = 72});

  final PetSkin pet;
  final double size;

  @override
  Widget build(BuildContext context) {
    final eye = size * 0.08;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [pet.from, pet.to],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: pet.to.withValues(alpha: 0.34),
            blurRadius: size * 0.22,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * 0.23,
            child: Container(
              width: size * 0.45,
              height: size * 0.17,
              decoration: BoxDecoration(
                color: pet.accent.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            top: size * 0.43,
            left: size * 0.31,
            child: CircleAvatar(radius: eye, backgroundColor: Colors.white),
          ),
          Positioned(
            top: size * 0.43,
            right: size * 0.31,
            child: CircleAvatar(radius: eye, backgroundColor: Colors.white),
          ),
          Positioned(
            bottom: size * 0.27,
            child: Container(
              width: size * 0.22,
              height: size * 0.08,
              decoration: BoxDecoration(
                color: gdSurface.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RewardTile extends StatelessWidget {
  const RewardTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.price,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int price;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        minVerticalPadding: 14,
        leading: CircleAvatar(
          backgroundColor: gdPrimarySoft,
          child: Icon(icon, color: gdPrimary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle, style: const TextStyle(color: gdMuted)),
        trailing: Chip(
          avatar: const Icon(Icons.monetization_on_rounded, size: 18),
          label: Text('$price'),
        ),
      ),
    );
  }
}
