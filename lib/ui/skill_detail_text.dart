import 'dart:math' as math;

import 'package:hordesurivor/data/data.dart';

import '../game/skill_level_scaling.dart';

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

class SkillLevelModifierLine {
  const SkillLevelModifierLine({
    required this.label,
    required this.deltaValue,
    required this.isBetter,
  });

  final String label;
  final String deltaValue;
  final bool isBetter;
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
  Map<StatId, double> statValues, {
  int skillLevel = 1,
}) {
  final def = skillDefsById[id];
  if (def == null) {
    return const [];
  }
  final tags = def.tags;
  return [
    for (final detail in def.displayDetails)
      _detailLineFor(detail, id, tags, statValues, skillLevel),
  ];
}

List<SkillLevelModifierLine> skillLevelModifierLinesFor(
  SkillId id, {
  int fromLevel = 1,
  int toLevel = 1,
}) {
  if (toLevel <= fromLevel) {
    return const [];
  }
  final def = skillDefsById[id];
  if (def == null) {
    return const [];
  }
  final lines = <SkillLevelModifierLine>[];
  for (final detail in def.displayDetails) {
    final type = detail.detailType;
    final primary = detail.primaryValue;
    if (type == null || primary == null) {
      continue;
    }
    final secondary = detail.secondaryValue;
    final basePrimary = _applySkillLevelScaling(type, primary, fromLevel);
    final baseSecondary = secondary == null
        ? null
        : _applySkillLevelScalingSecondary(type, secondary, fromLevel);
    final levelPrimary = _applySkillLevelScaling(type, primary, toLevel);
    final levelSecondary = secondary == null
        ? null
        : _applySkillLevelScalingSecondary(type, secondary, toLevel);
    if (!_hasMeaningfulChange(
      basePrimary,
      levelPrimary,
      baseSecondary,
      levelSecondary,
    )) {
      continue;
    }
    var deltaPrimary = levelPrimary - basePrimary;
    final deltaSecondary = (levelSecondary != null && baseSecondary != null)
        ? levelSecondary - baseSecondary
        : null;
    if (type == SkillDetailValueType.slow) {
      final baseSlow = (1 - basePrimary).clamp(0.0, 1.0);
      final levelSlow = (1 - levelPrimary).clamp(0.0, 1.0);
      deltaPrimary = levelSlow - baseSlow;
    }
    final deltaValue = _formatSkillLevelDelta(
      type,
      deltaPrimary,
      deltaSecondary,
    );
    if (deltaValue.isEmpty) {
      continue;
    }
    lines.add(
      SkillLevelModifierLine(
        label: detail.label,
        deltaValue: deltaValue,
        isBetter: _isLevelDeltaBetter(type, deltaPrimary, deltaSecondary),
      ),
    );
  }
  return lines;
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
  int skillLevel,
) {
  final type = detail.detailType;
  final primary = detail.primaryValue;
  final secondary = detail.secondaryValue;
  if (type == null || primary == null) {
    return SkillDetailDisplayLine(label: detail.label, baseValue: detail.value);
  }

  final levelPrimary = _applySkillLevelScaling(type, primary, skillLevel);
  final levelSecondary = secondary == null
      ? null
      : _applySkillLevelScalingSecondary(type, secondary, skillLevel);
  var actualPrimary = levelPrimary;
  var actualSecondary = levelSecondary;
  var isBetter = true;
  switch (type) {
    case SkillDetailValueType.cooldown:
      actualPrimary = levelPrimary / _cooldownSpeed(statValues);
      isBetter = actualPrimary < primary;
      break;
    case SkillDetailValueType.attackCooldown:
      actualPrimary = levelPrimary / _attackSpeedScale(statValues);
      isBetter = actualPrimary < primary;
      break;
    case SkillDetailValueType.damage:
    case SkillDetailValueType.damagePerSecond:
      actualPrimary = _scaledDamageForTags(tags, statValues, levelPrimary);
      isBetter = actualPrimary > primary;
      break;
    case SkillDetailValueType.damageOverTime:
      actualPrimary = _scaledDamageForTags(tags, statValues, levelPrimary);
      isBetter = actualPrimary > primary;
      break;
    case SkillDetailValueType.healingPerSecond:
      actualPrimary = levelPrimary * _supportMultiplier(statValues);
      isBetter = actualPrimary > primary;
      break;
    case SkillDetailValueType.beamLength:
    case SkillDetailValueType.beamWidth:
    case SkillDetailValueType.groundRadius:
    case SkillDetailValueType.deflectRadius:
      actualPrimary = levelPrimary * _aoeScale(statValues);
      isBetter = actualPrimary > primary;
      break;
    case SkillDetailValueType.range:
      if (detail.scalesWithAoe) {
        actualPrimary = levelPrimary * _aoeScale(statValues);
        isBetter = actualPrimary > primary;
      }
      break;
    case SkillDetailValueType.knockback:
      actualPrimary = levelPrimary * _knockbackScale(statValues);
      isBetter = actualPrimary > primary;
      break;
    case SkillDetailValueType.ignite:
      actualPrimary = _scaledDamageForTags(
        _igniteTags,
        statValues,
        levelPrimary,
      );
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
          actualSecondary = (levelSecondary ?? 0) * durationScale;
          final strength =
              (applySkillLevelSlowStrength(rootDef.baseStrength, skillLevel) +
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
      } else {
        final baseSlow = (1 - primary).clamp(0.0, 1.0);
        final actualSlow = (1 - actualPrimary).clamp(0.0, 1.0);
        if ((actualSlow - baseSlow).abs() > _epsilon) {
          isBetter = actualSlow > baseSlow;
        } else if (secondary != null) {
          isBetter = (actualSecondary ?? 0) > secondary;
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

double _applySkillLevelScaling(
  SkillDetailValueType type,
  double value,
  int skillLevel,
) {
  switch (type) {
    case SkillDetailValueType.cooldown:
    case SkillDetailValueType.attackCooldown:
      return applySkillLevelCooldown(value, skillLevel);
    case SkillDetailValueType.damage:
    case SkillDetailValueType.damagePerSecond:
    case SkillDetailValueType.damageOverTime:
    case SkillDetailValueType.healingPerSecond:
    case SkillDetailValueType.ignite:
      return applySkillLevelDamage(value, skillLevel);
    case SkillDetailValueType.projectileSpeed:
    case SkillDetailValueType.orbitSpeed:
    case SkillDetailValueType.moveSpeed:
      return applySkillLevelSpeed(value, skillLevel);
    case SkillDetailValueType.projectileRadius:
    case SkillDetailValueType.beamLength:
    case SkillDetailValueType.beamWidth:
    case SkillDetailValueType.groundRadius:
    case SkillDetailValueType.range:
    case SkillDetailValueType.arc:
    case SkillDetailValueType.deflectRadius:
    case SkillDetailValueType.orbitRadius:
      return applySkillLevelSize(value, skillLevel);
    case SkillDetailValueType.duration:
      return applySkillLevelDuration(value, skillLevel);
    case SkillDetailValueType.slow:
      return applySkillLevelSlowMultiplier(value, skillLevel);
    case SkillDetailValueType.knockback:
      return applySkillLevelKnockback(value, skillLevel);
  }
}

double _applySkillLevelScalingSecondary(
  SkillDetailValueType type,
  double value,
  int skillLevel,
) {
  switch (type) {
    case SkillDetailValueType.damageOverTime:
    case SkillDetailValueType.ignite:
    case SkillDetailValueType.knockback:
    case SkillDetailValueType.slow:
    case SkillDetailValueType.duration:
      return applySkillLevelDuration(value, skillLevel);
    case SkillDetailValueType.cooldown:
    case SkillDetailValueType.attackCooldown:
    case SkillDetailValueType.damage:
    case SkillDetailValueType.damagePerSecond:
    case SkillDetailValueType.healingPerSecond:
    case SkillDetailValueType.projectileSpeed:
    case SkillDetailValueType.projectileRadius:
    case SkillDetailValueType.beamLength:
    case SkillDetailValueType.beamWidth:
    case SkillDetailValueType.groundRadius:
    case SkillDetailValueType.range:
    case SkillDetailValueType.arc:
    case SkillDetailValueType.deflectRadius:
    case SkillDetailValueType.orbitRadius:
    case SkillDetailValueType.orbitSpeed:
    case SkillDetailValueType.moveSpeed:
      return value;
  }
}

String _formatSkillLevelDelta(
  SkillDetailValueType type,
  double deltaPrimary,
  double? deltaSecondary,
) {
  switch (type) {
    case SkillDetailValueType.cooldown:
    case SkillDetailValueType.attackCooldown:
    case SkillDetailValueType.duration:
      return _formatSigned(
        formatSkillSeconds(deltaPrimary.abs()),
        deltaPrimary,
      );
    case SkillDetailValueType.damage:
    case SkillDetailValueType.damagePerSecond:
    case SkillDetailValueType.healingPerSecond:
    case SkillDetailValueType.projectileSpeed:
    case SkillDetailValueType.projectileRadius:
    case SkillDetailValueType.beamLength:
    case SkillDetailValueType.beamWidth:
    case SkillDetailValueType.groundRadius:
    case SkillDetailValueType.range:
    case SkillDetailValueType.deflectRadius:
    case SkillDetailValueType.orbitRadius:
    case SkillDetailValueType.orbitSpeed:
    case SkillDetailValueType.moveSpeed:
      return _formatSigned(formatSkillNumber(deltaPrimary.abs()), deltaPrimary);
    case SkillDetailValueType.arc:
      final value = formatSkillNumber(deltaPrimary.abs());
      return _formatSigned('$value°', deltaPrimary);
    case SkillDetailValueType.damageOverTime:
      final primary = _formatSigned(
        formatSkillNumber(deltaPrimary.abs()),
        deltaPrimary,
      );
      final secondary = _formatSigned(
        formatSkillSeconds((deltaSecondary ?? 0).abs()),
        deltaSecondary ?? 0,
      );
      return '$primary / $secondary';
    case SkillDetailValueType.slow:
      final primary = _formatSigned(
        formatSkillPercent(deltaPrimary.abs()),
        deltaPrimary,
      );
      if (deltaSecondary == null) {
        return primary;
      }
      final secondary = _formatSigned(
        formatSkillSeconds(deltaSecondary.abs()),
        deltaSecondary,
      );
      return '$primary / $secondary';
    case SkillDetailValueType.ignite:
      final primary = _formatSigned(
        formatSkillNumber(deltaPrimary.abs()),
        deltaPrimary,
      );
      final secondary = _formatSigned(
        formatSkillSeconds((deltaSecondary ?? 0).abs()),
        deltaSecondary ?? 0,
      );
      return '$primary DPS / $secondary';
    case SkillDetailValueType.knockback:
      final primary = _formatSigned(
        formatSkillNumber(deltaPrimary.abs()),
        deltaPrimary,
      );
      final secondary = _formatSigned(
        formatSkillSeconds((deltaSecondary ?? 0).abs()),
        deltaSecondary ?? 0,
      );
      return '$primary force / $secondary';
  }
}

String _formatSigned(String value, double delta) {
  if (delta == 0) {
    return value;
  }
  return delta > 0 ? '+$value' : '-$value';
}

bool _isLevelDeltaBetter(
  SkillDetailValueType type,
  double deltaPrimary,
  double? deltaSecondary,
) {
  switch (type) {
    case SkillDetailValueType.cooldown:
    case SkillDetailValueType.attackCooldown:
      return deltaPrimary < 0;
    case SkillDetailValueType.slow:
      return deltaPrimary > 0 || (deltaSecondary ?? 0) > 0;
    default:
      return deltaPrimary > 0 || (deltaSecondary ?? 0) > 0;
  }
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
