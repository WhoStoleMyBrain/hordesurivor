import 'dart:ui';

import 'ids.dart';

class MapBackgroundDef {
  const MapBackgroundDef({
    required this.id,
    required this.name,
    required this.baseColor,
    required this.seed,
    required this.tileSize,
    required this.speckColors,
    required this.speckCount,
    required this.speckMinSize,
    required this.speckMaxSize,
    required this.blotchColors,
    required this.blotchCount,
    required this.blotchMinRadius,
    required this.blotchMaxRadius,
  });

  final MapBackgroundId id;
  final String name;
  final Color baseColor;
  final int seed;
  final int tileSize;
  final List<Color> speckColors;
  final int speckCount;
  final double speckMinSize;
  final double speckMaxSize;
  final List<Color> blotchColors;
  final int blotchCount;
  final double blotchMinRadius;
  final double blotchMaxRadius;
}

const List<MapBackgroundDef> mapBackgroundDefs = [
  MapBackgroundDef(
    id: MapBackgroundId.ashenOutskirts,
    name: 'Ashen Outskirts',
    baseColor: Color(0xFF17120F),
    seed: 4213,
    tileSize: 220,
    speckColors: [Color(0xFF120D0B), Color(0xFF1F1713), Color(0xFF2B211B)],
    speckCount: 260,
    speckMinSize: 1,
    speckMaxSize: 2.6,
    blotchColors: [Color(0xFF2B2119), Color(0xFF362A21), Color(0xFF201815)],
    blotchCount: 18,
    blotchMinRadius: 10,
    blotchMaxRadius: 26,
  ),
  MapBackgroundDef(
    id: MapBackgroundId.haloBreach,
    name: 'Halo Breach',
    baseColor: Color(0xFF101722),
    seed: 8721,
    tileSize: 240,
    speckColors: [Color(0xFF0A111B), Color(0xFF162131), Color(0xFF1F2B40)],
    speckCount: 300,
    speckMinSize: 1,
    speckMaxSize: 2.8,
    blotchColors: [Color(0xFF1A2638), Color(0xFF243246), Color(0xFF0F1B2B)],
    blotchCount: 20,
    blotchMinRadius: 12,
    blotchMaxRadius: 28,
  ),
];

final Map<MapBackgroundId, MapBackgroundDef> mapBackgroundDefsById =
    Map.unmodifiable({for (final def in mapBackgroundDefs) def.id: def});
