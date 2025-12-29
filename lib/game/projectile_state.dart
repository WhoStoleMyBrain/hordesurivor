import 'package:flame/extensions.dart';

class ProjectileState {
  ProjectileState()
      : position = Vector2.zero(),
        velocity = Vector2.zero();

  final Vector2 position;
  final Vector2 velocity;
  double damage = 1;
  double radius = 3;
  double lifespan = 1;
  double age = 0;
  bool active = false;

  void reset({
    required Vector2 position,
    required Vector2 velocity,
    required double damage,
    required double radius,
    required double lifespan,
  }) {
    this.position.setFrom(position);
    this.velocity.setFrom(velocity);
    this.damage = damage;
    this.radius = radius;
    this.lifespan = lifespan;
    age = 0;
    active = true;
  }
}
