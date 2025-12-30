import 'dart:math' as math;

import 'package:flame/extensions.dart';

import '../data/enemy_defs.dart';
import '../data/ids.dart';
import '../data/tags.dart';
import 'enemy_pool.dart';
import 'enemy_state.dart';
import 'projectile_pool.dart';
import 'projectile_state.dart';

class EnemySystem {
  EnemySystem({
    required EnemyPool pool,
    required ProjectilePool projectilePool,
    required math.Random random,
    required void Function(ProjectileState) onProjectileSpawn,
    required void Function(EnemyState) onSpawn,
  }) : _pool = pool,
       _projectilePool = projectilePool,
       _random = random,
       _onProjectileSpawn = onProjectileSpawn,
       _onSpawn = onSpawn;

  final EnemyPool _pool;
  final ProjectilePool _projectilePool;
  final math.Random _random;
  final void Function(ProjectileState) _onProjectileSpawn;
  final void Function(EnemyState) _onSpawn;
  final List<_SpawnRequest> _spawnRequests = [];
  final Vector2 _directionBuffer = Vector2.zero();

  void update(double dt, Vector2 playerPosition, Vector2 arenaSize) {
    _spawnRequests.clear();
    for (final enemy in _pool.active) {
      if (!enemy.active) {
        continue;
      }
      _directionBuffer
        ..setFrom(playerPosition)
        ..sub(enemy.position);
      final distance = _directionBuffer.length;

      switch (enemy.role) {
        case EnemyRole.ranged:
          _handleRanged(enemy, dt, distance);
        case EnemyRole.spawner:
          _handleSpawner(enemy, dt, arenaSize);
        default:
          _moveToward(enemy, dt);
      }
    }

    if (_spawnRequests.isEmpty) {
      return;
    }

    for (final request in _spawnRequests) {
      final spawned = _pool.acquire(request.id);
      spawned.reset(
        id: request.id,
        role: request.role,
        spawnPosition: request.position,
        maxHp: request.maxHp,
        moveSpeed: request.moveSpeed,
        xpReward: request.xpReward,
        attackCooldown: request.attackCooldown,
        attackRange: request.attackRange,
        projectileSpeed: request.projectileSpeed,
        projectileDamage: request.projectileDamage,
        projectileSpread: request.projectileSpread,
        spawnCooldown: request.spawnCooldown,
        spawnCount: request.spawnCount,
        spawnRadius: request.spawnRadius,
        spawnEnemyId: request.spawnEnemyId,
      );
      _onSpawn(spawned);
    }
    _spawnRequests.clear();
  }

  void _handleRanged(EnemyState enemy, double dt, double distance) {
    final retreatRange = enemy.attackRange * 0.55;
    final advanceRange = enemy.attackRange * 0.9;
    if (distance > advanceRange) {
      _moveToward(enemy, dt);
    } else if (distance > 0 && distance < retreatRange) {
      enemy.velocity
        ..setFrom(_directionBuffer)
        ..scale(-1);
      enemy.velocity.normalize();
      enemy.velocity.scale(enemy.moveSpeed);
      enemy.position.addScaled(enemy.velocity, dt);
    } else {
      enemy.velocity.setZero();
    }

    enemy.attackTimer -= dt;
    if (enemy.attackTimer <= 0 && distance <= enemy.attackRange) {
      _fireProjectile(enemy);
      enemy.attackTimer += enemy.attackCooldown;
    }
  }

  void _handleSpawner(EnemyState enemy, double dt, Vector2 arenaSize) {
    _moveToward(enemy, dt);
    enemy.spawnTimer -= dt;
    if (enemy.spawnTimer > 0) {
      return;
    }
    final spawnId = enemy.spawnEnemyId;
    if (spawnId == null) {
      enemy.spawnTimer = enemy.spawnCooldown;
      return;
    }
    final def = enemyDefsById[spawnId];
    if (def == null) {
      enemy.spawnTimer = enemy.spawnCooldown;
      return;
    }
    for (var i = 0; i < enemy.spawnCount; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final radius = _random.nextDouble() * enemy.spawnRadius;
      final position = Vector2(
        enemy.position.x + math.cos(angle) * radius,
        enemy.position.y + math.sin(angle) * radius,
      );
      position.x = position.x.clamp(0.0, arenaSize.x);
      position.y = position.y.clamp(0.0, arenaSize.y);
      _spawnRequests.add(
        _SpawnRequest(
          id: spawnId,
          role: def.role,
          position: position,
          maxHp: def.maxHp,
          moveSpeed: def.moveSpeed,
          xpReward: def.xpReward,
          attackCooldown: def.attackCooldown,
          attackRange: def.attackRange,
          projectileSpeed: def.projectileSpeed,
          projectileDamage: def.projectileDamage,
          projectileSpread: def.projectileSpread,
          spawnCooldown: def.spawnCooldown,
          spawnCount: def.spawnCount,
          spawnRadius: def.spawnRadius,
          spawnEnemyId: def.spawnEnemyId,
        ),
      );
    }
    enemy.spawnTimer = enemy.spawnCooldown;
  }

  void _moveToward(EnemyState enemy, double dt) {
    enemy.velocity.setFrom(_directionBuffer);
    if (enemy.velocity.length2 > 0) {
      enemy.velocity.normalize();
      enemy.velocity.scale(enemy.moveSpeed);
      enemy.position.addScaled(enemy.velocity, dt);
    }
  }

  void _fireProjectile(EnemyState enemy) {
    final baseAngle = math.atan2(_directionBuffer.y, _directionBuffer.x);
    final jitter = (_random.nextDouble() * 2 - 1) * enemy.projectileSpread;
    final angle = baseAngle + jitter;
    final direction = Vector2(math.cos(angle), math.sin(angle));
    final projectile = _projectilePool.acquire();
    projectile.reset(
      position: enemy.position,
      velocity: direction..scale(enemy.projectileSpeed),
      damage: enemy.projectileDamage,
      radius: 4,
      lifespan: 2.2,
      fromEnemy: true,
    );
    _onProjectileSpawn(projectile);
  }
}

class _SpawnRequest {
  _SpawnRequest({
    required this.id,
    required this.role,
    required this.position,
    required this.maxHp,
    required this.moveSpeed,
    required this.xpReward,
    required this.attackCooldown,
    required this.attackRange,
    required this.projectileSpeed,
    required this.projectileDamage,
    required this.projectileSpread,
    required this.spawnCooldown,
    required this.spawnCount,
    required this.spawnRadius,
    required this.spawnEnemyId,
  });

  final EnemyId id;
  final EnemyRole role;
  final Vector2 position;
  final double maxHp;
  final double moveSpeed;
  final int xpReward;
  final double attackCooldown;
  final double attackRange;
  final double projectileSpeed;
  final double projectileDamage;
  final double projectileSpread;
  final double spawnCooldown;
  final int spawnCount;
  final double spawnRadius;
  final EnemyId? spawnEnemyId;
}
