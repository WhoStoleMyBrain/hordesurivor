import 'dart:math' as math;

import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hordesurivor/game/player_state.dart';

void main() {
  test('PlayerState moves based on normalized intent and speed', () {
    final state = PlayerState(
      position: Vector2.zero(),
      maxHp: 100,
      moveSpeed: 10,
    );

    state.movementIntent.setValues(1, 1);
    state.step(1);

    final expected = 10 / math.sqrt(2);
    expect(state.position.x, closeTo(expected, 0.0001));
    expect(state.position.y, closeTo(expected, 0.0001));
  });

  test('PlayerState does not move without intent', () {
    final state = PlayerState(
      position: Vector2.zero(),
      maxHp: 100,
      moveSpeed: 10,
    );

    state.step(1);

    expect(state.position, Vector2.zero());
  });

  test('PlayerState clamps position within bounds', () {
    final state = PlayerState(
      position: Vector2(15, -2),
      maxHp: 100,
      moveSpeed: 10,
    );

    state.clampToBounds(
      min: Vector2.zero(),
      max: Vector2(10, 10),
    );

    expect(state.position.x, 10);
    expect(state.position.y, 0);
  });
}
