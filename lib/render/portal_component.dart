import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';

class PortalComponent extends PositionComponent {
  PortalComponent({required this.radius, required this.label})
    : super(anchor: Anchor.center);

  final double radius;
  final String label;
  bool visible = true;
  final Paint _fillPaint = Paint()..color = const Color(0xFF7DD3FC);
  final Paint _ringPaint = Paint()
    ..color = const Color(0xFF0EA5E9)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final TextPaint _textPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFF0EA5E9),
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
    ),
  );

  @override
  void render(Canvas canvas) {
    if (!visible) {
      return;
    }
    super.render(canvas);
    canvas.drawCircle(Offset.zero, radius, _fillPaint);
    canvas.drawCircle(Offset.zero, radius + 4, _ringPaint);
    _textPaint.render(canvas, label, Vector2(-label.length * 2.4, radius + 6));
  }
}
