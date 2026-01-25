import 'package:flutter/material.dart';

import '../data/character_defs.dart';
import '../data/ids.dart';
import '../data/stat_defs.dart';
import '../game/stat_sheet.dart';

Map<StatId, double> baselineStatValues(CharacterId id) {
  final def = characterDefsById[id] ?? characterDefs.first;
  final sheet = StatSheet(baseValues: def.baseStats);
  sheet.addModifiers(def.modifiers);
  return {for (final stat in StatId.values) stat: sheet.value(stat)};
}

Color statDeltaColor({
  required double value,
  required double baseline,
  required Color neutral,
  required Color better,
  required Color worse,
}) {
  const epsilon = 0.0001;
  if (value > baseline + epsilon) {
    return better;
  }
  if (value < baseline - epsilon) {
    return worse;
  }
  return neutral;
}
