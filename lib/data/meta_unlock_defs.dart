import 'ids.dart';
import 'stat_defs.dart';

class MetaUnlockDef {
  const MetaUnlockDef({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.modifiers,
  });

  final MetaUnlockId id;
  final String name;
  final String description;
  final int cost;
  final List<StatModifier> modifiers;
}

const List<MetaUnlockDef> metaUnlockDefs = [
  MetaUnlockDef(
    id: MetaUnlockId.extraReroll,
    name: 'Emergency Reroll Token',
    description: 'Gain +1 reroll for level-up selections each run.',
    cost: 40,
    modifiers: [
      StatModifier(stat: StatId.rerolls, amount: 1, kind: ModifierKind.flat),
    ],
  ),
  MetaUnlockDef(
    id: MetaUnlockId.extraChoice,
    name: 'Expanded Briefing',
    description: 'Gain +1 choice whenever you level up.',
    cost: 60,
    modifiers: [
      StatModifier(
        stat: StatId.choiceCount,
        amount: 1,
        kind: ModifierKind.flat,
      ),
    ],
  ),
];

final Map<MetaUnlockId, MetaUnlockDef> metaUnlockDefsById = {
  for (final def in metaUnlockDefs) def.id: def,
};
