import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:hordesurivor/data/tags.dart';

import '../game/enemy_state.dart';

class EnemyComponent extends PositionComponent {
  EnemyComponent({
    required EnemyState state,
    required double radius,
    Color color = const Color(0xFFE07064),
    Image? spriteImage,
  }) : _state = state,
       _radius = radius,
       _spriteImage = spriteImage,
       _role = state.role,
       _paint = Paint()..color = _roleColors[state.role] ?? color,
       _outlinePaint = Paint()
         ..color = (_roleColors[state.role] ?? color).withValues(alpha: 0.9)
         ..style = PaintingStyle.stroke
         ..strokeWidth = 2,
       _telegraphPaint = Paint()
         ..color = (_roleColors[state.role] ?? color).withValues(alpha: 0.5)
         ..style = PaintingStyle.stroke
         ..strokeWidth = 2 {
    anchor = Anchor.center;
    if (spriteImage != null) {
      size = Vector2(
        spriteImage.width.toDouble(),
        spriteImage.height.toDouble(),
      );
    } else {
      size = Vector2.all(radius * 2);
    }
    final shapeRadius = size.x > 0 ? size.x / 2 : radius;
    _shapeRadius = math.max(radius, shapeRadius);
    _squareRect = Rect.fromCenter(
      center: Offset.zero,
      width: _shapeRadius * 2,
      height: _shapeRadius * 2,
    );
    _diamondPath = Path()
      ..moveTo(0, -_shapeRadius)
      ..lineTo(_shapeRadius, 0)
      ..lineTo(0, _shapeRadius)
      ..lineTo(-_shapeRadius, 0)
      ..close();
    _telegraphRect = Rect.fromCircle(
      center: Offset.zero,
      radius: _shapeRadius + 6,
    );
  }

  final EnemyState _state;
  final double _radius;
  final Image? _spriteImage;
  final EnemyRole _role;
  final Paint _paint;
  final Paint _outlinePaint;
  final Paint _telegraphPaint;
  late final double _shapeRadius;
  late final Rect _squareRect;
  late final Path _diamondPath;
  late final Rect _telegraphRect;

  @override
  void update(double dt) {
    position.setFrom(_state.position);
    if (_spriteImage == null) {
      size.setValues(_radius * 2, _radius * 2);
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (_role == EnemyRole.ranged ||
        _role == EnemyRole.spawner ||
        _role == EnemyRole.disruptor ||
        _role == EnemyRole.zoner ||
        _role == EnemyRole.exploder ||
        _role == EnemyRole.supportHealer ||
        _role == EnemyRole.supportBuffer ||
        _role == EnemyRole.pattern ||
        _role == EnemyRole.elite) {
      final progress = _telegraphProgress();
      if (progress > 0) {
        canvas.drawArc(
          _telegraphRect,
          -math.pi / 2,
          math.pi * 2 * progress,
          false,
          _telegraphPaint,
        );
      }
    }
    if (_spriteImage != null) {
      final destRect = Rect.fromCenter(
        center: Offset.zero,
        width: size.x,
        height: size.y,
      );
      final srcRect = Rect.fromLTWH(
        0,
        0,
        _spriteImage.width.toDouble(),
        _spriteImage.height.toDouble(),
      );
      canvas.drawImageRect(_spriteImage, srcRect, destRect, _paint);
      return;
    }

    switch (_role) {
      case EnemyRole.ranged:
        canvas.drawPath(_diamondPath, _paint);
        canvas.drawPath(_diamondPath, _outlinePaint);
        break;
      case EnemyRole.spawner:
        canvas.drawRect(_squareRect, _paint);
        canvas.drawRect(_squareRect, _outlinePaint);
        break;
      default:
        canvas.drawCircle(Offset.zero, _shapeRadius, _paint);
    }
  }

  double _telegraphProgress() {
    switch (_role) {
      case EnemyRole.ranged:
        if (_state.attackCooldown <= 0) {
          return 0;
        }
        return (1 - (_state.attackTimer / _state.attackCooldown)).clamp(
          0.0,
          1.0,
        );
      case EnemyRole.spawner:
        if (_state.spawnCooldown <= 0) {
          return 0;
        }
        return (1 - (_state.spawnTimer / _state.spawnCooldown)).clamp(0.0, 1.0);
      case EnemyRole.disruptor:
      case EnemyRole.zoner:
      case EnemyRole.exploder:
      case EnemyRole.supportHealer:
      case EnemyRole.supportBuffer:
      case EnemyRole.pattern:
      case EnemyRole.elite:
        if (_state.specialCooldown <= 0) {
          return 0;
        }
        return (1 - (_state.specialTimer / _state.specialCooldown)).clamp(
          0.0,
          1.0,
        );
      default:
        return 0;
    }
  }

  static const Map<EnemyRole, Color> _roleColors = {
    EnemyRole.chaser: Color(0xFFE07064),
    EnemyRole.ranged: Color(0xFF7C6EE6),
    EnemyRole.spawner: Color(0xFFE6A04B),
    EnemyRole.disruptor: Color(0xFFB96DD7),
    EnemyRole.zoner: Color(0xFFD95A6F),
    EnemyRole.elite: Color(0xFFFFA136),
    EnemyRole.exploder: Color(0xFFE35B4F),
    EnemyRole.supportHealer: Color(0xFF6ED9C0),
    EnemyRole.supportBuffer: Color(0xFF5BB7E3),
    EnemyRole.pattern: Color(0xFF80C86A),
  };
}
