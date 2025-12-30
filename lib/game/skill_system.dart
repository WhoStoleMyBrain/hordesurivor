import 'dart:math' as math;

import 'package:flame/extensions.dart';

import '../data/ids.dart';
import '../data/skill_defs.dart';
import '../data/stat_defs.dart';
import '../data/tags.dart';
import 'enemy_pool.dart';
import 'enemy_state.dart';
import 'projectile_pool.dart';
import 'projectile_state.dart';
import 'spatial_grid.dart';
import 'stat_sheet.dart';

class SkillSystem {
  SkillSystem({
    required ProjectilePool projectilePool,
    List<SkillSlot>? skillSlots,
  }) : _projectilePool = projectilePool,
       _skills =
           skillSlots ??
           [
             SkillSlot(id: SkillId.fireball, cooldown: 0.6),
             SkillSlot(id: SkillId.swordCut, cooldown: 0.9),
           ];

  static const Map<SkillId, double> _baseCooldowns = {
    SkillId.fireball: 0.6,
    SkillId.swordCut: 0.9,
    SkillId.waterjet: 0.7,
    SkillId.oilBombs: 1.1,
    SkillId.swordThrust: 0.8,
    SkillId.swordSwing: 1.2,
    SkillId.swordDeflect: 1.4,
    SkillId.poisonGas: 1.3,
    SkillId.roots: 1.2,
  };

  final ProjectilePool _projectilePool;
  final List<SkillSlot> _skills;
  final Vector2 _aimBuffer = Vector2.zero();
  final Vector2 _fallbackDirection = Vector2(1, 0);
  final List<EnemyState> _queryBuffer = [];

  bool hasSkill(SkillId id) {
    return _skills.any((skill) => skill.id == id);
  }

  void addSkill(SkillId id) {
    if (hasSkill(id)) {
      return;
    }
    final cooldown = _baseCooldowns[id] ?? 1.0;
    _skills.add(SkillSlot(id: id, cooldown: cooldown));
  }

  void update({
    required double dt,
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    required void Function(ProjectileState) onProjectileSpawn,
    required void Function(EnemyState, double) onEnemyDamaged,
  }) {
    final cooldownSpeed = _cooldownSpeed(stats);
    final adjustedDt = dt * cooldownSpeed;
    for (final skill in _skills) {
      skill.cooldownRemaining -= adjustedDt;
      while (skill.cooldownRemaining < 0) {
        switch (skill.id) {
          case SkillId.fireball:
            _castFireball(
              playerPosition: playerPosition,
              aimDirection: aimDirection,
              stats: stats,
              enemyPool: enemyPool,
              onProjectileSpawn: onProjectileSpawn,
            );
          case SkillId.swordCut:
            _castSwordCut(
              playerPosition: playerPosition,
              aimDirection: aimDirection,
              stats: stats,
              enemyPool: enemyPool,
              enemyGrid: enemyGrid,
              onEnemyDamaged: onEnemyDamaged,
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
    required StatSheet stats,
    required EnemyPool enemyPool,
    required void Function(ProjectileState) onProjectileSpawn,
  }) {
    final direction = _resolveAim(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
    );
    final damage = 8 * _damageMultiplierFor(SkillId.fireball, stats);
    final projectile = _projectilePool.acquire();
    projectile.reset(
      position: playerPosition,
      velocity: direction..scale(220),
      damage: damage,
      radius: 4,
      lifespan: 2.0,
      fromEnemy: false,
    );
    onProjectileSpawn(projectile);
  }

  void _castSwordCut({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    required void Function(EnemyState, double) onEnemyDamaged,
  }) {
    const baseRange = 46.0;
    const arcDegrees = 90.0;
    final arcCosine = math.cos((arcDegrees * 0.5) * (math.pi / 180));
    final aoeScale = _aoeScale(stats);
    final range = baseRange * aoeScale;
    final damage = 12 * _damageMultiplierFor(SkillId.swordCut, stats);
    final direction = _resolveAim(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
    );

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
          : (dx * direction.x + dy * direction.y) / math.sqrt(distanceSquared);
      if (dotThreshold < arcCosine) {
        continue;
      }

      onEnemyDamaged(enemy, damage);
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

  double _cooldownSpeed(StatSheet stats) {
    final attackSpeed = stats.value(StatId.attackSpeed);
    final cooldownRecovery = stats.value(StatId.cooldownRecovery);
    return math.max(0.1, 1 + attackSpeed + cooldownRecovery);
  }

  double _aoeScale(StatSheet stats) {
    return math.max(0.25, 1 + stats.value(StatId.aoeSize));
  }

  double _damageMultiplierFor(SkillId id, StatSheet stats) {
    final def = skillDefsById[id];
    final tags = def?.tags;
    var multiplier =
        1 + stats.value(StatId.damage) + stats.value(StatId.directHitDamage);

    if (tags != null) {
      if (tags.hasDelivery(DeliveryTag.projectile)) {
        multiplier += stats.value(StatId.projectileDamage);
      }
      if (tags.hasDelivery(DeliveryTag.melee)) {
        multiplier += stats.value(StatId.meleeDamage);
      }
      if (tags.hasDelivery(DeliveryTag.beam)) {
        multiplier += stats.value(StatId.beamDamage);
      }
      if (tags.hasElement(ElementTag.fire)) {
        multiplier += stats.value(StatId.fireDamage);
      }
      if (tags.hasElement(ElementTag.water)) {
        multiplier += stats.value(StatId.waterDamage);
      }
    }

    return math.max(0.1, multiplier);
  }
}

class SkillSlot {
  SkillSlot({required this.id, required this.cooldown})
    : cooldownRemaining = cooldown;

  final SkillId id;
  final double cooldown;
  double cooldownRemaining;
}
