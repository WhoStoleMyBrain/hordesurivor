import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'ui_scale.dart';
import 'virtual_stick_state.dart';

class VirtualStickOverlay extends StatelessWidget {
  const VirtualStickOverlay({super.key, required this.state});

  static const String overlayKey = 'virtual_stick';

  final ValueListenable<VirtualStickState> state;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ValueListenableBuilder<VirtualStickState>(
        valueListenable: state,
        builder: (context, value, _) {
          if (!value.active) {
            return const SizedBox.shrink();
          }
          final baseRadius = value.maxRadius;
          final deadZoneRadius = math.min(baseRadius, value.deadZone);
          final knobRadius = math.max(UiScale.fontSize(14), baseRadius * 0.35);
          return SizedBox.expand(
            child: CustomPaint(
              painter: _VirtualStickPainter(
                state: value,
                baseRadius: baseRadius,
                deadZoneRadius: deadZoneRadius,
                knobRadius: knobRadius,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VirtualStickPainter extends CustomPainter {
  _VirtualStickPainter({
    required this.state,
    required this.baseRadius,
    required this.deadZoneRadius,
    required this.knobRadius,
  });

  final VirtualStickState state;
  final double baseRadius;
  final double deadZoneRadius;
  final double knobRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = state.origin;
    final clamped = state.clampedDelta;
    final knobCenter = Offset(origin.dx + clamped.dx, origin.dy + clamped.dy);
    final basePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final deadZonePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final knobPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    final knobOutlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(origin, baseRadius, basePaint);
    if (deadZoneRadius > 0) {
      canvas.drawCircle(origin, deadZoneRadius, deadZonePaint);
    }
    canvas.drawCircle(knobCenter, knobRadius, knobPaint);
    canvas.drawCircle(knobCenter, knobRadius, knobOutlinePaint);
  }

  @override
  bool shouldRepaint(covariant _VirtualStickPainter oldDelegate) {
    return oldDelegate.state.active != state.active ||
        oldDelegate.state.origin != state.origin ||
        oldDelegate.state.delta != state.delta ||
        oldDelegate.baseRadius != baseRadius ||
        oldDelegate.deadZoneRadius != deadZoneRadius ||
        oldDelegate.knobRadius != knobRadius;
  }
}
