import 'dart:math' as math;

import 'package:flame/extensions.dart';

import '../data/stat_defs.dart';
import 'stat_sheet.dart';

class PlayerState {
  PlayerState({
    required this.position,
    required double maxHp,
    required double moveSpeed,
  }) : hp = maxHp,
       stats = StatSheet(
         baseValues: {StatId.maxHp: maxHp, StatId.moveSpeed: moveSpeed},
       ),
       velocity = Vector2.zero(),
       movementIntent = Vector2.zero(),
       impulseVelocity = Vector2.zero();

  final Vector2 position;
  final Vector2 velocity;
  final Vector2 movementIntent;
  final Vector2 impulseVelocity;
  final StatSheet stats;
  double hp;
  double impulseTimeRemaining = 0;

  double get maxHp => math.max(1, stats.value(StatId.maxHp));
  double get moveSpeed => math.max(0, stats.value(StatId.moveSpeed));

  void applyModifiers(Iterable<StatModifier> modifiers) {
    stats.addModifiers(modifiers);
    hp = hp.clamp(0, maxHp);
  }

  void resetForRun() {
    stats.resetModifiers();
    hp = maxHp;
    velocity.setZero();
    movementIntent.setZero();
    impulseVelocity.setZero();
    impulseTimeRemaining = 0;
  }

  void step(double dt) {
    velocity.setFrom(movementIntent);
    final lengthSquared = velocity.length2;
    if (lengthSquared > 1) {
      velocity.normalize();
    }
    if (lengthSquared > 0) {
      velocity.scale(moveSpeed);
      position.addScaled(velocity, dt);
    }
    if (impulseTimeRemaining > 0) {
      position.addScaled(impulseVelocity, dt);
      impulseTimeRemaining = math.max(0, impulseTimeRemaining - dt);
    }
  }

  void clampToBounds({required Vector2 min, required Vector2 max}) {
    position.x = position.x.clamp(min.x, max.x);
    position.y = position.y.clamp(min.y, max.y);
  }

  void addImpulse({
    required double dx,
    required double dy,
    required double speed,
    required double duration,
  }) {
    if (speed <= 0 || duration <= 0) {
      return;
    }
    impulseVelocity.setValues(dx, dy);
    if (impulseVelocity.length2 <= 0) {
      return;
    }
    impulseVelocity
      ..normalize()
      ..scale(speed);
    impulseTimeRemaining = math.max(impulseTimeRemaining, duration);
  }
}
