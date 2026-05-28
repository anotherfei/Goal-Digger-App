import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/gd_constants.dart';
import '../../core/theme/gd_colors.dart';
import '../../models/models.dart';
import '../../shared/widgets/shared_widgets.dart';

class CompanionPage extends StatefulWidget {
  const CompanionPage({
    super.key,
    required this.coins,
    required this.happiness,
    required this.pet,
    required this.accessory,
    required this.todayTasks,
    required this.goalForTask,
    required this.onFeed,
    required this.onOpenChest,
    required this.onPetInteract,
    required this.onToggleTask,
    required this.onEquipSkin,
    required this.onEquipAccessory,
  });

  final int coins;
  final int happiness;
  final PetSkin pet;
  final String accessory;
  final List<MicroTask> todayTasks;
  final GoalProject Function(MicroTask task) goalForTask;
  final VoidCallback onFeed;
  final VoidCallback onOpenChest;
  final VoidCallback onPetInteract;
  final ValueChanged<MicroTask> onToggleTask;
  final ValueChanged<PetSkin> onEquipSkin;
  final ValueChanged<String> onEquipAccessory;

  @override
  State<CompanionPage> createState() => _CompanionPageState();
}

class _CompanionPageState extends State<CompanionPage> {
  static const List<PetSkin> _skinOptions = [
    defaultPet,
    PetSkin(
      name: 'Peach',
      from: Color(0xFFFF9F8A),
      to: Color(0xFFFFD166),
      accent: Color(0xFFFFF1E6),
    ),
    PetSkin(
      name: 'Lunar',
      from: Color(0xFF7485A3),
      to: Color(0xFF1E293B),
      accent: Color(0xFFE2E8F0),
    ),
    PetSkin(
      name: 'Bloom',
      from: Color(0xFFFB7185),
      to: Color(0xFF8B5CF6),
      accent: Color(0xFFFFE4E6),
    ),
  ];

  static const List<_GearOption> _gearOptions = [
    _GearOption(label: 'Cap', icon: Icons.workspace_premium_rounded),
    _GearOption(label: 'Star badge', icon: Icons.stars_rounded),
    _GearOption(label: 'Tiny scarf', icon: Icons.auto_awesome_motion_rounded),
    _GearOption(label: 'Focus glasses', icon: Icons.visibility_rounded),
    _GearOption(label: 'Trailblazer suit', icon: Icons.shield_rounded),
    _GearOption(label: 'Calm cloak', icon: Icons.nightlight_round),
  ];

  String _selectedSkin = defaultPet.name;

  @override
  void initState() {
    super.initState();
    _selectedSkin = widget.pet.name;
  }

  @override
  void didUpdateWidget(covariant CompanionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pet.name != widget.pet.name) {
      _selectedSkin = widget.pet.name;
    }
  }

  PetSkin get _previewSkin {
    return _skinOptions.firstWhere(
      (skin) => skin.name == _selectedSkin,
      orElse: () => widget.pet,
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedToday = widget.todayTasks.where((task) => task.done).length;
    final totalToday = widget.todayTasks.length;
    final remainingTasks =
        widget.todayTasks.where((task) => !task.done).toList();
    final remainingMinutes = remainingTasks.fold<int>(
      0,
      (sum, task) => sum + task.durationMinutes,
    );

    return PageScaffold(
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(18, 72, 18, 112),
            children: [
              _CompanionHeroCard(
                skin: _previewSkin,
                accessory: widget.accessory,
                happiness: widget.happiness,
                completedToday: completedToday,
                totalToday: totalToday,
                remainingMinutes: remainingMinutes,
                message: _companionMessage(remainingTasks),
                onFeed: widget.onFeed,
                onInteract: widget.onPetInteract,
              ),
              const SizedBox(height: 22),
              SectionTitle(
                title: 'Today with your companion',
                trailing: totalToday == 0
                    ? 'Clear'
                    : '$completedToday/$totalToday done',
              ),
              const SizedBox(height: 10),
              _DailyQuestCard(
                tasks: widget.todayTasks,
                goalForTask: widget.goalForTask,
                onToggleTask: widget.onToggleTask,
              ),
              const SizedBox(height: 22),
              const SectionTitle(title: 'Customize companion'),
              const SizedBox(height: 10),
              _CustomizationCard(
                selectedSkin: _selectedSkin,
                activeAccessory: widget.accessory,
                skinOptions: _skinOptions,
                gearOptions: _gearOptions,
                onSkinSelected: (skin) {
                  setState(() => _selectedSkin = skin.name);
                  widget.onEquipSkin(skin);
                },
                onGearSelected: widget.onEquipAccessory,
              ),
              const SizedBox(height: 22),
              SectionTitle(title: 'Mystery chest', trailing: '50 coins'),
              const SizedBox(height: 10),
              _ChestCard(
                onOpenChest: widget.onOpenChest,
                onFeed: widget.onFeed,
              ),
            ],
          ),
          Positioned(
            top: 14,
            left: 18,
            child: _FloatingWallet(coins: widget.coins),
          ),
        ],
      ),
    );
  }

  String _companionMessage(List<MicroTask> remainingTasks) {
    if (widget.todayTasks.isEmpty) {
      return 'No daily quests are scheduled. Your companion is ready when you are.';
    }
    if (remainingTasks.isEmpty) {
      return 'All daily quests are complete. Your companion is glowing with pride.';
    }

    final nextTask = remainingTasks.first;
    final goal = widget.goalForTask(nextTask);
    return 'Next: ${nextTask.title} for ${nextTask.durationMinutes} min. ${goal.title} gets closer today.';
  }
}

class _CompanionHeroCard extends StatelessWidget {
  const _CompanionHeroCard({
    required this.skin,
    required this.accessory,
    required this.happiness,
    required this.completedToday,
    required this.totalToday,
    required this.remainingMinutes,
    required this.message,
    required this.onFeed,
    required this.onInteract,
  });

  final PetSkin skin;
  final String accessory;
  final int happiness;
  final int completedToday;
  final int totalToday;
  final int remainingMinutes;
  final String message;
  final VoidCallback onFeed;
  final VoidCallback onInteract;

  @override
  Widget build(BuildContext context) {
    final todayProgress = totalToday == 0 ? 1.0 : completedToday / totalToday;

    return AppCard(
      color: gdSurface,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gdSurface,
              skin.accent.withValues(alpha: 0.42),
              gdPrimarySoft.withValues(alpha: 0.76),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Goal companion',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$accessory equipped',
                        style: const TextStyle(
                          color: gdMuted,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                _BondRing(value: happiness / 100),
              ],
            ),
            const SizedBox(height: 14),
            _CompanionStage(
              skin: skin,
              accessory: accessory,
              happiness: happiness,
              message: message,
              onTap: onInteract,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _MetricPill(
                    icon: Icons.favorite_rounded,
                    label: 'Bond',
                    value: '$happiness%',
                    progress: happiness / 100,
                    color: gdAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricPill(
                    icon: Icons.flag_rounded,
                    label: 'Quests',
                    value: totalToday == 0
                        ? 'Ready'
                        : '$completedToday/$totalToday',
                    progress: todayProgress,
                    color: gdPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricPill(
                    icon: Icons.timer_rounded,
                    label: 'Focus',
                    value: remainingMinutes == 0
                        ? 'Clear'
                        : '${remainingMinutes}m',
                    progress: remainingMinutes == 0 ? 1 : 0.35,
                    color: gdGradientFinanceTo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onInteract,
                    icon: const Icon(Icons.waving_hand_rounded),
                    label: const Text('Bond'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onFeed,
                    icon: const Icon(Icons.restaurant_rounded),
                    label: const Text('Feed -10'),
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

class _CompanionStage extends StatelessWidget {
  const _CompanionStage({
    required this.skin,
    required this.accessory,
    required this.happiness,
    required this.message,
    required this.onTap,
  });

  final PetSkin skin;
  final String accessory;
  final int happiness;
  final String message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final avatarSize = math.min(230.0, constraints.maxWidth * 0.76);

        return SizedBox(
          height: 342,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 8,
                right: 8,
                bottom: 6,
                child: _StagePlatform(color: skin.to),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _SpeechPanel(message: message),
              ),
              Positioned(
                top: 90,
                child: GestureDetector(
                  onTap: onTap,
                  child: _GoalGuardianAvatar(
                    skin: skin,
                    accessory: accessory,
                    happiness: happiness,
                    size: avatarSize,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SpeechPanel extends StatelessWidget {
  const _SpeechPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420, minHeight: 70),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: gdBorder),
          boxShadow: [
            BoxShadow(
              color: gdPrimary.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.assistant_photo_rounded,
                color: gdPrimary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: gdInk,
                  height: 1.28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StagePlatform extends StatelessWidget {
  const _StagePlatform({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 74,
      child: CustomPaint(
        painter: _StagePlatformPainter(color: color),
      ),
    );
  }
}

class _StagePlatformPainter extends CustomPainter {
  const _StagePlatformPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final baseRect = Rect.fromLTWH(
      size.width * 0.08,
      size.height * 0.28,
      size.width * 0.84,
      size.height * 0.42,
    );
    final shadowPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawOval(baseRect.inflate(12), shadowPaint);

    final ringPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.95),
          color.withValues(alpha: 0.28),
          gdPrimary.withValues(alpha: 0.18),
        ],
      ).createShader(baseRect);
    canvas.drawOval(baseRect, ringPaint);

    final strokePaint = Paint()
      ..color = gdBorderStrong.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawOval(baseRect.deflate(3), strokePaint);
  }

  @override
  bool shouldRepaint(covariant _StagePlatformPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _GoalGuardianAvatar extends StatelessWidget {
  const _GoalGuardianAvatar({
    required this.skin,
    required this.accessory,
    required this.happiness,
    required this.size,
  });

  final PetSkin skin;
  final String accessory;
  final int happiness;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.98, end: 1),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(-0.08)
          ..rotateY(0.10),
        child: CustomPaint(
          size: Size.square(size),
          painter: _GoalGuardianPainter(
            skin: skin,
            accessory: accessory,
            happiness: happiness,
          ),
        ),
      ),
    );
  }
}

class _GoalGuardianPainter extends CustomPainter {
  const _GoalGuardianPainter({
    required this.skin,
    required this.accessory,
    required this.happiness,
  });

  final PetSkin skin;
  final String accessory;
  final int happiness;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.52);
    final lowerAccessory = accessory.toLowerCase();

    _drawSoftShadow(canvas, size);
    if (lowerAccessory.contains('cloak')) {
      _drawCloak(canvas, size);
    }
    _drawSidePods(canvas, size);
    _drawBody(canvas, size);
    if (lowerAccessory.contains('suit')) {
      _drawSuit(canvas, size);
    }
    _drawCore(canvas, size);
    _drawFace(canvas, size);
    _drawExpression(canvas, size);

    if (lowerAccessory.contains('cap')) {
      _drawCap(canvas, size);
    }
    if (lowerAccessory.contains('glasses')) {
      _drawGlasses(canvas, size);
    }
    if (lowerAccessory.contains('scarf')) {
      _drawScarf(canvas, size);
    }
    if (lowerAccessory.contains('badge') || lowerAccessory.contains('star')) {
      _drawBadge(canvas, size);
    }

    final rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012;
    canvas.drawCircle(
        center.translate(w * 0.02, -h * 0.02), w * 0.32, rimPaint);
  }

  void _drawSoftShadow(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.88),
      width: size.width * 0.58,
      height: size.height * 0.12,
    );
    final paint = Paint()
      ..color = skin.to.withValues(alpha: 0.26)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawOval(rect, paint);
  }

  void _drawCloak(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cloak = Path()
      ..moveTo(w * 0.26, h * 0.34)
      ..quadraticBezierTo(w * 0.12, h * 0.54, w * 0.24, h * 0.82)
      ..quadraticBezierTo(w * 0.50, h * 0.94, w * 0.76, h * 0.82)
      ..quadraticBezierTo(w * 0.88, h * 0.54, w * 0.74, h * 0.34)
      ..close();
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          gdPrimaryDark.withValues(alpha: 0.86),
          gdGradientCreativeFrom.withValues(alpha: 0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, h * 0.28, w, h * 0.62));
    canvas.drawPath(cloak, paint);
  }

  void _drawSidePods(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          skin.from.withValues(alpha: 0.9),
          skin.to.withValues(alpha: 0.78)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, h * 0.34, w, h * 0.36));

    for (final side in [-1, 1]) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * (side == -1 ? 0.24 : 0.76), h * 0.58),
          width: w * 0.19,
          height: h * 0.30,
        ),
        Radius.circular(w * 0.09),
      );
      canvas.drawRRect(rect, paint);
      canvas.drawCircle(
        Offset(w * (side == -1 ? 0.20 : 0.80), h * 0.70),
        w * 0.035,
        Paint()..color = Colors.white.withValues(alpha: 0.72),
      );
    }
  }

  void _drawBody(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bodyRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.58),
      width: w * 0.56,
      height: h * 0.56,
    );
    final body = RRect.fromRectAndRadius(bodyRect, Radius.circular(w * 0.25));
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          skin.from,
          Color.lerp(skin.from, skin.to, 0.56)!,
          skin.to,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bodyRect);
    canvas.drawRRect(body, bodyPaint);

    final shadePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.42),
          Colors.white.withValues(alpha: 0.08),
          Colors.black.withValues(alpha: 0.08),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bodyRect);
    canvas.drawRRect(body.deflate(w * 0.018), shadePaint);

    final highlightRect = Rect.fromLTWH(
      bodyRect.left + w * 0.08,
      bodyRect.top + h * 0.08,
      w * 0.12,
      h * 0.25,
    );
    canvas.drawOval(
      highlightRect,
      Paint()..color = Colors.white.withValues(alpha: 0.34),
    );
  }

  void _drawSuit(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final left = Path()
      ..moveTo(w * 0.30, h * 0.50)
      ..lineTo(w * 0.47, h * 0.82)
      ..lineTo(w * 0.36, h * 0.84)
      ..quadraticBezierTo(w * 0.27, h * 0.68, w * 0.30, h * 0.50);
    final right = Path()
      ..moveTo(w * 0.70, h * 0.50)
      ..lineTo(w * 0.53, h * 0.82)
      ..lineTo(w * 0.64, h * 0.84)
      ..quadraticBezierTo(w * 0.73, h * 0.68, w * 0.70, h * 0.50);
    final paint = Paint()..color = gdInk.withValues(alpha: 0.68);
    canvas.drawPath(left, paint);
    canvas.drawPath(right, paint);

    final tie = Path()
      ..moveTo(w * 0.50, h * 0.56)
      ..lineTo(w * 0.56, h * 0.70)
      ..lineTo(w * 0.50, h * 0.82)
      ..lineTo(w * 0.44, h * 0.70)
      ..close();
    canvas.drawPath(tie, Paint()..color = gdStarGold.withValues(alpha: 0.9));
  }

  void _drawCore(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.50, h * 0.70);
    final glowPaint = Paint()
      ..color = skin.accent.withValues(alpha: 0.52)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, w * 0.11, glowPaint);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.018
      ..color = Colors.white.withValues(alpha: 0.86);
    canvas.drawCircle(center, w * 0.085, ringPaint);

    final gem = Path()
      ..moveTo(center.dx, center.dy - w * 0.065)
      ..lineTo(center.dx + w * 0.055, center.dy)
      ..lineTo(center.dx, center.dy + w * 0.07)
      ..lineTo(center.dx - w * 0.055, center.dy)
      ..close();
    canvas.drawPath(gem, Paint()..color = gdPrimary.withValues(alpha: 0.82));
  }

  void _drawFace(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final faceRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.39),
      width: w * 0.48,
      height: h * 0.27,
    );
    final face = RRect.fromRectAndRadius(faceRect, Radius.circular(w * 0.14));
    canvas.drawRRect(
      face,
      Paint()..color = Colors.white.withValues(alpha: 0.90),
    );
    canvas.drawRRect(
      face.deflate(w * 0.018),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012
        ..color = Colors.white.withValues(alpha: 0.72),
    );
  }

  void _drawExpression(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final eyePaint = Paint()..color = gdInk.withValues(alpha: 0.88);
    final shinePaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    final leftEye = Offset(w * 0.42, h * 0.38);
    final rightEye = Offset(w * 0.58, h * 0.38);

    canvas.drawOval(
      Rect.fromCenter(center: leftEye, width: w * 0.055, height: h * 0.075),
      eyePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: rightEye, width: w * 0.055, height: h * 0.075),
      eyePaint,
    );
    canvas.drawCircle(
        leftEye.translate(w * 0.01, -h * 0.012), w * 0.01, shinePaint);
    canvas.drawCircle(
        rightEye.translate(w * 0.01, -h * 0.012), w * 0.01, shinePaint);

    final smilePaint = Paint()
      ..color = gdInk.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.018;
    final smile = Path()..moveTo(w * 0.44, h * 0.46);
    final lift = happiness >= 70 ? h * 0.05 : h * 0.02;
    smile.quadraticBezierTo(w * 0.50, h * 0.50 + lift, w * 0.56, h * 0.46);
    canvas.drawPath(smile, smilePaint);

    final cheekPaint = Paint()..color = gdAccent.withValues(alpha: 0.22);
    canvas.drawCircle(Offset(w * 0.36, h * 0.45), w * 0.028, cheekPaint);
    canvas.drawCircle(Offset(w * 0.64, h * 0.45), w * 0.028, cheekPaint);
  }

  void _drawCap(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cap = Path()
      ..moveTo(w * 0.33, h * 0.25)
      ..quadraticBezierTo(w * 0.50, h * 0.13, w * 0.67, h * 0.25)
      ..lineTo(w * 0.63, h * 0.31)
      ..quadraticBezierTo(w * 0.50, h * 0.25, w * 0.37, h * 0.31)
      ..close();
    canvas.drawPath(cap, Paint()..color = gdPrimary);
    final brim = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.59, h * 0.30),
        width: w * 0.22,
        height: h * 0.045,
      ),
      Radius.circular(w * 0.03),
    );
    canvas.drawRRect(brim, Paint()..color = gdPrimaryDark);
  }

  void _drawGlasses(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = gdInk.withValues(alpha: 0.82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.014;
    final left = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.42, h * 0.38),
        width: w * 0.10,
        height: h * 0.075,
      ),
      Radius.circular(w * 0.025),
    );
    final right = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.58, h * 0.38),
        width: w * 0.10,
        height: h * 0.075,
      ),
      Radius.circular(w * 0.025),
    );
    canvas.drawRRect(left, paint);
    canvas.drawRRect(right, paint);
    canvas.drawLine(
        Offset(w * 0.47, h * 0.38), Offset(w * 0.53, h * 0.38), paint);
  }

  void _drawScarf(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final scarfPaint = Paint()..color = gdAccent.withValues(alpha: 0.92);
    final band = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.52),
        width: w * 0.42,
        height: h * 0.06,
      ),
      Radius.circular(w * 0.035),
    );
    canvas.drawRRect(band, scarfPaint);
    final tail = Path()
      ..moveTo(w * 0.58, h * 0.53)
      ..lineTo(w * 0.70, h * 0.66)
      ..lineTo(w * 0.62, h * 0.68)
      ..lineTo(w * 0.54, h * 0.55)
      ..close();
    canvas.drawPath(tail, scarfPaint);
  }

  void _drawBadge(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.64, h * 0.63);
    canvas.drawPath(
      _starPath(center, w * 0.055, w * 0.026),
      Paint()..color = gdStarGold,
    );
    canvas.drawPath(
      _starPath(center.translate(-w * 0.006, -h * 0.006), w * 0.018, w * 0.008),
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );
  }

  Path _starPath(Offset center, double outerRadius, double innerRadius) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _GoalGuardianPainter oldDelegate) {
    return oldDelegate.skin != skin ||
        oldDelegate.accessory != accessory ||
        oldDelegate.happiness != happiness;
  }
}

class _BondRing extends StatelessWidget {
  const _BondRing({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value.clamp(0, 1),
            strokeWidth: 7,
            backgroundColor: gdPrimarySoft,
            color: gdAccent,
            strokeCap: StrokeCap.round,
          ),
          const Icon(Icons.favorite_rounded, color: gdAccent, size: 21),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gdBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: gdMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: gdInk,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 6,
              backgroundColor: gdPrimarySoft,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyQuestCard extends StatelessWidget {
  const _DailyQuestCard({
    required this.tasks,
    required this.goalForTask,
    required this.onToggleTask,
  });

  final List<MicroTask> tasks;
  final GoalProject Function(MicroTask task) goalForTask;
  final ValueChanged<MicroTask> onToggleTask;

  @override
  Widget build(BuildContext context) {
    final visibleTasks = tasks.isEmpty
        ? <MicroTask>[]
        : [
            ...tasks.where((task) => !task.done),
            ...tasks.where((task) => task.done),
          ].take(4).toList();

    return AppCard(
      color: gdSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: tasks.isEmpty
            ? const _EmptyQuestState()
            : Column(
                children: [
                  for (var i = 0; i < visibleTasks.length; i++) ...[
                    _QuestTile(
                      task: visibleTasks[i],
                      goal: goalForTask(visibleTasks[i]),
                      onToggle: () => onToggleTask(visibleTasks[i]),
                    ),
                    if (i != visibleTasks.length - 1)
                      const Divider(height: 18, color: gdBorder),
                  ],
                ],
              ),
      ),
    );
  }
}

class _EmptyQuestState extends StatelessWidget {
  const _EmptyQuestState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: BoxDecoration(
        color: gdCardLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gdBorder),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: gdPrimarySoft,
            child: Icon(Icons.event_available_rounded, color: gdPrimary),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'No tasks are due today. Add a goal to give your companion a new quest.',
              style: TextStyle(color: gdInk, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestTile extends StatelessWidget {
  const _QuestTile({
    required this.task,
    required this.goal,
    required this.onToggle,
  });

  final MicroTask task;
  final GoalProject goal;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: task.done ? gdGradientFinanceTo : gdPrimarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                task.done ? Icons.check_rounded : task.load.icon,
                color: task.done ? Colors.white : gdPrimary,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: task.done ? gdMuted : gdInk,
                      fontWeight: FontWeight.w900,
                      decoration: task.done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${goal.title} - ${task.durationMinutes} min - ${task.load.label}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: gdMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text('+${task.points}'),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomizationCard extends StatelessWidget {
  const _CustomizationCard({
    required this.selectedSkin,
    required this.activeAccessory,
    required this.skinOptions,
    required this.gearOptions,
    required this.onSkinSelected,
    required this.onGearSelected,
  });

  final String selectedSkin;
  final String activeAccessory;
  final List<PetSkin> skinOptions;
  final List<_GearOption> gearOptions;
  final ValueChanged<PetSkin> onSkinSelected;
  final ValueChanged<String> onGearSelected;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: gdSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Skins',
              style: TextStyle(color: gdInk, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: skinOptions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final skin = skinOptions[index];
                  return _SkinSwatch(
                    skin: skin,
                    selected: selectedSkin == skin.name,
                    onTap: () => onSkinSelected(skin),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Gear and suits',
              style: TextStyle(color: gdInk, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth < 420
                    ? (constraints.maxWidth - 10) / 2
                    : (constraints.maxWidth - 20) / 3;

                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final option in gearOptions)
                      SizedBox(
                        width: itemWidth,
                        child: _GearTile(
                          option: option,
                          selected: activeAccessory == option.label,
                          onTap: () => onGearSelected(option.label),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SkinSwatch extends StatelessWidget {
  const _SkinSwatch({
    required this.skin,
    required this.selected,
    required this.onTap,
  });

  final PetSkin skin;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 116,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? gdInk : gdCardLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? gdInk : gdBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [skin.from, skin.to]),
                boxShadow: [
                  BoxShadow(
                    color: skin.to.withValues(alpha: 0.24),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                skin.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : gdInk,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GearTile extends StatelessWidget {
  const _GearTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _GearOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? gdPrimary : gdCardLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? gdPrimary : gdBorder),
        ),
        child: Row(
          children: [
            Icon(option.icon,
                color: selected ? Colors.white : gdPrimary, size: 22),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                option.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : gdInk,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChestCard extends StatelessWidget {
  const _ChestCard({
    required this.onOpenChest,
    required this.onFeed,
  });

  final VoidCallback onOpenChest;
  final VoidCallback onFeed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: gdSurface,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                CircleAvatar(
                  backgroundColor: gdPrimarySoft,
                  child: Icon(Icons.inventory_2_rounded, color: gdPrimary),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Open a chest for random skins, accessories, and suits.',
                    style: TextStyle(
                      color: gdInk,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onOpenChest,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Open chest -50'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onFeed,
                icon: const Icon(Icons.restaurant_rounded),
                label: const Text('Feed companion -10'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingWallet extends StatelessWidget {
  const _FloatingWallet({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: gdSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gdBorder),
        boxShadow: [
          BoxShadow(
            color: gdPrimary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration:
                const BoxDecoration(color: gdStarGold, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Text(
              'C',
              style: TextStyle(
                color: Color(0xFF5B3200),
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Wallet',
                style: TextStyle(
                  color: gdMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '$coins coins',
                style: const TextStyle(
                  color: gdInk,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GearOption {
  const _GearOption({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}
