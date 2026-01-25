import '../data/ids.dart';
import '../data/skill_defs.dart';
import '../data/stat_defs.dart';
import '../data/synergy_defs.dart';
import '../data/tags.dart';
import 'enemy_state.dart';
import 'stat_sheet.dart';

class SynergySystem {
  void apply({
    required EnemyState enemy,
    required SkillId sourceSkillId,
    required StatSheet stats,
    void Function(SynergyDef, EnemyState)? onSynergyTriggered,
  }) {
    final tags = skillDefsById[sourceSkillId]?.tags;
    if (tags == null || tags.isEmpty) {
      return;
    }
    for (final synergy in synergyDefs) {
      if (!synergy.matchesTags(tags)) {
        continue;
      }
      if (!_enemyMeetsStatusRequirements(enemy, synergy)) {
        continue;
      }
      if (!_applySynergyEffect(
        synergy: synergy,
        enemy: enemy,
        sourceSkillId: sourceSkillId,
        stats: stats,
      )) {
        continue;
      }
      if (synergy.consumeStatusEffects.isNotEmpty) {
        enemy.clearStatusEffects(synergy.consumeStatusEffects);
      }
      onSynergyTriggered?.call(synergy, enemy);
    }
  }

  bool _enemyMeetsStatusRequirements(EnemyState enemy, SynergyDef synergy) {
    for (final status in synergy.requiredStatusEffects) {
      if (!enemy.hasStatusEffect(status)) {
        return false;
      }
    }
    return true;
  }

  bool _applySynergyEffect({
    required SynergyDef synergy,
    required EnemyState enemy,
    required SkillId sourceSkillId,
    required StatSheet stats,
  }) {
    switch (synergy.resultStatusEffect) {
      case StatusEffectId.ignite:
        final duration = synergy.igniteDuration ?? 0;
        final damagePerSecond = synergy.igniteDamagePerSecond ?? 0;
        if (duration <= 0 || damagePerSecond <= 0) {
          return false;
        }
        const igniteTags = TagSet(
          elements: {ElementTag.fire},
          effects: {EffectTag.dot},
        );
        final scaledDamage = _scaledDamageForTags(
          igniteTags,
          stats,
          damagePerSecond,
        );
        enemy.applyIgnite(
          duration: duration,
          damagePerSecond: scaledDamage,
          sourceSkillId: sourceSkillId,
        );
        return true;
      case StatusEffectId.slow:
        final duration = synergy.slowDuration ?? 0;
        final multiplier = synergy.slowMultiplier ?? 1;
        if (duration <= 0 || multiplier >= 1) {
          return false;
        }
        enemy.applySlow(duration: duration, multiplier: multiplier);
        return true;
      case StatusEffectId.root:
        final duration = synergy.rootDuration ?? 0;
        final strength = synergy.rootStrength ?? 0;
        if (duration <= 0 || strength <= 0) {
          return false;
        }
        enemy.applyRoot(duration: duration, strength: strength);
        return true;
      case StatusEffectId.oilSoaked:
        final duration = synergy.oilDuration ?? 0;
        if (duration <= 0) {
          return false;
        }
        enemy.applyOil(duration: duration);
        return true;
      case StatusEffectId.vulnerable:
        final duration = synergy.vulnerableDuration ?? 0;
        final multiplier = synergy.vulnerableMultiplier ?? 1;
        if (duration <= 0 || multiplier <= 1) {
          return false;
        }
        enemy.applyVulnerable(duration: duration, multiplier: multiplier);
        return true;
    }
  }

  double _scaledDamageForTags(TagSet tags, StatSheet stats, double baseDamage) {
    final multiplier = _damageMultiplierForTags(tags, stats);
    final flat = _flatDamageForTags(tags, stats);
    return (baseDamage * multiplier + flat).clamp(0.0, double.infinity);
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

    return multiplier.clamp(0.1, double.infinity);
  }

  double _flatDamageForTags(TagSet tags, StatSheet stats) {
    var flat = stats.value(StatId.flatDamage);
    if (tags.elements.isNotEmpty) {
      flat += stats.value(StatId.flatElementalDamage);
    }
    return flat;
  }
}
