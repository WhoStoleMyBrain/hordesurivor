import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../game/summon_state.dart';
import 'render_scale.dart';

class SummonComponent extends PositionComponent {
  SummonComponent({required SummonState state})
    : _state = state,
      _baseColor = _colorForKind(state.kind),
      _paint = Paint()..color = _colorForKind(state.kind),
      _accentPaint = Paint()..color = _colorForKind(state.kind) {
    anchor = Anchor.center;
    scale = Vector2.all(RenderScale.worldScale);
  }

  final SummonState _state;
  final Color _baseColor;
  final Paint _paint;
  final Paint _accentPaint;

  @override
  void update(double dt) {
    position.setFrom(_state.position);
    size.setValues(_state.radius * 2, _state.radius * 2);
    angle = _state.kind == SummonKind.scrapRover ? _state.orbitAngle : 0;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    switch (_state.kind) {
      case SummonKind.scrapRover:
        _renderDiamond(canvas);
      case SummonKind.arcTurret:
        _renderTurret(canvas);
      case SummonKind.guardianOrb:
        canvas.drawCircle(Offset.zero, _state.radius, _paint);
      case SummonKind.menderOrb:
        _renderMender(canvas);
      case SummonKind.mine:
        _renderMine(canvas);
    }
  }

  void _renderDiamond(Canvas canvas) {
    final half = _state.radius;
    final path = Path()
      ..moveTo(0, -half)
      ..lineTo(half, 0)
      ..lineTo(0, half)
      ..lineTo(-half, 0)
      ..close();
    canvas.drawPath(path, _paint);
  }

  void _renderTurret(Canvas canvas) {
    final baseRadius = _state.radius;
    canvas.drawCircle(Offset.zero, baseRadius, _paint);
    final barrelLength = baseRadius * 1.3;
    _accentPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, baseRadius * 0.25);
    canvas.drawLine(Offset.zero, Offset(barrelLength, 0), _accentPaint);
  }

  void _renderMender(Canvas canvas) {
    final inner = _state.radius * 0.6;
    canvas.drawCircle(Offset.zero, _state.radius, _paint);
    _accentPaint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset.zero,
      inner,
      _accentPaint..color = _baseColor.withValues(alpha: 0.85),
    );
  }

  void _renderMine(Canvas canvas) {
    final base = _state.radius;
    canvas.drawCircle(Offset.zero, base, _paint);
    _accentPaint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset.zero,
      base * 0.35,
      _accentPaint..color = _baseColor.withValues(alpha: 0.7),
    );
  }

  static Color _colorForKind(SummonKind kind) {
    switch (kind) {
      case SummonKind.scrapRover:
        return const Color(0xFFB0BEC5);
      case SummonKind.arcTurret:
        return const Color(0xFF8FA3FF);
      case SummonKind.guardianOrb:
        return const Color(0xFFF6C945).withValues(alpha: 0.85);
      case SummonKind.menderOrb:
        return const Color(0xFF6FBF73).withValues(alpha: 0.8);
      case SummonKind.mine:
        return const Color(0xFFFF6B6B).withValues(alpha: 0.9);
    }
  }
}
