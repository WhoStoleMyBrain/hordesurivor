import 'dart:math' as math;

import 'package:flame/extensions.dart';

import '../data/ids.dart';
import '../data/skill_defs.dart';
import '../data/stat_defs.dart';
import '../data/tags.dart';
import 'effect_pool.dart';
import 'effect_state.dart';
import 'enemy_pool.dart';
import 'enemy_state.dart';
import 'projectile_pool.dart';
import 'projectile_state.dart';
import 'spatial_grid.dart';
import 'stat_sheet.dart';

class SkillSystem {
  SkillSystem({
    required EffectPool effectPool,
    required ProjectilePool projectilePool,
    List<SkillSlot>? skillSlots,
  }) : _effectPool = effectPool,
       _projectilePool = projectilePool,
       _skills = skillSlots ?? _defaultSkillSlots();

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

  final EffectPool _effectPool;
  final ProjectilePool _projectilePool;
  final List<SkillSlot> _skills;
  final Vector2 _aimBuffer = Vector2.zero();
  final Vector2 _fallbackDirection = Vector2(1, 0);
  final List<EnemyState> _queryBuffer = [];
  final List<ProjectileState> _projectileQueryBuffer = [];

  static List<SkillSlot> _defaultSkillSlots() {
    return [
      SkillSlot(
        id: SkillId.fireball,
        cooldown: _baseCooldowns[SkillId.fireball] ?? 0.6,
      ),
      SkillSlot(
        id: SkillId.swordCut,
        cooldown: _baseCooldowns[SkillId.swordCut] ?? 0.9,
      ),
    ];
  }

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

  void resetToDefaults() {
    _skills
      ..clear()
      ..addAll(_defaultSkillSlots());
  }

  void update({
    required double dt,
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    required void Function(ProjectileState) onProjectileSpawn,
    required void Function(EffectState) onEffectSpawn,
    required void Function(ProjectileState) onProjectileDespawn,
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
            _castWaterjet(
              playerPosition: playerPosition,
              aimDirection: aimDirection,
              stats: stats,
              enemyPool: enemyPool,
              onEffectSpawn: onEffectSpawn,
            );
          case SkillId.oilBombs:
            _castOilBombs(
              playerPosition: playerPosition,
              aimDirection: aimDirection,
              stats: stats,
              enemyPool: enemyPool,
              onProjectileSpawn: onProjectileSpawn,
              onEffectSpawn: onEffectSpawn,
            );
          case SkillId.swordThrust:
            _castSwordThrust(
              playerPosition: playerPosition,
              aimDirection: aimDirection,
              stats: stats,
              enemyPool: enemyPool,
              enemyGrid: enemyGrid,
              onEnemyDamaged: onEnemyDamaged,
            );
          case SkillId.swordSwing:
            _castSwordSwing(
              playerPosition: playerPosition,
              aimDirection: aimDirection,
              stats: stats,
              enemyPool: enemyPool,
              enemyGrid: enemyGrid,
              onEnemyDamaged: onEnemyDamaged,
            );
          case SkillId.swordDeflect:
            _castSwordDeflect(
              playerPosition: playerPosition,
              aimDirection: aimDirection,
              stats: stats,
              enemyPool: enemyPool,
              enemyGrid: enemyGrid,
              onEnemyDamaged: onEnemyDamaged,
              onProjectileDespawn: onProjectileDespawn,
            );
          case SkillId.poisonGas:
            _castPoisonGas(
              playerPosition: playerPosition,
              stats: stats,
              enemyPool: enemyPool,
              enemyGrid: enemyGrid,
              onEnemyDamaged: onEnemyDamaged,
            );
          case SkillId.roots:
            _castRoots(
              playerPosition: playerPosition,
              aimDirection: aimDirection,
              stats: stats,
              enemyPool: enemyPool,
              onEffectSpawn: onEffectSpawn,
            );
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

  void _castWaterjet({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    required void Function(EffectState) onEffectSpawn,
  }) {
    final direction = _resolveAim(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
    );
    const duration = 0.35;
    final damage = 6 * _damageMultiplierFor(SkillId.waterjet, stats);
    final effect = _effectPool.acquire();
    effect.reset(
      kind: EffectKind.waterjetBeam,
      shape: EffectShape.beam,
      position: playerPosition,
      direction: direction,
      radius: 0,
      length: 140,
      width: 10,
      duration: duration,
      damagePerSecond: damage / duration,
    );
    onEffectSpawn(effect);
  }

  void _castOilBombs({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    required void Function(ProjectileState) onProjectileSpawn,
    required void Function(EffectState) onEffectSpawn,
  }) {
    final direction = _resolveAim(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
    ).clone();
    final damage = 4 * _damageMultiplierFor(SkillId.oilBombs, stats);
    final projectile = _projectilePool.acquire();
    projectile.reset(
      position: playerPosition,
      velocity: direction.clone()..scale(160),
      damage: damage,
      radius: 6,
      lifespan: 1.4,
      fromEnemy: false,
    );
    onProjectileSpawn(projectile);

    const duration = 2.0;
    final aoeScale = _aoeScale(stats);
    final radius = 46 * aoeScale;
    final target = Vector2(
      playerPosition.x + direction.x * 90,
      playerPosition.y + direction.y * 90,
    );
    final groundDamage =
        (4 * _damageMultiplierFor(SkillId.oilBombs, stats)) / duration;
    final effect = _effectPool.acquire();
    effect.reset(
      kind: EffectKind.oilGround,
      shape: EffectShape.ground,
      position: target,
      direction: direction,
      radius: radius,
      length: 0,
      width: 0,
      duration: duration,
      damagePerSecond: groundDamage,
    );
    onEffectSpawn(effect);
  }

  void _castSwordCut({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    required void Function(EnemyState, double) onEnemyDamaged,
  }) {
    final damage = 12 * _damageMultiplierFor(SkillId.swordCut, stats);
    _castMeleeArc(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
      enemyGrid: enemyGrid,
      stats: stats,
      baseRange: 46,
      arcDegrees: 90,
      damage: damage,
      onEnemyDamaged: onEnemyDamaged,
    );
  }

  void _castSwordThrust({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    required void Function(EnemyState, double) onEnemyDamaged,
  }) {
    final damage = 10 * _damageMultiplierFor(SkillId.swordThrust, stats);
    _castMeleeArc(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
      enemyGrid: enemyGrid,
      stats: stats,
      baseRange: 58,
      arcDegrees: 30,
      damage: damage,
      onEnemyDamaged: onEnemyDamaged,
    );
  }

  void _castSwordSwing({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    required void Function(EnemyState, double) onEnemyDamaged,
  }) {
    final damage = 14 * _damageMultiplierFor(SkillId.swordSwing, stats);
    _castMeleeArc(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
      enemyGrid: enemyGrid,
      stats: stats,
      baseRange: 52,
      arcDegrees: 140,
      damage: damage,
      onEnemyDamaged: onEnemyDamaged,
    );
  }

  void _castSwordDeflect({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    required void Function(EnemyState, double) onEnemyDamaged,
    required void Function(ProjectileState) onProjectileDespawn,
  }) {
    final damage = 8 * _damageMultiplierFor(SkillId.swordDeflect, stats);
    _castMeleeArc(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
      enemyGrid: enemyGrid,
      stats: stats,
      baseRange: 42,
      arcDegrees: 100,
      damage: damage,
      onEnemyDamaged: onEnemyDamaged,
    );
    _deflectProjectiles(
      playerPosition: playerPosition,
      stats: stats,
      onProjectileDespawn: onProjectileDespawn,
    );
  }

  void _castPoisonGas({
    required Vector2 playerPosition,
    required StatSheet stats,
    required EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    required void Function(EnemyState, double) onEnemyDamaged,
  }) {
    final aoeScale = _aoeScale(stats);
    final radius = 70 * aoeScale;
    final damage = 4 * _damageMultiplierFor(SkillId.poisonGas, stats);
    final radiusSquared = radius * radius;
    final candidates = enemyGrid == null
        ? enemyPool.active
        : enemyGrid.queryCircle(playerPosition, radius, _queryBuffer);
    for (final enemy in candidates) {
      final dx = enemy.position.x - playerPosition.x;
      final dy = enemy.position.y - playerPosition.y;
      if (dx * dx + dy * dy <= radiusSquared) {
        onEnemyDamaged(enemy, damage);
      }
    }
  }

  void _castRoots({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    required void Function(EffectState) onEffectSpawn,
  }) {
    final direction = _resolveAim(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
    ).clone();
    final aoeScale = _aoeScale(stats);
    final radius = 54 * aoeScale;
    const duration = 1.8;
    final damage = 7 * _damageMultiplierFor(SkillId.roots, stats);
    final target = Vector2(
      playerPosition.x + direction.x * 60,
      playerPosition.y + direction.y * 60,
    );
    final effect = _effectPool.acquire();
    effect.reset(
      kind: EffectKind.rootsGround,
      shape: EffectShape.ground,
      position: target,
      direction: direction,
      radius: radius,
      length: 0,
      width: 0,
      duration: duration,
      damagePerSecond: damage / duration,
    );
    onEffectSpawn(effect);
  }

  void _castMeleeArc({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required EnemyPool enemyPool,
    required SpatialGrid? enemyGrid,
    required StatSheet stats,
    required double baseRange,
    required double arcDegrees,
    required double damage,
    required void Function(EnemyState, double) onEnemyDamaged,
  }) {
    final arcCosine = math.cos((arcDegrees * 0.5) * (math.pi / 180));
    final aoeScale = _aoeScale(stats);
    final range = baseRange * aoeScale;
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

  void _deflectProjectiles({
    required Vector2 playerPosition,
    required StatSheet stats,
    required void Function(ProjectileState) onProjectileDespawn,
  }) {
    final radius = 55 * _aoeScale(stats);
    final radiusSquared = radius * radius;
    _projectileQueryBuffer
      ..clear()
      ..addAll(_projectilePool.active);
    for (final projectile in _projectileQueryBuffer) {
      if (!projectile.active || !projectile.fromEnemy) {
        continue;
      }
      final dx = projectile.position.x - playerPosition.x;
      final dy = projectile.position.y - playerPosition.y;
      if (dx * dx + dy * dy <= radiusSquared) {
        onProjectileDespawn(projectile);
        _projectilePool.release(projectile);
      }
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
      if (tags.hasEffect(EffectTag.dot)) {
        multiplier += stats.value(StatId.dotDamage);
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
