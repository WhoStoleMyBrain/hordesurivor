import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../game/effect_state.dart';
import 'render_scale.dart';

class EffectComponent extends PositionComponent {
  EffectComponent({
    required EffectState state,
    double renderScale = RenderScale.worldScale,
  }) : _state = state,
       _paint = Paint()..color = _colorForKind(state.kind),
       _strokePaint = Paint()
         ..color = _colorForKind(state.kind).withValues(alpha: 0.85)
         ..style = PaintingStyle.stroke
         ..strokeWidth = 2 {
    anchor = Anchor.center;
    scale = Vector2.all(renderScale);
    priority = _priorityForShape(state.shape);
  }

  final EffectState _state;
  final Paint _paint;
  final Paint _strokePaint;

  @override
  void update(double dt) {
    if (_state.shape == EffectShape.beam) {
      anchor = Anchor.centerLeft;
      position.setFrom(_state.position);
      size.setValues(_state.length, _state.width);
      angle = math.atan2(_state.direction.y, _state.direction.x);
    } else if (_state.shape == EffectShape.ground &&
        _state.kind == EffectKind.poisonAura) {
      // Poison aura effect follows the player position.
      anchor = Anchor.topLeft;
      position.setFrom(_state.position);
      size.setValues(_state.radius * 2, _state.radius * 2);
      angle = 0;
    } else {
      anchor = Anchor.center;
      position.setFrom(_state.position);
      size.setValues(_state.radius * 2, _state.radius * 2);
      angle = 0;
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    switch (_state.shape) {
      case EffectShape.ground:
        canvas.drawCircle(Offset.zero, _state.radius, _paint);
      case EffectShape.beam:
        final rect = Rect.fromLTWH(0, -size.y * 0.5, size.x, size.y);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          _paint,
        );
      case EffectShape.arc:
        final sweep = _state.arcDegrees * (math.pi / 180);
        final startAngle =
            math.atan2(_state.direction.y, _state.direction.x) - sweep * 0.5;
        final rect = Rect.fromCircle(
          center: Offset.zero,
          radius: _state.radius,
        );
        final path = Path()
          ..moveTo(0, 0)
          ..arcTo(rect, startAngle, sweep, false)
          ..close();
        canvas.drawPath(path, _paint);
        canvas.drawPath(path, _strokePaint);
    }
  }

  static Color _colorForKind(EffectKind kind) {
    switch (kind) {
      case EffectKind.waterjetBeam:
        return const Color(0xFF6EC7FF).withValues(alpha: 0.7);
      case EffectKind.oilGround:
        return const Color(0xFF2B2D42).withValues(alpha: 0.5);
      case EffectKind.rootsGround:
        return const Color(0xFF3E7C3E).withValues(alpha: 0.45);
      case EffectKind.poisonAura:
        return const Color(0xFF6ABF69).withValues(alpha: 0.4);
      case EffectKind.flameWave:
        return const Color(0xFFFF9E3D).withValues(alpha: 0.65);
      case EffectKind.frostNova:
        return const Color(0xFF7CD9FF).withValues(alpha: 0.45);
      case EffectKind.earthSpikes:
        return const Color(0xFF7B5E3B).withValues(alpha: 0.5);
      case EffectKind.sporeCloud:
        return const Color(0xFF5F9E4A).withValues(alpha: 0.45);
      case EffectKind.swordSlash:
        return const Color(0xFFE5E8F2).withValues(alpha: 0.55);
    }
  }

  static int _priorityForShape(EffectShape shape) {
    switch (shape) {
      case EffectShape.ground:
        return -2;
      case EffectShape.beam:
        return 1;
      case EffectShape.arc:
        return 2;
    }
  }
}
