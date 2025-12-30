import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hordesurivor/data/enemy_defs.dart';
import 'package:hordesurivor/data/ids.dart';
import 'package:hordesurivor/data/stat_defs.dart';
import 'package:hordesurivor/game/damage_system.dart';
import 'package:hordesurivor/game/enemy_pool.dart';
import 'package:hordesurivor/game/player_state.dart';
import 'package:hordesurivor/game/projectile_pool.dart';
import 'package:hordesurivor/game/skill_system.dart';

void main() {
  void resetEnemy({
    required EnemyPool pool,
    required EnemyId id,
    required Vector2 position,
  }) {
    final enemy = pool.acquire(id);
    final def = enemyDefsById[id]!;
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
  }

  PlayerState buildPlayer() {
    return PlayerState(position: Vector2.zero(), maxHp: 100, moveSpeed: 120);
  }

  test('fireball casts on cooldown and supports burst updates', () {
    final projectilePool = ProjectilePool(initialCapacity: 0);
    final system = SkillSystem(
      projectilePool: projectilePool,
      skillSlots: [SkillSlot(id: SkillId.fireball, cooldown: 0.5)],
    );
    final playerState = buildPlayer();

    var spawnCount = 0;
    system.update(
      dt: 0.4,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2.zero(),
      stats: playerState.stats,
      enemyPool: EnemyPool(initialCapacity: 0),
      onProjectileSpawn: (_) => spawnCount++,
      onEnemyDamaged: (_, _) {},
    );

    expect(spawnCount, 0);

    system.update(
      dt: 1.6,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2.zero(),
      stats: playerState.stats,
      enemyPool: EnemyPool(initialCapacity: 0),
      onProjectileSpawn: (_) => spawnCount++,
      onEnemyDamaged: (_, _) {},
    );

    expect(spawnCount, 3);
  });

  test('sword cut waits for cooldown before damaging', () {
    final enemyPool = EnemyPool(initialCapacity: 0);
    resetEnemy(pool: enemyPool, id: EnemyId.imp, position: Vector2(18, 0));
    final enemy = enemyPool.active.first;
    enemy.hp = 20;
    enemy.maxHp = 20;
    enemy.moveSpeed = 0;

    final projectilePool = ProjectilePool(initialCapacity: 0);
    final system = SkillSystem(
      projectilePool: projectilePool,
      skillSlots: [SkillSlot(id: SkillId.swordCut, cooldown: 0.3)],
    );
    final playerState = buildPlayer();

    final damageSystem = DamageSystem(DamageEventPool(initialCapacity: 4));
    system.update(
      dt: 0.2,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2(1, 0),
      stats: playerState.stats,
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
      stats: playerState.stats,
      enemyPool: enemyPool,
      onProjectileSpawn: (_) {},
      onEnemyDamaged: damageSystem.queueEnemyDamage,
    );
    damageSystem.resolve(onEnemyDefeated: (_) {});

    expect(enemy.hp, lessThan(20));
  });

  test('sword cut damages enemies in arc only', () {
    final enemyPool = EnemyPool(initialCapacity: 0);
    resetEnemy(pool: enemyPool, id: EnemyId.imp, position: Vector2(12, 0));
    resetEnemy(pool: enemyPool, id: EnemyId.imp, position: Vector2(-18, 0));
    final frontEnemy = enemyPool.active.first;
    final backEnemy = enemyPool.active.last;
    frontEnemy.hp = 20;
    frontEnemy.maxHp = 20;
    frontEnemy.moveSpeed = 0;
    backEnemy.hp = 20;
    backEnemy.maxHp = 20;
    backEnemy.moveSpeed = 0;

    final projectilePool = ProjectilePool(initialCapacity: 0);
    final system = SkillSystem(
      projectilePool: projectilePool,
      skillSlots: [SkillSlot(id: SkillId.swordCut, cooldown: 0.1)],
    );
    final playerState = buildPlayer();

    var defeatedCount = 0;
    final damageSystem = DamageSystem(DamageEventPool(initialCapacity: 4));
    system.update(
      dt: 0.2,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2(1, 0),
      stats: playerState.stats,
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

  test('fireball damage scales with player stats', () {
    final projectilePool = ProjectilePool(initialCapacity: 0);
    final system = SkillSystem(
      projectilePool: projectilePool,
      skillSlots: [SkillSlot(id: SkillId.fireball, cooldown: 0.2)],
    );
    final playerState = buildPlayer();
    playerState.applyModifiers(const [
      StatModifier(stat: StatId.damage, amount: 0.5),
      StatModifier(stat: StatId.projectileDamage, amount: 0.25),
      StatModifier(stat: StatId.fireDamage, amount: 0.1),
    ]);

    double? damage;
    system.update(
      dt: 0.3,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2(1, 0),
      stats: playerState.stats,
      enemyPool: EnemyPool(initialCapacity: 0),
      onProjectileSpawn: (projectile) {
        damage = projectile.damage;
      },
      onEnemyDamaged: (_, _) {},
    );

    expect(damage, isNotNull);
    expect(damage!, closeTo(14.8, 0.01));
  });
}
