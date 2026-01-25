import 'package:flutter/material.dart';

import 'hud_state.dart';

class ExperienceBarOverlay extends StatelessWidget {
  const ExperienceBarOverlay({super.key, required this.hudState});

  static const String overlayKey = 'experienceBar';

  final PlayerHudState hudState;

  static const int _segmentCount = 10;
  static const double _barHeight = 14;
  static const double _maxBarWidth = 520;
  static const Color _fillColor = Color(0xFFFFF1D6);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final targetWidth = constraints.maxWidth * 0.82;
              final barWidth = targetWidth.clamp(160, _maxBarWidth).toDouble();
              return AnimatedBuilder(
                animation: hudState,
                builder: (context, _) {
                  final progress = _xpProgress();
                  return SizedBox(
                    width: barWidth,
                    height: _barHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: _fillColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _fillColor.withValues(alpha: 0.6),
                                      blurRadius: 6,
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _SegmentPainter(
                                segmentCount: _segmentCount,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  double _xpProgress() {
    if (hudState.xpToNext <= 0) {
      return 0;
    }
    return (hudState.xp / hudState.xpToNext).clamp(0.0, 1.0);
  }
}

class _SegmentPainter extends CustomPainter {
  const _SegmentPainter({required this.segmentCount});

  final int segmentCount;

  @override
  void paint(Canvas canvas, Size size) {
    if (segmentCount <= 1) {
      return;
    }
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    final segmentWidth = size.width / segmentCount;
    for (var i = 1; i < segmentCount; i++) {
      final x = segmentWidth * i;
      canvas.drawLine(Offset(x, 1), Offset(x, size.height - 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SegmentPainter oldDelegate) =>
      oldDelegate.segmentCount != segmentCount;
}
