import 'dart:math' as math;

import 'package:flame/extensions.dart';

import '../data/active_skill_defs.dart';
import '../data/ids.dart';
import '../data/stat_defs.dart';
import '../data/tags.dart';
import 'effect_pool.dart';
import 'effect_state.dart';
import 'player_state.dart';
import 'stat_sheet.dart';

class ActiveSkillSystem {
  ActiveSkillSystem({required EffectPool effectPool})
    : _effectPool = effectPool;

  final EffectPool _effectPool;
  ActiveSkillId? _activeSkillId;
  double _cooldownRemaining = 0;
  final Vector2 _aimBuffer = Vector2.zero();
  final Vector2 _fallbackDirection = Vector2(1, 0);

  ActiveSkillId? get activeSkillId => _activeSkillId;
  double get cooldownRemaining => _cooldownRemaining;
  ActiveSkillDef? get activeSkillDef =>
      _activeSkillId != null ? activeSkillDefsById[_activeSkillId] : null;

  void reset() {
    _activeSkillId = null;
    _cooldownRemaining = 0;
  }

  void setActiveSkill(ActiveSkillId? id) {
    _activeSkillId = id;
    _cooldownRemaining = 0;
  }

  void update(double dt, StatSheet stats) {
    if (_activeSkillId == null) {
      return;
    }
    final cooldownSpeed = _cooldownSpeed(stats);
    _cooldownRemaining = math.max(0, _cooldownRemaining - dt * cooldownSpeed);
  }

  bool canCast(PlayerState playerState) {
    final def = activeSkillDef;
    if (def == null) {
      return false;
    }
    return _cooldownRemaining <= 0 && playerState.mana >= def.manaCost;
  }

  bool tryCast({
    required PlayerState playerState,
    required Vector2 playerPosition,
    required Vector2 aimDirection,
    required StatSheet stats,
    required void Function(EffectState) onEffectSpawn,
  }) {
    final def = activeSkillDef;
    if (def == null || _cooldownRemaining > 0) {
      return false;
    }
    if (!playerState.trySpendMana(def.manaCost)) {
      return false;
    }
    _cooldownRemaining = def.cooldown;
    final direction = _resolveAimDirection(aimDirection, playerState);
    _spawnEffect(
      def: def,
      playerPosition: playerPosition,
      direction: direction,
      stats: stats,
      onEffectSpawn: onEffectSpawn,
    );
    return true;
  }

  Vector2 _resolveAimDirection(Vector2 aimDirection, PlayerState playerState) {
    if (aimDirection.length2 > 0) {
      _aimBuffer.setFrom(aimDirection);
    } else if (playerState.lastMovementDirection.length2 > 0) {
      _aimBuffer.setFrom(playerState.lastMovementDirection);
    } else {
      _aimBuffer.setFrom(_fallbackDirection);
    }
    _aimBuffer.normalize();
    return _aimBuffer;
  }

  void _spawnEffect({
    required ActiveSkillDef def,
    required Vector2 playerPosition,
    required Vector2 direction,
    required StatSheet stats,
    required void Function(EffectState) onEffectSpawn,
  }) {
    final params = def.effect;
    final aoeScale = _aoeScale(stats);
    final damage = _scaledDamageForTags(def.tags, stats, params.baseDamage);
    final effect = _effectPool.acquire();
    effect.reset(
      kind: _effectKindFor(params.kind),
      shape: _effectShapeFor(params.shape),
      position: playerPosition,
      direction: direction,
      radius: params.radius * aoeScale,
      length: params.length * aoeScale,
      width: params.width * aoeScale,
      arcDegrees: params.arcDegrees,
      duration: params.duration,
      damagePerSecond: damage,
      slowMultiplier: params.slowMultiplier,
      slowDuration: params.slowDuration,
      knockbackForce: params.knockbackForce * _knockbackScale(stats),
      knockbackDuration: params.knockbackDuration,
      followsPlayer: params.followsPlayer,
    );
    onEffectSpawn(effect);
  }

  EffectKind _effectKindFor(ActiveSkillEffectKind kind) {
    switch (kind) {
      case ActiveSkillEffectKind.censureBeam:
        return EffectKind.censureBeam;
      case ActiveSkillEffectKind.bastionRing:
        return EffectKind.bastionRing;
      case ActiveSkillEffectKind.soupSplash:
        return EffectKind.soupSplash;
    }
  }

  EffectShape _effectShapeFor(ActiveSkillEffectShape shape) {
    switch (shape) {
      case ActiveSkillEffectShape.beam:
        return EffectShape.beam;
      case ActiveSkillEffectShape.ground:
        return EffectShape.ground;
      case ActiveSkillEffectShape.arc:
        return EffectShape.arc;
    }
  }

  double _cooldownSpeed(StatSheet stats) {
    final attackSpeed = stats.value(StatId.attackSpeed);
    return math.max(0.1, 1 + attackSpeed);
  }

  double _aoeScale(StatSheet stats) {
    return math.max(0.25, 1 + stats.value(StatId.aoeSize));
  }

  double _knockbackScale(StatSheet stats) {
    return math.max(0.1, 1 + stats.value(StatId.banishmentForce));
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
}
