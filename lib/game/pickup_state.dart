import 'package:flame/extensions.dart';

enum PickupKind { xpOrb, goldCoin, skillSwapSeal }

class PickupState {
  PickupState() : position = Vector2.zero();

  final Vector2 position;
  PickupKind kind = PickupKind.xpOrb;
  int value = 0;
  int bonusValue = 0;
  double age = 0;
  double lifespan = 0;
  double magnetSpeed = 0;
  bool collecting = false;
  bool active = false;

  void reset({
    required PickupKind kind,
    required Vector2 position,
    required int value,
    int bonusValue = 0,
    required double lifespan,
  }) {
    this.kind = kind;
    this.position.setFrom(position);
    this.value = value;
    this.bonusValue = bonusValue;
    this.lifespan = lifespan;
    age = 0;
    magnetSpeed = 0;
    collecting = false;
    active = true;
  }
}
