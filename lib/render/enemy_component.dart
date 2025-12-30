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
         ..strokeWidth = 2,
       _slowPaint = Paint()
         ..color = const Color(0xFF6EC7FF).withValues(alpha: 0.7)
         ..style = PaintingStyle.stroke
         ..strokeWidth = 2,
       _rootPaint = Paint()
         ..color = const Color(0xFF3E7C3E).withValues(alpha: 0.8)
         ..style = PaintingStyle.stroke
         ..strokeWidth = 3,
       _auraFillPaint = _createAuraFillPaint(state.role),
       _auraStrokePaint = _createAuraStrokePaint(state.role),
       _zoneFillPaint = _createZoneFillPaint(state.role),
       _zoneStrokePaint = _createZoneStrokePaint(state.role) {
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
  final Paint _slowPaint;
  final Paint _rootPaint;
  final Paint? _auraFillPaint;
  final Paint? _auraStrokePaint;
  final Paint? _zoneFillPaint;
  final Paint? _zoneStrokePaint;
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
    _renderRoleAuras(canvas);
    _renderStatusRings(canvas);
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

  void _renderStatusRings(Canvas canvas) {
    if (_state.slowTimer > 0) {
      canvas.drawCircle(Offset.zero, _shapeRadius + 3, _slowPaint);
    }
    if (_state.rootTimer > 0) {
      canvas.drawCircle(Offset.zero, _shapeRadius + 6, _rootPaint);
    }
  }

  void _renderRoleAuras(Canvas canvas) {
    if (_role == EnemyRole.supportHealer || _role == EnemyRole.supportBuffer) {
      final auraRadius =
          _state.attackRange * (_role == EnemyRole.supportHealer ? 0.75 : 0.8);
      final fillPaint = _auraFillPaint;
      final strokePaint = _auraStrokePaint;
      if (auraRadius > 0 && fillPaint != null && strokePaint != null) {
        canvas.drawCircle(Offset.zero, auraRadius, fillPaint);
        canvas.drawCircle(Offset.zero, auraRadius, strokePaint);
      }
    }

    if (_role == EnemyRole.zoner) {
      final zoneRadius = _state.attackRange * 0.75;
      final fillPaint = _zoneFillPaint;
      final strokePaint = _zoneStrokePaint;
      if (zoneRadius > 0 && fillPaint != null && strokePaint != null) {
        canvas.drawCircle(Offset.zero, zoneRadius, fillPaint);
        canvas.drawCircle(Offset.zero, zoneRadius, strokePaint);
      }
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

  static Paint? _createAuraFillPaint(EnemyRole role) {
    if (role != EnemyRole.supportHealer && role != EnemyRole.supportBuffer) {
      return null;
    }
    return Paint()
      ..color = (_roleColors[role] ?? const Color(0xFF6ED9C0)).withValues(
        alpha: 0.12,
      )
      ..style = PaintingStyle.fill;
  }

  static Paint? _createAuraStrokePaint(EnemyRole role) {
    if (role != EnemyRole.supportHealer && role != EnemyRole.supportBuffer) {
      return null;
    }
    return Paint()
      ..color = (_roleColors[role] ?? const Color(0xFF6ED9C0)).withValues(
        alpha: 0.35,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
  }

  static Paint? _createZoneFillPaint(EnemyRole role) {
    if (role != EnemyRole.zoner) {
      return null;
    }
    return Paint()
      ..color = (_roleColors[role] ?? const Color(0xFFD95A6F)).withValues(
        alpha: 0.08,
      )
      ..style = PaintingStyle.fill;
  }

  static Paint? _createZoneStrokePaint(EnemyRole role) {
    if (role != EnemyRole.zoner) {
      return null;
    }
    return Paint()
      ..color = (_roleColors[role] ?? const Color(0xFFD95A6F)).withValues(
        alpha: 0.28,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
  }
}
