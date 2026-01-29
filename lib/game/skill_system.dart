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
import 'skill_level_scaling.dart';
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
    math.Random? random,
  }) : _effectPool = effectPool,
       _projectilePool = projectilePool,
       _summonPool = summonPool,
       _skills = skillSlots ?? _defaultSkillSlots(),
       _random = random ?? math.Random();

  static const int maxSkillSlots = 4;

  final EffectPool _effectPool;
  final ProjectilePool _projectilePool;
  final SummonPool _summonPool;
  final List<SkillSlot> _skills;
  Map<SkillId, int> _skillLevels = const {};
  final math.Random _random;
  final Set<SkillId> _passiveSummonSkills = {
    SkillId.vigilLantern,
    SkillId.guardianOrbs,
  };
  final List<SkillId> _pendingPassiveSummons = [];
  final Vector2 _aimBuffer = Vector2.zero();
  final Vector2 _fallbackDirection = Vector2(1, 0);
  final List<EnemyState> _queryBuffer = [];
  final List<ProjectileState> _projectileQueryBuffer = [];
  final Vector2 _spawnOffset = Vector2.zero();
  double _orbitSeed = 0;
  EnemyState? _debugTarget;
  bool debugHighlightTarget = false;

  static List<SkillSlot> _defaultSkillSlots() {
    return [];
  }

  bool hasSkill(SkillId id) {
    return _skills.any((skill) => skill.id == id);
  }

  bool get hasOpenSkillSlot => _skills.length < maxSkillSlots;

  List<SkillId> get skillIds =>
      _skills.map((skill) => skill.id).toList(growable: false);

  EnemyState? get debugTarget => _debugTarget;

  void addSkill(SkillId id) {
    if (hasSkill(id)) {
      return;
    }
    if (!hasOpenSkillSlot) {
      return;
    }
    final cooldown = skillDefsById[id]?.cooldown ?? 1.0;
    _skills.add(SkillSlot(id: id, cooldown: cooldown));
    if (_passiveSummonSkills.contains(id)) {
      _pendingPassiveSummons.add(id);
    }
  }

  void setSkills(List<SkillId> skillIds) {
    final existingSlots = {for (final slot in _skills) slot.id: slot};
    _skills
      ..clear()
      ..addAll(
        skillIds.map((id) {
          final existing = existingSlots[id];
          if (existing != null) {
            return existing;
          }
          final cooldown = skillDefsById[id]?.cooldown ?? 1.0;
          return SkillSlot(id: id, cooldown: cooldown);
        }),
      );
    for (final id in skillIds) {
      if (!existingSlots.containsKey(id) && _passiveSummonSkills.contains(id)) {
        _pendingPassiveSummons.add(id);
      }
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
    Map<SkillId, int> skillLevels = const {},
    required EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    required void Function(ProjectileState) onProjectileSpawn,
    required void Function(EffectState) onEffectSpawn,
    required void Function(ProjectileState) onProjectileDespawn,
    required void Function(SummonState) onSummonSpawn,
    required void Function(SkillId) onSkillCast,
    required void Function({required double radius, required double duration})
    onPlayerDeflect,
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
    _debugTarget = null;
    _skillLevels = skillLevels;
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
      final skillLevel = _skillLevelFor(skill.id);
      final cooldown = applySkillLevelCooldown(skill.cooldown, skillLevel);
      skill.cooldownRemaining -= adjustedDt;
      while (skill.cooldownRemaining < 0) {
        onSkillCast(skill.id);
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
              onEffectSpawn: onEffectSpawn,
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
              onEffectSpawn: onEffectSpawn,
              onEnemyDamaged: onEnemyDamaged,
            );
          case SkillId.swordSwing:
            _castSwordSwing(
              playerPosition: playerPosition,
              aimDirection: aimDirection,
              stats: stats,
              enemyPool: enemyPool,
              onEffectSpawn: onEffectSpawn,
            );
          case SkillId.swordDeflect:
            _castSwordDeflect(
              playerPosition: playerPosition,
              aimDirection: aimDirection,
              stats: stats,
              enemyPool: enemyPool,
              enemyGrid: enemyGrid,
              onEffectSpawn: onEffectSpawn,
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
          case SkillId.processionIdol:
            _castProcessionIdol(
              playerPosition: playerPosition,
              stats: stats,
              onSummonSpawn: onSummonSpawn,
            );
          case SkillId.vigilLantern:
            _castVigilLantern(
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
          case SkillId.chairThrow:
            _castChairThrow(
              playerPosition: playerPosition,
              aimDirection: aimDirection,
              stats: stats,
              enemyPool: enemyPool,
              onProjectileSpawn: onProjectileSpawn,
            );
          case SkillId.absolutionSlap:
            _castAbsolutionSlap(
              playerPosition: playerPosition,
              aimDirection: aimDirection,
              stats: stats,
              enemyPool: enemyPool,
              onEffectSpawn: onEffectSpawn,
              onEnemyDamaged: onEnemyDamaged,
            );
        }
        skill.cooldownRemaining += cooldown;
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
    final def = skillDefsById[SkillId.fireball]!;
    final projectileDef = def.projectile!;
    final igniteDef = def.ignite!;
    final skillLevel = _skillLevelFor(SkillId.fireball);
    final knockbackScale = _knockbackScale(stats);
    final direction = _applyAccuracyJitter(
      _resolveAim(
        playerPosition: playerPosition,
        aimDirection: aimDirection,
        enemyPool: enemyPool,
      ),
      stats,
    );
    final baseDamage = applySkillLevelDamage(
      projectileDef.baseDamage,
      skillLevel,
    );
    final damage = _scaledDamageFor(SkillId.fireball, stats, baseDamage);
    final projectileSpeed = applySkillLevelSpeed(
      projectileDef.speed,
      skillLevel,
    );
    final projectileRadius = applySkillLevelSize(
      projectileDef.radius,
      skillLevel,
    );
    final projectileLifespan = applySkillLevelDuration(
      projectileDef.lifespan,
      skillLevel,
    );
    const igniteTags = TagSet(
      elements: {ElementTag.fire},
      effects: {EffectTag.dot},
    );
    final igniteDamagePerSecond = _scaledDamageForTags(
      igniteTags,
      stats,
      applySkillLevelDamage(igniteDef.baseDamagePerSecond, skillLevel),
    ).toDouble();
    final igniteDuration = applySkillLevelDuration(
      igniteDef.duration,
      skillLevel,
    );
    final projectile = _projectilePool.acquire();
    projectile.reset(
      position: playerPosition,
      velocity: direction..scale(projectileSpeed),
      damage: damage,
      radius: GameSizes.projectileRadius(projectileRadius),
      lifespan: projectileLifespan,
      fromEnemy: false,
    );
    if (def.knockbackForce > 0 && def.knockbackDuration > 0) {
      projectile.knockbackForce =
          applySkillLevelKnockback(def.knockbackForce, skillLevel) *
          knockbackScale;
      projectile.knockbackDuration = applySkillLevelDuration(
        def.knockbackDuration,
        skillLevel,
      );
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
    final def = skillDefsById[SkillId.waterjet]!;
    final beamDef = def.beam!;
    final skillLevel = _skillLevelFor(SkillId.waterjet);
    final direction = _resolveAim(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
    );
    final aoeScale = _aoeScale(stats);
    final beamLength = applySkillLevelSize(beamDef.length, skillLevel);
    final beamWidth = applySkillLevelSize(beamDef.width, skillLevel);
    final beamDuration = applySkillLevelDuration(beamDef.duration, skillLevel);
    final damage = _scaledDamageFor(
      SkillId.waterjet,
      stats,
      applySkillLevelDamage(beamDef.baseDamage, skillLevel),
    );
    final effect = _effectPool.acquire();
    effect.reset(
      kind: EffectKind.waterjetBeam,
      shape: EffectShape.beam,
      position: playerPosition,
      direction: direction,
      radius: 0,
      length: beamLength * aoeScale,
      width: beamWidth * aoeScale,
      duration: beamDuration,
      damagePerSecond: damage / beamDuration,
      slowMultiplier: applySkillLevelSlowMultiplier(
        beamDef.slowMultiplier ?? 1,
        skillLevel,
      ),
      slowDuration: applySkillLevelDuration(
        beamDef.slowDuration ?? 0,
        skillLevel,
      ),
      sourceSkillId: SkillId.waterjet,
      followsPlayer: beamDef.followsPlayer,
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
    final def = skillDefsById[SkillId.oilBombs]!;
    final projectileDef = def.projectile!;
    final groundDef = def.ground!;
    final skillLevel = _skillLevelFor(SkillId.oilBombs);
    final knockbackScale = _knockbackScale(stats);
    final direction = _applyAccuracyJitter(
      _resolveAim(
        playerPosition: playerPosition,
        aimDirection: aimDirection,
        enemyPool: enemyPool,
      ),
      stats,
    ).clone();
    final baseDamage = applySkillLevelDamage(
      projectileDef.baseDamage,
      skillLevel,
    );
    final damage = _scaledDamageFor(SkillId.oilBombs, stats, baseDamage);
    final projectileSpeed = applySkillLevelSpeed(
      projectileDef.speed,
      skillLevel,
    );
    final projectileRadius = applySkillLevelSize(
      projectileDef.radius,
      skillLevel,
    );
    final projectileLifespan = applySkillLevelDuration(
      projectileDef.lifespan,
      skillLevel,
    );
    final projectile = _projectilePool.acquire();
    projectile.reset(
      position: playerPosition,
      velocity: direction.clone()..scale(projectileSpeed),
      damage: damage,
      radius: GameSizes.projectileRadius(projectileRadius),
      lifespan: projectileLifespan,
      fromEnemy: false,
    );
    projectile.sourceSkillId = SkillId.oilBombs;
    if (def.knockbackForce > 0 && def.knockbackDuration > 0) {
      projectile.knockbackForce =
          applySkillLevelKnockback(def.knockbackForce, skillLevel) *
          knockbackScale;
      projectile.knockbackDuration = applySkillLevelDuration(
        def.knockbackDuration,
        skillLevel,
      );
    }
    onProjectileSpawn(projectile);

    final aoeScale = _aoeScale(stats);
    final radius = applySkillLevelSize(groundDef.radius, skillLevel) * aoeScale;
    final groundDuration = applySkillLevelDuration(
      groundDef.duration,
      skillLevel,
    );
    final groundDamage =
        _scaledDamageFor(
          SkillId.oilBombs,
          stats,
          applySkillLevelDamage(groundDef.baseDamage, skillLevel),
        ) /
        groundDuration;
    projectile.setImpactEffect(
      kind: EffectKind.oilGround,
      shape: EffectShape.ground,
      direction: direction,
      radius: radius,
      length: 0,
      width: 0,
      duration: groundDuration,
      damagePerSecond: groundDamage,
      slowMultiplier: applySkillLevelSlowMultiplier(
        groundDef.slowMultiplier ?? 1,
        skillLevel,
      ),
      slowDuration: applySkillLevelDuration(
        groundDef.slowDuration ?? 0,
        skillLevel,
      ),
      oilDuration: applySkillLevelDuration(
        groundDef.oilDuration ?? 0,
        skillLevel,
      ),
    );
  }

  void _castChairThrow({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    required void Function(ProjectileState) onProjectileSpawn,
  }) {
    final def = skillDefsById[SkillId.chairThrow]!;
    final projectileDef = def.projectile!;
    final skillLevel = _skillLevelFor(SkillId.chairThrow);
    final knockbackScale = _knockbackScale(stats);
    final direction = _applyAccuracyJitter(
      _resolveAim(
        playerPosition: playerPosition,
        aimDirection: aimDirection,
        enemyPool: enemyPool,
      ),
      stats,
    ).clone();
    final baseDamage = applySkillLevelDamage(
      projectileDef.baseDamage,
      skillLevel,
    );
    final damage = _scaledDamageFor(SkillId.chairThrow, stats, baseDamage);
    final projectileSpeed = applySkillLevelSpeed(
      projectileDef.speed,
      skillLevel,
    );
    final projectileRadius = applySkillLevelSize(
      projectileDef.radius,
      skillLevel,
    );
    final projectileLifespan = applySkillLevelDuration(
      projectileDef.lifespan,
      skillLevel,
    );
    final projectile = _projectilePool.acquire();
    projectile.reset(
      position: playerPosition,
      velocity: direction.clone()..scale(projectileSpeed),
      damage: damage,
      radius: GameSizes.projectileRadius(projectileRadius),
      lifespan: projectileLifespan,
      fromEnemy: false,
    );
    projectile.sourceSkillId = SkillId.chairThrow;
    if (def.knockbackForce > 0 && def.knockbackDuration > 0) {
      projectile.knockbackForce =
          applySkillLevelKnockback(def.knockbackForce, skillLevel) *
          knockbackScale;
      projectile.knockbackDuration = applySkillLevelDuration(
        def.knockbackDuration,
        skillLevel,
      );
    }
    onProjectileSpawn(projectile);
  }

  void _castSwordCut({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    required void Function(EffectState) onEffectSpawn,
  }) {
    final def = skillDefsById[SkillId.swordCut]!;
    final meleeDef = def.melee!;
    final skillLevel = _skillLevelFor(SkillId.swordCut);
    final knockbackScale = _knockbackScale(stats);
    final damage = _scaledDamageFor(
      SkillId.swordCut,
      stats,
      applySkillLevelDamage(meleeDef.baseDamage, skillLevel),
    );
    final meleeRange = applySkillLevelSize(meleeDef.range, skillLevel);
    final meleeArc = applySkillLevelSize(meleeDef.arcDegrees, skillLevel);
    final effectDuration = applySkillLevelDuration(
      meleeDef.effectDuration,
      skillLevel,
    );
    final direction = _resolveAim(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
    );
    _spawnSwordArcEffect(
      playerPosition: playerPosition,
      direction: direction,
      stats: stats,
      baseRange: meleeRange,
      arcDegrees: meleeArc,
      duration: effectDuration,
      sourceSkillId: SkillId.swordCut,
      damagePerSecond: damage / effectDuration,
      sweepArcDegrees: 40,
      knockbackForce:
          applySkillLevelKnockback(def.knockbackForce, skillLevel) *
          knockbackScale,
      knockbackDuration: applySkillLevelDuration(
        def.knockbackDuration,
        skillLevel,
      ),
      onEffectSpawn: onEffectSpawn,
    );
  }

  void _castSwordThrust({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    required void Function(EffectState) onEffectSpawn,
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
    final def = skillDefsById[SkillId.swordThrust]!;
    final meleeDef = def.melee!;
    final skillLevel = _skillLevelFor(SkillId.swordThrust);
    final knockbackScale = _knockbackScale(stats);
    final damage = _scaledDamageFor(
      SkillId.swordThrust,
      stats,
      applySkillLevelDamage(meleeDef.baseDamage, skillLevel),
    );
    final meleeRange = applySkillLevelSize(meleeDef.range, skillLevel);
    final meleeArc = applySkillLevelSize(meleeDef.arcDegrees, skillLevel);
    final effectDuration = applySkillLevelDuration(
      meleeDef.effectDuration,
      skillLevel,
    );
    final direction = _resolveAim(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
    );
    _castMeleeArc(
      playerPosition: playerPosition,
      direction: direction,
      enemyPool: enemyPool,
      enemyGrid: enemyGrid,
      stats: stats,
      baseRange: meleeRange,
      arcDegrees: meleeArc,
      damage: damage,
      knockbackForce:
          applySkillLevelKnockback(def.knockbackForce, skillLevel) *
          knockbackScale,
      knockbackDuration: applySkillLevelDuration(
        def.knockbackDuration,
        skillLevel,
      ),
      sourceSkillId: SkillId.swordThrust,
      onEnemyDamaged: onEnemyDamaged,
    );
    _spawnSwordArcEffect(
      playerPosition: playerPosition,
      direction: direction,
      stats: stats,
      baseRange: meleeRange,
      arcDegrees: meleeArc,
      duration: effectDuration,
      sourceSkillId: SkillId.swordThrust,
      onEffectSpawn: onEffectSpawn,
    );
  }

  void _castSwordSwing({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    required void Function(EffectState) onEffectSpawn,
  }) {
    final def = skillDefsById[SkillId.swordSwing]!;
    final meleeDef = def.melee!;
    final skillLevel = _skillLevelFor(SkillId.swordSwing);
    final knockbackScale = _knockbackScale(stats);
    final damage = _scaledDamageFor(
      SkillId.swordSwing,
      stats,
      applySkillLevelDamage(meleeDef.baseDamage, skillLevel),
    );
    final meleeRange = applySkillLevelSize(meleeDef.range, skillLevel);
    final meleeArc = applySkillLevelSize(meleeDef.arcDegrees, skillLevel);
    final effectDuration = applySkillLevelDuration(
      meleeDef.effectDuration,
      skillLevel,
    );
    final direction = _resolveAim(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
    );
    _spawnSwordArcEffect(
      playerPosition: playerPosition,
      direction: direction,
      stats: stats,
      baseRange: meleeRange,
      arcDegrees: meleeArc,
      duration: effectDuration,
      sourceSkillId: SkillId.swordSwing,
      damagePerSecond: damage / effectDuration,
      sweepArcDegrees: 60,
      knockbackForce:
          applySkillLevelKnockback(def.knockbackForce, skillLevel) *
          knockbackScale,
      knockbackDuration: applySkillLevelDuration(
        def.knockbackDuration,
        skillLevel,
      ),
      onEffectSpawn: onEffectSpawn,
    );
  }

  void _castSwordDeflect({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    SpatialGrid? enemyGrid,
    required void Function(EffectState) onEffectSpawn,
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
    required void Function(ProjectileState) onProjectileDespawn,
    required void Function({required double radius, required double duration})
    onPlayerDeflect,
  }) {
    final def = skillDefsById[SkillId.swordDeflect]!;
    final meleeDef = def.melee!;
    final deflectDef = def.deflect!;
    final skillLevel = _skillLevelFor(SkillId.swordDeflect);
    final knockbackScale = _knockbackScale(stats);
    final damage = _scaledDamageFor(
      SkillId.swordDeflect,
      stats,
      applySkillLevelDamage(meleeDef.baseDamage, skillLevel),
    );
    final meleeRange = applySkillLevelSize(meleeDef.range, skillLevel);
    final meleeArc = applySkillLevelSize(meleeDef.arcDegrees, skillLevel);
    final effectDuration = applySkillLevelDuration(
      meleeDef.effectDuration,
      skillLevel,
    );
    final direction = _resolveAim(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
    );
    _castMeleeArc(
      playerPosition: playerPosition,
      direction: direction,
      enemyPool: enemyPool,
      enemyGrid: enemyGrid,
      stats: stats,
      baseRange: meleeRange,
      arcDegrees: meleeArc,
      damage: damage,
      knockbackForce:
          applySkillLevelKnockback(def.knockbackForce, skillLevel) *
          knockbackScale,
      knockbackDuration: applySkillLevelDuration(
        def.knockbackDuration,
        skillLevel,
      ),
      sourceSkillId: SkillId.swordDeflect,
      onEnemyDamaged: onEnemyDamaged,
    );
    _spawnSwordArcEffect(
      playerPosition: playerPosition,
      direction: direction,
      stats: stats,
      baseRange: meleeRange,
      arcDegrees: meleeArc,
      duration: effectDuration,
      sourceSkillId: SkillId.swordDeflect,
      sweepArcDegrees: 0,
      onEffectSpawn: onEffectSpawn,
    );
    final aoeScale = _aoeScale(stats);
    final deflectRadius =
        applySkillLevelSize(deflectDef.radius, skillLevel) * aoeScale;
    final deflectDuration = applySkillLevelDuration(
      deflectDef.duration,
      skillLevel,
    );
    onPlayerDeflect(radius: deflectRadius, duration: deflectDuration);
    _deflectProjectiles(
      playerPosition: playerPosition,
      radius: deflectRadius,
      onProjectileDespawn: onProjectileDespawn,
    );
  }

  void _castAbsolutionSlap({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required EnemyPool enemyPool,
    required void Function(EffectState) onEffectSpawn,
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
    final def = skillDefsById[SkillId.absolutionSlap]!;
    final meleeDef = def.melee!;
    final skillLevel = _skillLevelFor(SkillId.absolutionSlap);
    final knockbackScale = _knockbackScale(stats);
    final damage = _scaledDamageFor(
      SkillId.absolutionSlap,
      stats,
      applySkillLevelDamage(meleeDef.baseDamage, skillLevel),
    );
    final meleeRange = applySkillLevelSize(meleeDef.range, skillLevel);
    final meleeArc = applySkillLevelSize(meleeDef.arcDegrees, skillLevel);
    final effectDuration = applySkillLevelDuration(
      meleeDef.effectDuration,
      skillLevel,
    );
    final direction = _resolveAim(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
    );
    _spawnSwordArcEffect(
      playerPosition: playerPosition,
      direction: direction,
      stats: stats,
      baseRange: meleeRange,
      arcDegrees: meleeArc,
      duration: effectDuration,
      sourceSkillId: SkillId.absolutionSlap,
      damagePerSecond: damage / effectDuration,
      sweepArcDegrees: 40,
      knockbackForce:
          applySkillLevelKnockback(def.knockbackForce, skillLevel) *
          knockbackScale,
      knockbackDuration: applySkillLevelDuration(
        def.knockbackDuration,
        skillLevel,
      ),
      onEffectSpawn: onEffectSpawn,
    );
  }

  void _castPoisonGas({
    required Vector2 playerPosition,
    required StatSheet stats,
    required void Function(EffectState) onEffectSpawn,
  }) {
    final def = skillDefsById[SkillId.poisonGas]!;
    final groundDef = def.ground!;
    final skillLevel = _skillLevelFor(SkillId.poisonGas);
    final aoeScale = _aoeScale(stats);
    final radius = applySkillLevelSize(groundDef.radius, skillLevel) * aoeScale;
    final groundDuration = applySkillLevelDuration(
      groundDef.duration,
      skillLevel,
    );
    final damage = _scaledDamageFor(
      SkillId.poisonGas,
      stats,
      applySkillLevelDamage(groundDef.baseDamage, skillLevel),
    );
    final effect = _effectPool.acquire();
    effect.reset(
      kind: EffectKind.poisonAura,
      shape: EffectShape.ground,
      position: playerPosition,
      direction: _fallbackDirection,
      radius: radius,
      length: 0,
      width: 0,
      duration: groundDuration,
      damagePerSecond: damage / groundDuration,
      sourceSkillId: SkillId.poisonGas,
      followsPlayer: groundDef.followsPlayer,
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
    final def = skillDefsById[SkillId.roots]!;
    final groundDef = def.ground!;
    final rootDef = def.root!;
    final skillLevel = _skillLevelFor(SkillId.roots);
    final direction = _resolveAim(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
    ).clone();
    final aoeScale = _aoeScale(stats);
    final radius = applySkillLevelSize(groundDef.radius, skillLevel) * aoeScale;
    final baseDuration = applySkillLevelDuration(
      groundDef.duration,
      skillLevel,
    );
    final rootDuration =
        baseDuration *
        math.max(
          rootDef.minDurationScale,
          1 + stats.value(StatId.statusDurationPercent),
        );
    final rootStrength =
        (applySkillLevelSlowStrength(rootDef.baseStrength, skillLevel) +
                stats.value(StatId.statusPotencyPercent))
            .clamp(rootDef.minStrength, rootDef.maxStrength);
    final rootSlowMultiplier = (1 - rootStrength).clamp(
      rootDef.minSlowMultiplier,
      rootDef.maxSlowMultiplier,
    );
    final damage = _scaledDamageFor(
      SkillId.roots,
      stats,
      applySkillLevelDamage(groundDef.baseDamage, skillLevel),
    );
    final castOffset = applySkillLevelSize(
      groundDef.castOffset ?? 0,
      skillLevel,
    );
    final target = Vector2(
      playerPosition.x + direction.x * castOffset,
      playerPosition.y + direction.y * castOffset,
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
      sourceSkillId: SkillId.roots,
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
    final def = skillDefsById[SkillId.windCutter]!;
    final projectileDef = def.projectile!;
    final skillLevel = _skillLevelFor(SkillId.windCutter);
    final knockbackScale = _knockbackScale(stats);
    final direction = _applyAccuracyJitter(
      _resolveAim(
        playerPosition: playerPosition,
        aimDirection: aimDirection,
        enemyPool: enemyPool,
      ),
      stats,
    );
    final damage = _scaledDamageFor(
      SkillId.windCutter,
      stats,
      applySkillLevelDamage(projectileDef.baseDamage, skillLevel),
    );
    final projectileSpeed = applySkillLevelSpeed(
      projectileDef.speed,
      skillLevel,
    );
    final projectileRadius = applySkillLevelSize(
      projectileDef.radius,
      skillLevel,
    );
    final projectileLifespan = applySkillLevelDuration(
      projectileDef.lifespan,
      skillLevel,
    );
    final projectile = _projectilePool.acquire();
    projectile.reset(
      position: playerPosition,
      velocity: direction..scale(projectileSpeed),
      damage: damage,
      radius: GameSizes.projectileRadius(projectileRadius),
      lifespan: projectileLifespan,
      fromEnemy: false,
    );
    projectile.sourceSkillId = SkillId.windCutter;
    if (def.knockbackForce > 0 && def.knockbackDuration > 0) {
      projectile.knockbackForce =
          applySkillLevelKnockback(def.knockbackForce, skillLevel) *
          knockbackScale;
      projectile.knockbackDuration = applySkillLevelDuration(
        def.knockbackDuration,
        skillLevel,
      );
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
    final def = skillDefsById[SkillId.steelShards]!;
    final projectileDef = def.projectile!;
    final skillLevel = _skillLevelFor(SkillId.steelShards);
    final knockbackScale = _knockbackScale(stats);
    final direction = _resolveAim(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
    );
    final damage = _scaledDamageFor(
      SkillId.steelShards,
      stats,
      applySkillLevelDamage(projectileDef.baseDamage, skillLevel),
    );
    final projectileSpeed = applySkillLevelSpeed(
      projectileDef.speed,
      skillLevel,
    );
    final projectileRadius = applySkillLevelSize(
      projectileDef.radius,
      skillLevel,
    );
    final projectileLifespan = applySkillLevelDuration(
      projectileDef.lifespan,
      skillLevel,
    );
    final spread = projectileDef.spreadAngles;
    final spreadScale = _spreadScale(stats);
    for (final angle in spread) {
      final projectile = _projectilePool.acquire();
      final velocity = direction.clone()
        ..rotate(angle * spreadScale)
        ..scale(projectileSpeed);
      projectile.reset(
        position: playerPosition,
        velocity: velocity,
        damage: damage,
        radius: GameSizes.projectileRadius(projectileRadius),
        lifespan: projectileLifespan,
        fromEnemy: false,
      );
      projectile.sourceSkillId = SkillId.steelShards;
      if (def.knockbackForce > 0 && def.knockbackDuration > 0) {
        projectile.knockbackForce =
            applySkillLevelKnockback(def.knockbackForce, skillLevel) *
            knockbackScale;
        projectile.knockbackDuration = applySkillLevelDuration(
          def.knockbackDuration,
          skillLevel,
        );
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
    final def = skillDefsById[SkillId.flameWave]!;
    final beamDef = def.beam!;
    final skillLevel = _skillLevelFor(SkillId.flameWave);
    final direction = _resolveAim(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
    );
    final aoeScale = _aoeScale(stats);
    final beamLength = applySkillLevelSize(beamDef.length, skillLevel);
    final beamWidth = applySkillLevelSize(beamDef.width, skillLevel);
    final beamDuration = applySkillLevelDuration(beamDef.duration, skillLevel);
    final damage = _scaledDamageFor(
      SkillId.flameWave,
      stats,
      applySkillLevelDamage(beamDef.baseDamage, skillLevel),
    );
    final effect = _effectPool.acquire();
    effect.reset(
      kind: EffectKind.flameWave,
      shape: EffectShape.beam,
      position: playerPosition,
      direction: direction,
      radius: 0,
      length: beamLength * aoeScale,
      width: beamWidth * aoeScale,
      duration: beamDuration,
      damagePerSecond: damage / beamDuration,
      sourceSkillId: SkillId.flameWave,
    );
    onEffectSpawn(effect);
  }

  void _castFrostNova({
    required Vector2 playerPosition,
    required StatSheet stats,
    required void Function(EffectState) onEffectSpawn,
  }) {
    final def = skillDefsById[SkillId.frostNova]!;
    final groundDef = def.ground!;
    final skillLevel = _skillLevelFor(SkillId.frostNova);
    final aoeScale = _aoeScale(stats);
    final damage = _scaledDamageFor(
      SkillId.frostNova,
      stats,
      applySkillLevelDamage(groundDef.baseDamage, skillLevel),
    );
    final radius = applySkillLevelSize(groundDef.radius, skillLevel) * aoeScale;
    final groundDuration = applySkillLevelDuration(
      groundDef.duration,
      skillLevel,
    );
    final effect = _effectPool.acquire();
    effect.reset(
      kind: EffectKind.frostNova,
      shape: EffectShape.ground,
      position: playerPosition,
      direction: _fallbackDirection,
      radius: radius,
      length: 0,
      width: 0,
      duration: groundDuration,
      damagePerSecond: damage / groundDuration,
      slowMultiplier: applySkillLevelSlowMultiplier(
        groundDef.slowMultiplier ?? 1,
        skillLevel,
      ),
      slowDuration: applySkillLevelDuration(
        groundDef.slowDuration ?? 0,
        skillLevel,
      ),
      sourceSkillId: SkillId.frostNova,
      followsPlayer: groundDef.followsPlayer,
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
    final def = skillDefsById[SkillId.earthSpikes]!;
    final groundDef = def.ground!;
    final skillLevel = _skillLevelFor(SkillId.earthSpikes);
    final direction = _resolveAim(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: enemyPool,
    );
    final aoeScale = _aoeScale(stats);
    final damage = _scaledDamageFor(
      SkillId.earthSpikes,
      stats,
      applySkillLevelDamage(groundDef.baseDamage, skillLevel),
    );
    final radius = applySkillLevelSize(groundDef.radius, skillLevel) * aoeScale;
    final groundDuration = applySkillLevelDuration(
      groundDef.duration,
      skillLevel,
    );
    final castOffset = applySkillLevelSize(
      groundDef.castOffset ?? 0,
      skillLevel,
    );
    final target = Vector2(
      playerPosition.x + direction.x * castOffset,
      playerPosition.y + direction.y * castOffset,
    );
    final effect = _effectPool.acquire();
    effect.reset(
      kind: EffectKind.earthSpikes,
      shape: EffectShape.ground,
      position: target,
      direction: direction,
      radius: radius,
      length: 0,
      width: 0,
      duration: groundDuration,
      damagePerSecond: damage / groundDuration,
      sourceSkillId: SkillId.earthSpikes,
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
    final def = skillDefsById[SkillId.sporeBurst]!;
    final projectileDef = def.projectile!;
    final groundDef = def.ground!;
    final skillLevel = _skillLevelFor(SkillId.sporeBurst);
    final direction = _applyAccuracyJitter(
      _resolveAim(
        playerPosition: playerPosition,
        aimDirection: aimDirection,
        enemyPool: enemyPool,
      ),
      stats,
    ).clone();
    final damage = _scaledDamageFor(
      SkillId.sporeBurst,
      stats,
      applySkillLevelDamage(projectileDef.baseDamage, skillLevel),
    );
    final projectileSpeed = applySkillLevelSpeed(
      projectileDef.speed,
      skillLevel,
    );
    final projectileRadius = applySkillLevelSize(
      projectileDef.radius,
      skillLevel,
    );
    final projectileLifespan = applySkillLevelDuration(
      projectileDef.lifespan,
      skillLevel,
    );
    final projectile = _projectilePool.acquire();
    projectile.reset(
      position: playerPosition,
      velocity: direction.clone()..scale(projectileSpeed),
      damage: damage,
      radius: GameSizes.projectileRadius(projectileRadius),
      lifespan: projectileLifespan,
      fromEnemy: false,
    );
    projectile.sourceSkillId = SkillId.sporeBurst;
    onProjectileSpawn(projectile);

    final aoeScale = _aoeScale(stats);
    final radius = applySkillLevelSize(groundDef.radius, skillLevel) * aoeScale;
    final groundDuration = applySkillLevelDuration(
      groundDef.duration,
      skillLevel,
    );
    final cloudDamage =
        _scaledDamageFor(
          SkillId.sporeBurst,
          stats,
          applySkillLevelDamage(groundDef.baseDamage, skillLevel),
        ) /
        groundDuration;
    projectile.setImpactEffect(
      kind: EffectKind.sporeCloud,
      shape: EffectShape.ground,
      direction: direction,
      radius: radius,
      length: 0,
      width: 0,
      duration: groundDuration,
      damagePerSecond: cloudDamage,
      slowMultiplier: applySkillLevelSlowMultiplier(
        groundDef.slowMultiplier ?? 1,
        skillLevel,
      ),
      slowDuration: applySkillLevelDuration(
        groundDef.slowDuration ?? 0,
        skillLevel,
      ),
    );
  }

  void _castProcessionIdol({
    required Vector2 playerPosition,
    required StatSheet stats,
    required void Function(SummonState) onSummonSpawn,
  }) {
    final def = skillDefsById[SkillId.processionIdol]!;
    final summonDef = def.summon!;
    final skillLevel = _skillLevelFor(SkillId.processionIdol);
    final summon = _summonPool.acquire();
    final damage = _scaledDamageFor(
      SkillId.processionIdol,
      stats,
      applySkillLevelDamage(summonDef.damagePerSecond ?? 0, skillLevel),
    );
    final radius = applySkillLevelSize(summonDef.radius, skillLevel);
    final orbitRadius = applySkillLevelSize(summonDef.orbitRadius, skillLevel);
    final orbitSpeed = applySkillLevelSpeed(summonDef.orbitSpeed, skillLevel);
    final moveSpeed = applySkillLevelSpeed(
      summonDef.moveSpeed ?? 0,
      skillLevel,
    );
    final range = applySkillLevelSize(summonDef.range ?? 0, skillLevel);
    final lifespan = applySkillLevelDuration(summonDef.lifespan, skillLevel);
    _orbitSeed += summonDef.orbitSeedOffset;
    summon.reset(
      kind: SummonKind.processionIdol,
      sourceSkillId: SkillId.processionIdol,
      position: playerPosition,
      radius: radius,
      orbitAngle: _orbitSeed,
      orbitRadius: orbitRadius,
      orbitSpeed: orbitSpeed,
      moveSpeed: moveSpeed,
      damagePerSecond: damage,
      range: range,
      lifespan: lifespan,
    );
    onSummonSpawn(summon);
  }

  void _castVigilLantern({
    required Vector2 playerPosition,
    required StatSheet stats,
    required void Function(SummonState) onSummonSpawn,
  }) {
    final def = skillDefsById[SkillId.vigilLantern]!;
    final summonDef = def.summon!;
    final skillLevel = _skillLevelFor(SkillId.vigilLantern);
    final summon = _summonPool.acquire();
    final damage = _scaledDamageFor(
      SkillId.vigilLantern,
      stats,
      applySkillLevelDamage(summonDef.projectileDamage ?? 0, skillLevel),
    );
    final radius = applySkillLevelSize(summonDef.radius, skillLevel);
    final orbitRadius = applySkillLevelSize(summonDef.orbitRadius, skillLevel);
    final orbitSpeed = applySkillLevelSpeed(summonDef.orbitSpeed, skillLevel);
    final projectileSpeed = applySkillLevelSpeed(
      summonDef.projectileSpeed ?? 0,
      skillLevel,
    );
    final projectileRadius = applySkillLevelSize(
      summonDef.projectileRadius ?? 0,
      skillLevel,
    );
    final range = applySkillLevelSize(summonDef.range ?? 0, skillLevel);
    final lifespan = applySkillLevelDuration(summonDef.lifespan, skillLevel);
    final attackCooldown = applySkillLevelCooldown(
      summonDef.attackCooldown ?? 0,
      skillLevel,
    );
    _orbitSeed += summonDef.orbitSeedOffset;
    summon.reset(
      kind: SummonKind.vigilLantern,
      sourceSkillId: SkillId.vigilLantern,
      position: playerPosition,
      radius: radius,
      orbitAngle: _orbitSeed,
      orbitRadius: orbitRadius,
      orbitSpeed: orbitSpeed,
      projectileDamage: damage,
      projectileSpeed: projectileSpeed,
      projectileRadius: GameSizes.projectileRadius(projectileRadius),
      range: range,
      lifespan: lifespan,
      attackCooldown: attackCooldown / _attackSpeedScale(stats),
    );
    onSummonSpawn(summon);
  }

  void _castGuardianOrbs({
    required Vector2 playerPosition,
    required StatSheet stats,
    required void Function(SummonState) onSummonSpawn,
  }) {
    final def = skillDefsById[SkillId.guardianOrbs]!;
    final summonDef = def.summon!;
    final skillLevel = _skillLevelFor(SkillId.guardianOrbs);
    final damage = _scaledDamageFor(
      SkillId.guardianOrbs,
      stats,
      applySkillLevelDamage(summonDef.damagePerSecond ?? 0, skillLevel),
    );
    final radius = applySkillLevelSize(summonDef.radius, skillLevel);
    final orbitRadius = applySkillLevelSize(summonDef.orbitRadius, skillLevel);
    final orbitSpeed = applySkillLevelSpeed(summonDef.orbitSpeed, skillLevel);
    final lifespan = applySkillLevelDuration(summonDef.lifespan, skillLevel);
    for (var index = 0; index < summonDef.count; index++) {
      final summon = _summonPool.acquire();
      _orbitSeed += summonDef.orbitSeedOffset;
      summon.reset(
        kind: SummonKind.guardianOrb,
        sourceSkillId: SkillId.guardianOrbs,
        position: playerPosition,
        radius: radius,
        orbitAngle: _orbitSeed,
        orbitRadius: orbitRadius,
        orbitSpeed: orbitSpeed,
        damagePerSecond: damage,
        lifespan: lifespan,
      );
      onSummonSpawn(summon);
    }
  }

  void _castMenderOrb({
    required Vector2 playerPosition,
    required StatSheet stats,
    required void Function(SummonState) onSummonSpawn,
  }) {
    final def = skillDefsById[SkillId.menderOrb]!;
    final summonDef = def.summon!;
    final skillLevel = _skillLevelFor(SkillId.menderOrb);
    final summon = _summonPool.acquire();
    _orbitSeed += summonDef.orbitSeedOffset;
    final damage = _scaledDamageFor(
      SkillId.menderOrb,
      stats,
      applySkillLevelDamage(summonDef.damagePerSecond ?? 0, skillLevel),
    );
    final radius = applySkillLevelSize(summonDef.radius, skillLevel);
    final orbitRadius = applySkillLevelSize(summonDef.orbitRadius, skillLevel);
    final orbitSpeed = applySkillLevelSpeed(summonDef.orbitSpeed, skillLevel);
    final lifespan = applySkillLevelDuration(summonDef.lifespan, skillLevel);
    final healingPerSecond = applySkillLevelDamage(
      summonDef.healingPerSecond ?? 0,
      skillLevel,
    );
    summon.reset(
      kind: SummonKind.menderOrb,
      sourceSkillId: SkillId.menderOrb,
      position: playerPosition,
      radius: radius,
      orbitAngle: _orbitSeed,
      orbitRadius: orbitRadius,
      orbitSpeed: orbitSpeed,
      damagePerSecond: damage,
      healingPerSecond: healingPerSecond * _supportMultiplier(stats),
      lifespan: lifespan,
    );
    onSummonSpawn(summon);
  }

  void _castMineLayer({
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required void Function(SummonState) onSummonSpawn,
  }) {
    final def = skillDefsById[SkillId.mineLayer]!;
    final mineDef = def.mine!;
    final skillLevel = _skillLevelFor(SkillId.mineLayer);
    final direction = _resolveAim(
      playerPosition: playerPosition,
      aimDirection: aimDirection,
      enemyPool: null,
    );
    final spawnOffset = applySkillLevelSize(mineDef.spawnOffset, skillLevel);
    _spawnOffset
      ..setFrom(direction)
      ..scale(spawnOffset);
    final summon = _summonPool.acquire();
    summon.reset(
      kind: SummonKind.mine,
      sourceSkillId: SkillId.mineLayer,
      position: playerPosition + _spawnOffset,
      radius: applySkillLevelSize(mineDef.radius, skillLevel),
      lifespan: applySkillLevelDuration(mineDef.lifespan, skillLevel),
      triggerRadius: applySkillLevelSize(mineDef.triggerRadius, skillLevel),
      blastRadius: applySkillLevelSize(mineDef.blastRadius, skillLevel),
      blastDamage: _scaledDamageFor(
        SkillId.mineLayer,
        stats,
        applySkillLevelDamage(mineDef.baseDamage, skillLevel),
      ),
      armDuration: applySkillLevelDuration(mineDef.armDuration, skillLevel),
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
      case SkillId.vigilLantern:
        _castVigilLantern(
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
      case SkillId.processionIdol:
      case SkillId.menderOrb:
      case SkillId.mineLayer:
      case SkillId.chairThrow:
      case SkillId.absolutionSlap:
        break;
    }
  }

  void _castMeleeArc({
    required Vector2 playerPosition,
    required Vector2 direction,
    required EnemyPool enemyPool,
    required SpatialGrid? enemyGrid,
    required StatSheet stats,
    required double baseRange,
    required double arcDegrees,
    required double damage,
    required double knockbackForce,
    required double knockbackDuration,
    required SkillId sourceSkillId,
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
    final arcCosine = math.cos((arcDegrees * 0.5) * (math.pi / 180));
    final aoeScale = _aoeScale(stats);
    final range = baseRange * aoeScale;

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
        sourceSkillId: sourceSkillId,
        knockbackX: dx,
        knockbackY: dy,
        knockbackForce: knockbackForce,
        knockbackDuration: knockbackDuration,
      );
    }
  }

  void _spawnSwordArcEffect({
    required Vector2 playerPosition,
    required Vector2 direction,
    required StatSheet stats,
    required double baseRange,
    required double arcDegrees,
    required double duration,
    required SkillId sourceSkillId,
    double sweepArcDegrees = 0,
    double damagePerSecond = 0,
    double knockbackForce = 0,
    double knockbackDuration = 0,
    required void Function(EffectState) onEffectSpawn,
  }) {
    final range = baseRange * _aoeScale(stats);
    final effect = _effectPool.acquire();
    effect.reset(
      kind: EffectKind.swordSlash,
      shape: EffectShape.arc,
      position: playerPosition,
      direction: direction,
      radius: range,
      length: 0,
      width: 0,
      arcDegrees: arcDegrees,
      sweepArcDegrees: sweepArcDegrees,
      sweepStartAngle: sweepArcDegrees > 0 ? -sweepArcDegrees * 0.5 : 0,
      sweepEndAngle: sweepArcDegrees > 0 ? sweepArcDegrees * 0.5 : 0,
      duration: duration,
      damagePerSecond: damagePerSecond,
      knockbackForce: knockbackForce,
      knockbackDuration: knockbackDuration,
      sourceSkillId: sourceSkillId,
    );
    onEffectSpawn(effect);
  }

  void _deflectProjectiles({
    required Vector2 playerPosition,
    required double radius,
    required void Function(ProjectileState) onProjectileDespawn,
  }) {
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
    EnemyState? closestEnemy;
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
          closestEnemy = enemy;
        }
      }
    }
    if (debugHighlightTarget) {
      _debugTarget = closestEnemy;
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
    return math.max(0.1, 1 + attackSpeed);
  }

  double _attackSpeedScale(StatSheet stats) {
    final attackSpeed = stats.value(StatId.attackSpeed);
    return math.max(0.1, 1 + attackSpeed);
  }

  double _supportMultiplier(StatSheet stats) {
    return math.max(0.1, 1 + stats.value(StatId.healingReceivedPercent));
  }

  double _aoeScale(StatSheet stats) {
    return math.max(0.25, 1 + stats.value(StatId.aoeSize));
  }

  TagSet _tagsForSkill(SkillId id) {
    return skillDefsById[id]?.tags ?? const TagSet();
  }

  int _skillLevelFor(SkillId id) {
    return _skillLevels[id] ?? 1;
  }

  double _scaledDamageFor(SkillId id, StatSheet stats, double baseDamage) {
    return _scaledDamageForTags(_tagsForSkill(id), stats, baseDamage);
  }

  double _scaledDamageForTags(TagSet tags, StatSheet stats, double baseDamage) {
    final multiplier = _damageMultiplierForTags(tags, stats);
    final flat = _flatDamageForTags(tags, stats);
    return math.max(0, baseDamage * multiplier + flat);
  }

  double _damageMultiplierForTags(TagSet tags, StatSheet stats) {
    var multiplier = 1 + stats.value(StatId.damagePercent);
    if (tags.hasEffect(EffectTag.dot)) {
      multiplier += stats.value(StatId.dotDamagePercent);
    }

    if (tags.hasDelivery(DeliveryTag.projectile)) {
      multiplier += stats.value(StatId.projectileDamagePercent);
    }
    if (tags.hasDelivery(DeliveryTag.melee)) {
      multiplier += stats.value(StatId.meleeDamagePercent);
    }
    if (tags.hasDelivery(DeliveryTag.beam)) {
      multiplier += stats.value(StatId.beamDamagePercent);
    }
    if (tags.hasDelivery(DeliveryTag.aura)) {
      multiplier += stats.value(StatId.auraDamagePercent);
    }
    if (tags.hasDelivery(DeliveryTag.ground)) {
      multiplier += stats.value(StatId.groundDamagePercent);
      multiplier += stats.value(StatId.explosionDamagePercent);
    }

    if (tags.elements.isNotEmpty) {
      multiplier += stats.value(StatId.elementalDamagePercent);
    }
    if (tags.hasElement(ElementTag.fire)) {
      multiplier += stats.value(StatId.fireDamagePercent);
    }
    if (tags.hasElement(ElementTag.water)) {
      multiplier += stats.value(StatId.waterDamagePercent);
    }
    if (tags.hasElement(ElementTag.earth)) {
      multiplier += stats.value(StatId.earthDamagePercent);
    }
    if (tags.hasElement(ElementTag.wind)) {
      multiplier += stats.value(StatId.windDamagePercent);
    }
    if (tags.hasElement(ElementTag.poison)) {
      multiplier += stats.value(StatId.poisonDamagePercent);
    }
    if (tags.hasElement(ElementTag.steel)) {
      multiplier += stats.value(StatId.steelDamagePercent);
    }
    if (tags.hasElement(ElementTag.wood)) {
      multiplier += stats.value(StatId.woodDamagePercent);
    }

    return math.max(0.1, multiplier);
  }

  double _flatDamageForTags(TagSet tags, StatSheet stats) {
    var flat = stats.value(StatId.flatDamage);
    if (tags.elements.isNotEmpty) {
      flat += stats.value(StatId.flatElementalDamage);
    }
    return flat;
  }

  double _knockbackScale(StatSheet stats) {
    return math.max(0.1, 1 + stats.value(StatId.banishmentForce));
  }

  double _spreadScale(StatSheet stats) {
    final accuracy = stats.value(StatId.accuracy);
    return (1 - accuracy).clamp(0.0, 2.5).toDouble();
  }

  Vector2 _applyAccuracyJitter(Vector2 direction, StatSheet stats) {
    const baseJitter = 0.05;
    final spreadScale = _spreadScale(stats);
    final jitter = baseJitter * spreadScale;
    if (jitter <= 0.0001) {
      return direction;
    }
    final angle = (_random.nextDouble() * 2 - 1) * jitter;
    direction.rotate(angle);
    return direction;
  }
}

class SkillSlot {
  SkillSlot({required this.id, required this.cooldown})
    : cooldownRemaining = cooldown;

  final SkillId id;
  final double cooldown;
  double cooldownRemaining;
}
