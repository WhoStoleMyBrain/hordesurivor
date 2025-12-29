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
  }) {
    if (amount <= 0) {
      return;
    }
    final event = _pool.acquire();
    event.resetForEnemy(enemy, amount, tags);
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
    void Function()? onPlayerDefeated,
  }) {
    for (final event in _active) {
      final enemy = event.enemy;
      if (enemy != null) {
        if (!enemy.active) {
          continue;
        }
        enemy.hp -= event.amount;
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
      player.hp -= event.amount;
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

  void resetForEnemy(EnemyState enemy, double amount, TagSet tags) {
    this.enemy = enemy;
    player = null;
    this.amount = amount;
    this.tags = tags;
  }

  void resetForPlayer(PlayerState player, double amount, TagSet tags) {
    enemy = null;
    this.player = player;
    this.amount = amount;
    this.tags = tags;
  }

  void clear() {
    enemy = null;
    player = null;
    amount = 0;
    tags = const TagSet();
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
