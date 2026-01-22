import 'dart:math' as math;

import 'package:flame/extensions.dart';

import '../data/enemy_defs.dart';
import '../data/enemy_variants.dart';
import '../data/ids.dart';
import '../data/tags.dart';
import 'enemy_pool.dart';
import 'enemy_state.dart';

class SpawnWave {
  const SpawnWave({
    required this.time,
    required this.count,
    this.enemyId,
    this.roleWeights,
    this.enemyWeights,
    this.variantWeights,
  });

  final double time;
  final int count;
  final EnemyId? enemyId;
  final Map<EnemyRole, int>? roleWeights;
  final Map<EnemyId, int>? enemyWeights;
  final Map<EnemyVariant, int>? variantWeights;
}

class SpawnerSystem {
  SpawnerSystem({
    required EnemyPool pool,
    required math.Random random,
    required Vector2 arenaSize,
    required List<SpawnWave> waves,
    required void Function(EnemyState) onSpawn,
    Set<MetaUnlockId> unlockedMeta = const {},
    double championChance = 0.05,
    int maxChampions = 2,
    double spawnMinRadius = 120,
    double spawnMaxRadius = 200,
  }) : _pool = pool,
       _random = random,
       _arenaSize = arenaSize.clone(),
       _onSpawn = onSpawn,
       _unlockedMeta = unlockedMeta.toSet(),
       _championChance = championChance,
       _maxChampions = maxChampions,
       _spawnMinRadius = spawnMinRadius,
       _spawnMaxRadius = spawnMaxRadius {
    _rolePickers = _buildRolePickers();
    _resolvedWaves = _resolveWaves(waves);
  }

  final EnemyPool _pool;
  final math.Random _random;
  late Map<EnemyRole, _WeightedPicker<EnemyId>> _rolePickers;
  late List<_ResolvedWave> _resolvedWaves;
  final void Function(EnemyState) _onSpawn;
  Set<MetaUnlockId> _unlockedMeta;
  double _championChance;
  final int _maxChampions;
  final double _spawnMinRadius;
  final double _spawnMaxRadius;
  final Vector2 _arenaSize;
  final Vector2 _spawnPosition = Vector2.zero();
  double _projectileSpeedMultiplier = 1.0;
  double _moveSpeedMultiplier = 1.0;
  double _elapsed = 0;
  int _waveIndex = 0;

  void resetWaves(List<SpawnWave> waves) {
    _resolvedWaves = _resolveWaves(waves);
    _elapsed = 0;
    _waveIndex = 0;
  }

  void setUnlockedMeta(Set<MetaUnlockId> unlockedMeta) {
    _unlockedMeta = unlockedMeta.toSet();
    _rolePickers = _buildRolePickers();
  }

  void update(double dt, Vector2 playerPosition) {
    _elapsed += dt;
    while (_waveIndex < _resolvedWaves.length &&
        _elapsed >= _resolvedWaves[_waveIndex].time) {
      _spawnResolvedWave(_resolvedWaves[_waveIndex], playerPosition);
      _waveIndex++;
    }
  }

  void updateArenaSize(Vector2 size) {
    _arenaSize.setFrom(size);
  }

  void setProjectileSpeedMultiplier(double multiplier) {
    _projectileSpeedMultiplier = multiplier <= 0 ? 1.0 : multiplier;
  }

  void setMoveSpeedMultiplier(double multiplier) {
    _moveSpeedMultiplier = multiplier <= 0 ? 1.0 : multiplier;
  }

  void setChampionChance(double chance) {
    _championChance = chance.clamp(0.0, 1.0);
  }

  void spawnBurst(SpawnWave wave, Vector2 playerPosition) {
    final resolved = _resolveWave(wave);
    _spawnResolvedWave(resolved, playerPosition);
  }

  void _spawnEnemy(
    EnemyId id,
    Vector2 playerPosition, {
    required EnemyVariant variant,
  }) {
    final def = enemyDefsById[id];
    if (def == null || !_isEnemyUnlocked(def)) {
      return;
    }
    final variantDef =
        enemyVariantDefsById[variant] ??
        enemyVariantDefsById[EnemyVariant.base]!;
    final angle = _random.nextDouble() * math.pi * 2;
    final radius =
        _spawnMinRadius +
        _random.nextDouble() * (_spawnMaxRadius - _spawnMinRadius);
    _spawnPosition
      ..setValues(math.cos(angle) * radius, math.sin(angle) * radius)
      ..add(playerPosition);
    _spawnPosition.x = _spawnPosition.x.clamp(0.0, _arenaSize.x);
    _spawnPosition.y = _spawnPosition.y.clamp(0.0, _arenaSize.y);

    final enemy = _pool.acquire(id);
    enemy.reset(
      id: id,
      role: def.role,
      variant: variant,
      spawnPosition: _spawnPosition,
      maxHp: def.maxHp * variantDef.maxHpMultiplier,
      moveSpeed:
          def.moveSpeed * variantDef.moveSpeedMultiplier * _moveSpeedMultiplier,
      xpReward: (def.xpReward * variantDef.xpRewardMultiplier).round(),
      attackCooldown: def.attackCooldown * variantDef.attackCooldownMultiplier,
      attackRange: def.attackRange,
      projectileSpeed: def.projectileSpeed * _projectileSpeedMultiplier,
      projectileDamage:
          def.projectileDamage * variantDef.projectileDamageMultiplier,
      projectileSpread: def.projectileSpread,
      spawnCooldown: def.spawnCooldown,
      spawnCount: def.spawnCount,
      spawnRadius: def.spawnRadius,
      spawnEnemyId: def.spawnEnemyId,
      goldCurrencyReward:
          (def.goldCurrencyReward * variantDef.xpRewardMultiplier).round(),
      goldShopXpReward: (def.goldShopXpReward * variantDef.xpRewardMultiplier)
          .round(),
      spawnRewardMultiplier: def.spawnRewardMultiplier,
    );
    _onSpawn(enemy);
  }

  EnemyVariant _pickVariant(_WeightedPicker<EnemyVariant>? variantPicker) {
    if (variantPicker != null && variantPicker.totalWeight > 0) {
      return variantPicker.pick(_random);
    }
    if (_championChance <= 0 || _maxChampions <= 0) {
      return EnemyVariant.base;
    }
    if (_random.nextDouble() > _championChance) {
      return EnemyVariant.base;
    }
    final activeChampions = _pool.active.where(
      (enemy) => enemy.variant == EnemyVariant.champion,
    );
    if (activeChampions.length >= _maxChampions) {
      return EnemyVariant.base;
    }
    return EnemyVariant.champion;
  }

  List<_ResolvedWave> _resolveWaves(List<SpawnWave> waves) {
    return waves.map(_resolveWave).toList(growable: false);
  }

  _ResolvedWave _resolveWave(SpawnWave wave) {
    final roleEntries = _buildRoleEntries(wave.roleWeights);
    final rolePicker = roleEntries.isEmpty
        ? null
        : _WeightedPicker(roleEntries);
    final enemyEntries = _buildEnemyEntries(wave.enemyWeights);
    final enemyPicker = enemyEntries.isEmpty
        ? null
        : _WeightedPicker(enemyEntries);
    final variantEntries = _buildVariantEntries(wave.variantWeights);
    final variantPicker = variantEntries.isEmpty
        ? null
        : _WeightedPicker(variantEntries);
    return _ResolvedWave(
      time: wave.time,
      count: wave.count,
      enemyId: wave.enemyId,
      rolePicker: rolePicker,
      enemyPicker: enemyPicker,
      variantPicker: variantPicker,
    );
  }

  void _spawnResolvedWave(_ResolvedWave wave, Vector2 playerPosition) {
    for (var i = 0; i < wave.count; i++) {
      final enemyId =
          wave.enemyId ??
          _pickEnemyFromEnemies(wave.enemyPicker) ??
          _pickEnemyFromRoles(wave.rolePicker);
      if (enemyId == null) {
        continue;
      }
      final variant = _pickVariant(wave.variantPicker);
      _spawnEnemy(enemyId, playerPosition, variant: variant);
    }
  }

  Map<EnemyRole, _WeightedPicker<EnemyId>> _buildRolePickers() {
    final roleBuckets = <EnemyRole, List<_WeightedEntry<EnemyId>>>{};
    for (final def in enemyDefs) {
      if (!_isEnemyUnlocked(def)) {
        continue;
      }
      final entries = roleBuckets.putIfAbsent(def.role, () => []);
      entries.add(_WeightedEntry(def.id, def.weight));
    }
    return {
      for (final entry in roleBuckets.entries)
        entry.key: _WeightedPicker(entry.value),
    };
  }

  List<_WeightedEntry<EnemyRole>> _buildRoleEntries(
    Map<EnemyRole, int>? roleWeights,
  ) {
    if (roleWeights == null || roleWeights.isEmpty) {
      return const [];
    }
    final entries = <_WeightedEntry<EnemyRole>>[];
    roleWeights.forEach((role, weight) {
      if (weight <= 0) {
        return;
      }
      final picker = _rolePickers[role];
      if (picker == null || picker.totalWeight == 0) {
        return;
      }
      entries.add(_WeightedEntry(role, weight));
    });
    return entries;
  }

  List<_WeightedEntry<EnemyId>> _buildEnemyEntries(
    Map<EnemyId, int>? enemyWeights,
  ) {
    if (enemyWeights == null || enemyWeights.isEmpty) {
      return const [];
    }
    final entries = <_WeightedEntry<EnemyId>>[];
    enemyWeights.forEach((enemyId, weight) {
      if (weight <= 0) {
        return;
      }
      final def = enemyDefsById[enemyId];
      if (def == null || !_isEnemyUnlocked(def)) {
        return;
      }
      entries.add(_WeightedEntry(enemyId, weight));
    });
    return entries;
  }

  bool _isEnemyUnlocked(EnemyDef def) {
    final unlockId = def.metaUnlockId;
    if (unlockId == null) {
      return true;
    }
    return _unlockedMeta.contains(unlockId);
  }

  List<_WeightedEntry<EnemyVariant>> _buildVariantEntries(
    Map<EnemyVariant, int>? variantWeights,
  ) {
    if (variantWeights == null || variantWeights.isEmpty) {
      return const [];
    }
    final entries = <_WeightedEntry<EnemyVariant>>[];
    variantWeights.forEach((variant, weight) {
      if (weight <= 0) {
        return;
      }
      entries.add(_WeightedEntry(variant, weight));
    });
    return entries;
  }

  EnemyId? _pickEnemyFromRoles(_WeightedPicker<EnemyRole>? rolePicker) {
    if (rolePicker == null || rolePicker.totalWeight == 0) {
      return null;
    }
    final role = rolePicker.pick(_random);
    final picker = _rolePickers[role];
    if (picker == null || picker.totalWeight == 0) {
      return null;
    }
    return picker.pick(_random);
  }

  EnemyId? _pickEnemyFromEnemies(_WeightedPicker<EnemyId>? enemyPicker) {
    if (enemyPicker == null || enemyPicker.totalWeight == 0) {
      return null;
    }
    return enemyPicker.pick(_random);
  }
}

class _ResolvedWave {
  const _ResolvedWave({
    required this.time,
    required this.count,
    this.enemyId,
    this.rolePicker,
    this.enemyPicker,
    this.variantPicker,
  });

  final double time;
  final int count;
  final EnemyId? enemyId;
  final _WeightedPicker<EnemyRole>? rolePicker;
  final _WeightedPicker<EnemyId>? enemyPicker;
  final _WeightedPicker<EnemyVariant>? variantPicker;
}

class _WeightedEntry<T> {
  const _WeightedEntry(this.value, this.weight);

  final T value;
  final int weight;
}

class _WeightedPicker<T> {
  _WeightedPicker(List<_WeightedEntry<T>> entries)
    : _entries = entries,
      totalWeight = entries.fold<int>(0, (sum, entry) => sum + entry.weight);

  final List<_WeightedEntry<T>> _entries;
  final int totalWeight;

  T pick(math.Random random) {
    final roll = random.nextInt(totalWeight);
    var cumulative = 0;
    for (final entry in _entries) {
      cumulative += entry.weight;
      if (roll < cumulative) {
        return entry.value;
      }
    }
    return _entries.last.value;
  }
}
