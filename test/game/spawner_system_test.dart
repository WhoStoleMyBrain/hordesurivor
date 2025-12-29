import 'dart:math' as math;

import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hordesurivor/data/ids.dart';
import 'package:hordesurivor/data/tags.dart';
import 'package:hordesurivor/game/enemy_pool.dart';
import 'package:hordesurivor/game/enemy_state.dart';
import 'package:hordesurivor/game/spawner_system.dart';

void main() {
  test('spawns waves based on elapsed time', () {
    final pool = EnemyPool(initialCapacity: 0);
    final spawned = <EnemyState>[];
    final spawner = SpawnerSystem(
      pool: pool,
      random: math.Random(1),
      arenaSize: Vector2(200, 200),
      waves: const [
        SpawnWave(time: 0, enemyId: EnemyId.imp, count: 2),
        SpawnWave(time: 1, enemyId: EnemyId.imp, count: 3),
      ],
      onSpawn: spawned.add,
    );

    spawner.update(0.5, Vector2(100, 100));
    expect(spawned.length, 2);

    spawner.update(0.6, Vector2(100, 100));
    expect(spawned.length, 5);
  });

  test('spawns weighted role waves', () {
    final pool = EnemyPool(initialCapacity: 0);
    final spawned = <EnemyState>[];
    final spawner = SpawnerSystem(
      pool: pool,
      random: math.Random(4),
      arenaSize: Vector2(200, 200),
      waves: const [
        SpawnWave(
          time: 0,
          count: 4,
          roleWeights: {
            EnemyRole.chaser: 2,
          },
        ),
      ],
      onSpawn: spawned.add,
    );

    spawner.update(0.1, Vector2(100, 100));
    expect(spawned.length, 4);
    expect(
      spawned.every((enemy) => enemy.role == EnemyRole.chaser),
      isTrue,
    );
  });
}
