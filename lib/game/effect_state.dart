import 'package:flame/extensions.dart';

import '../data/ids.dart';

enum EffectKind {
  waterjetBeam,
  oilGround,
  rootsGround,
  poisonAura,
  flameWave,
  frostNova,
  earthSpikes,
  sporeCloud,
  swordSlash,
}

enum EffectShape { beam, ground, arc }

class EffectState {
  EffectState() : position = Vector2.zero(), direction = Vector2(1, 0);

  final Vector2 position;
  final Vector2 direction;
  EffectKind kind = EffectKind.oilGround;
  EffectShape shape = EffectShape.ground;
  double radius = 0;
  double length = 0;
  double width = 0;
  double arcDegrees = 0;
  double sweepStartAngle = 0;
  double sweepEndAngle = 0;
  double sweepArcDegrees = 0;
  double duration = 0;
  double age = 0;
  double damagePerSecond = 0;
  double slowMultiplier = 1;
  double slowDuration = 0;
  double oilDuration = 0;
  double knockbackForce = 0;
  double knockbackDuration = 0;
  SkillId? sourceSkillId;
  bool followsPlayer = false;
  bool active = false;

  void reset({
    required EffectKind kind,
    required EffectShape shape,
    required Vector2 position,
    required Vector2 direction,
    required double radius,
    required double length,
    required double width,
    double arcDegrees = 0,
    double sweepStartAngle = 0,
    double sweepEndAngle = 0,
    double sweepArcDegrees = 0,
    required double duration,
    required double damagePerSecond,
    double slowMultiplier = 1,
    double slowDuration = 0,
    double oilDuration = 0,
    double knockbackForce = 0,
    double knockbackDuration = 0,
    SkillId? sourceSkillId,
    bool followsPlayer = false,
  }) {
    this.kind = kind;
    this.shape = shape;
    this.position.setFrom(position);
    this.direction.setFrom(direction);
    if (this.direction.length2 == 0) {
      this.direction.setValues(1, 0);
    } else {
      this.direction.normalize();
    }
    this.radius = radius;
    this.length = length;
    this.width = width;
    this.arcDegrees = arcDegrees;
    this.sweepStartAngle = sweepStartAngle;
    this.sweepEndAngle = sweepEndAngle;
    this.sweepArcDegrees = sweepArcDegrees;
    this.duration = duration;
    this.damagePerSecond = damagePerSecond;
    this.slowMultiplier = slowMultiplier;
    this.slowDuration = slowDuration;
    this.oilDuration = oilDuration;
    this.knockbackForce = knockbackForce;
    this.knockbackDuration = knockbackDuration;
    this.sourceSkillId = sourceSkillId;
    this.followsPlayer = followsPlayer;
    age = 0;
    active = true;
  }
}
