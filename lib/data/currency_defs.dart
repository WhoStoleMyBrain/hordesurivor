import 'ids.dart';

class CurrencyDef {
  const CurrencyDef({
    required this.id,
    required this.name,
    required this.description,
    required this.iconId,
    required this.colorKey,
    this.dropWeight = 1.0,
  });

  final CurrencyId id;
  final String name;
  final String description;
  final String iconId;
  final String colorKey;
  final double dropWeight;
}

const List<CurrencyDef> currencyDefs = [
  CurrencyDef(
    id: CurrencyId.xp,
    name: 'Experience',
    description: 'Progresses the skill track toward new powers.',
    iconId: 'icon_xp',
    colorKey: 'xp',
    dropWeight: 1.0,
  ),
  CurrencyDef(
    id: CurrencyId.gold,
    name: 'Salvage',
    description: 'Funds item acquisition and refinements.',
    iconId: 'icon_gold',
    colorKey: 'gold',
    dropWeight: 0.7,
  ),
];

final Map<CurrencyId, CurrencyDef> currencyDefsById = Map.unmodifiable({
  for (final def in currencyDefs) def.id: def,
});
