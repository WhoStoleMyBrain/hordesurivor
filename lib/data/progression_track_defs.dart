import 'ids.dart';

class LevelCurve {
  const LevelCurve({required this.base, required this.growth});

  final int base;
  final int growth;

  int xpForLevel(int level) {
    return base + (level - 1) * growth;
  }
}

class ProgressionTrackDef {
  const ProgressionTrackDef({
    required this.id,
    required this.name,
    required this.currencyId,
    required this.selectionPoolId,
    required this.levelCurve,
    this.skipRewardFraction = 0.25,
  });

  final ProgressionTrackId id;
  final String name;
  final CurrencyId currencyId;
  final SelectionPoolId selectionPoolId;
  final LevelCurve levelCurve;
  final double skipRewardFraction;
}

const List<ProgressionTrackDef> progressionTrackDefs = [
  ProgressionTrackDef(
    id: ProgressionTrackId.skills,
    name: 'Skill Track',
    currencyId: CurrencyId.xp,
    selectionPoolId: SelectionPoolId.skillPool,
    levelCurve: LevelCurve(base: 40, growth: 15),
    skipRewardFraction: 0.2,
  ),
  ProgressionTrackDef(
    id: ProgressionTrackId.items,
    name: 'Item Track',
    currencyId: CurrencyId.gold,
    selectionPoolId: SelectionPoolId.itemPool,
    levelCurve: LevelCurve(base: 80, growth: 25),
    skipRewardFraction: 0.35,
  ),
];

final Map<ProgressionTrackId, ProgressionTrackDef> progressionTrackDefsById =
    Map.unmodifiable({for (final def in progressionTrackDefs) def.id: def});

final Map<CurrencyId, ProgressionTrackDef> progressionTracksByCurrencyId =
    Map.unmodifiable({
      for (final def in progressionTrackDefs) def.currencyId: def,
    });

final Map<SelectionPoolId, ProgressionTrackDef> progressionTracksByPoolId =
    Map.unmodifiable({
      for (final def in progressionTrackDefs) def.selectionPoolId: def,
    });
