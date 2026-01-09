import 'ids.dart';
import 'tags.dart';

class SkillDef {
  const SkillDef({
    required this.id,
    required this.name,
    required this.description,
    required this.tags,
    this.knockbackForce = 0,
    this.knockbackDuration = 0,
    this.weight = 1,
  });

  final SkillId id;
  final String name;
  final String description;
  final TagSet tags;
  final double knockbackForce;
  final double knockbackDuration;
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
    knockbackForce: 80,
    knockbackDuration: 0.18,
  ),
  SkillDef(
    id: SkillId.waterjet,
    name: 'Waterjet',
    description: 'Pulse a focused beam of water.',
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
