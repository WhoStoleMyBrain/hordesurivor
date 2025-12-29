import 'package:flame/extensions.dart';

import 'enemy_state.dart';
import 'projectile_pool.dart';
import 'projectile_state.dart';
import 'spatial_grid.dart';

class ProjectileSystem {
  ProjectileSystem(this._pool);

  final ProjectilePool _pool;
  final List<EnemyState> _queryBuffer = [];

  void update(
    double dt,
    Vector2 arenaSize, {
    required void Function(ProjectileState) onDespawn,
    required void Function(EnemyState, double) onEnemyHit,
    SpatialGrid? enemyGrid,
    required double enemyRadius,
  }) {
    final active = _pool.active;
    for (var index = active.length - 1; index >= 0; index--) {
      final projectile = active[index];
      projectile.age += dt;
      projectile.position.addScaled(projectile.velocity, dt);

      var hitEnemy = false;
      if (enemyGrid != null) {
        final combinedRadius = projectile.radius + enemyRadius;
        final combinedRadiusSquared = combinedRadius * combinedRadius;
        final candidates = enemyGrid.queryCircle(
          projectile.position,
          combinedRadius,
          _queryBuffer,
        );
        for (final enemy in candidates) {
          if (!enemy.active) {
            continue;
          }
          final dx = enemy.position.x - projectile.position.x;
          final dy = enemy.position.y - projectile.position.y;
          final distanceSquared = dx * dx + dy * dy;
          if (distanceSquared <= combinedRadiusSquared) {
            onEnemyHit(enemy, projectile.damage);
            onDespawn(projectile);
            _pool.release(projectile);
            hitEnemy = true;
            break;
          }
        }
      }

      if (hitEnemy) {
        continue;
      }

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
