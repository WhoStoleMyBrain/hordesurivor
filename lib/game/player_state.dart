import 'package:flame/extensions.dart';

class PlayerState {
  PlayerState({required Vector2 position, required Vector2 velocity})
      : position = position,
        velocity = velocity;

  final Vector2 position;
  final Vector2 velocity;

  void step(double dt) {
    position.addScaled(velocity, dt);
  }
}
