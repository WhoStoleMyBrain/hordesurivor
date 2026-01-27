import 'dart:ui';

import 'package:flame/components.dart';

import 'render_scale.dart';

class LevelUpPulseComponent extends PositionComponent {
  LevelUpPulseComponent({required Image sprite, required this.onComplete})
    : _sprite = sprite {
    anchor = Anchor.center;
    scale = Vector2.all(RenderScale.worldScale);
    priority = 22;
    _syncSprite(sprite);
  }

  final void Function(LevelUpPulseComponent) onComplete;
  Image _sprite;
  Rect _sourceRect = Rect.zero;
  Rect _destRect = Rect.zero;
  final Paint _spritePaint = Paint();
  final Paint _ringPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.2;
  double _remaining = 0;
  double _duration = 0.65;
  double _startScale = 0.7;
  double _endScale = 1.35;
  double _startRingRadius = 10;
  double _endRingRadius = 28;
  double _rotation = 0;
  double _rotationSpeed = 1.4;
  bool _active = false;

  void reset({
    required Vector2 position,
    double duration = 0.65,
    double startScale = 0.7,
    double endScale = 1.35,
    double startRingRadius = 10,
    double endRingRadius = 28,
    double rotationSpeed = 1.4,
  }) {
    this.position.setFrom(position);
    _duration = duration;
    _remaining = duration;
    _startScale = startScale;
    _endScale = endScale;
    _startRingRadius = startRingRadius;
    _endRingRadius = endRingRadius;
    _rotationSpeed = rotationSpeed;
    _rotation = 0;
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
      return;
    }
    _rotation += _rotationSpeed * dt;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (!_active) {
      return;
    }
    final progress = (_duration - _remaining) / _duration;
    final alpha = (1 - progress).clamp(0.0, 1.0);
    final scaleFactor = _startScale + (_endScale - _startScale) * progress;
    final ringRadius =
        _startRingRadius + (_endRingRadius - _startRingRadius) * progress;
    _spritePaint.color = const Color(0xFFFFFFFF).withValues(alpha: alpha);
    _ringPaint.color = const Color(0xFFE9D8A6).withValues(alpha: alpha);
    canvas.save();
    canvas.rotate(_rotation);
    canvas.scale(scaleFactor);
    canvas.drawImageRect(_sprite, _sourceRect, _destRect, _spritePaint);
    canvas.restore();
    canvas.drawCircle(Offset.zero, ringRadius, _ringPaint);
  }

  void _syncSprite(Image sprite) {
    _sprite = sprite;
    _sourceRect = Rect.fromLTWH(
      0,
      0,
      sprite.width.toDouble(),
      sprite.height.toDouble(),
    );
    _destRect = Rect.fromCenter(
      center: Offset.zero,
      width: sprite.width.toDouble(),
      height: sprite.height.toDouble(),
    );
  }
}
