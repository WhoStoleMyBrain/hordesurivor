import 'package:flame/extensions.dart';

import 'effect_state.dart';

class ProjectileState {
  ProjectileState()
    : position = Vector2.zero(),
      velocity = Vector2.zero(),
      impactDirection = Vector2(1, 0);

  final Vector2 position;
  final Vector2 velocity;
  final Vector2 impactDirection;
  double damage = 1;
  double radius = 3;
  double lifespan = 1;
  double age = 0;
  bool fromEnemy = false;
  bool active = false;
  bool spawnImpactEffect = false;
  bool ignitesOiledTargets = false;
  double igniteDuration = 0;
  double igniteDamagePerSecond = 0;
  EffectKind? impactEffectKind;
  EffectShape impactEffectShape = EffectShape.ground;
  double impactEffectRadius = 0;
  double impactEffectLength = 0;
  double impactEffectWidth = 0;
  double impactEffectDuration = 0;
  double impactEffectDamagePerSecond = 0;
  double impactEffectSlowMultiplier = 1;
  double impactEffectSlowDuration = 0;
  double impactEffectOilDuration = 0;

  void reset({
    required Vector2 position,
    required Vector2 velocity,
    required double damage,
    required double radius,
    required double lifespan,
    required bool fromEnemy,
  }) {
    this.position.setFrom(position);
    this.velocity.setFrom(velocity);
    this.damage = damage;
    this.radius = radius;
    this.lifespan = lifespan;
    this.fromEnemy = fromEnemy;
    age = 0;
    active = true;
    spawnImpactEffect = false;
    ignitesOiledTargets = false;
    igniteDuration = 0;
    igniteDamagePerSecond = 0;
    impactEffectKind = null;
    impactEffectShape = EffectShape.ground;
    impactEffectRadius = 0;
    impactEffectLength = 0;
    impactEffectWidth = 0;
    impactEffectDuration = 0;
    impactEffectDamagePerSecond = 0;
    impactEffectSlowMultiplier = 1;
    impactEffectSlowDuration = 0;
    impactEffectOilDuration = 0;
    impactDirection.setValues(1, 0);
  }

  void setImpactEffect({
    required EffectKind kind,
    required EffectShape shape,
    required Vector2 direction,
    required double radius,
    required double length,
    required double width,
    required double duration,
    required double damagePerSecond,
    double slowMultiplier = 1,
    double slowDuration = 0,
    double oilDuration = 0,
  }) {
    spawnImpactEffect = true;
    impactEffectKind = kind;
    impactEffectShape = shape;
    impactDirection.setFrom(direction);
    if (impactDirection.length2 == 0) {
      impactDirection.setValues(1, 0);
    } else {
      impactDirection.normalize();
    }
    impactEffectRadius = radius;
    impactEffectLength = length;
    impactEffectWidth = width;
    impactEffectDuration = duration;
    impactEffectDamagePerSecond = damagePerSecond;
    impactEffectSlowMultiplier = slowMultiplier;
    impactEffectSlowDuration = slowDuration;
    impactEffectOilDuration = oilDuration;
  }
}
