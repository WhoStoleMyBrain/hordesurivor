import 'dart:ui';

import 'package:flame/components.dart';

import 'render_scale.dart';

class PickupSparkComponent extends PositionComponent {
  PickupSparkComponent({required this.onComplete}) {
    anchor = Anchor.center;
    scale = Vector2.all(RenderScale.worldScale);
    priority = 16;
  }

  final void Function(PickupSparkComponent) onComplete;
  final Paint _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4;
  double _remaining = 0;
  double _duration = 0.3;
  double _startRadius = 6;
  double _endRadius = 14;
  bool _active = false;

  void reset({
    required Vector2 position,
    double duration = 0.3,
    double startRadius = 6,
    double endRadius = 14,
  }) {
    this.position.setFrom(position);
    _duration = duration;
    _remaining = duration;
    _startRadius = startRadius;
    _endRadius = endRadius;
    _active = true;
  }

  @override
  void update(double dt) {
    if (!_active) {
      return;
    }
    _remaining -= dt;
    if (_remaining <= 0) {
      _active = false;
      onComplete(this);
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (!_active) {
      return;
    }
    final progress = (_duration - _remaining) / _duration;
    final radius = _startRadius + (_endRadius - _startRadius) * progress;
    final alpha = (1 - progress).clamp(0.0, 1.0);
    _paint.color = const Color(0xFFE9D8A6).withValues(alpha: alpha);
    canvas.drawCircle(Offset.zero, radius, _paint);
  }
}
