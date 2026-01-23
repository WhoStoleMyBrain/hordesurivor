import 'ids.dart';
import 'skill_defs.dart';
import 'stat_defs.dart';
import 'tags.dart';

const int weaponUpgradeTierCount = 7;

class WeaponUpgradeDef {
  const WeaponUpgradeDef({
    required this.id,
    required this.skillId,
    required this.tier,
    required this.name,
    required this.summary,
    required this.tags,
    required this.modifiers,
    this.weight = 1,
  });

  final String id;
  final SkillId skillId;
  final int tier;
  final String name;
  final String summary;
  final TagSet tags;
  final List<StatModifier> modifiers;
  final int weight;
}

final List<WeaponUpgradeDef> weaponUpgradeDefs = [
  ..._buildWeaponUpgradeChain(
    skillId: SkillId.fireball,
    modifiersForTier: (tier) => _primarySecondary(
      StatId.damagePercent,
      0.06,
      0.02,
      StatId.fireDamagePercent,
      0.04,
      0.01,
      tier,
    ),
  ),
  ..._buildWeaponUpgradeChain(
    skillId: SkillId.waterjet,
    modifiersForTier: (tier) => _primarySecondary(
      StatId.beamDamagePercent,
      0.07,
      0.02,
      StatId.attackSpeed,
      0.04,
      0.01,
      tier,
    ),
  ),
  ..._buildWeaponUpgradeChain(
    skillId: SkillId.oilBombs,
    modifiersForTier: (tier) => _primarySecondary(
      StatId.explosionDamagePercent,
      0.06,
      0.02,
      StatId.aoeSize,
      0.05,
      0.015,
      tier,
    ),
  ),
  ..._buildWeaponUpgradeChain(
    skillId: SkillId.swordThrust,
    modifiersForTier: (tier) => _primarySecondary(
      StatId.meleeDamagePercent,
      0.07,
      0.02,
      StatId.attackSpeed,
      0.04,
      0.01,
      tier,
    ),
  ),
  ..._buildWeaponUpgradeChain(
    skillId: SkillId.swordCut,
    modifiersForTier: (tier) => _primarySecondary(
      StatId.meleeDamagePercent,
      0.08,
      0.02,
      StatId.aoeSize,
      0.05,
      0.015,
      tier,
    ),
  ),
  ..._buildWeaponUpgradeChain(
    skillId: SkillId.swordSwing,
    modifiersForTier: (tier) => _primarySecondary(
      StatId.meleeDamagePercent,
      0.09,
      0.02,
      StatId.aoeSize,
      0.05,
      0.015,
      tier,
    ),
  ),
  ..._buildWeaponUpgradeChain(
    skillId: SkillId.swordDeflect,
    modifiersForTier: (tier) => _primarySecondary(
      StatId.meleeDamagePercent,
      0.06,
      0.015,
      StatId.cooldownRecovery,
      0.04,
      0.01,
      tier,
    ),
  ),
  ..._buildWeaponUpgradeChain(
    skillId: SkillId.poisonGas,
    modifiersForTier: (tier) => _primarySecondary(
      StatId.dotDamagePercent,
      0.07,
      0.02,
      StatId.aoeSize,
      0.05,
      0.015,
      tier,
    ),
  ),
  ..._buildWeaponUpgradeChain(
    skillId: SkillId.roots,
    modifiersForTier: (tier) => _primarySecondary(
      StatId.statusDurationPercent,
      0.07,
      0.02,
      StatId.statusPotencyPercent,
      0.05,
      0.015,
      tier,
    ),
  ),
  ..._buildWeaponUpgradeChain(
    skillId: SkillId.windCutter,
    modifiersForTier: (tier) => _primarySecondary(
      StatId.projectileDamagePercent,
      0.07,
      0.02,
      StatId.attackSpeed,
      0.04,
      0.01,
      tier,
    ),
  ),
  ..._buildWeaponUpgradeChain(
    skillId: SkillId.steelShards,
    modifiersForTier: (tier) => _primarySecondary(
      StatId.projectileDamagePercent,
      0.08,
      0.02,
      StatId.attackSpeed,
      0.04,
      0.01,
      tier,
    ),
  ),
  ..._buildWeaponUpgradeChain(
    skillId: SkillId.flameWave,
    modifiersForTier: (tier) => _primarySecondary(
      StatId.beamDamagePercent,
      0.07,
      0.02,
      StatId.aoeSize,
      0.05,
      0.015,
      tier,
    ),
  ),
  ..._buildWeaponUpgradeChain(
    skillId: SkillId.frostNova,
    modifiersForTier: (tier) => _primarySecondary(
      StatId.aoeSize,
      0.06,
      0.015,
      StatId.waterDamagePercent,
      0.05,
      0.015,
      tier,
    ),
  ),
  ..._buildWeaponUpgradeChain(
    skillId: SkillId.earthSpikes,
    modifiersForTier: (tier) => _primarySecondary(
      StatId.damagePercent,
      0.07,
      0.02,
      StatId.aoeSize,
      0.05,
      0.015,
      tier,
    ),
  ),
  ..._buildWeaponUpgradeChain(
    skillId: SkillId.sporeBurst,
    modifiersForTier: (tier) => _primarySecondary(
      StatId.dotDamagePercent,
      0.07,
      0.02,
      StatId.aoeSize,
      0.05,
      0.015,
      tier,
    ),
  ),
  ..._buildWeaponUpgradeChain(
    skillId: SkillId.processionIdol,
    modifiersForTier: (tier) => _primarySecondary(
      StatId.meleeDamagePercent,
      0.07,
      0.02,
      StatId.attackSpeed,
      0.04,
      0.01,
      tier,
    ),
  ),
  ..._buildWeaponUpgradeChain(
    skillId: SkillId.vigilLantern,
    modifiersForTier: (tier) => _primarySecondary(
      StatId.projectileDamagePercent,
      0.07,
      0.02,
      StatId.attackSpeed,
      0.04,
      0.01,
      tier,
    ),
  ),
  ..._buildWeaponUpgradeChain(
    skillId: SkillId.guardianOrbs,
    modifiersForTier: (tier) => _primarySecondary(
      StatId.damagePercent,
      0.06,
      0.02,
      StatId.aoeSize,
      0.05,
      0.015,
      tier,
    ),
  ),
  ..._buildWeaponUpgradeChain(
    skillId: SkillId.menderOrb,
    modifiersForTier: (tier) => _primarySecondary(
      StatId.cooldownRecovery,
      0.05,
      0.015,
      StatId.healingReceivedPercent,
      0.04,
      0.01,
      tier,
    ),
  ),
  ..._buildWeaponUpgradeChain(
    skillId: SkillId.mineLayer,
    modifiersForTier: (tier) => _primarySecondary(
      StatId.explosionDamagePercent,
      0.07,
      0.02,
      StatId.aoeSize,
      0.05,
      0.015,
      tier,
    ),
  ),
  ..._buildWeaponUpgradeChain(
    skillId: SkillId.chairThrow,
    modifiersForTier: (tier) => _primarySecondary(
      StatId.projectileDamagePercent,
      0.08,
      0.02,
      StatId.attackSpeed,
      0.04,
      0.01,
      tier,
    ),
  ),
  ..._buildWeaponUpgradeChain(
    skillId: SkillId.absolutionSlap,
    modifiersForTier: (tier) => _primarySecondary(
      StatId.meleeDamagePercent,
      0.07,
      0.02,
      StatId.aoeSize,
      0.05,
      0.015,
      tier,
    ),
  ),
];

final Map<String, WeaponUpgradeDef> weaponUpgradeDefsById = Map.unmodifiable({
  for (final def in weaponUpgradeDefs) def.id: def,
});

final Map<SkillId, List<WeaponUpgradeDef>> weaponUpgradeChainsBySkillId =
    Map.unmodifiable(_buildWeaponUpgradeChainsBySkillId());

final Map<SkillId, Map<int, WeaponUpgradeDef>> weaponUpgradeDefsBySkillAndTier =
    Map.unmodifiable(_buildWeaponUpgradeDefsBySkillAndTier());

Map<SkillId, List<WeaponUpgradeDef>> _buildWeaponUpgradeChainsBySkillId() {
  final chains = <SkillId, List<WeaponUpgradeDef>>{};
  for (final def in weaponUpgradeDefs) {
    chains.putIfAbsent(def.skillId, () => <WeaponUpgradeDef>[]).add(def);
  }
  for (final entry in chains.entries) {
    entry.value.sort((a, b) => a.tier.compareTo(b.tier));
  }
  return chains;
}

Map<SkillId, Map<int, WeaponUpgradeDef>>
_buildWeaponUpgradeDefsBySkillAndTier() {
  final tiers = <SkillId, Map<int, WeaponUpgradeDef>>{};
  for (final entry in weaponUpgradeChainsBySkillId.entries) {
    tiers[entry.key] = Map<int, WeaponUpgradeDef>.unmodifiable({
      for (final def in entry.value) def.tier: def,
    });
  }
  return tiers;
}

List<WeaponUpgradeDef> _buildWeaponUpgradeChain({
  required SkillId skillId,
  required List<StatModifier> Function(int tier) modifiersForTier,
}) {
  final skill = skillDefsById[skillId];
  final name = skill?.name ?? skillId.name;
  final tags = skill?.tags ?? const TagSet();

  return List<WeaponUpgradeDef>.generate(weaponUpgradeTierCount, (index) {
    final tier = index + 1;
    return WeaponUpgradeDef(
      id: '${skillId.name}_tier_$tier',
      skillId: skillId,
      tier: tier,
      name: '$name Tier $tier',
      summary: 'Tier $tier upgrade for $name.',
      tags: tags,
      modifiers: modifiersForTier(tier),
    );
  });
}

List<StatModifier> _primarySecondary(
  StatId primary,
  double primaryBase,
  double primaryStep,
  StatId secondary,
  double secondaryBase,
  double secondaryStep,
  int tier,
) {
  final stepIndex = tier - 1;
  return [
    StatModifier(stat: primary, amount: primaryBase + primaryStep * stepIndex),
    StatModifier(
      stat: secondary,
      amount: secondaryBase + secondaryStep * stepIndex,
    ),
  ];
}
