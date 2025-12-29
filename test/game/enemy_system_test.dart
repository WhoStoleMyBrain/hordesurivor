import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hordesurivor/data/ids.dart';
import 'package:hordesurivor/game/enemy_pool.dart';
import 'package:hordesurivor/game/enemy_system.dart';

void main() {
  test('chaser moves toward player at move speed', () {
    final pool = EnemyPool(initialCapacity: 0);
    final enemy = pool.acquire(EnemyId.imp);
    enemy.reset(
      id: EnemyId.imp,
      spawnPosition: Vector2.zero(),
      maxHp: 5,
      moveSpeed: 10,
    );

    final system = EnemySystem(pool);
    system.update(1, Vector2(10, 0));

    expect(enemy.position.x, closeTo(10, 0.001));
    expect(enemy.position.y, closeTo(0, 0.001));
  });
}
