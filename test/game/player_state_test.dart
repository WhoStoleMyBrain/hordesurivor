import 'dart:math' as math;

import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hordesurivor/data/stat_defs.dart';
import 'package:hordesurivor/game/player_state.dart';

void main() {
  test('PlayerState moves based on normalized intent and speed', () {
    final state = PlayerState(
      position: Vector2.zero(),
      maxHp: 100,
      maxMana: 60,
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
      maxMana: 60,
      moveSpeed: 10,
    );

    state.step(1);

    expect(state.position, Vector2.zero());
  });

  test('PlayerState clamps position within bounds', () {
    final state = PlayerState(
      position: Vector2(15, -2),
      maxHp: 100,
      maxMana: 60,
      moveSpeed: 10,
    );

    state.clampToBounds(min: Vector2.zero(), max: Vector2(10, 10));

    expect(state.position.x, 10);
    expect(state.position.y, 0);
  });

  test(
    'PlayerState regen uses diminishing returns with a 10-point baseline',
    () {
      final baselineState = PlayerState(
        position: Vector2.zero(),
        maxHp: 100,
        maxMana: 60,
        moveSpeed: 10,
      );
      baselineState.hp = 50;
      baselineState.applyModifiers(const [
        StatModifier(stat: StatId.hpRegen, amount: 10, kind: ModifierKind.flat),
      ]);

      baselineState.step(1);

      expect(baselineState.hp, closeTo(51, 0.0001));

      final higherState = PlayerState(
        position: Vector2.zero(),
        maxHp: 100,
        maxMana: 60,
        moveSpeed: 10,
      );
      higherState.hp = 50;
      higherState.applyModifiers(const [
        StatModifier(stat: StatId.hpRegen, amount: 20, kind: ModifierKind.flat),
      ]);

      higherState.step(1);

      expect(higherState.hp, lessThan(52));
    },
  );
}
