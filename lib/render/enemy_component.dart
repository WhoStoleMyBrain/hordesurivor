import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:hordesurivor/data/enemy_variants.dart';
import 'package:hordesurivor/data/tags.dart';

import '../game/enemy_state.dart';
import 'render_scale.dart';

class EnemyComponent extends PositionComponent {
  EnemyComponent({
    required EnemyState state,
    required double radius,
    Color color = const Color(0xFFE07064),
    Image? spriteImage,
    double telegraphOpacityMultiplier = 1.0,
    double renderScale = RenderScale.worldScale,
  }) : _state = state,
       _radius = radius,
       _spriteImage = spriteImage,
       _role = state.role,
       _variant = state.variant,
       _telegraphTintColor = _resolveVariantColor(
         _roleColors[state.role] ?? color,
         state.variant,
       ),
       _paint = Paint()
         ..color = _resolveVariantColor(
           _roleColors[state.role] ?? color,
           state.variant,
         ),
       _outlinePaint = Paint()
         ..color = _resolveVariantColor(
           (_roleColors[state.role] ?? color).withValues(alpha: 0.9),
           state.variant,
         )
         ..style = PaintingStyle.stroke
         ..strokeWidth = 2,
       _badgePaint = Paint()
         ..color = _resolveVariantColor(
           (_roleColors[state.role] ?? color).withValues(alpha: 0.9),
           state.variant,
         )
         ..style = PaintingStyle.stroke
         ..strokeWidth = 2
         ..strokeCap = StrokeCap.round
         ..strokeJoin = StrokeJoin.round,
       _telegraphPaint = Paint()
         ..style = PaintingStyle.stroke
         ..strokeWidth = 2,
       _slowPaint = Paint()
         ..color = const Color(0xFF6EC7FF).withValues(alpha: 0.7)
         ..style = PaintingStyle.stroke
         ..strokeWidth = 2,
       _oilPaint = Paint()
         ..color = const Color(0xFF2B2D42).withValues(alpha: 0.75)
         ..style = PaintingStyle.stroke
         ..strokeWidth = 2,
       _rootPaint = Paint()
         ..color = const Color(0xFF3E7C3E).withValues(alpha: 0.8)
         ..style = PaintingStyle.stroke
         ..strokeWidth = 3,
       _ignitePaint = Paint()
         ..color = const Color(0xFFFF8C3B).withValues(alpha: 0.85)
         ..style = PaintingStyle.stroke
         ..strokeWidth = 2,
       _auraFillPaint = _createAuraFillPaint(state.role),
       _auraStrokePaint = _createAuraStrokePaint(state.role),
       _zoneFillPaint = _createZoneFillPaint(state.role),
       _zoneStrokePaint = _createZoneStrokePaint(state.role),
       _variantRingPaint = _createVariantRingPaint(state.variant) {
    anchor = Anchor.center;
    scale = Vector2.all(renderScale);
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
    applyTelegraphOpacity(telegraphOpacityMultiplier);
  }

  final EnemyState _state;
  final double _radius;
  final Image? _spriteImage;
  final EnemyRole _role;
  final EnemyVariant _variant;
  final Color _telegraphTintColor;
  final Paint _paint;
  final Paint _outlinePaint;
  final Paint _badgePaint;
  final Paint _telegraphPaint;
  final Paint _slowPaint;
  final Paint _oilPaint;
  final Paint _rootPaint;
  final Paint _ignitePaint;
  final Paint? _auraFillPaint;
  final Paint? _auraStrokePaint;
  final Paint? _zoneFillPaint;
  final Paint? _zoneStrokePaint;
  final Paint? _variantRingPaint;
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
    _renderVariantRing(canvas);
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
      _renderRoleBadge(canvas);
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

    _renderRoleBadge(canvas);
  }

  void applyTelegraphOpacity(double multiplier) {
    final clamped = multiplier.clamp(0.0, 2.0);
    _telegraphPaint.color = _telegraphTintColor.withValues(
      alpha: (_telegraphBaseAlpha * clamped).clamp(0.0, 1.0),
    );

    final auraFill = _auraFillPaint;
    if (auraFill != null) {
      auraFill.color = _telegraphTintColor.withValues(
        alpha: (_auraFillBaseAlpha * clamped).clamp(0.0, 1.0),
      );
    }
    final auraStroke = _auraStrokePaint;
    if (auraStroke != null) {
      auraStroke.color = _telegraphTintColor.withValues(
        alpha: (_auraStrokeBaseAlpha * clamped).clamp(0.0, 1.0),
      );
    }
    final zoneFill = _zoneFillPaint;
    if (zoneFill != null) {
      zoneFill.color = _telegraphTintColor.withValues(
        alpha: (_zoneFillBaseAlpha * clamped).clamp(0.0, 1.0),
      );
    }
    final zoneStroke = _zoneStrokePaint;
    if (zoneStroke != null) {
      zoneStroke.color = _telegraphTintColor.withValues(
        alpha: (_zoneStrokeBaseAlpha * clamped).clamp(0.0, 1.0),
      );
    }
  }

  void _renderStatusRings(Canvas canvas) {
    if (_state.slowTimer > 0) {
      canvas.drawCircle(Offset.zero, _shapeRadius + 3, _slowPaint);
    }
    if (_state.oilTimer > 0) {
      canvas.drawCircle(Offset.zero, _shapeRadius + 5, _oilPaint);
    }
    if (_state.rootTimer > 0) {
      canvas.drawCircle(Offset.zero, _shapeRadius + 7, _rootPaint);
    }
    if (_state.igniteTimer > 0) {
      canvas.drawCircle(Offset.zero, _shapeRadius + 11, _ignitePaint);
    }
  }

  void _renderVariantRing(Canvas canvas) {
    if (_variant != EnemyVariant.champion) {
      return;
    }
    final ringPaint = _variantRingPaint;
    if (ringPaint == null) {
      return;
    }
    canvas.drawCircle(Offset.zero, _shapeRadius + 8, ringPaint);
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

  void _renderRoleBadge(Canvas canvas) {
    if (_role == EnemyRole.chaser ||
        _role == EnemyRole.ranged ||
        _role == EnemyRole.spawner) {
      return;
    }

    final size = (_shapeRadius * 0.4).clamp(4.0, 10.0).toDouble();
    final center = Offset(0, -_shapeRadius - size - 4);
    final paint = _badgePaint;

    switch (_role) {
      case EnemyRole.disruptor:
        final half = size * 0.5;
        canvas.drawLine(
          center.translate(-half, -half),
          center.translate(half, half),
          paint,
        );
        canvas.drawLine(
          center.translate(-half, half),
          center.translate(half, -half),
          paint,
        );
        break;
      case EnemyRole.zoner:
        final half = size * 0.6;
        final rect = Rect.fromCenter(
          center: center,
          width: half * 2,
          height: half * 2,
        );
        canvas.drawRect(rect, paint);
        break;
      case EnemyRole.exploder:
        final half = size * 0.55;
        canvas.drawCircle(center, half, paint);
        canvas.drawLine(
          center.translate(-half, 0),
          center.translate(half, 0),
          paint,
        );
        canvas.drawLine(
          center.translate(0, -half),
          center.translate(0, half),
          paint,
        );
        break;
      case EnemyRole.supportHealer:
        final half = size * 0.6;
        canvas.drawLine(
          center.translate(-half, 0),
          center.translate(half, 0),
          paint,
        );
        canvas.drawLine(
          center.translate(0, -half),
          center.translate(0, half),
          paint,
        );
        break;
      case EnemyRole.supportBuffer:
        final half = size * 0.65;
        canvas.drawLine(
          center.translate(0, -half),
          center.translate(-half, half),
          paint,
        );
        canvas.drawLine(
          center.translate(0, -half),
          center.translate(half, half),
          paint,
        );
        canvas.drawLine(
          center.translate(-half, half),
          center.translate(half, half),
          paint,
        );
        break;
      case EnemyRole.pattern:
        final half = size * 0.6;
        canvas.drawLine(
          center.translate(-half, -half * 0.2),
          center.translate(0, half),
          paint,
        );
        canvas.drawLine(
          center.translate(half, -half * 0.2),
          center.translate(0, half),
          paint,
        );
        break;
      case EnemyRole.elite:
        final half = size * 0.7;
        canvas.drawLine(
          center.translate(-half, 0),
          center.translate(0, -half),
          paint,
        );
        canvas.drawLine(
          center.translate(0, -half),
          center.translate(half, 0),
          paint,
        );
        canvas.drawLine(
          center.translate(-half * 0.6, half),
          center.translate(half * 0.6, half),
          paint,
        );
        break;
      default:
        break;
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
        alpha: _auraFillBaseAlpha,
      )
      ..style = PaintingStyle.fill;
  }

  static Paint? _createAuraStrokePaint(EnemyRole role) {
    if (role != EnemyRole.supportHealer && role != EnemyRole.supportBuffer) {
      return null;
    }
    return Paint()
      ..color = (_roleColors[role] ?? const Color(0xFF6ED9C0)).withValues(
        alpha: _auraStrokeBaseAlpha,
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
        alpha: _zoneFillBaseAlpha,
      )
      ..style = PaintingStyle.fill;
  }

  static Paint? _createZoneStrokePaint(EnemyRole role) {
    if (role != EnemyRole.zoner) {
      return null;
    }
    return Paint()
      ..color = (_roleColors[role] ?? const Color(0xFFD95A6F)).withValues(
        alpha: _zoneStrokeBaseAlpha,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
  }

  static Paint? _createVariantRingPaint(EnemyVariant variant) {
    if (variant != EnemyVariant.champion) {
      return null;
    }
    final tint = enemyVariantDefsById[variant]?.tintColor ?? 0xFFFFD24A;
    return Paint()
      ..color = Color(tint).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
  }

  static Color _resolveVariantColor(Color base, EnemyVariant variant) {
    if (variant == EnemyVariant.base) {
      return base;
    }
    final tint = enemyVariantDefsById[variant]?.tintColor ?? 0xFFFFD24A;
    return Color.lerp(base, Color(tint), 0.45) ?? base;
  }

  static const double _telegraphBaseAlpha = 0.5;
  static const double _auraFillBaseAlpha = 0.12;
  static const double _auraStrokeBaseAlpha = 0.35;
  static const double _zoneFillBaseAlpha = 0.08;
  static const double _zoneStrokeBaseAlpha = 0.28;
}
