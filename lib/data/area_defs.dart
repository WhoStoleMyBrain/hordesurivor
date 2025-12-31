import 'ids.dart';
import 'tags.dart';

class StageSection {
  const StageSection({
    required this.startTime,
    required this.endTime,
    this.roleWeights = const {},
    this.enemyWeights = const {},
    this.variantWeights = const {},
    this.threatTier = 1,
    this.eliteChance = 0,
    this.note,
  });

  final double startTime;
  final double endTime;
  final Map<EnemyRole, int> roleWeights;
  final Map<EnemyId, int> enemyWeights;
  final Map<EnemyVariant, int> variantWeights;
  final int threatTier;
  final double eliteChance;
  final String? note;
}

class AreaDef {
  const AreaDef({
    required this.id,
    required this.name,
    required this.description,
    required this.recommendedLevel,
    required this.lootProfile,
    required this.stageDuration,
    required this.sections,
    this.spriteId,
    this.enemyThemes = const [],
    this.difficultyTiers = const ['Standard'],
  });

  final AreaId id;
  final String name;
  final String description;
  final String? spriteId;
  final int recommendedLevel;
  final String lootProfile;
  final List<String> enemyThemes;
  final List<String> difficultyTiers;
  final double stageDuration;
  final List<StageSection> sections;
}

const List<AreaDef> areaDefs = [
  AreaDef(
    id: AreaId.ashenOutskirts,
    name: 'Ashen Outskirts',
    description: 'Falling embers and crumbling demonstone outskirts.',
    spriteId: 'area_ashen_outskirts',
    recommendedLevel: 1,
    lootProfile: 'embers',
    enemyThemes: ['Demons'],
    stageDuration: 180,
    sections: [
      StageSection(
        startTime: 0,
        endTime: 60,
        roleWeights: {EnemyRole.chaser: 6, EnemyRole.ranged: 2},
        enemyWeights: {EnemyId.imp: 3, EnemyId.spitter: 1},
        threatTier: 1,
        eliteChance: 0.01,
        note: 'Warm-up pressure from imps.',
      ),
      StageSection(
        startTime: 60,
        endTime: 120,
        roleWeights: {
          EnemyRole.chaser: 5,
          EnemyRole.ranged: 3,
          EnemyRole.spawner: 2,
        },
        enemyWeights: {EnemyId.portalKeeper: 2},
        threatTier: 2,
        eliteChance: 0.03,
        note: 'Portal keepers start leaking reinforcements.',
      ),
      StageSection(
        startTime: 120,
        endTime: 180,
        roleWeights: {
          EnemyRole.chaser: 4,
          EnemyRole.ranged: 3,
          EnemyRole.spawner: 3,
        },
        enemyWeights: {EnemyId.hexer: 2},
        threatTier: 3,
        eliteChance: 0.05,
        note: 'Curses intensify with hexers.',
      ),
    ],
  ),
  AreaDef(
    id: AreaId.haloBreach,
    name: 'Halo Breach',
    description: 'Angelic foothold fractured by unstable light.',
    spriteId: 'area_halo_breach',
    recommendedLevel: 2,
    lootProfile: 'radiance',
    enemyThemes: ['Angels'],
    stageDuration: 210,
    sections: [
      StageSection(
        startTime: 0,
        endTime: 70,
        roleWeights: {EnemyRole.chaser: 5, EnemyRole.ranged: 3},
        enemyWeights: {EnemyId.zealot: 3, EnemyId.cherubArcher: 2},
        threatTier: 1,
        eliteChance: 0.01,
        note: 'Zealots advance in tight formation.',
      ),
      StageSection(
        startTime: 70,
        endTime: 140,
        roleWeights: {
          EnemyRole.chaser: 4,
          EnemyRole.ranged: 3,
          EnemyRole.supportHealer: 2,
          EnemyRole.supportBuffer: 1,
        },
        enemyWeights: {EnemyId.seraphMedic: 2, EnemyId.herald: 1},
        threatTier: 2,
        eliteChance: 0.03,
        note: 'Support angels bolster the frontline.',
      ),
      StageSection(
        startTime: 140,
        endTime: 210,
        roleWeights: {
          EnemyRole.chaser: 4,
          EnemyRole.ranged: 3,
          EnemyRole.zoner: 2,
          EnemyRole.elite: 1,
        },
        enemyWeights: {EnemyId.warden: 2, EnemyId.archonLancer: 1},
        threatTier: 3,
        eliteChance: 0.06,
        note: 'Light zones and elites control space.',
      ),
    ],
  ),
];

final Map<AreaId, AreaDef> areaDefsById = Map.unmodifiable({
  for (final def in areaDefs) def.id: def,
});
