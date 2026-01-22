import 'ids.dart';
import 'tags.dart';

class SkillDef {
  const SkillDef({
    required this.id,
    required this.name,
    required this.iconId,
    required this.description,
    required this.tags,
    this.metaUnlockId,
    this.statusEffects = const {},
    this.knockbackForce = 0,
    this.knockbackDuration = 0,
    this.deflectRadius = 0,
    this.deflectDuration = 0,
    this.weight = 1,
  });

  final SkillId id;
  final String name;
  final String iconId;
  final String description;
  final TagSet tags;
  final MetaUnlockId? metaUnlockId;
  final Set<StatusEffectId> statusEffects;
  final double knockbackForce;
  final double knockbackDuration;
  final double deflectRadius;
  final double deflectDuration;
  final int weight;
}

const List<SkillDef> skillDefs = [
  SkillDef(
    id: SkillId.fireball,
    name: 'Fireball',
    iconId: 'skill_fireball',
    description: 'Launch a fast fire projectile.',
    tags: TagSet(
      elements: {ElementTag.fire},
      deliveries: {DeliveryTag.projectile},
    ),
    statusEffects: {StatusEffectId.ignite},
    knockbackForce: 80,
    knockbackDuration: 0.18,
  ),
  SkillDef(
    id: SkillId.waterjet,
    name: 'Waterjet',
    iconId: 'skill_waterjet',
    description: 'Pulse a focused beam of water.',
    tags: TagSet(elements: {ElementTag.water}, deliveries: {DeliveryTag.beam}),
    statusEffects: {StatusEffectId.slow},
  ),
  SkillDef(
    id: SkillId.oilBombs,
    name: 'Oil Bombs',
    iconId: 'skill_oil_bombs',
    description: 'Lob oil bombs that leave slick ground.',
    tags: TagSet(
      effects: {EffectTag.debuff},
      deliveries: {DeliveryTag.projectile, DeliveryTag.ground},
    ),
    statusEffects: {StatusEffectId.oilSoaked, StatusEffectId.slow},
    knockbackForce: 60,
    knockbackDuration: 0.16,
  ),
  SkillDef(
    id: SkillId.swordThrust,
    name: 'Sword: Thrust',
    iconId: 'skill_sword_thrust',
    description: 'Quick narrow thrust with precision reach.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.mobility},
      deliveries: {DeliveryTag.melee},
    ),
    knockbackForce: 120,
    knockbackDuration: 0.2,
  ),
  SkillDef(
    id: SkillId.swordCut,
    name: 'Sword: Cut',
    iconId: 'skill_sword_cut',
    description: 'Short arc melee sweep.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.aoe},
      deliveries: {DeliveryTag.melee},
    ),
    knockbackForce: 100,
    knockbackDuration: 0.18,
  ),
  SkillDef(
    id: SkillId.swordSwing,
    name: 'Sword: Swing',
    iconId: 'skill_sword_swing',
    description: 'Wide arc melee swing with heavier wind-up.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.aoe},
      deliveries: {DeliveryTag.melee},
    ),
    knockbackForce: 135,
    knockbackDuration: 0.22,
  ),
  SkillDef(
    id: SkillId.swordDeflect,
    name: 'Sword: Deflect',
    iconId: 'skill_sword_deflect',
    description: 'Deflect nearby projectiles with a quick parry.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.support},
      deliveries: {DeliveryTag.melee},
    ),
    knockbackForce: 90,
    knockbackDuration: 0.16,
    deflectRadius: 55,
    deflectDuration: 0.18,
  ),
  SkillDef(
    id: SkillId.poisonGas,
    name: 'Poison Gas',
    iconId: 'skill_poison_gas',
    description: 'Emit a toxic aura that damages over time.',
    tags: TagSet(
      elements: {ElementTag.poison},
      effects: {EffectTag.aoe, EffectTag.dot},
      deliveries: {DeliveryTag.aura},
    ),
  ),
  SkillDef(
    id: SkillId.roots,
    name: 'Roots',
    iconId: 'skill_roots',
    description: 'Snare enemies with erupting roots.',
    tags: TagSet(
      elements: {ElementTag.earth, ElementTag.wood},
      effects: {EffectTag.debuff},
      deliveries: {DeliveryTag.ground},
    ),
    statusEffects: {StatusEffectId.root},
  ),
  SkillDef(
    id: SkillId.windCutter,
    name: 'Wind Cutter',
    iconId: 'skill_wind_cutter',
    description: 'Launch razor wind projectiles at high speed.',
    tags: TagSet(
      elements: {ElementTag.wind},
      deliveries: {DeliveryTag.projectile},
    ),
    metaUnlockId: MetaUnlockId.fieldManual,
    knockbackForce: 70,
    knockbackDuration: 0.16,
  ),
  SkillDef(
    id: SkillId.steelShards,
    name: 'Steel Shards',
    iconId: 'skill_steel_shards',
    description: 'Fan out a trio of steel shards.',
    tags: TagSet(
      elements: {ElementTag.steel},
      deliveries: {DeliveryTag.projectile},
    ),
    metaUnlockId: MetaUnlockId.steelShardsLicense,
    knockbackForce: 85,
    knockbackDuration: 0.18,
  ),
  SkillDef(
    id: SkillId.flameWave,
    name: 'Flame Wave',
    iconId: 'skill_flame_wave',
    description: 'Sweep a short fire beam across enemies.',
    tags: TagSet(
      elements: {ElementTag.fire},
      effects: {EffectTag.aoe},
      deliveries: {DeliveryTag.beam},
    ),
    metaUnlockId: MetaUnlockId.flameWaveTechnique,
  ),
  SkillDef(
    id: SkillId.frostNova,
    name: 'Frost Nova',
    iconId: 'skill_frost_nova',
    description: 'Release a chilling pulse that slows nearby foes.',
    tags: TagSet(
      elements: {ElementTag.water},
      effects: {EffectTag.aoe, EffectTag.debuff},
      deliveries: {DeliveryTag.aura},
    ),
    metaUnlockId: MetaUnlockId.frostNovaDiagram,
    statusEffects: {StatusEffectId.slow},
  ),
  SkillDef(
    id: SkillId.earthSpikes,
    name: 'Earth Spikes',
    iconId: 'skill_earth_spikes',
    description: 'Erupt spikes from the ground ahead.',
    tags: TagSet(
      elements: {ElementTag.earth},
      effects: {EffectTag.aoe, EffectTag.dot},
      deliveries: {DeliveryTag.ground},
    ),
    metaUnlockId: MetaUnlockId.earthSpikesSurvey,
  ),
  SkillDef(
    id: SkillId.sporeBurst,
    name: 'Spore Burst',
    iconId: 'skill_spore_burst',
    description: 'Lob spores that linger as toxic clouds.',
    tags: TagSet(
      elements: {ElementTag.poison},
      effects: {EffectTag.aoe, EffectTag.dot},
      deliveries: {DeliveryTag.projectile, DeliveryTag.ground},
    ),
    metaUnlockId: MetaUnlockId.sporeBurstCulture,
  ),
  SkillDef(
    id: SkillId.scrapRover,
    name: 'Scrap Rover',
    iconId: 'skill_scrap_rover',
    description: 'Deploy a melee rover that hunts nearby foes.',
    tags: TagSet(elements: {ElementTag.steel}, deliveries: {DeliveryTag.melee}),
  ),
  SkillDef(
    id: SkillId.arcTurret,
    name: 'Arc Turret',
    iconId: 'skill_arc_turret',
    description: 'Summon a turret drone that fires on its own.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.support},
      deliveries: {DeliveryTag.projectile},
    ),
  ),
  SkillDef(
    id: SkillId.guardianOrbs,
    name: 'Guardian Orbs',
    iconId: 'skill_guardian_orbs',
    description: 'Orbiting orbs intercept enemies with close-range damage.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.support},
      deliveries: {DeliveryTag.aura},
    ),
  ),
  SkillDef(
    id: SkillId.menderOrb,
    name: 'Mender Orb',
    iconId: 'skill_mender_orb',
    description: 'Orbiting wisp restores health over time.',
    tags: TagSet(
      elements: {ElementTag.wood},
      effects: {EffectTag.support},
      deliveries: {DeliveryTag.aura},
    ),
  ),
  SkillDef(
    id: SkillId.mineLayer,
    name: 'Mine Layer',
    iconId: 'skill_mine_layer',
    description: 'Drop proximity mines that detonate on approach.',
    tags: TagSet(
      elements: {ElementTag.fire},
      effects: {EffectTag.aoe},
      deliveries: {DeliveryTag.ground},
    ),
  ),
];

final Map<SkillId, SkillDef> skillDefsById = Map.unmodifiable({
  for (final def in skillDefs) def.id: def,
});
