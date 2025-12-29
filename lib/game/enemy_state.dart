import 'package:flame/extensions.dart';

import '../data/ids.dart';

class EnemyState {
  EnemyState({required EnemyId id})
      : id = id,
        position = Vector2.zero(),
        velocity = Vector2.zero();

  EnemyId id;
  final Vector2 position;
  final Vector2 velocity;
  double maxHp = 1;
  double hp = 1;
  double moveSpeed = 20;
  bool active = false;

  void reset({
    required EnemyId id,
    required Vector2 spawnPosition,
    required double maxHp,
    required double moveSpeed,
  }) {
    this.id = id;
    position.setFrom(spawnPosition);
    velocity.setZero();
    this.maxHp = maxHp;
    hp = maxHp;
    this.moveSpeed = moveSpeed;
    active = true;
  }
}
