import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hordesurivor/data/ids.dart';
import 'package:hordesurivor/game/enemy_pool.dart';
import 'package:hordesurivor/game/enemy_state.dart';
import 'package:hordesurivor/game/spatial_grid.dart';

void main() {
  test('enemy pool reuses released instances', () {
    final pool = EnemyPool(initialCapacity: 1);
    final first = pool.acquire(EnemyId.imp);
    pool.release(first);

    final reused = pool.acquire(EnemyId.imp);

    expect(identical(first, reused), isTrue);
  });

  test('spatial grid queries reuse the output buffer', () {
    final grid = SpatialGrid(cellSize: 64);
    final enemyA = EnemyState(id: EnemyId.imp)
      ..active = true
      ..position.setValues(10, 10);
    final enemyB = EnemyState(id: EnemyId.imp)
      ..active = true
      ..position.setValues(80, 10);

    grid.rebuild([enemyA, enemyB]);

    final buffer = <EnemyState>[];
    final result = grid.queryCircle(Vector2(32, 16), 96, buffer);

    expect(identical(buffer, result), isTrue);
    expect(buffer, containsAll(<EnemyState>[enemyA, enemyB]));

    grid.rebuild([]);
    grid.queryCircle(Vector2.zero(), 32, buffer);

    expect(buffer, isEmpty);
  });
}
