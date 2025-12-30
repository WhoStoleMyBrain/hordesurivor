import 'package:flame/extensions.dart';

import '../data/ids.dart';
import '../data/tags.dart';

class EnemyState {
  EnemyState({required this.id})
    : position = Vector2.zero(),
      velocity = Vector2.zero(),
      dashDirection = Vector2.zero();

  EnemyId id;
  EnemyRole role = EnemyRole.chaser;
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
  double specialCooldown = 0;
  double specialTimer = 0;
  double dashCooldown = 0;
  double dashTimer = 0;
  double orbitDirection = 1;
  double slowTimer = 0;
  double slowMultiplier = 1;
  double rootTimer = 0;
  double rootMultiplier = 1;
  double speedMultiplier = 1;
  bool behaviorInitialized = false;
  final Vector2 dashDirection;
  bool active = false;

  void reset({
    required EnemyId id,
    required EnemyRole role,
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
  }) {
    this.id = id;
    this.role = role;
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
    specialCooldown = 0;
    specialTimer = 0;
    dashCooldown = 0;
    dashTimer = 0;
    orbitDirection = 1;
    slowTimer = 0;
    slowMultiplier = 1;
    rootTimer = 0;
    rootMultiplier = 1;
    speedMultiplier = 1;
    behaviorInitialized = false;
    dashDirection.setZero();
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

  double get effectiveMoveSpeed => moveSpeed * speedMultiplier;
}
