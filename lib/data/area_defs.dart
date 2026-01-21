import 'dart:ui';

import 'ids.dart';
import 'map_size.dart';
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
    required this.mapSize,
    required this.backgroundColor,
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
  final MapSize mapSize;
  final Color backgroundColor;
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
    mapSize: MapSize(width: 2400, height: 1700),
    backgroundColor: Color(0xFF17120F),
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
    stageDuration: 288,
    milestones: [
      StageMilestone(
        time: 150,
        label: 'Midway Surge',
        note: 'Pressure spike and bonus XP.',
        bonusWaveCount: 10,
        xpReward: 32,
      ),
      StageMilestone(
        time: 250,
        label: 'Final Push',
        note: 'Last pressure spike before extraction.',
        bonusWaveCount: 12,
        xpReward: 40,
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
        endTime: 72,
        roleWeights: {EnemyRole.chaser: 8},
        threatTier: 1,
        eliteChance: 0.01,
        note: 'Imps lead with a few spitters supporting.',
      ),
      StageSection(
        startTime: 72,
        endTime: 144,
        roleWeights: {
          EnemyRole.chaser: 7,
          EnemyRole.ranged: 2,
          EnemyRole.spawner: 1,
        },
        threatTier: 2,
        eliteChance: 0.03,
        note: 'Portal keepers join as low-rate pressure.',
      ),
      StageSection(
        startTime: 144,
        endTime: 216,
        roleWeights: {
          EnemyRole.chaser: 7,
          EnemyRole.ranged: 2,
          EnemyRole.spawner: 1,
          EnemyRole.disruptor: 1,
        },
        threatTier: 3,
        eliteChance: 0.05,
        note: 'Hexers and portal keepers complement the chase.',
      ),
      StageSection(
        startTime: 216,
        endTime: 288,
        roleWeights: {
          EnemyRole.chaser: 8,
          EnemyRole.ranged: 2,
          EnemyRole.spawner: 1,
          EnemyRole.disruptor: 1,
          EnemyRole.exploder: 1,
          EnemyRole.zoner: 1,
        },
        threatTier: 4,
        eliteChance: 0.06,
        note: 'Cinderlings and branders add late pressure.',
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
    mapSize: MapSize(width: 2600, height: 1900),
    backgroundColor: Color(0xFF101722),
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
    stageDuration: 286,
    milestones: [
      StageMilestone(
        time: 150,
        label: 'Midway Surge',
        note: 'Pressure spike and bonus XP.',
        bonusWaveCount: 11,
        xpReward: 34,
      ),
      StageMilestone(
        time: 250,
        label: 'Final Push',
        note: 'Push through the final light surge.',
        bonusWaveCount: 14,
        xpReward: 42,
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
        endTime: 72,
        roleWeights: {EnemyRole.chaser: 8, EnemyRole.ranged: 2},
        threatTier: 1,
        eliteChance: 0.01,
        note: 'Zealots advance with light archer support.',
      ),
      StageSection(
        startTime: 72,
        endTime: 144,
        roleWeights: {
          EnemyRole.chaser: 7,
          EnemyRole.ranged: 2,
          EnemyRole.supportHealer: 1,
        },
        threatTier: 2,
        eliteChance: 0.03,
        note: 'Medics arrive to stabilize the front.',
      ),
      StageSection(
        startTime: 144,
        endTime: 216,
        roleWeights: {
          EnemyRole.chaser: 7,
          EnemyRole.ranged: 2,
          EnemyRole.supportHealer: 1,
          EnemyRole.supportBuffer: 1,
          EnemyRole.zoner: 1,
        },
        threatTier: 3,
        eliteChance: 0.05,
        note: 'Supports and wardens pressure the lanes.',
      ),
      StageSection(
        startTime: 216,
        endTime: 286,
        roleWeights: {
          EnemyRole.chaser: 8,
          EnemyRole.ranged: 2,
          EnemyRole.supportHealer: 1,
          EnemyRole.supportBuffer: 1,
          EnemyRole.zoner: 1,
          EnemyRole.pattern: 1,
          EnemyRole.elite: 1,
        },
        threatTier: 4,
        eliteChance: 0.06,
        note: 'Late tide adds sentinels and lancers.',
      ),
    ],
  ),
];

final Map<AreaId, AreaDef> areaDefsById = Map.unmodifiable({
  for (final def in areaDefs) def.id: def,
});
