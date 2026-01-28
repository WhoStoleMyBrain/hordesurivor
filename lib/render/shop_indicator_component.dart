import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

class ShopIndicatorComponent extends PositionComponent {
  ShopIndicatorComponent({required Image iconImage})
    : _icon = Sprite(iconImage),
      super(anchor: Anchor.center);

  bool visible = true;
  static const double _iconSize = 18;
  static const double _arrowLength = 10;
  static const double _arrowWidth = 8;
  double _angle = 0;

  final Sprite _icon;
  final Paint _ringPaint = Paint()
    ..color = const Color(0xFFF2D38A)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;
  final Paint _fillPaint = Paint()..color = const Color(0xFF1C140E);
  final Paint _arrowPaint = Paint()..color = const Color(0xFFF2D38A);

  void setDirection(Vector2 direction) {
    _angle = math.atan2(direction.y, direction.x);
  }

  @override
  void render(Canvas canvas) {
    if (!visible) {
      return;
    }
    super.render(canvas);
    final radius = _iconSize / 2 + 2;
    canvas.drawCircle(Offset.zero, radius, _fillPaint);
    canvas.drawCircle(Offset.zero, radius, _ringPaint);
    _icon.render(
      canvas,
      position: Vector2(-_iconSize / 2, -_iconSize / 2),
      size: Vector2.all(_iconSize),
    );
    canvas.save();
    canvas.rotate(_angle);
    final start = radius + 2;
    final path = Path()
      ..moveTo(start + _arrowLength, 0)
      ..lineTo(start, -_arrowWidth / 2)
      ..lineTo(start, _arrowWidth / 2)
      ..close();
    canvas.drawPath(path, _arrowPaint);
    canvas.restore();
  }
}
