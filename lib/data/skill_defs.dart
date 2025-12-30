import 'ids.dart';
import 'tags.dart';

class SkillDef {
  const SkillDef({
    required this.id,
    required this.name,
    required this.description,
    required this.tags,
    this.weight = 1,
  });

  final SkillId id;
  final String name;
  final String description;
  final TagSet tags;
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
  ),
  SkillDef(
    id: SkillId.waterjet,
    name: 'Waterjet',
    description: 'Channel a focused beam of water.',
    tags: TagSet(elements: {ElementTag.water}, deliveries: {DeliveryTag.beam}),
  ),
  SkillDef(
    id: SkillId.oilBombs,
    name: 'Oil Bombs',
    description: 'Lob oil bombs that leave slick ground.',
    tags: TagSet(
      effects: {EffectTag.debuff},
      deliveries: {DeliveryTag.projectile, DeliveryTag.ground},
    ),
  ),
  SkillDef(
    id: SkillId.swordThrust,
    name: 'Sword: Thrust',
    description: 'Quick lunge with a narrow strike.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.mobility},
      deliveries: {DeliveryTag.melee},
    ),
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
  ),
  SkillDef(
    id: SkillId.swordDeflect,
    name: 'Sword: Deflect',
    description: 'Brief parry window that deflects projectiles.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.support},
      deliveries: {DeliveryTag.melee},
    ),
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
  ),
];

final Map<SkillId, SkillDef> skillDefsById = Map.unmodifiable({
  for (final def in skillDefs) def.id: def,
});
