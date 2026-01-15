import 'ids.dart';

class SelectionPoolDef {
  const SelectionPoolDef({
    required this.id,
    required this.name,
    required this.description,
  });

  final SelectionPoolId id;
  final String name;
  final String description;
}

const List<SelectionPoolDef> selectionPoolDefs = [
  SelectionPoolDef(
    id: SelectionPoolId.skillPool,
    name: 'Skill Pool',
    description: 'Skills and related upgrades.',
  ),
  SelectionPoolDef(
    id: SelectionPoolId.itemPool,
    name: 'Item Pool',
    description: 'Items and tradeoff passives.',
  ),
  SelectionPoolDef(
    id: SelectionPoolId.futurePool,
    name: 'Future Pool',
    description: 'Placeholder pool for new progression tracks.',
  ),
];

final Map<SelectionPoolId, SelectionPoolDef> selectionPoolDefsById =
    Map.unmodifiable({for (final def in selectionPoolDefs) def.id: def});
