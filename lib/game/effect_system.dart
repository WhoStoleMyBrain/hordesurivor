import 'dart:math' as math;

import 'package:flame/extensions.dart';

import '../data/ids.dart';
import 'effect_pool.dart';
import 'effect_state.dart';
import 'enemy_pool.dart';
import 'enemy_state.dart';
import 'spatial_grid.dart';

class EffectSystem {
  EffectSystem(this._pool);

  final EffectPool _pool;
  final List<EnemyState> _queryBuffer = [];
  final Vector2 _beamCenter = Vector2.zero();

  void update(
    double dt, {
    required EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    Vector2? playerPosition,
    required void Function(EffectState) onDespawn,
    required void Function(
      EnemyState,
      double, {
      SkillId? sourceSkillId,
      double knockbackX,
      double knockbackY,
      double knockbackForce,
      double knockbackDuration,
    })
    onEnemyDamaged,
  }) {
    final active = _pool.active;
    for (var index = active.length - 1; index >= 0; index--) {
      final effect = active[index];
      if (!effect.active) {
        continue;
      }
      if (effect.followsPlayer && playerPosition != null) {
        effect.position.setFrom(playerPosition);
      }
      effect.age += dt;
      if (effect.age >= effect.duration) {
        onDespawn(effect);
        _pool.release(effect);
        continue;
      }

      final damage = effect.damagePerSecond * dt;
      if (damage <= 0) {
        continue;
      }

      switch (effect.shape) {
        case EffectShape.ground:
          _applyGroundDamage(
            effect,
            enemyPool,
            enemyGrid,
            damage,
            onEnemyDamaged,
          );
        case EffectShape.beam:
          _applyBeamDamage(
            effect,
            enemyPool,
            enemyGrid,
            damage,
            onEnemyDamaged,
          );
        case EffectShape.arc:
          _applyArcDamage(effect, enemyPool, enemyGrid, damage, onEnemyDamaged);
      }
    }
  }

  void _applyGroundDamage(
    EffectState effect,
    EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    double damage,
    void Function(
      EnemyState,
      double, {
      SkillId? sourceSkillId,
      double knockbackX,
      double knockbackY,
      double knockbackForce,
      double knockbackDuration,
    })
    onEnemyDamaged,
  ) {
    final radius = effect.radius;
    final radiusSquared = radius * radius;
    final candidates = enemyGrid == null
        ? enemyPool.active
        : enemyGrid.queryCircle(effect.position, radius, _queryBuffer);
    for (final enemy in candidates) {
      if (!enemy.active) {
        continue;
      }
      final dx = enemy.position.x - effect.position.x;
      final dy = enemy.position.y - effect.position.y;
      if (dx * dx + dy * dy <= radiusSquared) {
        _applyStatus(effect, enemy);
        onEnemyDamaged(enemy, damage, sourceSkillId: effect.sourceSkillId);
      }
    }
  }

  void _applyBeamDamage(
    EffectState effect,
    EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    double damage,
    void Function(
      EnemyState,
      double, {
      SkillId? sourceSkillId,
      double knockbackX,
      double knockbackY,
      double knockbackForce,
      double knockbackDuration,
    })
    onEnemyDamaged,
  ) {
    final dir = effect.direction;
    final length = effect.length;
    final halfWidth = effect.width * 0.5;
    _beamCenter
      ..setFrom(effect.position)
      ..addScaled(dir, length * 0.5);
    final queryRadius = length * 0.5 + halfWidth;
    final candidates = enemyGrid == null
        ? enemyPool.active
        : enemyGrid.queryCircle(_beamCenter, queryRadius, _queryBuffer);
    for (final enemy in candidates) {
      if (!enemy.active) {
        continue;
      }
      final dx = enemy.position.x - effect.position.x;
      final dy = enemy.position.y - effect.position.y;
      final projection = dx * dir.x + dy * dir.y;
      if (projection < 0 || projection > length) {
        continue;
      }
      final perpendicular = (dx * dir.y - dy * dir.x).abs();
      if (perpendicular <= halfWidth) {
        _applyStatus(effect, enemy);
        onEnemyDamaged(enemy, damage, sourceSkillId: effect.sourceSkillId);
      }
    }
  }

  void _applyArcDamage(
    EffectState effect,
    EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    double damage,
    void Function(
      EnemyState,
      double, {
      SkillId? sourceSkillId,
      double knockbackX,
      double knockbackY,
      double knockbackForce,
      double knockbackDuration,
    })
    onEnemyDamaged,
  ) {
    final arcCosine = math.cos((effect.arcDegrees * 0.5) * (math.pi / 180));
    final radius = effect.radius;
    final radiusSquared = radius * radius;
    final candidates = enemyGrid == null
        ? enemyPool.active
        : enemyGrid.queryCircle(effect.position, radius, _queryBuffer);
    for (final enemy in candidates) {
      if (!enemy.active) {
        continue;
      }
      final dx = enemy.position.x - effect.position.x;
      final dy = enemy.position.y - effect.position.y;
      final distanceSquared = dx * dx + dy * dy;
      if (distanceSquared > radiusSquared) {
        continue;
      }
      final dotThreshold = distanceSquared == 0
          ? 1.0
          : (dx * effect.direction.x + dy * effect.direction.y) /
                math.sqrt(distanceSquared);
      if (dotThreshold < arcCosine) {
        continue;
      }
      if (effect.sweepArcDegrees > 0 && effect.duration > 0) {
        final angle = math.atan2(dy, dx);
        final progress = _arcSweepProgress(effect, angle);
        if (progress <= 0) {
          continue;
        }
        _applyStatus(effect, enemy);
        onEnemyDamaged(
          enemy,
          damage * progress,
          sourceSkillId: effect.sourceSkillId,
          knockbackX: dx,
          knockbackY: dy,
          knockbackForce: effect.knockbackForce * progress,
          knockbackDuration: effect.knockbackDuration,
        );
        continue;
      }
      _applyStatus(effect, enemy);
      onEnemyDamaged(
        enemy,
        damage,
        sourceSkillId: effect.sourceSkillId,
        knockbackX: dx,
        knockbackY: dy,
        knockbackForce: effect.knockbackForce,
        knockbackDuration: effect.knockbackDuration,
      );
    }
  }

  double _arcSweepProgress(EffectState effect, double angle) {
    final sweepRange = effect.sweepArcDegrees * (math.pi / 180);
    final startAngle = effect.sweepStartAngle * (math.pi / 180);
    final endAngle = effect.sweepEndAngle * (math.pi / 180);
    if (sweepRange <= 0 || effect.duration <= 0) {
      return 0;
    }

    final ageProgress = (effect.age / effect.duration).clamp(0.0, 1.0);
    final currentAngle = startAngle + (endAngle - startAngle) * ageProgress;
    final angleDiff = _wrapAngle(angle - currentAngle).abs();
    if (angleDiff > sweepRange * 0.5) {
      return 0;
    }
    final normalized = 1 - (angleDiff / (sweepRange * 0.5));
    return normalized.clamp(0.0, 1.0);
  }

  double _wrapAngle(double angle) {
    var wrapped = angle;
    while (wrapped <= -math.pi) {
      wrapped += math.pi * 2;
    }
    while (wrapped > math.pi) {
      wrapped -= math.pi * 2;
    }
    return wrapped;
  }

  void _applyStatus(EffectState effect, EnemyState enemy) {
    if (effect.oilDuration > 0 && effect.kind == EffectKind.oilGround) {
      enemy.applyOil(duration: effect.oilDuration);
    }
    if (effect.slowDuration <= 0 || effect.slowMultiplier >= 1) {
      return;
    }
    if (effect.kind == EffectKind.rootsGround) {
      enemy.applyRoot(
        duration: effect.slowDuration,
        strength: 1 - effect.slowMultiplier,
      );
    } else {
      enemy.applySlow(
        duration: effect.slowDuration,
        multiplier: effect.slowMultiplier,
      );
    }
  }
}
