import 'dart:math' as math;

import 'package:hordesurivor/data/data.dart';

class SkillDetailDisplayLine {
  const SkillDetailDisplayLine({
    required this.label,
    required this.baseValue,
    this.actualValue,
    this.isBetter = true,
  });

  final String label;
  final String baseValue;
  final String? actualValue;
  final bool isBetter;

  bool get hasChange => actualValue != null && actualValue != baseValue;
}

List<SkillDetailLine> skillDetailLinesFor(SkillId id) {
  return skillDefsById[id]?.displayDetails ?? const [];
}

List<String> skillDetailTextLinesFor(SkillId id) {
  return skillDetailLinesFor(
    id,
  ).map((detail) => detail.format()).toList(growable: false);
}

List<SkillDetailDisplayLine> skillDetailDisplayLinesFor(
  SkillId id,
  Map<StatId, double> statValues,
) {
  final def = skillDefsById[id];
  if (def == null) {
    return const [];
  }
  final tags = def.tags;
  return [
    for (final detail in def.displayDetails)
      _detailLineFor(detail, id, tags, statValues),
  ];
}

String skillDetailBlockFor(SkillId id) {
  final lines = skillDetailLinesFor(id);
  if (lines.isEmpty) {
    return '';
  }
  return lines.map((detail) => '• ${detail.format()}').join('\n');
}

SkillDetailDisplayLine _detailLineFor(
  SkillDetailLine detail,
  SkillId skillId,
  TagSet tags,
  Map<StatId, double> statValues,
) {
  final type = detail.detailType;
  final primary = detail.primaryValue;
  final secondary = detail.secondaryValue;
  if (type == null || primary == null) {
    return SkillDetailDisplayLine(label: detail.label, baseValue: detail.value);
  }

  var actualPrimary = primary;
  var actualSecondary = secondary;
  var isBetter = true;
  switch (type) {
    case SkillDetailValueType.cooldown:
      actualPrimary = primary / _cooldownSpeed(statValues);
      isBetter = actualPrimary < primary;
      break;
    case SkillDetailValueType.attackCooldown:
      actualPrimary = primary / _attackSpeedScale(statValues);
      isBetter = actualPrimary < primary;
      break;
    case SkillDetailValueType.damage:
    case SkillDetailValueType.damagePerSecond:
      actualPrimary = _scaledDamageForTags(tags, statValues, primary);
      isBetter = actualPrimary > primary;
      break;
    case SkillDetailValueType.damageOverTime:
      actualPrimary = _scaledDamageForTags(tags, statValues, primary);
      isBetter = actualPrimary > primary;
      break;
    case SkillDetailValueType.healingPerSecond:
      actualPrimary = primary * _supportMultiplier(statValues);
      isBetter = actualPrimary > primary;
      break;
    case SkillDetailValueType.beamLength:
    case SkillDetailValueType.beamWidth:
    case SkillDetailValueType.groundRadius:
    case SkillDetailValueType.deflectRadius:
      actualPrimary = primary * _aoeScale(statValues);
      isBetter = actualPrimary > primary;
      break;
    case SkillDetailValueType.range:
      if (detail.scalesWithAoe) {
        actualPrimary = primary * _aoeScale(statValues);
        isBetter = actualPrimary > primary;
      }
      break;
    case SkillDetailValueType.knockback:
      actualPrimary = primary * _knockbackScale(statValues);
      isBetter = actualPrimary > primary;
      break;
    case SkillDetailValueType.ignite:
      actualPrimary = _scaledDamageForTags(_igniteTags, statValues, primary);
      isBetter = actualPrimary > primary;
      break;
    case SkillDetailValueType.slow:
      if (skillId == SkillId.roots) {
        final rootDef = skillDefsById[skillId]?.root;
        if (rootDef != null) {
          final durationScale = math.max(
            rootDef.minDurationScale,
            1 + _stat(statValues, StatId.statusDurationPercent),
          );
          actualSecondary = (secondary ?? 0) * durationScale;
          final strength =
              (rootDef.baseStrength +
                      _stat(statValues, StatId.statusPotencyPercent))
                  .clamp(rootDef.minStrength, rootDef.maxStrength);
          final multiplier = (1 - strength).clamp(
            rootDef.minSlowMultiplier,
            rootDef.maxSlowMultiplier,
          );
          actualPrimary = multiplier;
          final baseSlow = (1 - primary).clamp(0.0, 1.0);
          final actualSlow = (1 - actualPrimary).clamp(0.0, 1.0);
          if ((actualSlow - baseSlow).abs() > _epsilon) {
            isBetter = actualSlow > baseSlow;
          } else if (secondary != null) {
            isBetter = actualSecondary > secondary;
          }
        }
      }
      break;
    case SkillDetailValueType.projectileSpeed:
    case SkillDetailValueType.projectileRadius:
    case SkillDetailValueType.arc:
    case SkillDetailValueType.orbitRadius:
    case SkillDetailValueType.orbitSpeed:
    case SkillDetailValueType.moveSpeed:
    case SkillDetailValueType.duration:
      break;
  }

  final formattedBase = detail.value;
  final formattedActual = formatSkillDetailValue(
    type,
    actualPrimary,
    actualSecondary,
  );
  if (!_hasMeaningfulChange(
    primary,
    actualPrimary,
    secondary,
    actualSecondary,
  )) {
    return SkillDetailDisplayLine(
      label: detail.label,
      baseValue: formattedBase,
    );
  }
  return SkillDetailDisplayLine(
    label: detail.label,
    baseValue: formattedBase,
    actualValue: formattedActual,
    isBetter: isBetter,
  );
}

const _epsilon = 0.0001;

bool _hasMeaningfulChange(
  double basePrimary,
  double actualPrimary,
  double? baseSecondary,
  double? actualSecondary,
) {
  if ((actualPrimary - basePrimary).abs() > _epsilon) {
    return true;
  }
  if (baseSecondary == null || actualSecondary == null) {
    return false;
  }
  return (actualSecondary - baseSecondary).abs() > _epsilon;
}

double _stat(Map<StatId, double> statValues, StatId id) {
  return statValues[id] ?? 0;
}

double _cooldownSpeed(Map<StatId, double> statValues) {
  final attackSpeed = _stat(statValues, StatId.attackSpeed);
  return math.max(0.1, 1 + attackSpeed);
}

double _attackSpeedScale(Map<StatId, double> statValues) {
  final attackSpeed = _stat(statValues, StatId.attackSpeed);
  return math.max(0.1, 1 + attackSpeed);
}

double _supportMultiplier(Map<StatId, double> statValues) {
  return math.max(0.1, 1 + _stat(statValues, StatId.healingReceivedPercent));
}

double _aoeScale(Map<StatId, double> statValues) {
  return math.max(0.25, 1 + _stat(statValues, StatId.aoeSize));
}

double _knockbackScale(Map<StatId, double> statValues) {
  return math.max(0.1, 1 + _stat(statValues, StatId.banishmentForce));
}

double _scaledDamageForTags(
  TagSet tags,
  Map<StatId, double> statValues,
  double baseDamage,
) {
  final multiplier = _damageMultiplierForTags(tags, statValues);
  final flat = _flatDamageForTags(tags, statValues);
  return math.max(0, baseDamage * multiplier + flat);
}

double _damageMultiplierForTags(TagSet tags, Map<StatId, double> statValues) {
  var multiplier = 1 + _stat(statValues, StatId.damagePercent);
  if (tags.hasEffect(EffectTag.dot)) {
    multiplier += _stat(statValues, StatId.dotDamagePercent);
  }

  if (tags.hasDelivery(DeliveryTag.projectile)) {
    multiplier += _stat(statValues, StatId.projectileDamagePercent);
  }
  if (tags.hasDelivery(DeliveryTag.melee)) {
    multiplier += _stat(statValues, StatId.meleeDamagePercent);
  }
  if (tags.hasDelivery(DeliveryTag.beam)) {
    multiplier += _stat(statValues, StatId.beamDamagePercent);
  }
  if (tags.hasDelivery(DeliveryTag.aura)) {
    multiplier += _stat(statValues, StatId.auraDamagePercent);
  }
  if (tags.hasDelivery(DeliveryTag.ground)) {
    multiplier += _stat(statValues, StatId.groundDamagePercent);
    multiplier += _stat(statValues, StatId.explosionDamagePercent);
  }

  if (tags.elements.isNotEmpty) {
    multiplier += _stat(statValues, StatId.elementalDamagePercent);
  }
  if (tags.hasElement(ElementTag.fire)) {
    multiplier += _stat(statValues, StatId.fireDamagePercent);
  }
  if (tags.hasElement(ElementTag.water)) {
    multiplier += _stat(statValues, StatId.waterDamagePercent);
  }
  if (tags.hasElement(ElementTag.earth)) {
    multiplier += _stat(statValues, StatId.earthDamagePercent);
  }
  if (tags.hasElement(ElementTag.wind)) {
    multiplier += _stat(statValues, StatId.windDamagePercent);
  }
  if (tags.hasElement(ElementTag.poison)) {
    multiplier += _stat(statValues, StatId.poisonDamagePercent);
  }
  if (tags.hasElement(ElementTag.steel)) {
    multiplier += _stat(statValues, StatId.steelDamagePercent);
  }
  if (tags.hasElement(ElementTag.wood)) {
    multiplier += _stat(statValues, StatId.woodDamagePercent);
  }

  return math.max(0.1, multiplier);
}

double _flatDamageForTags(TagSet tags, Map<StatId, double> statValues) {
  var flat = _stat(statValues, StatId.flatDamage);
  if (tags.elements.isNotEmpty) {
    flat += _stat(statValues, StatId.flatElementalDamage);
  }
  return flat;
}

const _igniteTags = TagSet(
  elements: {ElementTag.fire},
  effects: {EffectTag.dot},
);
