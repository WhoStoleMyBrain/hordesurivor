import 'ids.dart';
import 'stat_defs.dart';

class StatLevelUpDef {
  const StatLevelUpDef({
    required this.id,
    required this.name,
    required this.description,
    required this.modifiers,
    this.weight = 10,
  });

  final StatLevelUpId id;
  final String name;
  final String description;
  final List<StatModifier> modifiers;
  final int weight;
}

const List<StatLevelUpDef> statLevelUpDefs = [
  StatLevelUpDef(
    id: StatLevelUpId.vitality,
    name: 'Minor Benediction: Vitality',
    description: 'Harden your resolve.',
    modifiers: [StatModifier(stat: StatId.maxHp, amount: 0.04)],
  ),
  StatLevelUpDef(
    id: StatLevelUpId.quickness,
    name: 'Minor Benediction: Quickness',
    description: 'Hasten your strikes.',
    modifiers: [StatModifier(stat: StatId.attackSpeed, amount: 0.03)],
  ),
  StatLevelUpDef(
    id: StatLevelUpId.footwork,
    name: 'Minor Benediction: Footwork',
    description: 'Keep your footing true.',
    modifiers: [StatModifier(stat: StatId.moveSpeedPercent, amount: 0.03)],
  ),
  StatLevelUpDef(
    id: StatLevelUpId.renewal,
    name: 'Minor Benediction: Renewal',
    description: 'A steadier recovery.',
    modifiers: [
      StatModifier(stat: StatId.hpRegen, amount: 0.2, kind: ModifierKind.flat),
    ],
  ),
  StatLevelUpDef(
    id: StatLevelUpId.warding,
    name: 'Minor Benediction: Warding',
    description: 'Brace against harm.',
    modifiers: [StatModifier(stat: StatId.defense, amount: 0.04)],
  ),
  StatLevelUpDef(
    id: StatLevelUpId.focus,
    name: 'Minor Benediction: Focus',
    description: 'Sharpen your cadence.',
    modifiers: [StatModifier(stat: StatId.attackSpeed, amount: 0.03)],
  ),
  StatLevelUpDef(
    id: StatLevelUpId.reach,
    name: 'Minor Benediction: Reach',
    description: 'Broaden your rites.',
    modifiers: [StatModifier(stat: StatId.aoeSize, amount: 0.04)],
  ),
];

final Map<StatLevelUpId, StatLevelUpDef> statLevelUpDefsById = {
  for (final def in statLevelUpDefs) def.id: def,
};
