import 'package:flame/extensions.dart';

import 'projectile_pool.dart';
import 'projectile_state.dart';

class ProjectileSystem {
  ProjectileSystem(this._pool);

  final ProjectilePool _pool;

  void update(
    double dt,
    Vector2 arenaSize, {
    required void Function(ProjectileState) onDespawn,
  }) {
    final active = _pool.active;
    for (var index = active.length - 1; index >= 0; index--) {
      final projectile = active[index];
      projectile.age += dt;
      projectile.position.addScaled(projectile.velocity, dt);
      final radius = projectile.radius;
      final outOfBounds = projectile.position.x < -radius ||
          projectile.position.y < -radius ||
          projectile.position.x > arenaSize.x + radius ||
          projectile.position.y > arenaSize.y + radius;
      if (projectile.age >= projectile.lifespan || outOfBounds) {
        onDespawn(projectile);
        _pool.release(projectile);
      }
    }
  }
}
