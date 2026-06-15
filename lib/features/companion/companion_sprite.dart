import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../models/models.dart';

/// The streak tier controls which sprite sheet is displayed.
enum CompanionStreakTier { low, mid, high }

extension CompanionStreakTierX on CompanionStreakTier {
  String get assetPrefix {
    switch (this) {
      case CompanionStreakTier.low:
        return 'low';
      case CompanionStreakTier.mid:
        return 'mid';
      case CompanionStreakTier.high:
        return 'high';
    }
  }
}

CompanionStreakTier companionStreakTierFor(int streak) {
  if (streak >= 14) return CompanionStreakTier.high;
  if (streak >= 7) return CompanionStreakTier.mid;
  return CompanionStreakTier.low;
}

enum _SpriteMood { idle, interacted }

const _idleAnimationDuration = Duration(milliseconds: 2200);
const _interactedAnimationDuration = Duration(milliseconds: 1400);
const _interactionHoldDuration = Duration(milliseconds: 1800);

class CompanionSprite extends StatefulWidget {
  const CompanionSprite({
    super.key,
    required this.kind,
    required this.tier,
    this.size = 178,
    this.onTap,
  });

  final CompanionKind kind;
  final CompanionStreakTier tier;
  final double size;
  final VoidCallback? onTap;

  @override
  State<CompanionSprite> createState() => _CompanionSpriteState();
}

class _CompanionSpriteState extends State<CompanionSprite> {
  _SpriteMood _mood = _SpriteMood.idle;
  Timer? _interactionTimer;

  String get _assetPath {
    final moodName = _mood == _SpriteMood.interacted ? 'interacted' : 'idle';
    return 'assets/${widget.kind.assetFolder}/${widget.tier.assetPrefix}_$moodName.png';
  }

  void _handleTap() {
    widget.onTap?.call();
    _interactionTimer?.cancel();
    setState(() => _mood = _SpriteMood.interacted);
    _interactionTimer = Timer(_interactionHoldDuration, () {
      if (!mounted) return;
      setState(() => _mood = _SpriteMood.idle);
    });
  }

  @override
  void dispose() {
    _interactionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${widget.kind.label} companion',
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _handleTap,
        child: SpriteSheetAnimation(
          assetPath: _assetPath,
          size: widget.size,
          duration: _mood == _SpriteMood.interacted
              ? _interactedAnimationDuration
              : _idleAnimationDuration,
        ),
      ),
    );
  }
}

class CompanionPortrait extends StatefulWidget {
  const CompanionPortrait({
    super.key,
    required this.kind,
    this.size = 64,
    this.silhouette = false,
  });

  final CompanionKind kind;
  final double size;
  final bool silhouette;

  @override
  State<CompanionPortrait> createState() => _CompanionPortraitState();
}

class _CompanionPortraitState extends State<CompanionPortrait> {
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;
  ui.Image? _image;

  String get _assetPath => 'assets/${widget.kind.assetFolder}/mid_idle.png';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant CompanionPortrait oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.kind != widget.kind) {
      _resolveImage();
    }
  }

  void _resolveImage() {
    final provider = AssetImage(_assetPath);
    final stream = provider.resolve(createLocalImageConfiguration(context));
    if (stream.key == _imageStream?.key) return;

    if (_imageStream != null && _imageStreamListener != null) {
      _imageStream!.removeListener(_imageStreamListener!);
    }
    _imageStream = stream;
    _image = null;

    _imageStreamListener = ImageStreamListener((info, _) {
      if (!mounted) return;
      setState(() => _image = info.image);
    });
    stream.addListener(_imageStreamListener!);
  }

  @override
  void dispose() {
    if (_imageStream != null && _imageStreamListener != null) {
      _imageStream!.removeListener(_imageStreamListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: _image == null
          ? const SizedBox.shrink()
          : CustomPaint(
              painter: _SpriteSheetPainter(
                image: _image!,
                frame: 0,
                frameSize: 320,
                silhouette: widget.silhouette,
              ),
              size: Size.square(widget.size),
            ),
    );
  }
}

class SpriteSheetAnimation extends StatefulWidget {
  const SpriteSheetAnimation({
    super.key,
    required this.assetPath,
    required this.size,
    this.frameCount = 8,
    this.frameSize = 320,
    this.duration = _idleAnimationDuration,
  });

  final String assetPath;
  final double size;
  final int frameCount;
  final double frameSize;
  final Duration duration;

  @override
  State<SpriteSheetAnimation> createState() => _SpriteSheetAnimationState();
}

class _SpriteSheetAnimationState extends State<SpriteSheetAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant SpriteSheetAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      _controller.repeat();
    }
    if (oldWidget.assetPath != widget.assetPath) {
      _resolveImage();
    }
  }

  void _resolveImage() {
    final provider = AssetImage(widget.assetPath);
    final stream = provider.resolve(createLocalImageConfiguration(context));
    if (stream.key == _imageStream?.key) return;

    _imageStream?.removeListener(_imageStreamListener!);
    _imageStream = stream;
    _image = null;

    _imageStreamListener = ImageStreamListener((info, _) {
      if (!mounted) return;
      setState(() => _image = info.image);
    });
    stream.addListener(_imageStreamListener!);
  }

  @override
  void dispose() {
    if (_imageStream != null && _imageStreamListener != null) {
      _imageStream!.removeListener(_imageStreamListener!);
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final image = _image;
          if (image == null) return const SizedBox.shrink();

          final frame = (_controller.value * widget.frameCount)
              .floor()
              .clamp(0, widget.frameCount - 1);
          return CustomPaint(
            painter: _SpriteSheetPainter(
              image: image,
              frame: frame,
              frameSize: widget.frameSize,
              silhouette: false,
            ),
            size: Size.square(widget.size),
          );
        },
      ),
    );
  }
}

class _SpriteSheetPainter extends CustomPainter {
  const _SpriteSheetPainter({
    required this.image,
    required this.frame,
    required this.frameSize,
    required this.silhouette,
  });

  final ui.Image image;
  final int frame;
  final double frameSize;
  final bool silhouette;

  @override
  void paint(Canvas canvas, Size size) {
    final source = Rect.fromLTWH(
      frame * frameSize,
      0,
      frameSize,
      frameSize,
    );
    final destination = Offset.zero & size;
    final paint = Paint()..filterQuality = FilterQuality.high;
    if (silhouette) {
      paint.colorFilter = const ColorFilter.mode(Colors.black, BlendMode.srcIn);
    }
    canvas.drawImageRect(
      image,
      source,
      destination,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpriteSheetPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.frame != frame ||
        oldDelegate.silhouette != silhouette;
  }
}
