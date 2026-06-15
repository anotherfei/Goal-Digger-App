import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/constants/gd_constants.dart';
import '../../core/theme/gd_design.dart';
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

/// The app's base canvas. Deliberately a single flat, calm colour rather than
/// a gradient: the background is the quietest layer in a focus tool, so it
/// should add zero visual energy and let content + reward colour do the work.
/// (Energy/gradients are reserved for gamified surfaces like the pet and
/// rewards.)
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    // Depend on Theme so this repaints when brightness changes. Without it,
    // `const AmbientBackground()` is never rebuilt on a theme switch and the
    // canvas colour freezes at the brightness used on first launch.
    Theme.of(context);
    return Positioned.fill(
      child: IgnorePointer(
        child: ColoredBox(color: GdColors.canvas),
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
        borderRadius: GdRadius.card,
        boxShadow: GdShadows.soft,
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
                  Text(title, style: GdText.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style:
                        TextStyle(color: gdMuted, fontWeight: FontWeight.w600),
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

  // A getter so the option colours resolve against the live light/dark tokens
  // each build instead of baking at first access.
  static List<_MoodOption> get _moods => [
        _MoodOption(
          label: 'Tired',
          icon: Icons.spa_rounded,
          // Low energy → a calm, restorative green (settle and recover gently).
          color: GdColors.positive,
          softColor: GdColors.positiveSoft,
          subtitle: 'Light pace',
        ),
        _MoodOption(
          label: 'Okay',
          icon: Icons.tune_rounded,
          // Balanced → steady brand blue (neutral-positive).
          color: GdColors.brand,
          softColor: GdColors.brandSoft,
          subtitle: 'Balanced',
        ),
        _MoodOption(
          label: 'Great',
          icon: Icons.bolt_rounded,
          // High energy → energising warm coral (enthusiasm, push further).
          color: GdColors.warm,
          softColor: GdColors.warmSoft,
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
                  child: Icon(
                    Icons.favorite_rounded,
                    color: gdPrimary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
          boxShadow: selected ? GdShadows.glow(option.color) : null,
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
                          ? option.color.withValues(alpha: GdAlpha.soft)
                          : gdSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? option.color.withValues(alpha: GdAlpha.muted)
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
                    style: TextStyle(
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
                        child: Text(label, style: GdText.titleMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    secondsRemaining == 0
                        ? 'Almost ready...'
                        : 'About $secondsRemaining seconds remaining',
                    style:
                        TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
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
                    style: GdText.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$completed/$total done',
                    style: TextStyle(
                      color: gdInk,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'About $remainingMinutes minutes left',
                    style:
                        TextStyle(color: gdMuted, fontWeight: FontWeight.w800),
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
    final isPercentLabel = label.trim().endsWith('%');

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: safeProgress),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, _) {
        final animatedLabel =
            isPercentLabel ? '${(animatedProgress * 100).round()}%' : label;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: animatedProgress,
                  strokeWidth: strokeWidth,
                  backgroundColor: gdBorder,
                  color: gdPrimary,
                ),
              ),
              Text(
                animatedLabel,
                style: TextStyle(
                  color: gdPrimaryDark,
                  fontSize: size >= 100 ? 22 : 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      },
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
          Icon(Icons.info_outline_rounded, color: gdError),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: gdError, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(message, style: TextStyle(color: gdInk, height: 1.4)),
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
            Text(title, style: GdText.headlineMedium),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: gdMuted, fontWeight: FontWeight.w600),
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
        Expanded(child: Text(title, style: GdText.headlineMedium)),
        if (trailing != null)
          Text(
            trailing!,
            style: TextStyle(
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

  IconData _iconFor(String category) => GdCategory.iconFor(category);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Category',
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
          Text(value, style: GdText.titleLarge),
          Text(label,
              style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
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
        Text(
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
              Text(task.title, style: GdText.headlineMedium),
              const SizedBox(height: 10),
              Text(goal.title,
                  style:
                      TextStyle(color: gdMuted, fontWeight: FontWeight.w800)),
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
                          style: TextStyle(
                              color: gdMuted, fontWeight: FontWeight.w700)))),
              const SizedBox(height: 12),
              Text(
                  task.done ? 'Status: completed' : 'Status: not completed yet',
                  style: TextStyle(color: gdInk, fontWeight: FontWeight.w800)),
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
              Expanded(child: Text(goal.title, style: GdText.titleLarge)),
              Chip(
                  backgroundColor: gdPrimarySoft,
                  label: Text(goal.category,
                      style: TextStyle(
                          color: gdPrimary, fontWeight: FontWeight.w900))),
              IconButton(
                  tooltip: 'Remove goal',
                  onPressed: onDelete,
                  icon: Icon(Icons.close_rounded, color: gdError)),
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
                        style: TextStyle(
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
                      Icon(Icons.star_rounded, size: 18, color: gdStarGold),
                      const SizedBox(width: 4),
                      Text('Priority ${goal.importance}/5',
                          style: TextStyle(
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
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: Text('Subtasks',
                    style:
                        TextStyle(color: gdInk, fontWeight: FontWeight.w900)),
                subtitle: Text(
                  '$completed/${goal.tasks.length} complete',
                  style: TextStyle(color: gdMuted, fontWeight: FontWeight.w800),
                ),
                children: [
                  if (goal.tasks.isEmpty)
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 4, 0, 8),
                      child: Text('No subtasks scheduled yet.',
                          style: TextStyle(
                              color: gdMuted, fontWeight: FontWeight.w700)),
                    )
                  else
                    SizedBox(
                      height: min(goal.tasks.length * 58.0, 288),
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: goal.tasks.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final task = goal.tasks[index];
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            tileColor: task.done
                                ? gdPrimarySoft.withValues(alpha: 0.45)
                                : null,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            leading: Icon(task.load.icon,
                                color: task.done ? gdMuted : gdPrimary),
                            title: Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: task.done ? gdMuted : gdInk,
                                decoration: task.done
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                decorationThickness: 2,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            subtitle: Text(
                              '${task.durationMinutes} min · ${longDate(task.scheduledDate)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: task.done
                                      ? gdMuted.withValues(alpha: 0.72)
                                      : gdMuted,
                                  fontWeight: FontWeight.w700),
                            ),
                            onTap: () => _showTaskDetail(context, task),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
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
      color: GdMood.surface(mood),
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
                      style:
                          TextStyle(fontWeight: FontWeight.w900, color: gdInk)),
                  const SizedBox(height: 3),
                  Text(
                    message,
                    style: TextStyle(
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

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.goal,
    required this.mood,
    required this.onComplete,
  });

  final MicroTask task;
  final GoalProject goal;
  final String mood;
  final VoidCallback onComplete;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _completePulse;
  late bool _lastDone;

  @override
  void initState() {
    super.initState();
    _lastDone = widget.task.done;
    _completePulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
  }

  @override
  void didUpdateWidget(covariant TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.task.done != _lastDone) {
      if (widget.task.done) {
        _completePulse.forward(from: 0);
      }
      _lastDone = widget.task.done;
    }
  }

  @override
  void dispose() {
    _completePulse.dispose();
    super.dispose();
  }

  String get _adjustedTitle {
    if (widget.mood == 'Tired') {
      if (widget.task.load == TaskLoad.stretch) {
        return 'Tiny version: ${widget.task.title}';
      }
      if (widget.task.durationMinutes > 15) {
        return 'Start only: ${widget.task.title}';
      }
      return widget.task.title;
    }
    if (widget.mood == 'Great' && widget.task.load != TaskLoad.light) {
      return 'Deep work: ${widget.task.title}';
    }
    return widget.task.title;
  }

  int get _adjustedMinutes {
    if (widget.mood == 'Tired') {
      return min(
        widget.task.durationMinutes,
        widget.task.load == TaskLoad.stretch ? 12 : 15,
      );
    }
    if (widget.mood == 'Great' && widget.task.load == TaskLoad.stretch) {
      return widget.task.durationMinutes + 10;
    }
    return widget.task.durationMinutes;
  }

  String get _moodTip {
    if (widget.mood == 'Tired') {
      return widget.task.load == TaskLoad.stretch
          ? 'Mood adjusted: do only the smallest useful part. You can finish the rest later.'
          : 'Mood adjusted: keep this light and stop after the first clear win.';
    }
    if (widget.mood == 'Great') {
      return widget.task.load == TaskLoad.light
          ? 'Warm-up task. Finish this quickly, then move to a deeper step.'
          : 'Mood adjusted: good energy today, so this can become a focused stretch block.';
    }
    return widget.task.load == TaskLoad.light
        ? 'Start here when energy is low. This task is intentionally small.'
        : widget.task.load == TaskLoad.focus
            ? 'Block distractions and work on this single step first.'
            : 'This is a higher-effort step. Do it when you have enough time.';
  }

  Color get _moodChipColor {
    if (widget.mood == 'Tired') return GdColors.positiveSoft;
    if (widget.mood == 'Great') return GdColors.warmSoft;
    return gdPrimarySoft;
  }

  @override
  Widget build(BuildContext context) {
    final isDone = widget.task.done;
    final titleColor = isDone ? gdMuted.withValues(alpha: 0.58) : gdInk;
    final detailColor = isDone ? gdMuted.withValues(alpha: 0.54) : gdMuted;

    return AnimatedBuilder(
      animation: _completePulse,
      child: AppCard(
        color: isDone ? gdCardLight.withValues(alpha: 0.72) : null,
        child: InkWell(
          onTap: isDone ? null : widget.onComplete,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: isDone,
                  onChanged: isDone ? null : (_) => widget.onComplete(),
                ),
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
                              color: titleColor,
                              fontSize: 16,
                              fontWeight:
                                  isDone ? FontWeight.w800 : FontWeight.w900,
                              decoration:
                                  isDone ? TextDecoration.lineThrough : null,
                              decorationColor: gdMuted.withValues(alpha: 0.50),
                              decorationThickness: 1.8,
                            ),
                          ),
                          if (widget.mood != 'Okay')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: _moodChipColor,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: gdBorder),
                              ),
                              child: Text(
                                widget.mood == 'Tired'
                                    ? 'Adjusted lighter'
                                    : 'Stretch option',
                                style: TextStyle(
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
                        '${widget.goal.title} · ${shortDate(widget.task.scheduledDate)} · $_adjustedMinutes min · ${widget.task.load.label}',
                        style: TextStyle(
                            color: detailColor, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(widget.task.load.icon,
                              size: 18, color: detailColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _moodTip,
                              style: TextStyle(
                                  color: detailColor,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Chip(
                  backgroundColor: isDone
                      ? gdSuccessSoft
                      : gdPrimarySoft.withValues(alpha: 0.72),
                  avatar: isDone
                      ? Icon(Icons.check_circle_rounded,
                          size: 16, color: gdSuccess)
                      : null,
                  label: Text(
                    isDone ? 'Done' : '+${widget.task.points}',
                    style: TextStyle(
                      color: isDone ? gdSuccess : gdPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      builder: (context, child) {
        final pulse = sin(_completePulse.value * pi);
        final glowOpacity = widget.task.done ? 0.24 * pulse : 0.0;

        return Transform.scale(
          scale: 1 + pulse * 0.025,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: GdRadius.card,
              boxShadow: glowOpacity > 0
                  ? [
                      BoxShadow(
                        color: gdSuccess.withValues(alpha: glowOpacity),
                        blurRadius: 28,
                        spreadRadius: 1,
                        offset: const Offset(0, 12),
                      ),
                    ]
                  : null,
            ),
            child: child,
          ),
        );
      },
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
        subtitle: Text(subtitle, style: TextStyle(color: gdMuted)),
        trailing: Chip(
          avatar: const Icon(Icons.monetization_on_rounded, size: 18),
          label: Text('$price'),
        ),
      ),
    );
  }
}
