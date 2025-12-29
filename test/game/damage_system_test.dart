import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hordesurivor/data/enemy_defs.dart';
import 'package:hordesurivor/data/ids.dart';
import 'package:hordesurivor/game/damage_system.dart';
import 'package:hordesurivor/game/enemy_pool.dart';
import 'package:hordesurivor/game/player_state.dart';

void main() {
  test('damage system applies enemy damage and signals defeat', () {
    final pool = EnemyPool(initialCapacity: 0);
    final enemy = pool.acquire(EnemyId.imp);
    final def = enemyDefsById[EnemyId.imp]!;
    enemy.reset(
      id: EnemyId.imp,
      role: def.role,
      spawnPosition: Vector2.zero(),
      maxHp: 10,
      moveSpeed: 0,
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

    final damageSystem = DamageSystem(DamageEventPool(initialCapacity: 2));
    var defeatedCount = 0;
    damageSystem.queueEnemyDamage(enemy, 12);
    damageSystem.resolve(
      onEnemyDefeated: (_) => defeatedCount++,
    );

    expect(enemy.hp, 0);
    expect(defeatedCount, 1);
  });

  test('damage system clamps player hp at zero', () {
    final player = PlayerState(
      position: Vector2.zero(),
      maxHp: 5,
      moveSpeed: 0,
    );
    final damageSystem = DamageSystem(DamageEventPool(initialCapacity: 1));
    damageSystem.queuePlayerDamage(player, 12);
    damageSystem.resolve(onEnemyDefeated: (_) {});

    expect(player.hp, 0);
  });
}
