import 'package:flame/extensions.dart';

enum PickupKind { xpOrb }

class PickupState {
  PickupState() : position = Vector2.zero();

  final Vector2 position;
  PickupKind kind = PickupKind.xpOrb;
  int value = 0;
  double age = 0;
  double lifespan = 0;
  bool active = false;

  void reset({
    required PickupKind kind,
    required Vector2 position,
    required int value,
    required double lifespan,
  }) {
    this.kind = kind;
    this.position.setFrom(position);
    this.value = value;
    this.lifespan = lifespan;
    age = 0;
    active = true;
  }
}
