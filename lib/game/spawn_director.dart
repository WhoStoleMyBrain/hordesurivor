import 'dart:math' as math;

import '../data/area_defs.dart';
import '../data/ids.dart';
import '../data/tags.dart';
import 'progression_system.dart';

class SpawnTuning {
  const SpawnTuning({
    required this.roleWeights,
    required this.enemyWeights,
    required this.variantWeights,
  });

  final Map<EnemyRole, int> roleWeights;
  final Map<EnemyId, int> enemyWeights;
  final Map<EnemyVariant, int> variantWeights;
}

class SpawnDirector {
  SpawnDirector({
    required ProgressionSystem progressionSystem,
    double transitionDuration = 8,
  }) : _progressionSystem = progressionSystem,
       _transitionDuration = transitionDuration;

  final ProgressionSystem _progressionSystem;
  final double _transitionDuration;

  SpawnTuning tuneSection({
    required StageSection section,
    required double sectionDuration,
    StageSection? previousSection,
    required double timeIntoSection,
  }) {
    final transition = math.min(_transitionDuration, sectionDuration * 0.5);
    final blend = transition <= 0
        ? 1.0
        : (timeIntoSection / transition).clamp(0.0, 1.0);
    final blendedRoles = _blendWeights(
      previousSection?.roleWeights ?? const <EnemyRole, int>{},
      section.roleWeights,
      blend,
    );
    final blendedEnemies = _blendWeights(
      previousSection?.enemyWeights ?? const <EnemyId, int>{},
      section.enemyWeights,
      blend,
    );
    final blendedVariants = _blendWeights(
      previousSection?.variantWeights ?? const <EnemyVariant, int>{},
      section.variantWeights,
      blend,
    );
    final tunedRoles = _applyThreatTier(
      blendedRoles,
      section.threatTier,
      _progressionSystem.trackForId(ProgressionTrackId.skills).level,
    );
    final resolvedVariants = _resolveVariantWeights(
      blendedVariants,
      section,
      _progressionSystem.trackForId(ProgressionTrackId.skills).level,
    );
    return SpawnTuning(
      roleWeights: tunedRoles,
      enemyWeights: blendedEnemies,
      variantWeights: resolvedVariants,
    );
  }

  Map<EnemyRole, int> _applyThreatTier(
    Map<EnemyRole, int> base,
    int threatTier,
    int playerLevel,
  ) {
    if (base.isEmpty) {
      return base;
    }
    final levelBonus = math.max(0, (playerLevel - 1) ~/ 3);
    final tierBoost = math.max(0, (playerLevel - 1) ~/ 6);
    final effectiveTier = (threatTier + tierBoost).clamp(1, 3);
    final tuned = <EnemyRole, int>{};
    base.forEach((role, weight) {
      final roleTier = _roleTiers[role] ?? 1;
      if (roleTier > effectiveTier) {
        return;
      }
      var adjusted = weight;
      if (roleTier >= 2) {
        adjusted += levelBonus;
      }
      if (adjusted > 0) {
        tuned[role] = adjusted;
      }
    });
    return tuned.isEmpty ? base : tuned;
  }

  Map<EnemyVariant, int> _resolveVariantWeights(
    Map<EnemyVariant, int> blended,
    StageSection section,
    int playerLevel,
  ) {
    if (blended.isNotEmpty) {
      return blended;
    }
    final tierBoost = math.max(0, section.threatTier - 1) * 0.01;
    final levelBoost = math.max(0, playerLevel - 1) * 0.002;
    final chance = (section.eliteChance + tierBoost + levelBoost).clamp(
      0.0,
      0.2,
    );
    final championWeight = (chance * 100).round();
    if (championWeight <= 0) {
      return const {EnemyVariant.base: 100};
    }
    final baseWeight = math.max(1, 100 - championWeight);
    return {
      EnemyVariant.base: baseWeight,
      EnemyVariant.champion: championWeight,
    };
  }

  Map<T, int> _blendWeights<T>(Map<T, int> from, Map<T, int> to, double t) {
    if (from.isEmpty) {
      return Map<T, int>.from(to);
    }
    if (to.isEmpty) {
      return Map<T, int>.from(from);
    }
    final blended = <T, int>{};
    final keys = {...from.keys, ...to.keys};
    for (final key in keys) {
      final a = from[key] ?? 0;
      final b = to[key] ?? 0;
      final value = (a * (1 - t) + b * t).round();
      if (value > 0) {
        blended[key] = value;
      }
    }
    return blended;
  }

  static const Map<EnemyRole, int> _roleTiers = {
    EnemyRole.chaser: 1,
    EnemyRole.ranged: 1,
    EnemyRole.spawner: 1,
    EnemyRole.disruptor: 2,
    EnemyRole.zoner: 2,
    EnemyRole.exploder: 2,
    EnemyRole.supportHealer: 2,
    EnemyRole.supportBuffer: 2,
    EnemyRole.pattern: 2,
    EnemyRole.elite: 3,
  };
}
