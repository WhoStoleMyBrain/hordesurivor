import 'dart:math' as math;

import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hordesurivor/data/enemy_defs.dart';
import 'package:hordesurivor/data/ids.dart';
import 'package:hordesurivor/data/tags.dart';
import 'package:hordesurivor/game/damage_system.dart';
import 'package:hordesurivor/game/enemy_pool.dart';
import 'package:hordesurivor/game/enemy_state.dart';
import 'package:hordesurivor/game/player_state.dart';
import 'package:hordesurivor/game/projectile_pool.dart';
import 'package:hordesurivor/game/summon_pool.dart';
import 'package:hordesurivor/game/summon_state.dart';
import 'package:hordesurivor/game/summon_system.dart';

void main() {
  EnemyState spawnEnemy(EnemyPool pool, Vector2 position) {
    final def = enemyDefsById[EnemyId.imp]!;
    final enemy = pool.acquire(EnemyId.imp);
    enemy.reset(
      id: EnemyId.imp,
      role: def.role,
      variant: EnemyVariant.base,
      spawnPosition: position,
      maxHp: def.maxHp,
      moveSpeed: 0,
      xpReward: def.xpReward,
      goldCurrencyReward: def.goldCurrencyReward,
      attackCooldown: def.attackCooldown,
      attackRange: def.attackRange,
      projectileSpeed: def.projectileSpeed,
      projectileDamage: def.projectileDamage,
      projectileSpread: def.projectileSpread,
      spawnCooldown: def.spawnCooldown,
      spawnCount: def.spawnCount,
      spawnRadius: def.spawnRadius,
      spawnEnemyId: def.spawnEnemyId,
      spawnRewardMultiplier: def.spawnRewardMultiplier,
    );
    return enemy;
  }

  void noopEnemyDamaged(
    EnemyState enemy,
    double damage, {
    SkillId? sourceSkillId,
    double knockbackDuration = 0,
    double knockbackForce = 0,
    double knockbackX = 0,
    double knockbackY = 0,
  }) {}

  test('vigil lantern fires at nearby enemies', () {
    final summonPool = SummonPool(initialCapacity: 0);
    final summon = summonPool.acquire();
    summon.reset(
      kind: SummonKind.vigilLantern,
      sourceSkillId: SkillId.vigilLantern,
      position: Vector2.zero(),
      projectileDamage: 6,
      projectileSpeed: 120,
      projectileRadius: SummonSystem.defaultProjectileRadius(),
      range: 120,
      lifespan: 3,
      attackCooldown: 0.1,
    );

    final enemyPool = EnemyPool(initialCapacity: 0);
    spawnEnemy(enemyPool, Vector2(40, 0));
    final projectilePool = ProjectilePool(initialCapacity: 0);
    final system = SummonSystem(summonPool);

    var fired = false;
    system.update(
      0.2,
      playerState: PlayerState(
        position: Vector2.zero(),
        maxHp: 100,
        maxMana: 60,
        moveSpeed: 0,
      ),
      enemyPool: enemyPool,
      projectilePool: projectilePool,
      onProjectileSpawn: (_) {
        fired = true;
      },
      onDespawn: (_) {},
      onEnemyDamaged: noopEnemyDamaged,
      onPlayerDamaged: (_, {tags = const TagSet(), selfInflicted = false}) {},
    );

    expect(fired, isTrue);
  });

  test('guardian orb damages nearby enemies', () {
    final summonPool = SummonPool(initialCapacity: 0);
    final summon = summonPool.acquire();
    summon.reset(
      kind: SummonKind.guardianOrb,
      sourceSkillId: SkillId.guardianOrbs,
      position: Vector2.zero(),
      radius: 18,
      damagePerSecond: 10,
      lifespan: 3,
    );

    final enemyPool = EnemyPool(initialCapacity: 0);
    final enemy = spawnEnemy(enemyPool, Vector2(10, 0));
    enemy.hp = 20;

    final damageSystem = DamageSystem(
      DamageEventPool(initialCapacity: 4),
      random: math.Random(1),
    );
    final system = SummonSystem(summonPool);

    system.update(
      0.5,
      playerState: PlayerState(
        position: Vector2.zero(),
        maxHp: 100,
        maxMana: 60,
        moveSpeed: 0,
      ),
      enemyPool: enemyPool,
      projectilePool: ProjectilePool(initialCapacity: 0),
      onProjectileSpawn: (_) {},
      onDespawn: (_) {},
      onEnemyDamaged: damageSystem.queueEnemyDamage,
      onPlayerDamaged: (_, {tags = const TagSet(), selfInflicted = false}) {},
    );
    damageSystem.resolve(onEnemyDefeated: (_) {});

    expect(enemy.hp, lessThan(20));
  });

  test('mender orb heals the player', () {
    final summonPool = SummonPool(initialCapacity: 0);
    final summon = summonPool.acquire();
    summon.reset(
      kind: SummonKind.menderOrb,
      sourceSkillId: SkillId.menderOrb,
      position: Vector2.zero(),
      radius: 14,
      healingPerSecond: 6,
      lifespan: 3,
    );

    final player = PlayerState(
      position: Vector2.zero(),
      maxHp: 100,
      maxMana: 60,
      moveSpeed: 0,
    );
    player.hp = 60;

    final system = SummonSystem(summonPool);
    system.update(
      1.0,
      playerState: player,
      enemyPool: EnemyPool(initialCapacity: 0),
      projectilePool: ProjectilePool(initialCapacity: 0),
      onProjectileSpawn: (_) {},
      onDespawn: (_) {},
      onEnemyDamaged: noopEnemyDamaged,
      onPlayerDamaged: (_, {tags = const TagSet(), selfInflicted = false}) {},
    );

    expect(player.hp, greaterThan(60));
  });

  test('mine detonates when an enemy approaches', () {
    final summonPool = SummonPool(initialCapacity: 0);
    final summon = summonPool.acquire();
    summon.reset(
      kind: SummonKind.mine,
      sourceSkillId: SkillId.mineLayer,
      position: Vector2.zero(),
      triggerRadius: 20,
      blastRadius: 30,
      blastDamage: 12,
      lifespan: 3,
      armDuration: 0,
    );

    final enemyPool = EnemyPool(initialCapacity: 0);
    final enemy = spawnEnemy(enemyPool, Vector2(10, 0));
    enemy.hp = 20;

    final damageSystem = DamageSystem(
      DamageEventPool(initialCapacity: 4),
      random: math.Random(2),
    );
    final system = SummonSystem(summonPool);
    var despawned = false;

    system.update(
      0.2,
      playerState: PlayerState(
        position: Vector2.zero(),
        maxHp: 100,
        maxMana: 60,
        moveSpeed: 0,
      ),
      enemyPool: enemyPool,
      projectilePool: ProjectilePool(initialCapacity: 0),
      onProjectileSpawn: (_) {},
      onDespawn: (_) {
        despawned = true;
      },
      onEnemyDamaged: damageSystem.queueEnemyDamage,
      onPlayerDamaged: (_, {tags = const TagSet(), selfInflicted = false}) {},
    );
    damageSystem.resolve(onEnemyDefeated: (_) {});

    expect(despawned, isTrue);
    expect(enemy.hp, lessThan(20));
  });
}
