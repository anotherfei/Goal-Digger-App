import 'package:flutter/material.dart';

class PetWidget extends StatelessWidget {
  final double size;
  final Color from;
  final Color to;
  final Color accent;
  final bool animate;

  const PetWidget({super.key, this.size = 80, required this.from, required this.to, required this.accent, this.animate = true});

  @override
  Widget build(BuildContext context) {
    final body = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [from, to]);
    final w = size;
    final h = size;

    final widget = SizedBox(
      width: w, height: h,
      child: CustomPaint(painter: _PetPainter(body: body, accent: accent)),
    );

    if (!animate) return widget;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 3400),
      builder: (_, v, child) => Transform.translate(offset: Offset(0, -6 * (0.5 - (v - 0.5).abs())), child: child),
      child: widget,
    );
  }
}

class _PetPainter extends CustomPainter {
  final LinearGradient body;
  final Color accent;
  _PetPainter({required this.body, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bodyPaint = Paint()..shader = body.createShader(Rect.fromLTWH(0, 0, w, h));
    final dark = Paint()..color = const Color(0xFF0F172A);
    final accentPaint = Paint()..color = accent;
    final blush = Paint()..color = const Color(0xFFFB7185).withValues(alpha: 0.45);

    // Ears
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.28, h * 0.22), width: w * 0.2, height: h * 0.28), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.72, h * 0.22), width: w * 0.2, height: h * 0.28), bodyPaint);

    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.58), width: w * 0.67, height: h * 0.63), bodyPaint);

    // Belly
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.68), width: w * 0.4, height: h * 0.33), accentPaint);

    // Cheeks
    canvas.drawCircle(Offset(w * 0.3, h * 0.6), w * 0.04, blush);
    canvas.drawCircle(Offset(w * 0.7, h * 0.6), w * 0.04, blush);

    // Eyes
    canvas.drawCircle(Offset(w * 0.38, h * 0.5), w * 0.035, dark);
    canvas.drawCircle(Offset(w * 0.68, h * 0.5), w * 0.035, dark);
    final white = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.39, h * 0.49), w * 0.012, white);
    canvas.drawCircle(Offset(w * 0.69, h * 0.49), w * 0.012, white);

    // Mouth
    final mouth = Path()
      ..moveTo(w * 0.43, h * 0.62)
      ..quadraticBezierTo(w * 0.5, h * 0.67, w * 0.57, h * 0.62);
    canvas.drawPath(mouth, dark..style = PaintingStyle.stroke..strokeWidth = w * 0.02..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
