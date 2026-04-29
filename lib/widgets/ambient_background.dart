import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AmbientBackground extends StatefulWidget {
  const AmbientBackground({super.key});

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final v = _controller.value;
        return Stack(
          children: [
            Positioned(
              left: -60 + (24 * v),
              top: 20 - (18 * v),
              child: Container(
                width: 240 + (20 * v),
                height: 240 + (20 * v),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.warmGlow.withValues(alpha: 0.35),
                ),
              ),
            ),
            Positioned(
              right: -40 + (20 * v),
              top: 60 - (14 * v),
              child: Container(
                width: 320 + (26 * v),
                height: 320 + (26 * v),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.coolGlow.withValues(alpha: 0.35),
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.3,
              bottom: -40 + (16 * v),
              child: Container(
                width: 260 + (22 * v),
                height: 260 + (22 * v),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.purpleGlow.withValues(alpha: 0.28),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
