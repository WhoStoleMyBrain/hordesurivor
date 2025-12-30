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
    required void Function(EnemyState) onSelfDestruct,
  }) : _pool = pool,
       _projectilePool = projectilePool,
       _random = random,
       _onProjectileSpawn = onProjectileSpawn,
       _onSpawn = onSpawn,
       _onSelfDestruct = onSelfDestruct;

  final EnemyPool _pool;
  final ProjectilePool _projectilePool;
  final math.Random _random;
  final void Function(ProjectileState) _onProjectileSpawn;
  final void Function(EnemyState) _onSpawn;
  final void Function(EnemyState) _onSelfDestruct;
  final List<_SpawnRequest> _spawnRequests = [];
  final Vector2 _directionBuffer = Vector2.zero();
  final Vector2 _perpBuffer = Vector2.zero();

  void update(double dt, Vector2 playerPosition, Vector2 arenaSize) {
    _spawnRequests.clear();
    for (final enemy in _pool.active) {
      if (!enemy.active) {
        continue;
      }
      enemy.updateDebuffs(dt);
      _initializeBehavior(enemy);
      _directionBuffer
        ..setFrom(playerPosition)
        ..sub(enemy.position);
      final distance = _directionBuffer.length;

      switch (enemy.role) {
        case EnemyRole.ranged:
          _handleRanged(enemy, dt, distance);
        case EnemyRole.spawner:
          _handleSpawner(enemy, dt, arenaSize);
        case EnemyRole.disruptor:
          _handleDisruptor(enemy, dt, distance);
        case EnemyRole.zoner:
          _handleZoner(enemy, dt, distance);
        case EnemyRole.exploder:
          _handleExploder(enemy, dt, distance);
        case EnemyRole.supportHealer:
          _handleSupportHealer(enemy, dt, distance);
        case EnemyRole.supportBuffer:
          _handleSupportBuffer(enemy, dt, distance);
        case EnemyRole.pattern:
          _handlePattern(enemy, dt, distance);
        case EnemyRole.elite:
          _handleElite(enemy, dt, distance);
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
      enemy.velocity.scale(enemy.effectiveMoveSpeed);
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

  void _handleDisruptor(EnemyState enemy, double dt, double distance) {
    _applyRangedMovement(enemy, dt, distance, advanceFactor: 1.0);
    enemy.specialTimer -= dt;
    if (enemy.specialTimer <= 0 && distance <= enemy.attackRange) {
      _fireProjectileBurst(
        enemy,
        count: 3,
        spreadMultiplier: 1.6,
        speedMultiplier: 0.9,
        damageMultiplier: 0.9,
      );
      enemy.specialTimer = enemy.specialCooldown;
    }
  }

  void _handleZoner(EnemyState enemy, double dt, double distance) {
    final zoneRange = enemy.attackRange * 0.75;
    if (distance > zoneRange) {
      _moveToward(enemy, dt);
    } else {
      enemy.velocity.setZero();
    }
    enemy.specialTimer -= dt;
    if (enemy.specialTimer <= 0 && distance <= enemy.attackRange) {
      _fireProjectileRing(
        enemy,
        count: 4,
        speedMultiplier: 0.6,
        damageMultiplier: 0.8,
        radius: 6,
        lifespan: 3.0,
      );
      enemy.specialTimer = enemy.specialCooldown;
    }
  }

  void _handleExploder(EnemyState enemy, double dt, double distance) {
    _moveToward(enemy, dt);
    enemy.specialTimer -= dt;
    final triggerRange = enemy.attackRange * 0.45;
    if (enemy.specialTimer <= 0 && distance <= triggerRange) {
      _fireProjectileRing(
        enemy,
        count: 8,
        speedMultiplier: 1.0,
        damageMultiplier: 1.1,
        radius: 5,
        lifespan: 1.4,
      );
      enemy.specialTimer = enemy.specialCooldown;
      _onSelfDestruct(enemy);
    }
  }

  void _handleSupportHealer(EnemyState enemy, double dt, double distance) {
    _applyRangedMovement(enemy, dt, distance, advanceFactor: 0.8);
    enemy.specialTimer -= dt;
    if (enemy.specialTimer <= 0) {
      _pulseHealAllies(enemy, healAmount: 6, radius: enemy.attackRange * 0.75);
      enemy.specialTimer = enemy.specialCooldown;
    }
  }

  void _handleSupportBuffer(EnemyState enemy, double dt, double distance) {
    _applyRangedMovement(enemy, dt, distance, advanceFactor: 0.8);
    enemy.specialTimer -= dt;
    if (enemy.specialTimer <= 0) {
      _pulseRallyAllies(enemy, radius: enemy.attackRange * 0.8);
      enemy.specialTimer = enemy.specialCooldown;
    }
  }

  void _handlePattern(EnemyState enemy, double dt, double distance) {
    if (distance > 0) {
      _directionBuffer.normalize();
    }
    _perpBuffer
      ..setValues(-_directionBuffer.y, _directionBuffer.x)
      ..scale(enemy.orbitDirection);
    final velocity = _directionBuffer..scale(0.4);
    velocity
      ..addScaled(_perpBuffer, 0.9)
      ..normalize()
      ..scale(enemy.effectiveMoveSpeed);
    enemy.velocity.setFrom(velocity);
    enemy.position.addScaled(enemy.velocity, dt);
    enemy.specialTimer -= dt;
    if (enemy.specialTimer <= 0 && distance <= enemy.attackRange) {
      _fireProjectileBurst(
        enemy,
        count: 2,
        spreadMultiplier: 1.2,
        speedMultiplier: 1.0,
        damageMultiplier: 0.9,
      );
      enemy.specialTimer = enemy.specialCooldown;
    }
  }

  void _handleElite(EnemyState enemy, double dt, double distance) {
    if (enemy.dashTimer > 0) {
      enemy.dashTimer -= dt;
      enemy.velocity
        ..setFrom(enemy.dashDirection)
        ..scale(enemy.effectiveMoveSpeed * 2.6);
      enemy.position.addScaled(enemy.velocity, dt);
      return;
    }
    enemy.specialTimer -= dt;
    if (enemy.specialTimer <= 0 && distance <= enemy.attackRange) {
      if (_directionBuffer.length2 > 0) {
        enemy.dashDirection.setFrom(_directionBuffer);
        enemy.dashDirection.normalize();
      } else {
        enemy.dashDirection.setFrom(Vector2(1, 0));
      }
      enemy.dashTimer = 0.35;
      enemy.specialTimer = enemy.specialCooldown;
      return;
    }
    _moveToward(enemy, dt);
  }

  void _moveToward(EnemyState enemy, double dt) {
    enemy.velocity.setFrom(_directionBuffer);
    if (enemy.velocity.length2 > 0) {
      enemy.velocity.normalize();
      enemy.velocity.scale(enemy.effectiveMoveSpeed);
      enemy.position.addScaled(enemy.velocity, dt);
    }
  }

  void _applyRangedMovement(
    EnemyState enemy,
    double dt,
    double distance, {
    double advanceFactor = 0.9,
    double retreatFactor = 0.55,
  }) {
    final retreatRange = enemy.attackRange * retreatFactor;
    final advanceRange = enemy.attackRange * advanceFactor;
    if (distance > advanceRange) {
      _moveToward(enemy, dt);
    } else if (distance > 0 && distance < retreatRange) {
      enemy.velocity
        ..setFrom(_directionBuffer)
        ..scale(-1);
      enemy.velocity.normalize();
      enemy.velocity.scale(enemy.effectiveMoveSpeed);
      enemy.position.addScaled(enemy.velocity, dt);
    } else {
      enemy.velocity.setZero();
    }
  }

  void _fireProjectile(EnemyState enemy) {
    _spawnProjectile(
      enemy: enemy,
      direction: _directionBuffer,
      spread: enemy.projectileSpread,
      speedMultiplier: 1.0,
      damageMultiplier: 1.0,
      radius: 4,
      lifespan: 2.2,
    );
  }

  void _spawnProjectile({
    required EnemyState enemy,
    required Vector2 direction,
    required double spread,
    required double speedMultiplier,
    required double damageMultiplier,
    required double radius,
    required double lifespan,
  }) {
    final baseAngle = math.atan2(direction.y, direction.x);
    final jitter = (_random.nextDouble() * 2 - 1) * spread;
    final angle = baseAngle + jitter;
    final aimDirection = Vector2(math.cos(angle), math.sin(angle));
    final projectile = _projectilePool.acquire();
    projectile.reset(
      position: enemy.position,
      velocity: aimDirection..scale(enemy.projectileSpeed * speedMultiplier),
      damage: enemy.projectileDamage * damageMultiplier,
      radius: radius,
      lifespan: lifespan,
      fromEnemy: true,
    );
    _onProjectileSpawn(projectile);
  }

  void _fireProjectileBurst(
    EnemyState enemy, {
    required int count,
    required double spreadMultiplier,
    required double speedMultiplier,
    required double damageMultiplier,
  }) {
    final baseAngle = math.atan2(_directionBuffer.y, _directionBuffer.x);
    final spread = enemy.projectileSpread * spreadMultiplier;
    if (count <= 1) {
      _spawnProjectile(
        enemy: enemy,
        direction: _directionBuffer,
        spread: spread,
        speedMultiplier: speedMultiplier,
        damageMultiplier: damageMultiplier,
        radius: 4,
        lifespan: 2.2,
      );
      return;
    }
    final step = spread * 2 / (count - 1);
    for (var i = 0; i < count; i++) {
      final angle = baseAngle - spread + step * i;
      final aimDirection = Vector2(math.cos(angle), math.sin(angle));
      final projectile = _projectilePool.acquire();
      projectile.reset(
        position: enemy.position,
        velocity: aimDirection..scale(enemy.projectileSpeed * speedMultiplier),
        damage: enemy.projectileDamage * damageMultiplier,
        radius: 4,
        lifespan: 2.2,
        fromEnemy: true,
      );
      _onProjectileSpawn(projectile);
    }
  }

  void _fireProjectileRing(
    EnemyState enemy, {
    required int count,
    required double speedMultiplier,
    required double damageMultiplier,
    required double radius,
    required double lifespan,
  }) {
    if (count <= 0) {
      return;
    }
    final angleStep = math.pi * 2 / count;
    for (var i = 0; i < count; i++) {
      final angle = angleStep * i;
      final aimDirection = Vector2(math.cos(angle), math.sin(angle));
      final projectile = _projectilePool.acquire();
      projectile.reset(
        position: enemy.position,
        velocity: aimDirection..scale(enemy.projectileSpeed * speedMultiplier),
        damage: enemy.projectileDamage * damageMultiplier,
        radius: radius,
        lifespan: lifespan,
        fromEnemy: true,
      );
      _onProjectileSpawn(projectile);
    }
  }

  void _pulseHealAllies(
    EnemyState source, {
    required double healAmount,
    required double radius,
  }) {
    final radiusSquared = radius * radius;
    for (final ally in _pool.active) {
      if (!ally.active) {
        continue;
      }
      final dx = ally.position.x - source.position.x;
      final dy = ally.position.y - source.position.y;
      if (dx * dx + dy * dy > radiusSquared) {
        continue;
      }
      if (ally.hp < ally.maxHp) {
        ally.hp = math.min(ally.maxHp, ally.hp + healAmount);
      }
    }
  }

  void _pulseRallyAllies(EnemyState source, {required double radius}) {
    final radiusSquared = radius * radius;
    for (final ally in _pool.active) {
      if (!ally.active) {
        continue;
      }
      final dx = ally.position.x - source.position.x;
      final dy = ally.position.y - source.position.y;
      if (dx * dx + dy * dy > radiusSquared) {
        continue;
      }
      if (ally.attackTimer > ally.attackCooldown * 0.5) {
        ally.attackTimer = ally.attackCooldown * 0.5;
      }
      if (ally.spawnTimer > ally.spawnCooldown * 0.6) {
        ally.spawnTimer = ally.spawnCooldown * 0.6;
      }
    }
  }

  void _initializeBehavior(EnemyState enemy) {
    if (enemy.behaviorInitialized) {
      return;
    }
    enemy.behaviorInitialized = true;
    switch (enemy.role) {
      case EnemyRole.disruptor:
        enemy.specialCooldown = enemy.attackCooldown * 1.4;
        enemy.specialTimer =
            enemy.specialCooldown * (0.4 + _random.nextDouble());
      case EnemyRole.zoner:
        enemy.specialCooldown = enemy.attackCooldown * 1.7;
        enemy.specialTimer =
            enemy.specialCooldown * (0.6 + _random.nextDouble());
      case EnemyRole.exploder:
        enemy.specialCooldown = enemy.attackCooldown * 1.3;
        enemy.specialTimer =
            enemy.specialCooldown * (0.2 + _random.nextDouble());
      case EnemyRole.supportHealer:
      case EnemyRole.supportBuffer:
        enemy.specialCooldown = enemy.attackCooldown * 1.8;
        enemy.specialTimer =
            enemy.specialCooldown * (0.5 + _random.nextDouble());
      case EnemyRole.pattern:
        enemy.specialCooldown = enemy.attackCooldown * 1.3;
        enemy.specialTimer =
            enemy.specialCooldown * (0.3 + _random.nextDouble());
        enemy.orbitDirection = _random.nextBool() ? 1 : -1;
      case EnemyRole.elite:
        enemy.specialCooldown = enemy.attackCooldown * 1.5;
        enemy.specialTimer =
            enemy.specialCooldown * (0.3 + _random.nextDouble());
      default:
        enemy.specialCooldown = 0;
        enemy.specialTimer = 0;
    }
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
