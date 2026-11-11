import 'dart:math' as math;
import 'package:flutter/material.dart';

class RingPainter extends CustomPainter {
  final double progress;
  final Color color, trackColor;
  final double strokeWidth;
  final bool showDot;

  RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    this.strokeWidth = 14,
    this.showDot = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth);
    if (progress > 0) {
      final arcPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      final sweep = 2 * math.pi * progress;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, sweep, false, arcPaint);
      if (showDot) {
        final a = -math.pi / 2 + sweep;
        canvas.drawCircle(Offset(center.dx + radius * math.cos(a), center.dy + radius * math.sin(a)),
            strokeWidth * 0.8, Paint()..color = color);
      }
    }
  }

  @override
  bool shouldRepaint(RingPainter old) => old.progress != progress || old.color != color;
}
