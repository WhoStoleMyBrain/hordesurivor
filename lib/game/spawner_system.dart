import 'dart:math' as math;

import 'package:flame/extensions.dart';

import '../data/ids.dart';
import '../data/enemy_defs.dart';
import '../data/tags.dart';
import 'enemy_pool.dart';
import 'enemy_state.dart';

class SpawnWave {
  const SpawnWave({
    required this.time,
    required this.count,
    this.enemyId,
    this.roleWeights,
  });

  final double time;
  final int count;
  final EnemyId? enemyId;
  final Map<EnemyRole, int>? roleWeights;
}

class SpawnerSystem {
  SpawnerSystem({
    required EnemyPool pool,
    required math.Random random,
    required Vector2 arenaSize,
    required List<SpawnWave> waves,
    required void Function(EnemyState) onSpawn,
    double spawnMinRadius = 120,
    double spawnMaxRadius = 200,
  }) : _pool = pool,
       _random = random,
       _arenaSize = arenaSize.clone(),
       _onSpawn = onSpawn,
       _spawnMinRadius = spawnMinRadius,
       _spawnMaxRadius = spawnMaxRadius {
    _rolePickers = _buildRolePickers();
    _resolvedWaves = _resolveWaves(waves);
  }

  final EnemyPool _pool;
  final math.Random _random;
  late final Map<EnemyRole, _WeightedPicker<EnemyId>> _rolePickers;
  late final List<_ResolvedWave> _resolvedWaves;
  final void Function(EnemyState) _onSpawn;
  final double _spawnMinRadius;
  final double _spawnMaxRadius;
  final Vector2 _arenaSize;
  final Vector2 _spawnPosition = Vector2.zero();
  double _elapsed = 0;
  int _waveIndex = 0;

  void update(double dt, Vector2 playerPosition) {
    _elapsed += dt;
    while (_waveIndex < _resolvedWaves.length &&
        _elapsed >= _resolvedWaves[_waveIndex].time) {
      final wave = _resolvedWaves[_waveIndex];
      for (var i = 0; i < wave.count; i++) {
        final enemyId = wave.enemyId ?? _pickEnemyFromRoles(wave.rolePicker);
        if (enemyId == null) {
          continue;
        }
        _spawnEnemy(enemyId, playerPosition);
      }
      _waveIndex++;
    }
  }

  void updateArenaSize(Vector2 size) {
    _arenaSize.setFrom(size);
  }

  void _spawnEnemy(EnemyId id, Vector2 playerPosition) {
    final def = enemyDefsById[id];
    if (def == null) {
      return;
    }
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
      spawnPosition: _spawnPosition,
      maxHp: def.maxHp,
      moveSpeed: def.moveSpeed,
      xpReward: def.xpReward,
      attackCooldown: def.attackCooldown,
      attackRange: def.attackRange,
      projectileSpeed: def.projectileSpeed,
      projectileDamage: def.projectileDamage,
      projectileSpread: def.projectileSpread,
      spawnCooldown: def.spawnCooldown,
      spawnCount: def.spawnCount,
      spawnRadius: def.spawnRadius,
      spawnEnemyId: def.spawnEnemyId,
    );
    _onSpawn(enemy);
  }

  List<_ResolvedWave> _resolveWaves(List<SpawnWave> waves) {
    return waves
        .map((wave) {
          final roleEntries = _buildRoleEntries(wave.roleWeights);
          final rolePicker = roleEntries.isEmpty
              ? null
              : _WeightedPicker(roleEntries);
          return _ResolvedWave(
            time: wave.time,
            count: wave.count,
            enemyId: wave.enemyId,
            rolePicker: rolePicker,
          );
        })
        .toList(growable: false);
  }

  Map<EnemyRole, _WeightedPicker<EnemyId>> _buildRolePickers() {
    final roleBuckets = <EnemyRole, List<_WeightedEntry<EnemyId>>>{};
    for (final def in enemyDefs) {
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
}

class _ResolvedWave {
  const _ResolvedWave({
    required this.time,
    required this.count,
    this.enemyId,
    this.rolePicker,
  });

  final double time;
  final int count;
  final EnemyId? enemyId;
  final _WeightedPicker<EnemyRole>? rolePicker;
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
