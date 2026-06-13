import 'package:flutter/material.dart';

enum LumiStreakTier { low, mid, high }

enum LumiAnimationState { idle, interacted }

class LumiCompanionSprite extends StatefulWidget {
  const LumiCompanionSprite({
    super.key,
    required this.streak,
    this.size = 180,
    this.onTap,
    this.idleFrameDuration = const Duration(milliseconds: 320),
    this.interactedFrameDuration = const Duration(milliseconds: 180),
  });

  final int streak;
  final double size;
  final VoidCallback? onTap;
  final Duration idleFrameDuration;
  final Duration interactedFrameDuration;

  static const int frameCount = 8;

  @override
  State<LumiCompanionSprite> createState() => _LumiCompanionSpriteState();
}

class _LumiCompanionSpriteState extends State<LumiCompanionSprite>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  LumiAnimationState _state = LumiAnimationState.idle;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          _state == LumiAnimationState.interacted) {
        _playIdle();
      }
    });

    _playIdle(rebuild: false);
  }

  @override
  void didUpdateWidget(covariant LumiCompanionSprite oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.streak != widget.streak &&
        _state == LumiAnimationState.idle) {
      _playIdle();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LumiStreakTier _tierForStreak(int streak) {
    if (streak >= 7) return LumiStreakTier.high;
    if (streak >= 3) return LumiStreakTier.mid;
    return LumiStreakTier.low;
  }

  String _assetPath(LumiStreakTier tier, LumiAnimationState state) {
    return 'assets/lumi/${tier.name}_${state.name}.png';
  }

  void _playIdle({bool rebuild = true}) {
    _controller.stop();

    if (rebuild && mounted) {
      setState(() => _state = LumiAnimationState.idle);
    } else {
      _state = LumiAnimationState.idle;
    }

    _controller.duration =
        widget.idleFrameDuration * LumiCompanionSprite.frameCount;

    _controller.repeat();
  }

  void _playInteraction() {
    widget.onTap?.call();

    _controller.stop();

    setState(() => _state = LumiAnimationState.interacted);

    _controller.duration =
        widget.interactedFrameDuration * LumiCompanionSprite.frameCount;

    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final tier = _tierForStreak(widget.streak);
    final asset = _assetPath(tier, _state);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _playInteraction,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final frame = (_controller.value * LumiCompanionSprite.frameCount)
                .floor()
                .clamp(0, LumiCompanionSprite.frameCount - 1)
                .toInt();

            return ClipRect(
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: OverflowBox(
                  alignment: Alignment.centerLeft,
                  minWidth: widget.size * LumiCompanionSprite.frameCount,
                  maxWidth: widget.size * LumiCompanionSprite.frameCount,
                  minHeight: widget.size,
                  maxHeight: widget.size,
                  child: Transform.translate(
                    offset: Offset(-frame * widget.size, 0),
                    child: Image.asset(
                      asset,
                      width: widget.size * LumiCompanionSprite.frameCount,
                      height: widget.size,
                      fit: BoxFit.fill,
                      gaplessPlayback: true,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}