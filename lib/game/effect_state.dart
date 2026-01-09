import 'package:flame/extensions.dart';

enum EffectKind { waterjetBeam, oilGround, rootsGround, poisonAura }

enum EffectShape { beam, ground }

class EffectState {
  EffectState() : position = Vector2.zero(), direction = Vector2(1, 0);

  final Vector2 position;
  final Vector2 direction;
  EffectKind kind = EffectKind.oilGround;
  EffectShape shape = EffectShape.ground;
  double radius = 0;
  double length = 0;
  double width = 0;
  double duration = 0;
  double age = 0;
  double damagePerSecond = 0;
  double slowMultiplier = 1;
  double slowDuration = 0;
  double oilDuration = 0;
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
    required double duration,
    required double damagePerSecond,
    double slowMultiplier = 1,
    double slowDuration = 0,
    double oilDuration = 0,
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
    this.duration = duration;
    this.damagePerSecond = damagePerSecond;
    this.slowMultiplier = slowMultiplier;
    this.slowDuration = slowDuration;
    this.oilDuration = oilDuration;
    this.followsPlayer = followsPlayer;
    age = 0;
    active = true;
  }
}
