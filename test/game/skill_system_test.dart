import 'dart:math' as math;

import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hordesurivor/data/enemy_defs.dart';
import 'package:hordesurivor/data/ids.dart';
import 'package:hordesurivor/data/stat_defs.dart';
import 'package:hordesurivor/data/tags.dart';
import 'package:hordesurivor/game/damage_system.dart';
import 'package:hordesurivor/game/effect_system.dart';
import 'package:hordesurivor/game/effect_pool.dart';
import 'package:hordesurivor/game/effect_state.dart';
import 'package:hordesurivor/game/enemy_pool.dart';
import 'package:hordesurivor/game/enemy_state.dart';
import 'package:hordesurivor/game/player_state.dart';
import 'package:hordesurivor/game/projectile_pool.dart';
import 'package:hordesurivor/game/projectile_state.dart';
import 'package:hordesurivor/game/skill_system.dart';
import 'package:hordesurivor/game/summon_pool.dart';
import 'package:hordesurivor/game/summon_state.dart';

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
      variant: EnemyVariant.base,
      spawnPosition: position,
      maxHp: def.maxHp,
      moveSpeed: def.moveSpeed,
      xpReward: def.xpReward,
      goldCurrencyReward: def.goldCurrencyReward,
      goldShopXpReward: def.goldShopXpReward,
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
  }

  PlayerState buildPlayer() {
    return PlayerState(
      position: Vector2.zero(),
      maxHp: 100,
      maxMana: 60,
      moveSpeed: 120,
    );
  }

  void noopPlayerDeflect({required double radius, required double duration}) {}

  void noopSummonSpawn(SummonState summon) {}

  void noopEnemyDamaged(
    EnemyState enemy,
    double damage, {
    SkillId? sourceSkillId,
    double knockbackDuration = 0,
    double knockbackForce = 0,
    double knockbackX = 0,
    double knockbackY = 0,
  }) {}

  test('fireball casts on cooldown and supports burst updates', () {
    final projectilePool = ProjectilePool(initialCapacity: 0);
    final effectPool = EffectPool(initialCapacity: 0);
    final system = SkillSystem(
      effectPool: effectPool,
      projectilePool: projectilePool,
      summonPool: SummonPool(initialCapacity: 0),
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
      onEffectSpawn: (_) {},
      onProjectileDespawn: (_) {},
      onSummonSpawn: noopSummonSpawn,
      onPlayerDeflect: noopPlayerDeflect,
      onEnemyDamaged: noopEnemyDamaged,
    );

    expect(spawnCount, 0);

    system.update(
      dt: 1.6,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2.zero(),
      stats: playerState.stats,
      enemyPool: EnemyPool(initialCapacity: 0),
      onProjectileSpawn: (_) => spawnCount++,
      onEffectSpawn: (_) {},
      onProjectileDespawn: (_) {},
      onSummonSpawn: noopSummonSpawn,
      onPlayerDeflect: noopPlayerDeflect,
      onEnemyDamaged: noopEnemyDamaged,
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
    final effectPool = EffectPool(initialCapacity: 0);
    final effectSystem = EffectSystem(effectPool);
    final system = SkillSystem(
      effectPool: effectPool,
      projectilePool: projectilePool,
      summonPool: SummonPool(initialCapacity: 0),
      skillSlots: [SkillSlot(id: SkillId.swordCut, cooldown: 0.3)],
    );
    final playerState = buildPlayer();

    final damageSystem = DamageSystem(
      DamageEventPool(initialCapacity: 4),
      random: math.Random(5),
    );
    system.update(
      dt: 0.2,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2(1, 0),
      stats: playerState.stats,
      enemyPool: enemyPool,
      onProjectileSpawn: (_) {},
      onEffectSpawn: (_) {},
      onProjectileDespawn: (_) {},
      onSummonSpawn: noopSummonSpawn,
      onPlayerDeflect: noopPlayerDeflect,
      onEnemyDamaged: damageSystem.queueEnemyDamage,
    );
    effectSystem.update(
      0.07,
      enemyPool: enemyPool,
      onDespawn: (_) {},
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
      onEffectSpawn: (_) {},
      onProjectileDespawn: (_) {},
      onSummonSpawn: noopSummonSpawn,
      onPlayerDeflect: noopPlayerDeflect,
      onEnemyDamaged: damageSystem.queueEnemyDamage,
    );
    effectSystem.update(
      0.07,
      enemyPool: enemyPool,
      onDespawn: (_) {},
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
    final effectPool = EffectPool(initialCapacity: 0);
    final effectSystem = EffectSystem(effectPool);
    final system = SkillSystem(
      effectPool: effectPool,
      projectilePool: projectilePool,
      summonPool: SummonPool(initialCapacity: 0),
      skillSlots: [SkillSlot(id: SkillId.swordCut, cooldown: 0.1)],
    );
    final playerState = buildPlayer();

    var defeatedCount = 0;
    final damageSystem = DamageSystem(
      DamageEventPool(initialCapacity: 4),
      random: math.Random(6),
    );
    system.update(
      dt: 0.2,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2(1, 0),
      stats: playerState.stats,
      enemyPool: enemyPool,
      onProjectileSpawn: (_) {},
      onEffectSpawn: (_) {},
      onProjectileDespawn: (_) {},
      onSummonSpawn: noopSummonSpawn,
      onPlayerDeflect: noopPlayerDeflect,
      onEnemyDamaged: damageSystem.queueEnemyDamage,
    );
    effectSystem.update(
      0.07,
      enemyPool: enemyPool,
      onDespawn: (_) {},
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

  test('sword skills spawn arc visuals for melee attacks', () {
    final effectPool = EffectPool(initialCapacity: 0);
    final system = SkillSystem(
      effectPool: effectPool,
      projectilePool: ProjectilePool(initialCapacity: 0),
      summonPool: SummonPool(initialCapacity: 0),
      skillSlots: [
        SkillSlot(id: SkillId.swordCut, cooldown: 0.1),
        SkillSlot(id: SkillId.swordThrust, cooldown: 0.1),
        SkillSlot(id: SkillId.swordSwing, cooldown: 0.1),
        SkillSlot(id: SkillId.swordDeflect, cooldown: 0.1),
      ],
    );
    final playerState = buildPlayer();

    final effects = <EffectState>[];
    system.update(
      dt: 0.2,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2(1, 0),
      stats: playerState.stats,
      enemyPool: EnemyPool(initialCapacity: 0),
      onProjectileSpawn: (_) {},
      onEffectSpawn: effects.add,
      onProjectileDespawn: (_) {},
      onSummonSpawn: noopSummonSpawn,
      onPlayerDeflect: noopPlayerDeflect,
      onEnemyDamaged: noopEnemyDamaged,
    );

    expect(effects.length, 4);
    for (final effect in effects) {
      expect(effect.kind, EffectKind.swordSlash);
      expect(effect.shape, EffectShape.arc);
      expect(effect.arcDegrees, greaterThan(0));
    }
  });

  test('sword swing arc visual scales with AOE', () {
    final effectPool = EffectPool(initialCapacity: 0);
    final system = SkillSystem(
      effectPool: effectPool,
      projectilePool: ProjectilePool(initialCapacity: 0),
      summonPool: SummonPool(initialCapacity: 0),
      skillSlots: [SkillSlot(id: SkillId.swordSwing, cooldown: 0.1)],
    );
    final playerState = buildPlayer();
    playerState.applyModifiers(const [
      StatModifier(stat: StatId.aoeSize, amount: 0.5),
    ]);

    EffectState? effect;
    system.update(
      dt: 0.2,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2(1, 0),
      stats: playerState.stats,
      enemyPool: EnemyPool(initialCapacity: 0),
      onProjectileSpawn: (_) {},
      onEffectSpawn: (state) => effect = state,
      onProjectileDespawn: (_) {},
      onSummonSpawn: noopSummonSpawn,
      onPlayerDeflect: noopPlayerDeflect,
      onEnemyDamaged: noopEnemyDamaged,
    );

    expect(effect, isNotNull);
    expect(effect!.shape, EffectShape.arc);
    expect(effect!.arcDegrees, 140);
    expect(effect!.radius, closeTo(78, 0.01));
  });

  test('fireball damage scales with player stats', () {
    final projectilePool = ProjectilePool(initialCapacity: 0);
    final effectPool = EffectPool(initialCapacity: 0);
    final system = SkillSystem(
      effectPool: effectPool,
      projectilePool: projectilePool,
      summonPool: SummonPool(initialCapacity: 0),
      skillSlots: [SkillSlot(id: SkillId.fireball, cooldown: 0.2)],
    );
    final playerState = buildPlayer();
    playerState.applyModifiers(const [
      StatModifier(stat: StatId.damagePercent, amount: 0.5),
      StatModifier(stat: StatId.projectileDamagePercent, amount: 0.25),
      StatModifier(stat: StatId.fireDamagePercent, amount: 0.1),
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
      onEffectSpawn: (_) {},
      onProjectileDespawn: (_) {},
      onSummonSpawn: noopSummonSpawn,
      onPlayerDeflect: noopPlayerDeflect,
      onEnemyDamaged: noopEnemyDamaged,
    );

    expect(damage, isNotNull);
    expect(damage!, closeTo(14.8, 0.01));
  });

  test('wind cutter spawns a fast projectile', () {
    final projectilePool = ProjectilePool(initialCapacity: 0);
    final effectPool = EffectPool(initialCapacity: 0);
    final system = SkillSystem(
      effectPool: effectPool,
      projectilePool: projectilePool,
      summonPool: SummonPool(initialCapacity: 0),
      skillSlots: [SkillSlot(id: SkillId.windCutter, cooldown: 0.1)],
    );
    final playerState = buildPlayer();

    ProjectileState? projectile;
    system.update(
      dt: 0.2,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2(1, 0),
      stats: playerState.stats,
      enemyPool: EnemyPool(initialCapacity: 0),
      onProjectileSpawn: (state) => projectile = state,
      onEffectSpawn: (_) {},
      onProjectileDespawn: (_) {},
      onSummonSpawn: noopSummonSpawn,
      onPlayerDeflect: noopPlayerDeflect,
      onEnemyDamaged: noopEnemyDamaged,
    );

    expect(projectile, isNotNull);
    expect(projectile!.sourceSkillId, SkillId.windCutter);
    expect(projectile!.velocity.x, greaterThan(200));
  });

  test('steel shards fires a triple spread', () {
    final projectilePool = ProjectilePool(initialCapacity: 0);
    final effectPool = EffectPool(initialCapacity: 0);
    final system = SkillSystem(
      effectPool: effectPool,
      projectilePool: projectilePool,
      summonPool: SummonPool(initialCapacity: 0),
      skillSlots: [SkillSlot(id: SkillId.steelShards, cooldown: 0.1)],
    );
    final playerState = buildPlayer();

    final projectiles = <ProjectileState>[];
    system.update(
      dt: 0.2,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2(1, 0),
      stats: playerState.stats,
      enemyPool: EnemyPool(initialCapacity: 0),
      onProjectileSpawn: projectiles.add,
      onEffectSpawn: (_) {},
      onProjectileDespawn: (_) {},
      onSummonSpawn: noopSummonSpawn,
      onPlayerDeflect: noopPlayerDeflect,
      onEnemyDamaged: noopEnemyDamaged,
    );

    expect(projectiles.length, 3);
    final hasPositive = projectiles.any((p) => p.velocity.y > 0);
    final hasNegative = projectiles.any((p) => p.velocity.y < 0);
    expect(hasPositive, isTrue);
    expect(hasNegative, isTrue);
  });

  test('flame wave spawns a beam effect', () {
    final projectilePool = ProjectilePool(initialCapacity: 0);
    final effectPool = EffectPool(initialCapacity: 0);
    final system = SkillSystem(
      effectPool: effectPool,
      projectilePool: projectilePool,
      summonPool: SummonPool(initialCapacity: 0),
      skillSlots: [SkillSlot(id: SkillId.flameWave, cooldown: 0.1)],
    );
    final playerState = buildPlayer();

    EffectState? effect;
    system.update(
      dt: 0.2,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2(1, 0),
      stats: playerState.stats,
      enemyPool: EnemyPool(initialCapacity: 0),
      onProjectileSpawn: (_) {},
      onEffectSpawn: (state) => effect = state,
      onProjectileDespawn: (_) {},
      onSummonSpawn: noopSummonSpawn,
      onPlayerDeflect: noopPlayerDeflect,
      onEnemyDamaged: noopEnemyDamaged,
    );

    expect(effect, isNotNull);
    expect(effect!.kind, EffectKind.flameWave);
    expect(effect!.shape, EffectShape.beam);
  });

  test('frost nova follows the player and slows targets', () {
    final projectilePool = ProjectilePool(initialCapacity: 0);
    final effectPool = EffectPool(initialCapacity: 0);
    final system = SkillSystem(
      effectPool: effectPool,
      projectilePool: projectilePool,
      summonPool: SummonPool(initialCapacity: 0),
      skillSlots: [SkillSlot(id: SkillId.frostNova, cooldown: 0.1)],
    );
    final playerState = buildPlayer();

    EffectState? effect;
    system.update(
      dt: 0.2,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2(1, 0),
      stats: playerState.stats,
      enemyPool: EnemyPool(initialCapacity: 0),
      onProjectileSpawn: (_) {},
      onEffectSpawn: (state) => effect = state,
      onProjectileDespawn: (_) {},
      onSummonSpawn: noopSummonSpawn,
      onPlayerDeflect: noopPlayerDeflect,
      onEnemyDamaged: noopEnemyDamaged,
    );

    expect(effect, isNotNull);
    expect(effect!.kind, EffectKind.frostNova);
    expect(effect!.followsPlayer, isFalse);
    expect(effect!.slowMultiplier, lessThan(1));
  });

  test('earth spikes erupts ahead of the player', () {
    final projectilePool = ProjectilePool(initialCapacity: 0);
    final effectPool = EffectPool(initialCapacity: 0);
    final system = SkillSystem(
      effectPool: effectPool,
      projectilePool: projectilePool,
      summonPool: SummonPool(initialCapacity: 0),
      skillSlots: [SkillSlot(id: SkillId.earthSpikes, cooldown: 0.1)],
    );
    final playerState = buildPlayer();

    EffectState? effect;
    system.update(
      dt: 0.2,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2(1, 0),
      stats: playerState.stats,
      enemyPool: EnemyPool(initialCapacity: 0),
      onProjectileSpawn: (_) {},
      onEffectSpawn: (state) => effect = state,
      onProjectileDespawn: (_) {},
      onSummonSpawn: noopSummonSpawn,
      onPlayerDeflect: noopPlayerDeflect,
      onEnemyDamaged: noopEnemyDamaged,
    );

    expect(effect, isNotNull);
    expect(effect!.kind, EffectKind.earthSpikes);
    expect(effect!.position.x, greaterThan(0));
  });

  test('spore burst spawns an impact cloud', () {
    final projectilePool = ProjectilePool(initialCapacity: 0);
    final effectPool = EffectPool(initialCapacity: 0);
    final system = SkillSystem(
      effectPool: effectPool,
      projectilePool: projectilePool,
      summonPool: SummonPool(initialCapacity: 0),
      skillSlots: [SkillSlot(id: SkillId.sporeBurst, cooldown: 0.1)],
    );
    final playerState = buildPlayer();

    ProjectileState? projectile;
    system.update(
      dt: 0.2,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2(1, 0),
      stats: playerState.stats,
      enemyPool: EnemyPool(initialCapacity: 0),
      onProjectileSpawn: (state) => projectile = state,
      onEffectSpawn: (_) {},
      onProjectileDespawn: (_) {},
      onSummonSpawn: noopSummonSpawn,
      onPlayerDeflect: noopPlayerDeflect,
      onEnemyDamaged: noopEnemyDamaged,
    );

    expect(projectile, isNotNull);
    expect(projectile!.spawnImpactEffect, isTrue);
    expect(projectile!.impactEffectKind, EffectKind.sporeCloud);
    expect(projectile!.impactEffectDuration, greaterThan(0));
  });

  test('procession idol spawns autonomous summons', () {
    final projectilePool = ProjectilePool(initialCapacity: 0);
    final effectPool = EffectPool(initialCapacity: 0);
    final system = SkillSystem(
      effectPool: effectPool,
      projectilePool: projectilePool,
      summonPool: SummonPool(initialCapacity: 0),
      skillSlots: [SkillSlot(id: SkillId.processionIdol, cooldown: 0.1)],
    );
    final playerState = buildPlayer();

    var summonCount = 0;
    system.update(
      dt: 0.2,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2.zero(),
      stats: playerState.stats,
      enemyPool: EnemyPool(initialCapacity: 0),
      onProjectileSpawn: (_) {},
      onEffectSpawn: (_) {},
      onProjectileDespawn: (_) {},
      onSummonSpawn: (_) => summonCount++,
      onPlayerDeflect: noopPlayerDeflect,
      onEnemyDamaged: noopEnemyDamaged,
    );

    expect(summonCount, greaterThan(0));
  });

  test('chair throw launches a heavy projectile with knockback', () {
    final projectilePool = ProjectilePool(initialCapacity: 0);
    final effectPool = EffectPool(initialCapacity: 0);
    final system = SkillSystem(
      effectPool: effectPool,
      projectilePool: projectilePool,
      summonPool: SummonPool(initialCapacity: 0),
      skillSlots: [SkillSlot(id: SkillId.chairThrow, cooldown: 0.1)],
    );
    final playerState = buildPlayer();

    ProjectileState? projectile;
    system.update(
      dt: 0.2,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2(1, 0),
      stats: playerState.stats,
      enemyPool: EnemyPool(initialCapacity: 0),
      onProjectileSpawn: (state) => projectile = state,
      onEffectSpawn: (_) {},
      onProjectileDespawn: (_) {},
      onSummonSpawn: noopSummonSpawn,
      onPlayerDeflect: noopPlayerDeflect,
      onEnemyDamaged: noopEnemyDamaged,
    );

    expect(projectile, isNotNull);
    expect(projectile!.sourceSkillId, SkillId.chairThrow);
    expect(projectile!.knockbackForce, greaterThan(0));
  });

  test('absolution slap hits the front arc only', () {
    final enemyPool = EnemyPool(initialCapacity: 0);
    resetEnemy(pool: enemyPool, id: EnemyId.imp, position: Vector2(26, 0));
    resetEnemy(pool: enemyPool, id: EnemyId.imp, position: Vector2(-26, 0));
    final frontEnemy = enemyPool.active.first;
    final backEnemy = enemyPool.active.last;
    frontEnemy.hp = 20;
    frontEnemy.maxHp = 20;
    frontEnemy.moveSpeed = 0;
    backEnemy.hp = 20;
    backEnemy.maxHp = 20;
    backEnemy.moveSpeed = 0;

    final projectilePool = ProjectilePool(initialCapacity: 0);
    final effectPool = EffectPool(initialCapacity: 0);
    final effectSystem = EffectSystem(effectPool);
    final system = SkillSystem(
      effectPool: effectPool,
      projectilePool: projectilePool,
      summonPool: SummonPool(initialCapacity: 0),
      skillSlots: [SkillSlot(id: SkillId.absolutionSlap, cooldown: 0.1)],
    );
    final playerState = buildPlayer();

    final damageSystem = DamageSystem(
      DamageEventPool(initialCapacity: 4),
      random: math.Random(7),
    );
    system.update(
      dt: 0.2,
      playerPosition: Vector2.zero(),
      aimDirection: Vector2(1, 0),
      stats: playerState.stats,
      enemyPool: enemyPool,
      onProjectileSpawn: (_) {},
      onEffectSpawn: (_) {},
      onProjectileDespawn: (_) {},
      onSummonSpawn: noopSummonSpawn,
      onPlayerDeflect: noopPlayerDeflect,
      onEnemyDamaged: damageSystem.queueEnemyDamage,
    );
    effectSystem.update(
      0.07,
      enemyPool: enemyPool,
      onDespawn: (_) {},
      onEnemyDamaged: damageSystem.queueEnemyDamage,
    );
    damageSystem.resolve(onEnemyDefeated: (_) {});

    expect(frontEnemy.hp, lessThan(20));
    expect(backEnemy.hp, 20);
  });

  test('SkillSystem limits the number of skill slots', () {
    final system = SkillSystem(
      effectPool: EffectPool(initialCapacity: 0),
      projectilePool: ProjectilePool(initialCapacity: 0),
      summonPool: SummonPool(initialCapacity: 0),
      skillSlots: [],
    );

    system
      ..addSkill(SkillId.fireball)
      ..addSkill(SkillId.swordCut)
      ..addSkill(SkillId.waterjet)
      ..addSkill(SkillId.oilBombs)
      ..addSkill(SkillId.swordThrust);

    expect(system.skillIds.length, SkillSystem.maxSkillSlots);
    expect(system.skillIds.contains(SkillId.swordThrust), isFalse);
  });
}
