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
    name: 'Censer Ember',
    iconId: 'skill_censer_ember',
    description: 'Fling a burning coal from the censer.',
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
    name: 'Holy Water Jet',
    iconId: 'skill_holy_water_jet',
    description: 'Spray a focused line of holy water.',
    tags: TagSet(elements: {ElementTag.water}, deliveries: {DeliveryTag.beam}),
    statusEffects: {StatusEffectId.slow},
  ),
  SkillDef(
    id: SkillId.oilBombs,
    name: 'Anointing Oil Flasks',
    iconId: 'skill_anointing_oil',
    description: 'Lob flasks that slick the ground for later “purification.”',
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
    name: 'Riteblade: Thrust',
    iconId: 'skill_riteblade_thrust',
    description: 'A precise thrust to “encourage” departure.',
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
    name: 'Riteblade: Cut',
    iconId: 'skill_riteblade_cut',
    description: 'A short sweeping cut of righteous steel.',
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
    name: 'Riteblade: Swing',
    iconId: 'skill_riteblade_swing',
    description: 'A wide swing with a heavier wind-up and heavier judgement.',
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
    name: 'Riteblade: Rebuke',
    iconId: 'skill_riteblade_rebuke',
    description: 'A quick rebuke that turns back hostile projectiles.',
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
    name: 'Thurible Fumes',
    iconId: 'skill_thurible_fumes',
    description: 'A lingering cloud of “cleansing” incense that hurts to breathe.',
    tags: TagSet(
      elements: {ElementTag.poison},
      effects: {EffectTag.aoe, EffectTag.dot},
      deliveries: {DeliveryTag.aura},
    ),
  ),
  SkillDef(
    id: SkillId.roots,
    name: 'Salt Circle',
    iconId: 'skill_salt_circle',
    description: 'A harsh ring that snares anything trying to cross it.',
    tags: TagSet(
      elements: {ElementTag.earth, ElementTag.wood},
      effects: {EffectTag.debuff},
      deliveries: {DeliveryTag.ground},
    ),
    statusEffects: {StatusEffectId.root},
  ),
  SkillDef(
    id: SkillId.windCutter,
    name: 'Psalm: Razor Hymn',
    iconId: 'skill_razor_hymn',
    description: 'Sing a sharp verse; the air does the rest.',
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
    name: 'Rosary Shards',
    iconId: 'skill_rosary_shards',
    description: 'Fan out blessed fragments in a tight burst.',
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
    name: 'Litany: Flame Sweep',
    iconId: 'skill_flame_sweep',
    description: 'A short sweeping wave of consecrated fire.',
    tags: TagSet(
      elements: {ElementTag.fire},
      effects: {EffectTag.aoe},
      deliveries: {DeliveryTag.beam},
    ),
    metaUnlockId: MetaUnlockId.flameWaveTechnique,
  ),
  SkillDef(
    id: SkillId.frostNova,
    name: 'Rite of Chill',
    iconId: 'skill_rite_of_chill',
    description: 'A cold blessing that slows everything nearby.',
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
    name: 'Grave-Script Spikes',
    iconId: 'skill_gravescript_spikes',
    description: 'Inscribed ground erupts into punitive spikes.',
    tags: TagSet(
      elements: {ElementTag.earth},
      effects: {EffectTag.aoe, EffectTag.dot},
      deliveries: {DeliveryTag.ground},
    ),
    metaUnlockId: MetaUnlockId.earthSpikesSurvey,
  ),
  SkillDef(
    id: SkillId.sporeBurst,
    name: 'Censer Spores',
    iconId: 'skill_censer_spores',
    description: 'A toxic “blessing” that lingers as a choking cloud.',
    tags: TagSet(
      elements: {ElementTag.poison},
      effects: {EffectTag.aoe, EffectTag.dot},
      deliveries: {DeliveryTag.projectile, DeliveryTag.ground},
    ),
    metaUnlockId: MetaUnlockId.sporeBurstCulture,
  ),
  SkillDef(
    id: SkillId.scrapRover,
    name: 'Relic: Procession Idol',
    iconId: 'skill_procession_idol',
    description: 'A small idol trudges around and “corrects” nearby foes.',
    tags: TagSet(elements: {ElementTag.steel}, deliveries: {DeliveryTag.melee}),
  ),
  SkillDef(
    id: SkillId.arcTurret,
    name: 'Relic: Vigil Lantern',
    iconId: 'skill_vigil_lantern',
    description: 'A hovering lantern fires warding shots on its own.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.support},
      deliveries: {DeliveryTag.projectile},
    ),
  ),
  SkillDef(
    id: SkillId.guardianOrbs,
    name: 'Warding Rosary',
    iconId: 'skill_warding_rosary',
    description: 'Orbiting beads keep close company and closer damage.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.support},
      deliveries: {DeliveryTag.aura},
    ),
  ),
  SkillDef(
    id: SkillId.menderOrb,
    name: 'Absolving Wisp',
    iconId: 'skill_absolving_wisp',
    description: 'A patient little wisp that restores health over time.',
    tags: TagSet(
      elements: {ElementTag.wood},
      effects: {EffectTag.support},
      deliveries: {DeliveryTag.aura},
    ),
  ),
  SkillDef(
    id: SkillId.mineLayer,
    name: 'Consecrated Wards',
    iconId: 'skill_consecrated_wards',
    description: 'Place wards that detonate when something unholy approaches.',
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
