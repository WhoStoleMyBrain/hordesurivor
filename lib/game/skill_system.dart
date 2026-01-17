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
import 'game_sizes.dart';
import 'projectile_pool.dart';
import 'projectile_state.dart';
import 'spatial_grid.dart';
import 'stat_sheet.dart';
import 'summon_pool.dart';
import 'summon_state.dart';

class SkillSystem {
  SkillSystem({
    required EffectPool effectPool,
    required ProjectilePool projectilePool,
    required SummonPool summonPool,
    List<SkillSlot>? skillSlots,
  }) : _effectPool = effectPool,
       _projectilePool = projectilePool,
       _summonPool = summonPool,
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
    SkillId.windCutter: 0.55,
    SkillId.steelShards: 0.9,
    SkillId.flameWave: 1.1,
    SkillId.frostNova: 1.4,
    SkillId.earthSpikes: 1.3,
    SkillId.sporeBurst: 1.0,
    SkillId.scrapRover: 9.5,
    SkillId.arcTurret: 1.6,
    SkillId.guardianOrbs: 1.4,
    SkillId.menderOrb: 9.5,
    SkillId.mineLayer: 8.0,
  };

  final EffectPool _effectPool;
  final ProjectilePool _projectilePool;
  final SummonPool _summonPool;
  final List<SkillSlot> _skills;
  final Set<SkillId> _passiveSummonSkills = {
    SkillId.arcTurret,
    SkillId.guardianOrbs,
  };
  final List<SkillId> _pendingPassiveSummons = [];
  final Vector2 _aimBuffer = Vector2.zero();
  final Vector2 _fallbackDirection = Vector2(1, 0);
  final List<EnemyState> _queryBuffer = [];
  final List<ProjectileState> _projectileQueryBuffer = [];
  final Vector2 _spawnOffset = Vector2.zero();
  double _orbitSeed = 0;

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

  List<SkillId> get skillIds =>
      _skills.map((skill) => skill.id).toList(growable: false);

  void addSkill(SkillId id) {
    if (hasSkill(id)) {
      return;
    }
    final cooldown = _baseCooldowns[id] ?? 1.0;
    _skills.add(SkillSlot(id: id, cooldown: cooldown));
    if (_passiveSummonSkills.contains(id)) {
      _pendingPassiveSummons.add(id);
    }
  }

  void resetToDefaults() {
    _skills
      ..clear()
      ..addAll(_defaultSkillSlots());
    _pendingPassiveSummons.clear();
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
    required void Function(SummonState) onSummonSpawn,
    required void Function({required double radius, required double duration})
    onPlayerDeflect,
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
    final cooldownSpeed = _cooldownSpeed(stats);
    final adjustedDt = dt * cooldownSpeed;
    if (_pendingPassiveSummons.isNotEmpty) {
      final pending = List<SkillId>.from(_pendingPassiveSummons);
      _pendingPassiveSummons.clear();
      for (final skillId in pending) {
        _spawnPassiveSummon(
          skillId: skillId,
          playerPosition: playerPosition,
          stats: stats,
          onSummonSpawn: onSummonSpawn,
        );
      }
    }
    for (final skill in _skills) {
      if (_passiveSummonSkills.contains(skill.id)) {
        continue;
      }
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
              onPlayerDeflect: onPlayerDeflect,
            );
          case SkillId.poisonGas:
            _castPoisonGas(
              playerPosition: playerPosition,
              stats: stats,
              onEffectSpawn: onEffectSpawn,
            );
          case SkillId.roots:
            _castRoots(
              playerPosition: playerPosition,
              aimDirection: aimDirection,
              stats: stats,
              enemyPool: enemyPool,
              onEffectSpawn: onEffectSpawn,
            );
          case SkillId.windCutter:
            _castWindCutter(
              playerPosition: playerPosition,
              aimDirection: aimDirection,
              stats: stats,
              enemyPool: enemyPool,
              onProjectileSpawn: onProjectileSpawn,
            );
          case SkillId.steelShards:
            _castSteelShards(
              playerPosition: playerPosition,
              aimDirection: aimDirection,
              stats: stats,
              enemyPool: enemyPool,
              onProjectileSpawn: onProjectileSpawn,
            );
          case SkillId.flameWave:
            _castFlameWave(
              playerPosition: playerPosition,
              aimDirection: aimDirection,
              stats: stats,
              enemyPool: enemyPool,
              onEffectSpawn: onEffectSpawn,
            );
          case SkillId.frostNova:
            _castFrostNova(
              playerPosition: playerPosition,
              stats: stats,
              onEffectSpawn: onEffectSpawn,
            );
          case SkillId.earthSpikes:
            _castEarthSpikes(
              playerPosition: playerPosition,
              aimDirection: aimDirection,
              stats: stats,
              enemyPool: enemyPool,
              onEffectSpawn: onEffectSpawn,
            );
          case SkillId.sporeBurst:
            _castSporeBurst(
              playerPosition: playerPosition,
              aimDirection: aimDirection,
              stats: stats,
              enemyPool: enemyPool,
              onProjectileSpawn: onProjectileSpawn,
            );
            break;
          case SkillId.scrapRover:
            _castScrapRover(
              playerPosition: playerPosition,
              stats: stats,
              onSummonSpawn: onSummonSpawn,
            );
          case SkillId.arcTurret:
            _castArcTurret(
              playerPosition: playerPosition,
              stats: stats,
              onSummonSpawn: onSummonSpawn,
            );
          case SkillId.guardianOrbs:
            _castGuardianOrbs(
              playerPosition: playerPosition,
              stats: stats,
              onSummonSpawn: onSummonSpawn,
            );
          case SkillId.menderOrb:
            _castMenderOrb(
              playerPosition: playerPosition,
              stats: stats,
              onSummonSpawn: onSummonSpawn,
            );
          case SkillId.mineLayer:
            _castMineLayer(
              playerPosition: playerPosition,
              aimDirection: aimDirection,
              stats: stats,
              onSummonSpawn: onSummonSpawn,
            );
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
    final def = skillDefsById[SkillId.fireball];
    final knockbackScale = _knockbackScale(stats);
    final direction = _resolveAim(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
    );
    final damage = 8 * _damageMultiplierFor(SkillId.fireball, stats);
    const igniteDuration = 1.4;
    final igniteMultiplier =
        1 +
        stats.value(StatId.damage) +
        stats.value(StatId.dotDamage) +
        stats.value(StatId.fireDamage);
    final igniteDamagePerSecond =
        3 * math.max(0.1, igniteMultiplier).toDouble();
    final projectile = _projectilePool.acquire();
    projectile.reset(
      position: playerPosition,
      velocity: direction..scale(220),
      damage: damage,
      radius: GameSizes.projectileRadius(4),
      lifespan: 2.0,
      fromEnemy: false,
    );
    if (def != null && def.knockbackForce > 0 && def.knockbackDuration > 0) {
      projectile.knockbackForce = def.knockbackForce * knockbackScale;
      projectile.knockbackDuration = def.knockbackDuration;
    }
    projectile
      ..sourceSkillId = SkillId.fireball
      ..igniteDuration = igniteDuration
      ..igniteDamagePerSecond = igniteDamagePerSecond;
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
    final aoeScale = _aoeScale(stats);
    final damage = 6 * _damageMultiplierFor(SkillId.waterjet, stats);
    final effect = _effectPool.acquire();
    effect.reset(
      kind: EffectKind.waterjetBeam,
      shape: EffectShape.beam,
      position: playerPosition,
      direction: direction,
      radius: 0,
      length: 140 * aoeScale,
      width: 10 * aoeScale,
      duration: duration,
      damagePerSecond: damage / duration,
      slowMultiplier: 0.7,
      slowDuration: duration * 0.9,
      followsPlayer: true,
    );
    onEffectSpawn(effect);
  }

  void _castOilBombs({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    required void Function(ProjectileState) onProjectileSpawn,
  }) {
    final def = skillDefsById[SkillId.oilBombs];
    final knockbackScale = _knockbackScale(stats);
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
      radius: GameSizes.projectileRadius(6),
      lifespan: 1.4,
      fromEnemy: false,
    );
    projectile.sourceSkillId = SkillId.oilBombs;
    if (def != null && def.knockbackForce > 0 && def.knockbackDuration > 0) {
      projectile.knockbackForce = def.knockbackForce * knockbackScale;
      projectile.knockbackDuration = def.knockbackDuration;
    }
    onProjectileSpawn(projectile);

    const duration = 2.0;
    final aoeScale = _aoeScale(stats);
    final radius = 46 * aoeScale;
    final groundDamage =
        (4 * _damageMultiplierFor(SkillId.oilBombs, stats)) / duration;
    projectile.setImpactEffect(
      kind: EffectKind.oilGround,
      shape: EffectShape.ground,
      direction: direction,
      radius: radius,
      length: 0,
      width: 0,
      duration: duration,
      damagePerSecond: groundDamage,
      slowMultiplier: 0.8,
      slowDuration: 0.6,
      oilDuration: duration * 0.6,
    );
  }

  void _castSwordCut({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
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
    final def = skillDefsById[SkillId.swordCut];
    final knockbackScale = _knockbackScale(stats);
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
      knockbackForce: (def?.knockbackForce ?? 0) * knockbackScale,
      knockbackDuration: def?.knockbackDuration ?? 0,
      onEnemyDamaged: onEnemyDamaged,
    );
  }

  void _castSwordThrust({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
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
    final def = skillDefsById[SkillId.swordThrust];
    final knockbackScale = _knockbackScale(stats);
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
      knockbackForce: (def?.knockbackForce ?? 0) * knockbackScale,
      knockbackDuration: def?.knockbackDuration ?? 0,
      onEnemyDamaged: onEnemyDamaged,
    );
  }

  void _castSwordSwing({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
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
    final def = skillDefsById[SkillId.swordSwing];
    final knockbackScale = _knockbackScale(stats);
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
      knockbackForce: (def?.knockbackForce ?? 0) * knockbackScale,
      knockbackDuration: def?.knockbackDuration ?? 0,
      onEnemyDamaged: onEnemyDamaged,
    );
  }

  void _castSwordDeflect({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    required void Function(
      EnemyState,
      double, {
      double knockbackX,
      double knockbackY,
      double knockbackForce,
      double knockbackDuration,
    })
    onEnemyDamaged,
    required void Function(ProjectileState) onProjectileDespawn,
    required void Function({required double radius, required double duration})
    onPlayerDeflect,
  }) {
    final def = skillDefsById[SkillId.swordDeflect];
    final knockbackScale = _knockbackScale(stats);
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
      knockbackForce: (def?.knockbackForce ?? 0) * knockbackScale,
      knockbackDuration: def?.knockbackDuration ?? 0,
      onEnemyDamaged: onEnemyDamaged,
    );
    final aoeScale = _aoeScale(stats);
    final deflectRadius = (def?.deflectRadius ?? 0) * aoeScale;
    final deflectDuration = def?.deflectDuration ?? 0;
    onPlayerDeflect(radius: deflectRadius, duration: deflectDuration);
    _deflectProjectiles(
      playerPosition: playerPosition,
      stats: stats,
      onProjectileDespawn: onProjectileDespawn,
    );
  }

  void _castPoisonGas({
    required Vector2 playerPosition,
    required StatSheet stats,
    required void Function(EffectState) onEffectSpawn,
  }) {
    final aoeScale = _aoeScale(stats);
    final radius = 70 * aoeScale;
    const duration = 0.8;
    final damage = 4 * _damageMultiplierFor(SkillId.poisonGas, stats);
    final effect = _effectPool.acquire();
    effect.reset(
      kind: EffectKind.poisonAura,
      shape: EffectShape.ground,
      position: playerPosition,
      direction: _fallbackDirection,
      radius: radius,
      length: 0,
      width: 0,
      duration: duration,
      damagePerSecond: damage / duration,
      followsPlayer: true,
    );
    onEffectSpawn(effect);
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
    const baseDuration = 1.8;
    final rootDuration =
        baseDuration * math.max(0.1, 1 + stats.value(StatId.rootDuration));
    final rootStrength = (0.6 + stats.value(StatId.rootStrength)).clamp(
      0.2,
      0.9,
    );
    final rootSlowMultiplier = (1 - rootStrength).clamp(0.05, 1.0);
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
      duration: rootDuration,
      damagePerSecond: damage / rootDuration,
      slowMultiplier: rootSlowMultiplier,
      slowDuration: rootDuration,
    );
    onEffectSpawn(effect);
  }

  void _castWindCutter({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    required void Function(ProjectileState) onProjectileSpawn,
  }) {
    final def = skillDefsById[SkillId.windCutter];
    final knockbackScale = _knockbackScale(stats);
    final direction = _resolveAim(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
    );
    final damage = 7 * _damageMultiplierFor(SkillId.windCutter, stats);
    final projectile = _projectilePool.acquire();
    projectile.reset(
      position: playerPosition,
      velocity: direction..scale(280),
      damage: damage,
      radius: GameSizes.projectileRadius(3),
      lifespan: 1.4,
      fromEnemy: false,
    );
    projectile.sourceSkillId = SkillId.windCutter;
    if (def != null && def.knockbackForce > 0 && def.knockbackDuration > 0) {
      projectile.knockbackForce = def.knockbackForce * knockbackScale;
      projectile.knockbackDuration = def.knockbackDuration;
    }
    onProjectileSpawn(projectile);
  }

  void _castSteelShards({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    required void Function(ProjectileState) onProjectileSpawn,
  }) {
    final def = skillDefsById[SkillId.steelShards];
    final knockbackScale = _knockbackScale(stats);
    final direction = _resolveAim(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
    );
    final damage = 6 * _damageMultiplierFor(SkillId.steelShards, stats);
    const spread = [-0.2, 0.0, 0.2];
    for (final angle in spread) {
      final projectile = _projectilePool.acquire();
      final velocity = direction.clone()
        ..rotate(angle)
        ..scale(200);
      projectile.reset(
        position: playerPosition,
        velocity: velocity,
        damage: damage,
        radius: GameSizes.projectileRadius(3),
        lifespan: 1.2,
        fromEnemy: false,
      );
      projectile.sourceSkillId = SkillId.steelShards;
      if (def != null && def.knockbackForce > 0 && def.knockbackDuration > 0) {
        projectile.knockbackForce = def.knockbackForce * knockbackScale;
        projectile.knockbackDuration = def.knockbackDuration;
      }
      onProjectileSpawn(projectile);
    }
  }

  void _castFlameWave({
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
    const duration = 0.45;
    final aoeScale = _aoeScale(stats);
    final damage = 10 * _damageMultiplierFor(SkillId.flameWave, stats);
    final effect = _effectPool.acquire();
    effect.reset(
      kind: EffectKind.flameWave,
      shape: EffectShape.beam,
      position: playerPosition,
      direction: direction,
      radius: 0,
      length: 120 * aoeScale,
      width: 18 * aoeScale,
      duration: duration,
      damagePerSecond: damage / duration,
    );
    onEffectSpawn(effect);
  }

  void _castFrostNova({
    required Vector2 playerPosition,
    required StatSheet stats,
    required void Function(EffectState) onEffectSpawn,
  }) {
    final aoeScale = _aoeScale(stats);
    const duration = 0.6;
    final damage = 5 * _damageMultiplierFor(SkillId.frostNova, stats);
    final effect = _effectPool.acquire();
    effect.reset(
      kind: EffectKind.frostNova,
      shape: EffectShape.ground,
      position: playerPosition,
      direction: _fallbackDirection,
      radius: 80 * aoeScale,
      length: 0,
      width: 0,
      duration: duration,
      damagePerSecond: damage / duration,
      slowMultiplier: 0.6,
      slowDuration: duration,
      followsPlayer: true,
    );
    onEffectSpawn(effect);
  }

  void _castEarthSpikes({
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
    final aoeScale = _aoeScale(stats);
    const duration = 0.7;
    final damage = 9 * _damageMultiplierFor(SkillId.earthSpikes, stats);
    final target = Vector2(
      playerPosition.x + direction.x * 72,
      playerPosition.y + direction.y * 72,
    );
    final effect = _effectPool.acquire();
    effect.reset(
      kind: EffectKind.earthSpikes,
      shape: EffectShape.ground,
      position: target,
      direction: direction,
      radius: 68 * aoeScale,
      length: 0,
      width: 0,
      duration: duration,
      damagePerSecond: damage / duration,
    );
    onEffectSpawn(effect);
  }

  void _castSporeBurst({
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
    ).clone();
    final damage = 5 * _damageMultiplierFor(SkillId.sporeBurst, stats);
    final projectile = _projectilePool.acquire();
    projectile.reset(
      position: playerPosition,
      velocity: direction.clone()..scale(170),
      damage: damage,
      radius: GameSizes.projectileRadius(5),
      lifespan: 1.6,
      fromEnemy: false,
    );
    projectile.sourceSkillId = SkillId.sporeBurst;
    onProjectileSpawn(projectile);

    final aoeScale = _aoeScale(stats);
    const duration = 1.4;
    final radius = 50 * aoeScale;
    final cloudDamage =
        (4 * _damageMultiplierFor(SkillId.sporeBurst, stats)) / duration;
    projectile.setImpactEffect(
      kind: EffectKind.sporeCloud,
      shape: EffectShape.ground,
      direction: direction,
      radius: radius,
      length: 0,
      width: 0,
      duration: duration,
      damagePerSecond: cloudDamage,
      slowMultiplier: 0.85,
      slowDuration: 0.4,
    );
  }

  void _castScrapRover({
    required Vector2 playerPosition,
    required StatSheet stats,
    required void Function(SummonState) onSummonSpawn,
  }) {
    final summon = _summonPool.acquire();
    final damage = 9 * _damageMultiplierFor(SkillId.scrapRover, stats);
    _orbitSeed += math.pi * 0.7;
    summon.reset(
      kind: SummonKind.scrapRover,
      sourceSkillId: SkillId.scrapRover,
      position: playerPosition,
      radius: 10,
      orbitAngle: _orbitSeed,
      orbitRadius: 36,
      orbitSpeed: 2.4,
      moveSpeed: 120,
      damagePerSecond: damage,
      range: 160,
      lifespan: 6,
    );
    onSummonSpawn(summon);
  }

  void _castArcTurret({
    required Vector2 playerPosition,
    required StatSheet stats,
    required void Function(SummonState) onSummonSpawn,
  }) {
    final summon = _summonPool.acquire();
    final damage = 6 * _damageMultiplierFor(SkillId.arcTurret, stats);
    _orbitSeed += math.pi * 0.5;
    summon.reset(
      kind: SummonKind.arcTurret,
      sourceSkillId: SkillId.arcTurret,
      position: playerPosition,
      radius: 8,
      orbitAngle: _orbitSeed,
      orbitRadius: 44,
      orbitSpeed: 1.6,
      projectileDamage: damage,
      projectileSpeed: 260,
      projectileRadius: GameSizes.projectileRadius(3),
      range: 220,
      lifespan: double.infinity,
      attackCooldown: 0.75 / _attackSpeedScale(stats),
    );
    onSummonSpawn(summon);
  }

  void _castGuardianOrbs({
    required Vector2 playerPosition,
    required StatSheet stats,
    required void Function(SummonState) onSummonSpawn,
  }) {
    final damage = 5 * _damageMultiplierFor(SkillId.guardianOrbs, stats);
    for (var index = 0; index < 2; index++) {
      final summon = _summonPool.acquire();
      _orbitSeed += math.pi;
      summon.reset(
        kind: SummonKind.guardianOrb,
        sourceSkillId: SkillId.guardianOrbs,
        position: playerPosition,
        radius: 18,
        orbitAngle: _orbitSeed,
        orbitRadius: 34,
        orbitSpeed: 2.8,
        damagePerSecond: damage,
        lifespan: double.infinity,
      );
      onSummonSpawn(summon);
    }
  }

  void _castMenderOrb({
    required Vector2 playerPosition,
    required StatSheet stats,
    required void Function(SummonState) onSummonSpawn,
  }) {
    final summon = _summonPool.acquire();
    _orbitSeed += math.pi * 0.35;
    summon.reset(
      kind: SummonKind.menderOrb,
      sourceSkillId: SkillId.menderOrb,
      position: playerPosition,
      radius: 14,
      orbitAngle: _orbitSeed,
      orbitRadius: 38,
      orbitSpeed: 2.2,
      healingPerSecond: 3.2 * _supportMultiplier(stats),
      lifespan: 6,
    );
    onSummonSpawn(summon);
  }

  void _castMineLayer({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required void Function(SummonState) onSummonSpawn,
  }) {
    final direction = _resolveAim(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: null,
    );
    _spawnOffset
      ..setFrom(direction)
      ..scale(28);
    final summon = _summonPool.acquire();
    summon.reset(
      kind: SummonKind.mine,
      sourceSkillId: SkillId.mineLayer,
      position: playerPosition + _spawnOffset,
      radius: 6,
      lifespan: 5,
      triggerRadius: 22,
      blastRadius: 36,
      blastDamage: 12 * _damageMultiplierFor(SkillId.mineLayer, stats),
      armDuration: 0.25,
    );
    onSummonSpawn(summon);
  }

  void _spawnPassiveSummon({
    required SkillId skillId,
    required Vector2 playerPosition,
    required StatSheet stats,
    required void Function(SummonState) onSummonSpawn,
  }) {
    switch (skillId) {
      case SkillId.arcTurret:
        _castArcTurret(
          playerPosition: playerPosition,
          stats: stats,
          onSummonSpawn: onSummonSpawn,
        );
      case SkillId.guardianOrbs:
        _castGuardianOrbs(
          playerPosition: playerPosition,
          stats: stats,
          onSummonSpawn: onSummonSpawn,
        );
      case SkillId.fireball:
      case SkillId.swordCut:
      case SkillId.waterjet:
      case SkillId.oilBombs:
      case SkillId.swordThrust:
      case SkillId.swordSwing:
      case SkillId.swordDeflect:
      case SkillId.poisonGas:
      case SkillId.roots:
      case SkillId.windCutter:
      case SkillId.steelShards:
      case SkillId.flameWave:
      case SkillId.frostNova:
      case SkillId.earthSpikes:
      case SkillId.sporeBurst:
      case SkillId.scrapRover:
      case SkillId.menderOrb:
      case SkillId.mineLayer:
        break;
    }
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
    required double knockbackForce,
    required double knockbackDuration,
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

      onEnemyDamaged(
        enemy,
        damage,
        knockbackX: dx,
        knockbackY: dy,
        knockbackForce: knockbackForce,
        knockbackDuration: knockbackDuration,
      );
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
    required EnemyPool? enemyPool,
  }) {
    var closestDistance = double.infinity;
    var closestDx = 0.0;
    var closestDy = 0.0;
    var hasTarget = false;
    if (enemyPool != null) {
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

  double _attackSpeedScale(StatSheet stats) {
    final attackSpeed = stats.value(StatId.attackSpeed);
    return math.max(0.1, 1 + attackSpeed);
  }

  double _supportMultiplier(StatSheet stats) {
    return math.max(0.1, 1 + stats.value(StatId.healingReceived));
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

  double _knockbackScale(StatSheet stats) {
    return math.max(0.1, 1 + stats.value(StatId.knockbackStrength));
  }
}

class SkillSlot {
  SkillSlot({required this.id, required this.cooldown})
    : cooldownRemaining = cooldown;

  final SkillId id;
  final double cooldown;
  double cooldownRemaining;
}
