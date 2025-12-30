import '../data/stat_defs.dart';

class StatSheet {
  StatSheet({Map<StatId, double>? baseValues})
    : _baseValues = Map<StatId, double>.from(baseValues ?? {}),
      _multipliers = <StatId, double>{},
      _flatBonuses = <StatId, double>{};

  final Map<StatId, double> _baseValues;
  final Map<StatId, double> _multipliers;
  final Map<StatId, double> _flatBonuses;

  double value(StatId id) {
    final base = _baseValues[id] ?? 0;
    final multiplier = _multipliers[id] ?? 0;
    final flat = _flatBonuses[id] ?? 0;
    if (base == 0) {
      return multiplier + flat;
    }
    return base * (1 + multiplier) + flat;
  }

  void addModifiers(Iterable<StatModifier> modifiers) {
    for (final modifier in modifiers) {
      switch (modifier.kind) {
        case ModifierKind.percent:
          _multipliers.update(
            modifier.stat,
            (value) => value + modifier.amount,
            ifAbsent: () => modifier.amount,
          );
        case ModifierKind.flat:
          _flatBonuses.update(
            modifier.stat,
            (value) => value + modifier.amount,
            ifAbsent: () => modifier.amount,
          );
      }
    }
  }
}
