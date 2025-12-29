import 'dart:math' as math;

import 'package:flame/extensions.dart';

import '../data/ids.dart';
import 'enemy_pool.dart';
import 'enemy_state.dart';
import 'projectile_pool.dart';
import 'projectile_state.dart';
import 'spatial_grid.dart';

class SkillSystem {
  SkillSystem({
    required ProjectilePool projectilePool,
    List<SkillSlot>? skillSlots,
  })  : _projectilePool = projectilePool,
        _skills = skillSlots ??
            [
              SkillSlot(id: SkillId.fireball, cooldown: 0.6),
              SkillSlot(id: SkillId.swordCut, cooldown: 0.9),
            ];

  final ProjectilePool _projectilePool;
  final List<SkillSlot> _skills;
  final Vector2 _aimBuffer = Vector2.zero();
  final Vector2 _fallbackDirection = Vector2(1, 0);
  final List<EnemyState> _defeatedBuffer = [];
  final List<EnemyState> _queryBuffer = [];

  void update({
    required double dt,
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    required void Function(ProjectileState) onProjectileSpawn,
    required void Function(EnemyState) onEnemyDefeated,
  }) {
    for (final skill in _skills) {
      skill.cooldownRemaining -= dt;
      while (skill.cooldownRemaining <= 0) {
        switch (skill.id) {
          case SkillId.fireball:
            _castFireball(
              playerPosition: playerPosition,
              aimDirection: aimDirection,
              enemyPool: enemyPool,
              onProjectileSpawn: onProjectileSpawn,
            );
          case SkillId.swordCut:
            _castSwordCut(
              playerPosition: playerPosition,
              aimDirection: aimDirection,
              enemyPool: enemyPool,
              enemyGrid: enemyGrid,
              onEnemyDefeated: onEnemyDefeated,
            );
          case SkillId.waterjet:
          case SkillId.oilBombs:
          case SkillId.swordThrust:
          case SkillId.swordSwing:
          case SkillId.swordDeflect:
          case SkillId.poisonGas:
          case SkillId.roots:
            break;
        }
        skill.cooldownRemaining += skill.cooldown;
      }
    }
  }

  void _castFireball({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required EnemyPool enemyPool,
    required void Function(ProjectileState) onProjectileSpawn,
  }) {
    final direction = _resolveAim(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
    );
    final projectile = _projectilePool.acquire();
    projectile.reset(
      position: playerPosition,
      velocity: direction..scale(220),
      damage: 8,
      radius: 4,
      lifespan: 2.0,
    );
    onProjectileSpawn(projectile);
  }

  void _castSwordCut({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    required void Function(EnemyState) onEnemyDefeated,
  }) {
    const range = 46.0;
    const arcDegrees = 90.0;
    const damage = 12.0;
    final arcCosine = math.cos((arcDegrees * 0.5) * (math.pi / 180));
    final direction = _resolveAim(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
    );

    _defeatedBuffer.clear();
    final rangeSquared = range * range;
    final candidates = enemyGrid == null
        ? enemyPool.active
        : enemyGrid.queryCircle(playerPosition, range, _queryBuffer);
    for (final enemy in candidates) {
      final dx = enemy.position.x - playerPosition.x;
      final dy = enemy.position.y - playerPosition.y;
      final distanceSquared = dx * dx + dy * dy;
      if (distanceSquared > rangeSquared) {
        continue;
      }

      final dotThreshold = distanceSquared == 0
          ? 1.0
          : (dx * direction.x + dy * direction.y) /
              math.sqrt(distanceSquared);
      if (dotThreshold < arcCosine) {
        continue;
      }

      enemy.hp -= damage;
      if (enemy.hp <= 0) {
        _defeatedBuffer.add(enemy);
      }
    }

    for (final enemy in _defeatedBuffer) {
      onEnemyDefeated(enemy);
    }
  }

  Vector2 _resolveAim({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required EnemyPool enemyPool,
  }) {
    var closestDistance = double.infinity;
    var closestDx = 0.0;
    var closestDy = 0.0;
    var hasTarget = false;
    for (final enemy in enemyPool.active) {
      final dx = enemy.position.x - playerPosition.x;
      final dy = enemy.position.y - playerPosition.y;
      final distance = dx * dx + dy * dy;
      if (distance < closestDistance) {
        closestDistance = distance;
        closestDx = dx;
        closestDy = dy;
        hasTarget = true;
      }
    }

    if (hasTarget) {
      _aimBuffer.setValues(closestDx, closestDy);
    } else if (aimDirection.length2 > 0) {
      _aimBuffer.setFrom(aimDirection);
    } else {
      _aimBuffer.setFrom(_fallbackDirection);
    }

    _aimBuffer.normalize();
    return _aimBuffer;
  }
}

class SkillSlot {
  SkillSlot({required this.id, required this.cooldown})
      : cooldownRemaining = cooldown;

  final SkillId id;
  final double cooldown;
  double cooldownRemaining;
}
