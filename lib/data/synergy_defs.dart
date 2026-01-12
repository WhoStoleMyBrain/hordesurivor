import 'ids.dart';
import 'tags.dart';

class SynergyDef {
  const SynergyDef({
    required this.id,
    required this.name,
    required this.description,
    required this.selectionHint,
    required this.triggerTags,
    required this.requiredStatusEffects,
    required this.resultStatusEffect,
    String? triggerLabel,
  }) : triggerLabel = triggerLabel ?? name;

  final SynergyId id;
  final String name;
  final String description;
  final String selectionHint;
  final String triggerLabel;
  final TagSet triggerTags;
  final Set<StatusEffectId> requiredStatusEffects;
  final StatusEffectId resultStatusEffect;

  bool matchesTags(TagSet tags) {
    return tags.elements.containsAll(triggerTags.elements) &&
        tags.effects.containsAll(triggerTags.effects) &&
        tags.deliveries.containsAll(triggerTags.deliveries);
  }
}

const List<SynergyDef> synergyDefs = [
  SynergyDef(
    id: SynergyId.igniteOnOil,
    name: 'Ignite',
    description: 'Fire hits on oil-soaked enemies ignite into burning damage.',
    selectionHint: 'Oil + Fire → Ignite',
    triggerLabel: 'Ignite!',
    triggerTags: TagSet(elements: {ElementTag.fire}),
    requiredStatusEffects: {StatusEffectId.oilSoaked},
    resultStatusEffect: StatusEffectId.ignite,
  ),
];

final Map<SynergyId, SynergyDef> synergyDefsById = Map.unmodifiable({
  for (final def in synergyDefs) def.id: def,
});
