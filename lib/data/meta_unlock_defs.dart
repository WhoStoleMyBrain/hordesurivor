import 'ids.dart';
import 'stat_defs.dart';

class MetaUnlockPosition {
  const MetaUnlockPosition({required this.column, required this.row});

  final int column;
  final int row;
}

class MetaUnlockDef {
  const MetaUnlockDef({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.position,
    this.modifiers = const [],
    this.prerequisites = const [],
    this.unlockedSkills = const [],
    this.unlockedItems = const [],
  });

  final MetaUnlockId id;
  final String name;
  final String description;
  final int cost;
  final MetaUnlockPosition position;
  final List<StatModifier> modifiers;
  final List<MetaUnlockId> prerequisites;
  final List<SkillId> unlockedSkills;
  final List<ItemId> unlockedItems;
}

const List<MetaUnlockDef> metaUnlockDefs = [
  MetaUnlockDef(
    id: MetaUnlockId.fieldManual,
    name: 'Field Manual',
    description: 'Unlock the Wind Cutter skill for future runs.',
    cost: 10,
    position: MetaUnlockPosition(column: 2, row: 0),
    unlockedSkills: [SkillId.windCutter],
  ),
  MetaUnlockDef(
    id: MetaUnlockId.extraReroll,
    name: 'Emergency Reroll Token',
    description: 'Gain +1 reroll for level-up selections each run.',
    cost: 40,
    position: MetaUnlockPosition(column: 1, row: 1),
    prerequisites: [MetaUnlockId.fieldManual],
    modifiers: [
      StatModifier(stat: StatId.rerolls, amount: 1, kind: ModifierKind.flat),
    ],
  ),
  MetaUnlockDef(
    id: MetaUnlockId.steelShardsLicense,
    name: 'Steel Shards License',
    description: 'Unlock the Steel Shards skill for future runs.',
    cost: 35,
    position: MetaUnlockPosition(column: 2, row: 1),
    prerequisites: [MetaUnlockId.fieldManual],
    unlockedSkills: [SkillId.steelShards],
  ),
  MetaUnlockDef(
    id: MetaUnlockId.thermalCoilBlueprint,
    name: 'Thermal Coil Blueprint',
    description: 'Unlock the Thermal Coil item for future runs.',
    cost: 30,
    position: MetaUnlockPosition(column: 3, row: 1),
    prerequisites: [MetaUnlockId.fieldManual],
    unlockedItems: [ItemId.thermalCoil],
  ),
  MetaUnlockDef(
    id: MetaUnlockId.sporeSatchelKit,
    name: 'Spore Satchel Kit',
    description: 'Unlock the Spore Satchel item for future runs.',
    cost: 45,
    position: MetaUnlockPosition(column: 0, row: 2),
    prerequisites: [MetaUnlockId.extraReroll],
    unlockedItems: [ItemId.sporeSatchel],
  ),
  MetaUnlockDef(
    id: MetaUnlockId.extraChoice,
    name: 'Expanded Briefing',
    description: 'Gain +1 choice whenever you level up.',
    cost: 60,
    position: MetaUnlockPosition(column: 1, row: 2),
    prerequisites: [MetaUnlockId.extraReroll],
    modifiers: [
      StatModifier(
        stat: StatId.choiceCount,
        amount: 1,
        kind: ModifierKind.flat,
      ),
    ],
  ),
  MetaUnlockDef(
    id: MetaUnlockId.flameWaveTechnique,
    name: 'Flame Wave Technique',
    description: 'Unlock the Flame Wave skill for future runs.',
    cost: 70,
    position: MetaUnlockPosition(column: 2, row: 2),
    prerequisites: [MetaUnlockId.steelShardsLicense],
    unlockedSkills: [SkillId.flameWave],
  ),
  MetaUnlockDef(
    id: MetaUnlockId.hydraulicStabilizerPermit,
    name: 'Hydraulic Stabilizer Permit',
    description: 'Unlock the Hydraulic Stabilizer item for future runs.',
    cost: 50,
    position: MetaUnlockPosition(column: 3, row: 2),
    prerequisites: [MetaUnlockId.thermalCoilBlueprint],
    unlockedItems: [ItemId.hydraulicStabilizer],
  ),
  MetaUnlockDef(
    id: MetaUnlockId.gravelBootsPattern,
    name: 'Gravel Boots Pattern',
    description: 'Unlock the Gravel Boots item for future runs.',
    cost: 50,
    position: MetaUnlockPosition(column: 4, row: 2),
    prerequisites: [MetaUnlockId.thermalCoilBlueprint],
    unlockedItems: [ItemId.gravelBoots],
  ),
  MetaUnlockDef(
    id: MetaUnlockId.sporeBurstCulture,
    name: 'Spore Burst Culture',
    description: 'Unlock the Spore Burst skill for future runs.',
    cost: 80,
    position: MetaUnlockPosition(column: 0, row: 3),
    prerequisites: [MetaUnlockId.sporeSatchelKit],
    unlockedSkills: [SkillId.sporeBurst],
  ),
  MetaUnlockDef(
    id: MetaUnlockId.mercyCharmVow,
    name: 'Mercy Charm Vow',
    description: 'Unlock the Mercy Charm item for future runs.',
    cost: 75,
    position: MetaUnlockPosition(column: 1, row: 3),
    prerequisites: [MetaUnlockId.extraChoice],
    unlockedItems: [ItemId.mercyCharm],
  ),
  MetaUnlockDef(
    id: MetaUnlockId.frostNovaDiagram,
    name: 'Frost Nova Diagram',
    description: 'Unlock the Frost Nova skill for future runs.',
    cost: 90,
    position: MetaUnlockPosition(column: 2, row: 3),
    prerequisites: [MetaUnlockId.flameWaveTechnique],
    unlockedSkills: [SkillId.frostNova],
  ),
  MetaUnlockDef(
    id: MetaUnlockId.moltenBuckleForge,
    name: 'Molten Buckle Forge',
    description: 'Unlock the Molten Buckle item for future runs.',
    cost: 65,
    position: MetaUnlockPosition(column: 3, row: 3),
    prerequisites: [MetaUnlockId.hydraulicStabilizerPermit],
    unlockedItems: [ItemId.moltenBuckle],
  ),
  MetaUnlockDef(
    id: MetaUnlockId.serratedEdgeRecipe,
    name: 'Serrated Edge Recipe',
    description: 'Unlock the Serrated Edge item for future runs.',
    cost: 65,
    position: MetaUnlockPosition(column: 4, row: 3),
    prerequisites: [MetaUnlockId.gravelBootsPattern],
    unlockedItems: [ItemId.serratedEdge],
  ),
  MetaUnlockDef(
    id: MetaUnlockId.earthSpikesSurvey,
    name: 'Earth Spikes Survey',
    description: 'Unlock the Earth Spikes skill for future runs.',
    cost: 110,
    position: MetaUnlockPosition(column: 2, row: 4),
    prerequisites: [MetaUnlockId.frostNovaDiagram],
    unlockedSkills: [SkillId.earthSpikes],
  ),
];

final Map<MetaUnlockId, MetaUnlockDef> metaUnlockDefsById = {
  for (final def in metaUnlockDefs) def.id: def,
};
