import '../data/tags.dart';
import 'enemy_state.dart';
import 'player_state.dart';

class DamageSystem {
  DamageSystem(this._pool);

  final DamageEventPool _pool;
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
  }) {
    if (amount <= 0) {
      return;
    }
    final event = _pool.acquire();
    event.resetForPlayer(player, amount, tags);
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
      player.hp -= event.amount;
      player.registerHit();
      onPlayerDamaged?.call(event.amount);
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

  void resetForPlayer(PlayerState player, double amount, TagSet tags) {
    enemy = null;
    this.player = player;
    this.amount = amount;
    this.tags = tags;
    knockbackX = 0;
    knockbackY = 0;
    knockbackForce = 0;
    knockbackDuration = 0;
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
