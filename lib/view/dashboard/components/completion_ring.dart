import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dashboard_theme.dart';

/// Anel de conclusão: arco com gradiente pink -> purple e a % geral no centro.
class CompletionRing extends StatelessWidget {
  final double percent; // 0..100
  final double size;
  final double strokeWidth;

  const CompletionRing({
    super.key,
    required this.percent,
    this.size = 180,
    this.strokeWidth = 18,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CustomPaint(
        painter: _RingPainter(
          fraction: (percent / 100).clamp(0.0, 1.0),
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatPercent(percent),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 34,
                ),
              ),
              Text(
                'dash_ring_complete'.tr,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  /// 0..1 — já validado pelo widget.
  final double fraction;
  final double strokeWidth;

  const _RingPainter({required this.fraction, required this.strokeWidth});

  static const _startAngle = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final circle = rect.deflate(strokeWidth / 2);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(.08);
    canvas.drawArc(circle, _startAngle, 2 * math.pi, false, track);

    if (fraction <= 0) return;

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: dashboardGradientColors,
        transform: GradientRotation(_startAngle),
      ).createShader(rect);
    canvas.drawArc(circle, _startAngle, 2 * math.pi * fraction, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.strokeWidth != strokeWidth;
}
