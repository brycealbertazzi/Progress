import 'package:flutter/material.dart';

class BodyweightBadge extends StatelessWidget {
  const BodyweightBadge({super.key, this.size = 18, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white.withValues(alpha: 0.6);
    return Icon(Icons.accessibility_new, size: size, color: c);
  }
}
