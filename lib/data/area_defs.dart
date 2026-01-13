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

class StageMilestone {
  const StageMilestone({
    required this.time,
    required this.label,
    this.note,
    this.bonusWaveCount = 0,
    this.xpReward = 0,
  });

  final double time;
  final String label;
  final String? note;
  final int bonusWaveCount;
  final int xpReward;
}

class StageFinale {
  const StageFinale({
    required this.duration,
    required this.label,
    this.note,
    this.bonusWaveCount = 0,
  });

  final double duration;
  final String label;
  final String? note;
  final int bonusWaveCount;
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
    this.lootModifiers = const [],
    this.mapMutators = const [],
    this.contractPool = const [],
    this.milestones = const [],
    this.finale,
  });

  final AreaId id;
  final String name;
  final String description;
  final String? spriteId;
  final int recommendedLevel;
  final String lootProfile;
  final List<String> enemyThemes;
  final List<String> difficultyTiers;
  final List<String> lootModifiers;
  final List<String> mapMutators;
  final List<ContractId> contractPool;
  final double stageDuration;
  final List<StageSection> sections;
  final List<StageMilestone> milestones;
  final StageFinale? finale;
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
    lootModifiers: ['+Ember shards'],
    mapMutators: ['Falling embers'],
    contractPool: [
      ContractId.volleyPressure,
      ContractId.relentlessAdvance,
      ContractId.crossfireRush,
      ContractId.eliteSurge,
      ContractId.vanguardVolley,
    ],
    stageDuration: 180,
    milestones: [
      StageMilestone(
        time: 90,
        label: 'Midway Surge',
        note: 'Pressure spike and bonus XP.',
        bonusWaveCount: 8,
        xpReward: 24,
      ),
      StageMilestone(
        time: 150,
        label: 'Final Push',
        note: 'Last pressure spike before extraction.',
        bonusWaveCount: 10,
        xpReward: 32,
      ),
    ],
    finale: StageFinale(
      duration: 12,
      label: 'Extraction Hold',
      note: 'Survive the last infernal push.',
      bonusWaveCount: 14,
    ),
    sections: [
      StageSection(
        startTime: 0,
        endTime: 60,
        roleWeights: {EnemyRole.chaser: 6},
        enemyWeights: {EnemyId.imp: 3},
        threatTier: 1,
        eliteChance: 0.01,
        note: 'Warm-up pressure from imps only.',
      ),
      StageSection(
        startTime: 60,
        endTime: 120,
        roleWeights: {EnemyRole.chaser: 5, EnemyRole.ranged: 3},
        enemyWeights: {EnemyId.spitter: 2},
        threatTier: 2,
        eliteChance: 0.03,
        note: 'Spitters join the chase.',
      ),
      StageSection(
        startTime: 120,
        endTime: 180,
        roleWeights: {
          EnemyRole.chaser: 4,
          EnemyRole.ranged: 3,
          EnemyRole.spawner: 3,
        },
        enemyWeights: {EnemyId.portalKeeper: 2, EnemyId.hexer: 1},
        threatTier: 3,
        eliteChance: 0.05,
        note: 'Final surge: portal keepers and hexers.',
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
    lootModifiers: ['+Radiant sigils'],
    mapMutators: ['Unstable light zones'],
    contractPool: [
      ContractId.supportUplink,
      ContractId.coordinatedAssault,
      ContractId.siegeFormation,
      ContractId.commandingPresence,
      ContractId.radiantBarrage,
      ContractId.radiantPursuit,
    ],
    stageDuration: 210,
    milestones: [
      StageMilestone(
        time: 105,
        label: 'Midway Surge',
        note: 'Pressure spike and bonus XP.',
        bonusWaveCount: 9,
        xpReward: 26,
      ),
      StageMilestone(
        time: 175,
        label: 'Final Push',
        note: 'Push through the final light surge.',
        bonusWaveCount: 12,
        xpReward: 36,
      ),
    ],
    finale: StageFinale(
      duration: 14,
      label: 'Sanctum Stand',
      note: 'Hold against the final light tide.',
      bonusWaveCount: 16,
    ),
    sections: [
      StageSection(
        startTime: 0,
        endTime: 70,
        roleWeights: {EnemyRole.chaser: 5},
        enemyWeights: {EnemyId.zealot: 3},
        threatTier: 1,
        eliteChance: 0.01,
        note: 'Zealots advance in tight formation.',
      ),
      StageSection(
        startTime: 70,
        endTime: 140,
        roleWeights: {EnemyRole.chaser: 4, EnemyRole.ranged: 3},
        enemyWeights: {EnemyId.cherubArcher: 2},
        threatTier: 2,
        eliteChance: 0.03,
        note: 'Archers reinforce the breach.',
      ),
      StageSection(
        startTime: 140,
        endTime: 210,
        roleWeights: {
          EnemyRole.chaser: 4,
          EnemyRole.ranged: 3,
          EnemyRole.supportHealer: 2,
          EnemyRole.supportBuffer: 1,
          EnemyRole.zoner: 2,
          EnemyRole.elite: 1,
        },
        enemyWeights: {
          EnemyId.seraphMedic: 2,
          EnemyId.herald: 1,
          EnemyId.warden: 2,
          EnemyId.archonLancer: 1,
        },
        threatTier: 3,
        eliteChance: 0.06,
        note: 'Final surge: supports, light zones, elites.',
      ),
    ],
  ),
];

final Map<AreaId, AreaDef> areaDefsById = Map.unmodifiable({
  for (final def in areaDefs) def.id: def,
});
