import 'dart:math' as math;

import 'package:flame/extensions.dart';

import '../data/ids.dart';
import '../data/enemy_defs.dart';
import 'enemy_pool.dart';
import 'enemy_state.dart';

class SpawnWave {
  const SpawnWave({
    required this.time,
    required this.enemyId,
    required this.count,
  });

  final double time;
  final EnemyId enemyId;
  final int count;
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
  })  : _pool = pool,
        _random = random,
        _arenaSize = arenaSize.clone(),
        _waves = waves,
        _onSpawn = onSpawn,
        _spawnMinRadius = spawnMinRadius,
        _spawnMaxRadius = spawnMaxRadius;

  final EnemyPool _pool;
  final math.Random _random;
  final List<SpawnWave> _waves;
  final void Function(EnemyState) _onSpawn;
  final double _spawnMinRadius;
  final double _spawnMaxRadius;
  final Vector2 _arenaSize;
  final Vector2 _spawnPosition = Vector2.zero();
  double _elapsed = 0;
  int _waveIndex = 0;

  void update(double dt, Vector2 playerPosition) {
    _elapsed += dt;
    while (_waveIndex < _waves.length && _elapsed >= _waves[_waveIndex].time) {
      final wave = _waves[_waveIndex];
      for (var i = 0; i < wave.count; i++) {
        _spawnEnemy(wave.enemyId, playerPosition);
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
    final radius = _spawnMinRadius +
        _random.nextDouble() * (_spawnMaxRadius - _spawnMinRadius);
    _spawnPosition
      ..setValues(math.cos(angle) * radius, math.sin(angle) * radius)
      ..add(playerPosition);
    _spawnPosition.x = _spawnPosition.x.clamp(0.0, _arenaSize.x);
    _spawnPosition.y = _spawnPosition.y.clamp(0.0, _arenaSize.y);

    final enemy = _pool.acquire(id);
    enemy.reset(
      id: id,
      spawnPosition: _spawnPosition,
      maxHp: 15,
      moveSpeed: 28,
      xpReward: def.xpReward,
    );
    _onSpawn(enemy);
  }
}
