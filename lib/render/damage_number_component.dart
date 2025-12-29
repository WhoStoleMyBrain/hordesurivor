import 'package:flame/components.dart';
import 'package:flame/text.dart';

class DamageNumberComponent extends PositionComponent {
  static final Vector2 _zero = Vector2.zero();

  DamageNumberComponent({
    required TextPaint textPaint,
    required this.onComplete,
  }) : _textPaint = textPaint {
    anchor = Anchor.center;
    priority = 20;
  }

  final void Function(DamageNumberComponent) onComplete;
  final Vector2 _velocity = Vector2.zero();
  TextPaint _textPaint;
  String _text = '';
  double _remaining = 0;
  bool _active = false;

  void reset({
    required Vector2 position,
    required double amount,
    required TextPaint textPaint,
    required Vector2 velocity,
    double lifespan = 0.7,
  }) {
    this.position.setFrom(position);
    _velocity.setFrom(velocity);
    _textPaint = textPaint;
    _text = amount.toStringAsFixed(0);
    _remaining = lifespan;
    _active = true;
  }

  @override
  void update(double dt) {
    if (!_active) {
      return;
    }
    _remaining -= dt;
    position.x += _velocity.x * dt;
    position.y += _velocity.y * dt;
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
    _textPaint.render(canvas, _text, _zero, anchor: Anchor.center);
  }
}
