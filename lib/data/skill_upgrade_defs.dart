import 'ids.dart';
import 'stat_defs.dart';
import 'tags.dart';

class SkillUpgradeDef {
  const SkillUpgradeDef({
    required this.id,
    required this.skillId,
    required this.name,
    required this.summary,
    required this.tags,
    required this.modifiers,
    this.weight = 1,
  });

  final SkillUpgradeId id;
  final SkillId skillId;
  final String name;
  final String summary;
  final TagSet tags;
  final List<StatModifier> modifiers;
  final int weight;
}

const List<SkillUpgradeDef> skillUpgradeDefs = [
  SkillUpgradeDef(
    id: SkillUpgradeId.fireballBlastCoating,
    skillId: SkillId.fireball,
    name: 'Blast Coating',
    summary: 'Fireball hits harder with hotter flames.',
    tags: TagSet(
      elements: {ElementTag.fire},
      deliveries: {DeliveryTag.projectile},
    ),
    modifiers: [
      StatModifier(stat: StatId.damage, amount: 0.15),
      StatModifier(stat: StatId.fireDamage, amount: 0.1),
    ],
  ),
  SkillUpgradeDef(
    id: SkillUpgradeId.fireballQuickFuse,
    skillId: SkillId.fireball,
    name: 'Quick Fuse',
    summary: 'Fireballs launch more often.',
    tags: TagSet(
      elements: {ElementTag.fire},
      deliveries: {DeliveryTag.projectile},
    ),
    modifiers: [
      StatModifier(stat: StatId.attackSpeed, amount: 0.1),
      StatModifier(stat: StatId.projectileDamage, amount: 0.05),
    ],
  ),
  SkillUpgradeDef(
    id: SkillUpgradeId.waterjetPressureLine,
    skillId: SkillId.waterjet,
    name: 'Pressure Line',
    summary: 'Waterjet cuts harder.',
    tags: TagSet(elements: {ElementTag.water}, deliveries: {DeliveryTag.beam}),
    modifiers: [StatModifier(stat: StatId.beamDamage, amount: 0.2)],
  ),
  SkillUpgradeDef(
    id: SkillUpgradeId.waterjetSteadyStream,
    skillId: SkillId.waterjet,
    name: 'Steady Stream',
    summary: 'Waterjet cycles faster.',
    tags: TagSet(elements: {ElementTag.water}, deliveries: {DeliveryTag.beam}),
    modifiers: [
      StatModifier(stat: StatId.attackSpeed, amount: 0.1),
      StatModifier(stat: StatId.cooldownRecovery, amount: 0.05),
    ],
  ),
  SkillUpgradeDef(
    id: SkillUpgradeId.oilBombsExpandedPuddles,
    skillId: SkillId.oilBombs,
    name: 'Expanded Puddles',
    summary: 'Oil slicks spread wider.',
    tags: TagSet(
      effects: {EffectTag.debuff},
      deliveries: {DeliveryTag.projectile, DeliveryTag.ground},
    ),
    modifiers: [StatModifier(stat: StatId.aoeSize, amount: 0.2)],
  ),
  SkillUpgradeDef(
    id: SkillUpgradeId.oilBombsHeavyPayload,
    skillId: SkillId.oilBombs,
    name: 'Heavy Payload',
    summary: 'Oil bombs hit harder on impact.',
    tags: TagSet(
      effects: {EffectTag.debuff},
      deliveries: {DeliveryTag.projectile, DeliveryTag.ground},
    ),
    modifiers: [
      StatModifier(stat: StatId.damage, amount: 0.12),
      StatModifier(stat: StatId.projectileDamage, amount: 0.08),
    ],
  ),
  SkillUpgradeDef(
    id: SkillUpgradeId.swordThrustLongReach,
    skillId: SkillId.swordThrust,
    name: 'Long Reach',
    summary: 'Thrust extends farther.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.mobility},
      deliveries: {DeliveryTag.melee},
    ),
    modifiers: [StatModifier(stat: StatId.aoeSize, amount: 0.1)],
  ),
  SkillUpgradeDef(
    id: SkillUpgradeId.swordThrustQuickStep,
    skillId: SkillId.swordThrust,
    name: 'Quick Step',
    summary: 'Thrusts recover faster.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.mobility},
      deliveries: {DeliveryTag.melee},
    ),
    modifiers: [
      StatModifier(stat: StatId.attackSpeed, amount: 0.1),
      StatModifier(stat: StatId.meleeDamage, amount: 0.05),
    ],
  ),
  SkillUpgradeDef(
    id: SkillUpgradeId.swordCutBroadArc,
    skillId: SkillId.swordCut,
    name: 'Broad Arc',
    summary: 'Cut sweeps wider.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.aoe},
      deliveries: {DeliveryTag.melee},
    ),
    modifiers: [StatModifier(stat: StatId.aoeSize, amount: 0.15)],
  ),
  SkillUpgradeDef(
    id: SkillUpgradeId.swordCutSharpenedEdge,
    skillId: SkillId.swordCut,
    name: 'Sharpened Edge',
    summary: 'Cut deals more damage.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.aoe},
      deliveries: {DeliveryTag.melee},
    ),
    modifiers: [StatModifier(stat: StatId.meleeDamage, amount: 0.15)],
  ),
  SkillUpgradeDef(
    id: SkillUpgradeId.swordSwingHeavyMomentum,
    skillId: SkillId.swordSwing,
    name: 'Heavy Momentum',
    summary: 'Swing hits harder.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.aoe},
      deliveries: {DeliveryTag.melee},
    ),
    modifiers: [StatModifier(stat: StatId.meleeDamage, amount: 0.2)],
  ),
  SkillUpgradeDef(
    id: SkillUpgradeId.swordSwingFlowingStrike,
    skillId: SkillId.swordSwing,
    name: 'Flowing Strike',
    summary: 'Swing cooldowns shorten.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.aoe},
      deliveries: {DeliveryTag.melee},
    ),
    modifiers: [
      StatModifier(stat: StatId.attackSpeed, amount: 0.1),
      StatModifier(stat: StatId.cooldownRecovery, amount: 0.05),
    ],
  ),
  SkillUpgradeDef(
    id: SkillUpgradeId.swordDeflectWiderParry,
    skillId: SkillId.swordDeflect,
    name: 'Wider Parry',
    summary: 'Deflect covers more space.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.support},
      deliveries: {DeliveryTag.melee},
    ),
    modifiers: [StatModifier(stat: StatId.aoeSize, amount: 0.15)],
  ),
  SkillUpgradeDef(
    id: SkillUpgradeId.swordDeflectCountercut,
    skillId: SkillId.swordDeflect,
    name: 'Countercut',
    summary: 'Deflect strikes hit harder.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.support},
      deliveries: {DeliveryTag.melee},
    ),
    modifiers: [
      StatModifier(stat: StatId.meleeDamage, amount: 0.1),
      StatModifier(stat: StatId.damage, amount: 0.05),
    ],
  ),
  SkillUpgradeDef(
    id: SkillUpgradeId.poisonGasThickClouds,
    skillId: SkillId.poisonGas,
    name: 'Thick Clouds',
    summary: 'Poison gas expands outward.',
    tags: TagSet(
      elements: {ElementTag.poison},
      effects: {EffectTag.aoe, EffectTag.dot},
      deliveries: {DeliveryTag.aura},
    ),
    modifiers: [StatModifier(stat: StatId.aoeSize, amount: 0.2)],
  ),
  SkillUpgradeDef(
    id: SkillUpgradeId.poisonGasVirulentFumes,
    skillId: SkillId.poisonGas,
    name: 'Virulent Fumes',
    summary: 'Poison gas deals stronger DOT.',
    tags: TagSet(
      elements: {ElementTag.poison},
      effects: {EffectTag.aoe, EffectTag.dot},
      deliveries: {DeliveryTag.aura},
    ),
    modifiers: [StatModifier(stat: StatId.dotDamage, amount: 0.2)],
  ),
  SkillUpgradeDef(
    id: SkillUpgradeId.rootsDeepBind,
    skillId: SkillId.roots,
    name: 'Deep Bind',
    summary: 'Roots snare longer.',
    tags: TagSet(
      elements: {ElementTag.earth, ElementTag.wood},
      effects: {EffectTag.debuff},
      deliveries: {DeliveryTag.ground},
    ),
    modifiers: [StatModifier(stat: StatId.rootDuration, amount: 0.25)],
  ),
  SkillUpgradeDef(
    id: SkillUpgradeId.rootsTighteningGrasp,
    skillId: SkillId.roots,
    name: 'Tightening Grasp',
    summary: 'Roots slow enemies more.',
    tags: TagSet(
      elements: {ElementTag.earth, ElementTag.wood},
      effects: {EffectTag.debuff},
      deliveries: {DeliveryTag.ground},
    ),
    modifiers: [StatModifier(stat: StatId.rootStrength, amount: 0.15)],
  ),
];

final Map<SkillUpgradeId, SkillUpgradeDef> skillUpgradeDefsById =
    Map.unmodifiable({for (final def in skillUpgradeDefs) def.id: def});
