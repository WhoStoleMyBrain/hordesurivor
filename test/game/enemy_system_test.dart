import 'dart:math' as math;

import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hordesurivor/data/ids.dart';
import 'package:hordesurivor/data/enemy_defs.dart';
import 'package:hordesurivor/game/enemy_pool.dart';
import 'package:hordesurivor/game/enemy_state.dart';
import 'package:hordesurivor/game/enemy_system.dart';
import 'package:hordesurivor/game/projectile_pool.dart';

void main() {
  EnemyState spawnEnemy(EnemyPool pool, EnemyId id, Vector2 position) {
    final def = enemyDefsById[id]!;
    final enemy = pool.acquire(id);
    enemy.reset(
      id: id,
      role: def.role,
      spawnPosition: position,
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
    return enemy;
  }

  test('chaser moves toward player at move speed', () {
    final pool = EnemyPool(initialCapacity: 0);
    final enemy = spawnEnemy(pool, EnemyId.imp, Vector2.zero());
    enemy.maxHp = 5;
    enemy.hp = 5;
    enemy.moveSpeed = 10;

    final system = EnemySystem(
      pool: pool,
      projectilePool: ProjectilePool(initialCapacity: 0),
      random: math.Random(1),
      onProjectileSpawn: (_) {},
      onSpawn: (_) {},
    );
    system.update(1, Vector2(10, 0), Vector2(200, 200));

    expect(enemy.position.x, closeTo(10, 0.001));
    expect(enemy.position.y, closeTo(0, 0.001));
  });

  test('ranged enemy fires projectiles when in range', () {
    final pool = EnemyPool(initialCapacity: 0);
    final projectilePool = ProjectilePool(initialCapacity: 0);
    spawnEnemy(pool, EnemyId.spitter, Vector2.zero());
    var projectileCount = 0;
    final system = EnemySystem(
      pool: pool,
      projectilePool: projectilePool,
      random: math.Random(2),
      onProjectileSpawn: (_) => projectileCount++,
      onSpawn: (_) {},
    );

    system.update(2, Vector2(120, 0), Vector2(200, 200));

    expect(projectileCount, 1);
  });

  test('spawner enemy emits imps on cooldown', () {
    final pool = EnemyPool(initialCapacity: 0);
    final projectilePool = ProjectilePool(initialCapacity: 0);
    spawnEnemy(pool, EnemyId.portalKeeper, Vector2(100, 100));
    var spawnCount = 0;
    final system = EnemySystem(
      pool: pool,
      projectilePool: projectilePool,
      random: math.Random(3),
      onProjectileSpawn: (_) {},
      onSpawn: (_) => spawnCount++,
    );

    system.update(4, Vector2(120, 120), Vector2(200, 200));

    expect(spawnCount, greaterThanOrEqualTo(2));
  });
}
