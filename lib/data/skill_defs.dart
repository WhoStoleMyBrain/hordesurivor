import 'ids.dart';
import 'tags.dart';

class SkillDef {
  const SkillDef({
    required this.id,
    required this.name,
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
    description: 'Pulse a focused beam of water.',
    tags: TagSet(elements: {ElementTag.water}, deliveries: {DeliveryTag.beam}),
    statusEffects: {StatusEffectId.slow},
  ),
  SkillDef(
    id: SkillId.oilBombs,
    name: 'Oil Bombs',
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
    description: 'Lob spores that linger as toxic clouds.',
    tags: TagSet(
      elements: {ElementTag.poison},
      effects: {EffectTag.aoe, EffectTag.dot},
      deliveries: {DeliveryTag.projectile, DeliveryTag.ground},
    ),
    metaUnlockId: MetaUnlockId.sporeBurstCulture,
  ),
];

final Map<SkillId, SkillDef> skillDefsById = Map.unmodifiable({
  for (final def in skillDefs) def.id: def,
});
