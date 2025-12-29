import 'package:flame/extensions.dart';

import 'enemy_pool.dart';

class EnemySystem {
  EnemySystem(this._pool);

  final EnemyPool _pool;

  void update(double dt, Vector2 playerPosition) {
    for (final enemy in _pool.active) {
      enemy.velocity
        ..setFrom(playerPosition)
        ..sub(enemy.position);
      if (enemy.velocity.length2 > 0) {
        enemy.velocity.normalize();
        enemy.velocity.scale(enemy.moveSpeed);
        enemy.position.addScaled(enemy.velocity, dt);
      }
    }
  }
}
