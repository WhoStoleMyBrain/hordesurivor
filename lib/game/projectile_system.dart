import 'package:flame/extensions.dart';

import '../data/ids.dart';
import '../data/skill_defs.dart';
import '../data/synergy_defs.dart';
import 'enemy_state.dart';
import 'player_state.dart';
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
    required void Function(
      EnemyState,
      double, {
      double knockbackX,
      double knockbackY,
      double knockbackForce,
      double knockbackDuration,
    })
    onEnemyHit,
    SpatialGrid? enemyGrid,
    required double enemyRadius,
    PlayerState? playerState,
    double playerRadius = 0,
    void Function(double)? onPlayerHit,
    void Function(SynergyDef, EnemyState)? onSynergyTriggered,
  }) {
    final active = _pool.active;
    for (var index = active.length - 1; index >= 0; index--) {
      final projectile = active[index];
      projectile.age += dt;
      projectile.position.addScaled(projectile.velocity, dt);

      if (projectile.fromEnemy) {
        final player = playerState;
        if (player != null && onPlayerHit != null) {
          if (player.deflectTimeRemaining > 0) {
            final dx = player.position.x - projectile.position.x;
            final dy = player.position.y - projectile.position.y;
            final combinedRadius = projectile.radius + player.deflectRadius;
            if (dx * dx + dy * dy <= combinedRadius * combinedRadius) {
              onDespawn(projectile);
              _pool.release(projectile);
              continue;
            }
          }
          final dx = player.position.x - projectile.position.x;
          final dy = player.position.y - projectile.position.y;
          final combinedRadius = projectile.radius + playerRadius;
          if (dx * dx + dy * dy <= combinedRadius * combinedRadius) {
            onPlayerHit(projectile.damage);
            onDespawn(projectile);
            _pool.release(projectile);
            continue;
          }
        }
      } else if (enemyGrid != null) {
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
            _applySynergies(
              projectile: projectile,
              enemy: enemy,
              onSynergyTriggered: onSynergyTriggered,
            );
            onEnemyHit(
              enemy,
              projectile.damage,
              knockbackX: projectile.velocity.x,
              knockbackY: projectile.velocity.y,
              knockbackForce: projectile.knockbackForce,
              knockbackDuration: projectile.knockbackDuration,
            );
            onDespawn(projectile);
            _pool.release(projectile);
            break;
          }
        }
        if (!projectile.active) {
          continue;
        }
      }

      final radius = projectile.radius;
      final outOfBounds =
          projectile.position.x < -radius ||
          projectile.position.y < -radius ||
          projectile.position.x > arenaSize.x + radius ||
          projectile.position.y > arenaSize.y + radius;
      if (projectile.age >= projectile.lifespan || outOfBounds) {
        onDespawn(projectile);
        _pool.release(projectile);
      }
    }
  }

  void _applySynergies({
    required ProjectileState projectile,
    required EnemyState enemy,
    void Function(SynergyDef, EnemyState)? onSynergyTriggered,
  }) {
    final sourceSkillId = projectile.sourceSkillId;
    if (sourceSkillId == null) {
      return;
    }
    final tags = skillDefsById[sourceSkillId]?.tags;
    if (tags == null || tags.isEmpty) {
      return;
    }
    for (final synergy in synergyDefs) {
      if (!synergy.matchesTags(tags)) {
        continue;
      }
      if (!_enemyMeetsStatusRequirements(enemy, synergy)) {
        continue;
      }
      if (synergy.resultStatusEffect == StatusEffectId.ignite) {
        if (projectile.igniteDuration <= 0 ||
            projectile.igniteDamagePerSecond <= 0) {
          continue;
        }
        enemy.applyIgnite(
          duration: projectile.igniteDuration,
          damagePerSecond: projectile.igniteDamagePerSecond,
        );
        onSynergyTriggered?.call(synergy, enemy);
      }
    }
  }

  bool _enemyMeetsStatusRequirements(EnemyState enemy, SynergyDef synergy) {
    for (final status in synergy.requiredStatusEffects) {
      if (!enemy.hasStatusEffect(status)) {
        return false;
      }
    }
    return true;
  }
}
