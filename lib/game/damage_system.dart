import 'dart:math' as math;

import '../data/stat_defs.dart';
import '../data/tags.dart';
import 'enemy_state.dart';
import 'player_state.dart';

class DamageSystem {
  DamageSystem(this._pool, {required math.Random random}) : _random = random;

  final DamageEventPool _pool;
  final math.Random _random;
  final List<DamageEvent> _active = [];

  void queueEnemyDamage(
    EnemyState enemy,
    double amount, {
    TagSet tags = const TagSet(),
    double knockbackX = 0,
    double knockbackY = 0,
    double knockbackForce = 0,
    double knockbackDuration = 0,
  }) {
    if (amount <= 0) {
      return;
    }
    final event = _pool.acquire();
    event.resetForEnemy(
      enemy,
      amount,
      tags,
      knockbackX: knockbackX,
      knockbackY: knockbackY,
      knockbackForce: knockbackForce,
      knockbackDuration: knockbackDuration,
    );
    _active.add(event);
  }

  void queuePlayerDamage(
    PlayerState player,
    double amount, {
    TagSet tags = const TagSet(),
    bool selfInflicted = false,
  }) {
    if (amount <= 0) {
      return;
    }
    final event = _pool.acquire();
    event.resetForPlayer(player, amount, tags, selfInflicted: selfInflicted);
    _active.add(event);
  }

  void resolve({
    required void Function(EnemyState) onEnemyDefeated,
    void Function(EnemyState, double)? onEnemyDamaged,
    void Function(double)? onPlayerDamaged,
    void Function()? onPlayerDefeated,
  }) {
    for (final event in _active) {
      final enemy = event.enemy;
      if (enemy != null) {
        if (!enemy.active) {
          continue;
        }
        enemy.hp -= event.amount;
        if (event.knockbackForce > 0 && event.knockbackDuration > 0) {
          enemy.applyKnockback(
            directionX: event.knockbackX,
            directionY: event.knockbackY,
            force: event.knockbackForce,
            duration: event.knockbackDuration,
          );
        }
        onEnemyDamaged?.call(enemy, event.amount);
        if (enemy.hp <= 0) {
          enemy.hp = 0;
          enemy.active = false;
          onEnemyDefeated(enemy);
        }
        continue;
      }

      final player = event.player;
      if (player == null || player.hp <= 0) {
        continue;
      }
      if (player.isInvulnerable) {
        continue;
      }
      final mitigatedDamage = _mitigatePlayerDamage(player, event);
      if (mitigatedDamage <= 0) {
        continue;
      }
      player.hp -= mitigatedDamage;
      player.registerHit();
      onPlayerDamaged?.call(mitigatedDamage);
      if (player.hp <= 0) {
        player.hp = 0;
        onPlayerDefeated?.call();
      }
    }

    for (final event in _active) {
      _pool.release(event);
    }
    _active.clear();
  }

  double _mitigatePlayerDamage(PlayerState player, DamageEvent event) {
    var damage = event.amount;
    if (damage <= 0) {
      return 0;
    }
    final stats = player.stats;
    final dodgeChance = stats.value(StatId.dodgeChance).clamp(0.0, 0.85);
    if (dodgeChance > 0 && _random.nextDouble() < dodgeChance) {
      return 0;
    }
    final defense = stats.value(StatId.defense);
    final defenseMultiplier = (1 - defense).clamp(0.05, 3.0).toDouble();
    damage *= defenseMultiplier;
    final armor = stats.value(StatId.armor);
    if (armor != 0) {
      damage -= armor;
    }
    if (event.tags.hasElement(ElementTag.poison)) {
      final resistance = stats.value(StatId.poisonResistance);
      final resistanceMultiplier = (1 - resistance).clamp(0.05, 3.0).toDouble();
      damage *= resistanceMultiplier;
    }
    if (event.selfInflicted && event.tags.hasDelivery(DeliveryTag.ground)) {
      final selfExplosion = stats.value(StatId.selfExplosionDamageTaken);
      final selfMultiplier = (1 + selfExplosion).clamp(0.1, 3.0).toDouble();
      damage *= selfMultiplier;
    }
    return math.max(0, damage);
  }
}

class DamageEvent {
  EnemyState? enemy;
  PlayerState? player;
  double amount = 0;
  TagSet tags = const TagSet();
  double knockbackX = 0;
  double knockbackY = 0;
  double knockbackForce = 0;
  double knockbackDuration = 0;
  bool selfInflicted = false;

  void resetForEnemy(
    EnemyState enemy,
    double amount,
    TagSet tags, {
    double knockbackX = 0,
    double knockbackY = 0,
    double knockbackForce = 0,
    double knockbackDuration = 0,
  }) {
    this.enemy = enemy;
    player = null;
    this.amount = amount;
    this.tags = tags;
    this.knockbackX = knockbackX;
    this.knockbackY = knockbackY;
    this.knockbackForce = knockbackForce;
    this.knockbackDuration = knockbackDuration;
  }

  void resetForPlayer(
    PlayerState player,
    double amount,
    TagSet tags, {
    required bool selfInflicted,
  }) {
    enemy = null;
    this.player = player;
    this.amount = amount;
    this.tags = tags;
    knockbackX = 0;
    knockbackY = 0;
    knockbackForce = 0;
    knockbackDuration = 0;
    this.selfInflicted = selfInflicted;
  }

  void clear() {
    enemy = null;
    player = null;
    amount = 0;
    tags = const TagSet();
    knockbackX = 0;
    knockbackY = 0;
    knockbackForce = 0;
    knockbackDuration = 0;
    selfInflicted = false;
  }
}

class DamageEventPool {
  DamageEventPool({int initialCapacity = 32})
    : _inactive = List.generate(initialCapacity, (_) => DamageEvent());

  final List<DamageEvent> _inactive;

  DamageEvent acquire() {
    return _inactive.isNotEmpty ? _inactive.removeLast() : DamageEvent();
  }

  void release(DamageEvent event) {
    event.clear();
    _inactive.add(event);
  }
}
