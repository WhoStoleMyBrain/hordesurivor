import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hordesurivor/data/ids.dart';
import 'package:hordesurivor/game/damage_system.dart';
import 'package:hordesurivor/game/enemy_pool.dart';
import 'package:hordesurivor/game/projectile_pool.dart';
import 'package:hordesurivor/game/skill_system.dart';

void main() {
  test('fireball casts on cooldown and supports burst updates', () {
    final projectilePool = ProjectilePool(initialCapacity: 0);
    final system = SkillSystem(
      projectilePool: projectilePool,
      skillSlots: [
        SkillSlot(id: SkillId.fireball, cooldown: 0.5),
      ],
    );

    var spawnCount = 0;
    system.update(
      dt: 0.4,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2.zero(),
      enemyPool: EnemyPool(initialCapacity: 0),
      onProjectileSpawn: (_) => spawnCount++,
      onEnemyDamaged: (_, __) {},
    );

    expect(spawnCount, 0);

    system.update(
      dt: 1.6,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2.zero(),
      enemyPool: EnemyPool(initialCapacity: 0),
      onProjectileSpawn: (_) => spawnCount++,
      onEnemyDamaged: (_, __) {},
    );

    expect(spawnCount, 3);
  });

  test('sword cut waits for cooldown before damaging', () {
    final enemyPool = EnemyPool(initialCapacity: 0);
    final enemy = enemyPool.acquire(EnemyId.imp);
    enemy.reset(
      id: EnemyId.imp,
      spawnPosition: Vector2(18, 0),
      maxHp: 20,
      moveSpeed: 0,
    );

    final projectilePool = ProjectilePool(initialCapacity: 0);
    final system = SkillSystem(
      projectilePool: projectilePool,
      skillSlots: [
        SkillSlot(id: SkillId.swordCut, cooldown: 0.3),
      ],
    );

    final damageSystem = DamageSystem(DamageEventPool(initialCapacity: 4));
    system.update(
      dt: 0.2,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2(1, 0),
      enemyPool: enemyPool,
      onProjectileSpawn: (_) {},
      onEnemyDamaged: damageSystem.queueEnemyDamage,
    );
    damageSystem.resolve(onEnemyDefeated: (_) {});

    expect(enemy.hp, 20);

    system.update(
      dt: 0.2,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2(1, 0),
      enemyPool: enemyPool,
      onProjectileSpawn: (_) {},
      onEnemyDamaged: damageSystem.queueEnemyDamage,
    );
    damageSystem.resolve(onEnemyDefeated: (_) {});

    expect(enemy.hp, lessThan(20));
  });

  test('sword cut damages enemies in arc only', () {
    final enemyPool = EnemyPool(initialCapacity: 0);
    final frontEnemy = enemyPool.acquire(EnemyId.imp);
    frontEnemy.reset(
      id: EnemyId.imp,
      spawnPosition: Vector2(12, 0),
      maxHp: 20,
      moveSpeed: 0,
    );
    final backEnemy = enemyPool.acquire(EnemyId.imp);
    backEnemy.reset(
      id: EnemyId.imp,
      spawnPosition: Vector2(-18, 0),
      maxHp: 20,
      moveSpeed: 0,
    );

    final projectilePool = ProjectilePool(initialCapacity: 0);
    final system = SkillSystem(
      projectilePool: projectilePool,
      skillSlots: [
        SkillSlot(id: SkillId.swordCut, cooldown: 0.1),
      ],
    );

    var defeatedCount = 0;
    final damageSystem = DamageSystem(DamageEventPool(initialCapacity: 4));
    system.update(
      dt: 0.2,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2(1, 0),
      enemyPool: enemyPool,
      onProjectileSpawn: (_) {},
      onEnemyDamaged: damageSystem.queueEnemyDamage,
    );
    damageSystem.resolve(
      onEnemyDefeated: (_) {
        defeatedCount++;
      },
    );

    expect(frontEnemy.hp, lessThan(20));
    expect(backEnemy.hp, 20);
    expect(defeatedCount, 0);
  });
}
