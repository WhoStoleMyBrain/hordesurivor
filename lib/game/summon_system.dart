import 'dart:math' as math;

import 'package:flame/extensions.dart';

import 'enemy_pool.dart';
import 'enemy_state.dart';
import 'game_sizes.dart';
import 'player_state.dart';
import 'projectile_pool.dart';
import 'projectile_state.dart';
import 'spatial_grid.dart';
import 'summon_pool.dart';
import 'summon_state.dart';

class SummonSystem {
  SummonSystem(this._pool);

  final SummonPool _pool;
  final List<EnemyState> _queryBuffer = [];
  final Vector2 _orbitOffset = Vector2.zero();
  final Vector2 _aimDirection = Vector2.zero();

  void update(
    double dt, {
    required PlayerState playerState,
    required EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    required ProjectilePool projectilePool,
    required void Function(ProjectileState) onProjectileSpawn,
    required void Function(SummonState) onDespawn,
    required void Function(
      EnemyState,
      double, {
      double knockbackX,
      double knockbackY,
      double knockbackForce,
      double knockbackDuration,
    })
    onEnemyDamaged,
  }) {
    final active = _pool.active;
    for (var index = active.length - 1; index >= 0; index--) {
      final summon = active[index];
      if (!summon.active) {
        continue;
      }
      summon.age += dt;
      if (summon.age >= summon.lifespan) {
        onDespawn(summon);
        _pool.release(summon);
        continue;
      }

      switch (summon.kind) {
        case SummonKind.guardianOrb:
          _updateOrbitingSummon(summon, playerState.position, dt);
          _applyAuraDamage(summon, enemyPool, enemyGrid, dt, onEnemyDamaged);
        case SummonKind.menderOrb:
          _updateOrbitingSummon(summon, playerState.position, dt);
          if (summon.healingPerSecond > 0) {
            playerState.heal(summon.healingPerSecond * dt);
          }
        case SummonKind.arcTurret:
          _updateOrbitingSummon(summon, playerState.position, dt);
          _updateRangedSummon(
            summon,
            enemyPool,
            enemyGrid,
            projectilePool,
            onProjectileSpawn,
            dt,
          );
        case SummonKind.scrapRover:
          _updateMeleeRover(
            summon,
            playerState.position,
            enemyPool,
            enemyGrid,
            dt,
            onEnemyDamaged,
          );
        case SummonKind.mine:
          _updateMine(summon, enemyPool, enemyGrid, onEnemyDamaged, onDespawn);
      }
    }
  }

  void _updateOrbitingSummon(
    SummonState summon,
    Vector2 playerPosition,
    double dt,
  ) {
    summon.orbitAngle += summon.orbitSpeed * dt;
    _orbitOffset
      ..setValues(math.cos(summon.orbitAngle), math.sin(summon.orbitAngle))
      ..scale(summon.orbitRadius);
    summon.position
      ..setFrom(playerPosition)
      ..add(_orbitOffset);
  }

  void _applyAuraDamage(
    SummonState summon,
    EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    double dt,
    void Function(
      EnemyState,
      double, {
      double knockbackX,
      double knockbackY,
      double knockbackForce,
      double knockbackDuration,
    })
    onEnemyDamaged,
  ) {
    if (summon.damagePerSecond <= 0) {
      return;
    }
    final radius = summon.radius;
    final radiusSquared = radius * radius;
    final candidates = enemyGrid == null
        ? enemyPool.active
        : enemyGrid.queryCircle(summon.position, radius, _queryBuffer);
    for (final enemy in candidates) {
      if (!enemy.active) {
        continue;
      }
      final dx = enemy.position.x - summon.position.x;
      final dy = enemy.position.y - summon.position.y;
      if (dx * dx + dy * dy <= radiusSquared) {
        onEnemyDamaged(enemy, summon.damagePerSecond * dt);
      }
    }
  }

  void _updateRangedSummon(
    SummonState summon,
    EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    ProjectilePool projectilePool,
    void Function(ProjectileState) onProjectileSpawn,
    double dt,
  ) {
    summon.attackTimer -= dt;
    if (summon.attackTimer > 0) {
      return;
    }
    summon.attackTimer = summon.attackCooldown;
    final target = _findNearestEnemy(
      summon.position,
      summon.range,
      enemyPool,
      enemyGrid,
    );
    if (target == null) {
      return;
    }
    _aimDirection
      ..setFrom(target.position)
      ..sub(summon.position);
    if (_aimDirection.length2 <= 0) {
      _aimDirection.setValues(1, 0);
    } else {
      _aimDirection.normalize();
    }
    final projectile = projectilePool.acquire();
    projectile.reset(
      position: summon.position,
      velocity: _aimDirection * summon.projectileSpeed,
      damage: summon.projectileDamage,
      radius: summon.projectileRadius,
      lifespan: 1.2,
      fromEnemy: false,
    );
    projectile.sourceSkillId = summon.sourceSkillId;
    onProjectileSpawn(projectile);
  }

  void _updateMeleeRover(
    SummonState summon,
    Vector2 playerPosition,
    EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    double dt,
    void Function(
      EnemyState,
      double, {
      double knockbackX,
      double knockbackY,
      double knockbackForce,
      double knockbackDuration,
    })
    onEnemyDamaged,
  ) {
    final target = _findNearestEnemy(
      summon.position,
      summon.range,
      enemyPool,
      enemyGrid,
    );
    if (target == null) {
      _updateOrbitingSummon(summon, playerPosition, dt);
      return;
    }
    _aimDirection
      ..setFrom(target.position)
      ..sub(summon.position);
    if (_aimDirection.length2 > 0) {
      _aimDirection.normalize();
      summon.velocity
        ..setFrom(_aimDirection)
        ..scale(summon.moveSpeed);
      summon.position.addScaled(summon.velocity, dt);
    }
    _applyAuraDamage(summon, enemyPool, enemyGrid, dt, onEnemyDamaged);
  }

  void _updateMine(
    SummonState summon,
    EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    void Function(
      EnemyState,
      double, {
      double knockbackX,
      double knockbackY,
      double knockbackForce,
      double knockbackDuration,
    })
    onEnemyDamaged,
    void Function(SummonState) onDespawn,
  ) {
    if (summon.age < summon.armDuration) {
      return;
    }
    final triggerRadius = summon.triggerRadius;
    final triggerRadiusSquared = triggerRadius * triggerRadius;
    final candidates = enemyGrid == null
        ? enemyPool.active
        : enemyGrid.queryCircle(summon.position, triggerRadius, _queryBuffer);
    for (final enemy in candidates) {
      if (!enemy.active) {
        continue;
      }
      final dx = enemy.position.x - summon.position.x;
      final dy = enemy.position.y - summon.position.y;
      if (dx * dx + dy * dy <= triggerRadiusSquared) {
        _detonateMine(summon, enemyPool, enemyGrid, onEnemyDamaged);
        onDespawn(summon);
        _pool.release(summon);
        return;
      }
    }
  }

  void _detonateMine(
    SummonState summon,
    EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    void Function(
      EnemyState,
      double, {
      double knockbackX,
      double knockbackY,
      double knockbackForce,
      double knockbackDuration,
    })
    onEnemyDamaged,
  ) {
    final blastRadius = summon.blastRadius;
    final blastRadiusSquared = blastRadius * blastRadius;
    final candidates = enemyGrid == null
        ? enemyPool.active
        : enemyGrid.queryCircle(summon.position, blastRadius, _queryBuffer);
    for (final enemy in candidates) {
      if (!enemy.active) {
        continue;
      }
      final dx = enemy.position.x - summon.position.x;
      final dy = enemy.position.y - summon.position.y;
      if (dx * dx + dy * dy <= blastRadiusSquared) {
        onEnemyDamaged(enemy, summon.blastDamage);
      }
    }
  }

  EnemyState? _findNearestEnemy(
    Vector2 origin,
    double range,
    EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
  ) {
    if (range <= 0) {
      return null;
    }
    final rangeSquared = range * range;
    final candidates = enemyGrid == null
        ? enemyPool.active
        : enemyGrid.queryCircle(origin, range, _queryBuffer);
    EnemyState? nearest;
    var bestDistance = double.infinity;
    for (final enemy in candidates) {
      if (!enemy.active) {
        continue;
      }
      final dx = enemy.position.x - origin.x;
      final dy = enemy.position.y - origin.y;
      final distanceSquared = dx * dx + dy * dy;
      if (distanceSquared <= rangeSquared && distanceSquared < bestDistance) {
        bestDistance = distanceSquared;
        nearest = enemy;
      }
    }
    return nearest;
  }

  static double defaultProjectileRadius() {
    return GameSizes.projectileRadius(3);
  }
}
