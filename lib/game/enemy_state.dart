import 'dart:math' as math;

import 'package:flame/extensions.dart';

import '../data/ids.dart';
import '../data/tags.dart';

class EnemyState {
  EnemyState({required this.id})
    : position = Vector2.zero(),
      velocity = Vector2.zero(),
      knockbackDirection = Vector2.zero(),
      dashDirection = Vector2.zero();

  EnemyId id;
  EnemyRole role = EnemyRole.chaser;
  EnemyVariant variant = EnemyVariant.base;
  EnemyId? spawnEnemyId;
  final Vector2 position;
  final Vector2 velocity;
  double maxHp = 1;
  double hp = 1;
  double moveSpeed = 20;
  double attackCooldown = 1.6;
  double attackTimer = 0;
  double attackRange = 160;
  double projectileSpeed = 140;
  double projectileDamage = 6;
  double projectileSpread = 0.3;
  double spawnCooldown = 3.5;
  double spawnTimer = 0;
  int spawnCount = 1;
  double spawnRadius = 48;
  int xpReward = 0;
  int goldCurrencyReward = 0;
  int goldShopXpReward = 0;
  double spawnRewardMultiplier = 0;
  double specialCooldown = 0;
  double specialTimer = 0;
  double dashCooldown = 0;
  double dashTimer = 0;
  double orbitDirection = 1;
  double slowTimer = 0;
  double slowMultiplier = 1;
  double rootTimer = 0;
  double rootMultiplier = 1;
  double oilTimer = 0;
  double igniteTimer = 0;
  double igniteDamagePerSecond = 0;
  SkillId? igniteSourceSkillId;
  double speedMultiplier = 1;
  bool behaviorInitialized = false;
  double knockbackTimer = 0;
  double knockbackDuration = 0;
  double knockbackBaseSpeed = 0;
  final Vector2 dashDirection;
  final Vector2 knockbackDirection;
  bool active = false;

  void reset({
    required EnemyId id,
    required EnemyRole role,
    required EnemyVariant variant,
    required Vector2 spawnPosition,
    required double maxHp,
    required double moveSpeed,
    required int xpReward,
    required double attackCooldown,
    required double attackRange,
    required double projectileSpeed,
    required double projectileDamage,
    required double projectileSpread,
    required double spawnCooldown,
    required int spawnCount,
    required double spawnRadius,
    required EnemyId? spawnEnemyId,
    required int goldCurrencyReward,
    required int goldShopXpReward,
    required double spawnRewardMultiplier,
  }) {
    this.id = id;
    this.role = role;
    this.variant = variant;
    this.spawnEnemyId = spawnEnemyId;
    position.setFrom(spawnPosition);
    velocity.setZero();
    this.maxHp = maxHp;
    hp = maxHp;
    this.moveSpeed = moveSpeed;
    this.attackCooldown = attackCooldown;
    attackTimer = attackCooldown;
    this.attackRange = attackRange;
    this.projectileSpeed = projectileSpeed;
    this.projectileDamage = projectileDamage;
    this.projectileSpread = projectileSpread;
    this.spawnCooldown = spawnCooldown;
    spawnTimer = spawnCooldown;
    this.spawnCount = spawnCount;
    this.spawnRadius = spawnRadius;
    this.xpReward = xpReward;
    this.goldCurrencyReward = goldCurrencyReward;
    this.goldShopXpReward = goldShopXpReward;
    this.spawnRewardMultiplier = spawnRewardMultiplier;
    specialCooldown = 0;
    specialTimer = 0;
    dashCooldown = 0;
    dashTimer = 0;
    orbitDirection = 1;
    slowTimer = 0;
    slowMultiplier = 1;
    rootTimer = 0;
    rootMultiplier = 1;
    oilTimer = 0;
    igniteTimer = 0;
    igniteDamagePerSecond = 0;
    igniteSourceSkillId = null;
    speedMultiplier = 1;
    behaviorInitialized = false;
    dashDirection.setZero();
    knockbackTimer = 0;
    knockbackDuration = 0;
    knockbackBaseSpeed = 0;
    knockbackDirection.setZero();
    active = true;
  }

  void applySlow({required double duration, required double multiplier}) {
    if (duration <= 0) {
      return;
    }
    final clampedMultiplier = multiplier.clamp(0.1, 1.0);
    if (slowTimer <= 0 || clampedMultiplier < slowMultiplier) {
      slowMultiplier = clampedMultiplier;
    }
    if (duration > slowTimer) {
      slowTimer = duration;
    }
  }

  void applyRoot({required double duration, required double strength}) {
    if (duration <= 0) {
      return;
    }
    final clampedStrength = strength.clamp(0.0, 0.95);
    final clampedMultiplier = (1 - clampedStrength).clamp(0.05, 1.0);
    if (rootTimer <= 0 || clampedMultiplier < rootMultiplier) {
      rootMultiplier = clampedMultiplier;
    }
    if (duration > rootTimer) {
      rootTimer = duration;
    }
  }

  void applyOil({required double duration}) {
    if (duration <= 0) {
      return;
    }
    if (duration > oilTimer) {
      oilTimer = duration;
    }
  }

  void applyIgnite({
    required double duration,
    required double damagePerSecond,
    SkillId? sourceSkillId,
  }) {
    if (duration <= 0 || damagePerSecond <= 0) {
      return;
    }
    if (igniteTimer <= 0 || damagePerSecond > igniteDamagePerSecond) {
      igniteDamagePerSecond = damagePerSecond;
    }
    if (duration > igniteTimer) {
      igniteTimer = duration;
    }
    if (sourceSkillId != null) {
      igniteSourceSkillId = sourceSkillId;
    }
  }

  void updateDebuffs(double dt) {
    if (slowTimer > 0) {
      slowTimer -= dt;
      if (slowTimer <= 0) {
        slowTimer = 0;
        slowMultiplier = 1;
      }
    }
    if (rootTimer > 0) {
      rootTimer -= dt;
      if (rootTimer <= 0) {
        rootTimer = 0;
        rootMultiplier = 1;
      }
    }
    speedMultiplier = slowMultiplier < rootMultiplier
        ? slowMultiplier
        : rootMultiplier;
  }

  void updateStatusTimers(double dt) {
    if (oilTimer > 0) {
      oilTimer -= dt;
      if (oilTimer <= 0) {
        oilTimer = 0;
      }
    }
    if (igniteTimer > 0) {
      igniteTimer -= dt;
      if (igniteTimer <= 0) {
        igniteTimer = 0;
        igniteDamagePerSecond = 0;
        igniteSourceSkillId = null;
      }
    }
  }

  bool hasStatusEffect(StatusEffectId id) {
    switch (id) {
      case StatusEffectId.slow:
        return slowTimer > 0;
      case StatusEffectId.root:
        return rootTimer > 0;
      case StatusEffectId.ignite:
        return igniteTimer > 0;
      case StatusEffectId.oilSoaked:
        return oilTimer > 0;
      case StatusEffectId.vulnerable:
        return false;
    }
  }

  double get effectiveMoveSpeed => moveSpeed * speedMultiplier;

  void applyKnockback({
    required double directionX,
    required double directionY,
    required double force,
    required double duration,
  }) {
    if (force <= 0 || duration <= 0) {
      return;
    }
    final lengthSquared = directionX * directionX + directionY * directionY;
    if (lengthSquared <= 0) {
      return;
    }
    if (force >= knockbackBaseSpeed) {
      final length = math.sqrt(lengthSquared);
      knockbackDirection.setValues(directionX / length, directionY / length);
      knockbackBaseSpeed = force;
    }
    if (duration > knockbackDuration) {
      knockbackDuration = duration;
    }
    if (duration > knockbackTimer) {
      knockbackTimer = duration;
    }
  }

  void updateKnockback(double dt) {
    if (knockbackTimer <= 0 || knockbackDuration <= 0) {
      return;
    }
    knockbackTimer -= dt;
    if (knockbackTimer <= 0) {
      knockbackTimer = 0;
      knockbackDuration = 0;
      knockbackBaseSpeed = 0;
      knockbackDirection.setZero();
      return;
    }
    final intensity = (knockbackTimer / knockbackDuration).clamp(0.0, 1.0);
    position.addScaled(knockbackDirection, knockbackBaseSpeed * intensity * dt);
  }
}
