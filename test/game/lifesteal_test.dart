import 'dart:math' as math;

import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hordesurivor/game/lifesteal.dart';
import 'package:hordesurivor/game/player_state.dart';

void main() {
  test('tryLifesteal heals for 1 HP on a successful roll', () {
    final playerState = PlayerState(
      position: Vector2.zero(),
      maxHp: 10,
      moveSpeed: 5,
    );
    playerState.hp = 5;

    final healed = tryLifesteal(
      player: playerState,
      chance: 1,
      random: math.Random(1),
    );

    expect(healed, isTrue);
    expect(playerState.hp, 6);
  });

  test('tryLifesteal does nothing when chance is zero', () {
    final playerState = PlayerState(
      position: Vector2.zero(),
      maxHp: 10,
      moveSpeed: 5,
    );
    playerState.hp = 5;

    final healed = tryLifesteal(
      player: playerState,
      chance: 0,
      random: math.Random(2),
    );

    expect(healed, isFalse);
    expect(playerState.hp, 5);
  });

  test('tryLifesteal does nothing when already at max health', () {
    final playerState = PlayerState(
      position: Vector2.zero(),
      maxHp: 10,
      moveSpeed: 5,
    );

    final healed = tryLifesteal(
      player: playerState,
      chance: 1,
      random: math.Random(3),
    );

    expect(healed, isFalse);
    expect(playerState.hp, 10);
  });
}
