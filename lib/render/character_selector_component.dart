import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';

import 'render_scale.dart';

class CharacterSelectorComponent extends PositionComponent {
  CharacterSelectorComponent({
    required this.radius,
    required this.label,
    double renderScale = RenderScale.worldScale,
  }) : super(anchor: Anchor.center) {
    scale = Vector2.all(renderScale);
  }

  final double radius;
  final String label;
  bool visible = true;
  final Paint _fillPaint = Paint()..color = const Color(0xFFBFA77A);
  final Paint _ringPaint = Paint()
    ..color = const Color(0xFFE9D7A8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final Paint _runePaint = Paint()..color = const Color(0xFF4C3924);
  final TextPaint _textPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFFE9D7A8),
      fontSize: 9,
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
    canvas.drawLine(
      Offset(-radius * 0.35, 0),
      Offset(radius * 0.35, 0),
      _runePaint,
    );
    canvas.drawLine(
      Offset(0, -radius * 0.35),
      Offset(0, radius * 0.35),
      _runePaint,
    );
    _textPaint.render(canvas, label, Vector2(-label.length * 2.1, radius + 6));
  }
}
