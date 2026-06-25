import 'package:flutter/material.dart';

class BodyweightBadge extends StatelessWidget {
  const BodyweightBadge({super.key, this.size = 18, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white.withValues(alpha: 0.6);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.fitness_center, size: size * 0.72, color: c),
          CustomPaint(
            size: Size(size, size),
            painter: _SlashCirclePainter(color: c, strokeWidth: size * 0.09),
          ),
        ],
      ),
    );
  }
}

class _SlashCirclePainter extends CustomPainter {
  const _SlashCirclePainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.46;

    canvas.drawCircle(center, radius, paint);

    // Standard "no" slash — top-left to bottom-right
    canvas.drawLine(
      Offset(center.dx - radius * 0.68, center.dy - radius * 0.68),
      Offset(center.dx + radius * 0.68, center.dy + radius * 0.68),
      paint,
    );
  }

  @override
  bool shouldRepaint(_SlashCirclePainter old) => false;
}
