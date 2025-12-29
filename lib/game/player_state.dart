import 'package:flame/extensions.dart';

class PlayerState {
  PlayerState({
    required Vector2 position,
    required this.maxHp,
    required this.moveSpeed,
  })  : position = position,
        hp = maxHp,
        velocity = Vector2.zero(),
        movementIntent = Vector2.zero();

  final Vector2 position;
  final Vector2 velocity;
  final Vector2 movementIntent;
  final double maxHp;
  final double moveSpeed;
  double hp;

  void step(double dt) {
    velocity.setFrom(movementIntent);
    if (velocity.length2 > 0) {
      velocity.normalize();
      velocity.scale(moveSpeed);
      position.addScaled(velocity, dt);
    }
  }

  void clampToBounds({required Vector2 min, required Vector2 max}) {
    position.x = position.x.clamp(min.x, max.x);
    position.y = position.y.clamp(min.y, max.y);
  }
}
