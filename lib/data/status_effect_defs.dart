import 'ids.dart';
import 'tags.dart';

class StatusEffectDef {
  const StatusEffectDef({
    required this.id,
    required this.name,
    required this.description,
    required this.tags,
  });

  final StatusEffectId id;
  final String name;
  final String description;
  final TagSet tags;
}

const List<StatusEffectDef> statusEffectDefs = [
  StatusEffectDef(
    id: StatusEffectId.slow,
    name: 'Slow',
    description: 'Reduces enemy movement speed for a short duration.',
    tags: TagSet(effects: {EffectTag.debuff}),
  ),
  StatusEffectDef(
    id: StatusEffectId.root,
    name: 'Root',
    description: 'Snaring vines reduce enemy movement dramatically.',
    tags: TagSet(
      elements: {ElementTag.earth, ElementTag.wood},
      effects: {EffectTag.debuff},
    ),
  ),
  StatusEffectDef(
    id: StatusEffectId.ignite,
    name: 'Ignite',
    description: 'Burning damage over time after a fire hit.',
    tags: TagSet(elements: {ElementTag.fire}, effects: {EffectTag.dot}),
  ),
  StatusEffectDef(
    id: StatusEffectId.oilSoaked,
    name: 'Oil-Soaked',
    description: 'Slick oil primes enemies for fiery follow-ups.',
    tags: TagSet(effects: {EffectTag.debuff}),
  ),
  StatusEffectDef(
    id: StatusEffectId.vulnerable,
    name: 'Vulnerable',
    description: 'Enemies take increased damage while exposed.',
    tags: TagSet(effects: {EffectTag.debuff}),
  ),
];

final Map<StatusEffectId, StatusEffectDef> statusEffectDefsById =
    Map.unmodifiable({for (final def in statusEffectDefs) def.id: def});
