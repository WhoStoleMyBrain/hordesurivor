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
    this.igniteDuration,
    this.igniteDamagePerSecond,
    this.slowDuration,
    this.slowMultiplier,
    this.rootDuration,
    this.rootStrength,
    this.oilDuration,
    this.vulnerableDuration,
    this.vulnerableMultiplier,
    this.consumeStatusEffects = const {},
  }) : triggerLabel = triggerLabel ?? name;

  final SynergyId id;
  final String name;
  final String description;
  final String selectionHint;
  final String triggerLabel;
  final TagSet triggerTags;
  final Set<StatusEffectId> requiredStatusEffects;
  final StatusEffectId resultStatusEffect;
  final double? igniteDuration;
  final double? igniteDamagePerSecond;
  final double? slowDuration;
  final double? slowMultiplier;
  final double? rootDuration;
  final double? rootStrength;
  final double? oilDuration;
  final double? vulnerableDuration;
  final double? vulnerableMultiplier;
  final Set<StatusEffectId> consumeStatusEffects;

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
    igniteDuration: 1.3,
    igniteDamagePerSecond: 3.0,
  ),
  SynergyDef(
    id: SynergyId.igniteOnRoot,
    name: 'Kindling',
    description: 'Fire hits on rooted enemies spark into burning damage.',
    selectionHint: 'Roots + Fire → Kindling',
    triggerLabel: 'Kindling!',
    triggerTags: TagSet(elements: {ElementTag.fire}),
    requiredStatusEffects: {StatusEffectId.root},
    resultStatusEffect: StatusEffectId.ignite,
    igniteDuration: 1.2,
    igniteDamagePerSecond: 2.6,
  ),
  SynergyDef(
    id: SynergyId.douseOnIgnite,
    name: 'Douse',
    description: 'Water smothers burning foes, slowing their advance.',
    selectionHint: 'Ignite + Water → Douse',
    triggerLabel: 'Douse!',
    triggerTags: TagSet(elements: {ElementTag.water}),
    requiredStatusEffects: {StatusEffectId.ignite},
    resultStatusEffect: StatusEffectId.slow,
    slowDuration: 0.9,
    slowMultiplier: 0.55,
    consumeStatusEffects: {StatusEffectId.ignite},
  ),
  SynergyDef(
    id: SynergyId.exposeOnSlow,
    name: 'Expose',
    description: 'Steel strikes find the openings left by slowed foes.',
    selectionHint: 'Slow + Steel → Expose',
    triggerLabel: 'Expose!',
    triggerTags: TagSet(elements: {ElementTag.steel}),
    requiredStatusEffects: {StatusEffectId.slow},
    resultStatusEffect: StatusEffectId.vulnerable,
    vulnerableDuration: 1.2,
    vulnerableMultiplier: 1.2,
  ),
  SynergyDef(
    id: SynergyId.witherOnRoot,
    name: 'Wither',
    description: 'Poison bites deeper into foes held fast.',
    selectionHint: 'Roots + Poison → Wither',
    triggerLabel: 'Wither!',
    triggerTags: TagSet(elements: {ElementTag.poison}),
    requiredStatusEffects: {StatusEffectId.root},
    resultStatusEffect: StatusEffectId.vulnerable,
    vulnerableDuration: 1.4,
    vulnerableMultiplier: 1.25,
  ),
  SynergyDef(
    id: SynergyId.scourOnOil,
    name: 'Scour',
    description: 'Wind strips the oil away and chills the target.',
    selectionHint: 'Oil + Wind → Scour',
    triggerLabel: 'Scour!',
    triggerTags: TagSet(elements: {ElementTag.wind}),
    requiredStatusEffects: {StatusEffectId.oilSoaked},
    resultStatusEffect: StatusEffectId.slow,
    slowDuration: 0.8,
    slowMultiplier: 0.6,
    consumeStatusEffects: {StatusEffectId.oilSoaked},
  ),
  SynergyDef(
    id: SynergyId.tangleOnSlow,
    name: 'Tangle',
    description: 'Wooden blows catch slowed foes in a snare.',
    selectionHint: 'Slow + Wood → Tangle',
    triggerLabel: 'Tangle!',
    triggerTags: TagSet(elements: {ElementTag.wood}),
    requiredStatusEffects: {StatusEffectId.slow},
    resultStatusEffect: StatusEffectId.root,
    rootDuration: 0.8,
    rootStrength: 0.55,
  ),
  SynergyDef(
    id: SynergyId.tremorOnSlow,
    name: 'Tremor Bind',
    description: 'Earth shocks pin slowed foes in place.',
    selectionHint: 'Slow + Earth → Tremor Bind',
    triggerLabel: 'Bind!',
    triggerTags: TagSet(elements: {ElementTag.earth}),
    requiredStatusEffects: {StatusEffectId.slow},
    resultStatusEffect: StatusEffectId.root,
    rootDuration: 0.75,
    rootStrength: 0.5,
  ),
  SynergyDef(
    id: SynergyId.smearOnOil,
    name: 'Smear',
    description: 'Debuffs smear the oil into tender targets.',
    selectionHint: 'Oil + Debuff → Smear',
    triggerLabel: 'Smear!',
    triggerTags: TagSet(effects: {EffectTag.debuff}),
    requiredStatusEffects: {StatusEffectId.oilSoaked},
    resultStatusEffect: StatusEffectId.vulnerable,
    vulnerableDuration: 1.1,
    vulnerableMultiplier: 1.15,
  ),
];

final Map<SynergyId, SynergyDef> synergyDefsById = Map.unmodifiable({
  for (final def in synergyDefs) def.id: def,
});
