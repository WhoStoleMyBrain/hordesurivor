import 'dart:math' as math;

import 'player_state.dart';

bool tryLifesteal({
  required PlayerState player,
  required double chance,
  required math.Random random,
}) {
  if (chance <= 0) {
    return false;
  }
  if (player.hp >= player.maxHp) {
    return false;
  }
  final clampedChance = chance.clamp(0.0, 1.0);
  if (random.nextDouble() > clampedChance) {
    return false;
  }
  player.heal(1);
  return true;
}
