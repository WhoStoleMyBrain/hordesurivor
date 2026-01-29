import 'dart:math' as math;

const double _damagePerLevel = 0.06;
const double _durationPerLevel = 0.04;
const double _sizePerLevel = 0.03;
const double _speedPerLevel = 0.02;
const double _cooldownPerLevel = 0.03;
const double _knockbackPerLevel = 0.04;
const double _slowStrengthPerLevel = 0.03;
const double _minCooldownScale = 0.4;

double applySkillLevelDamage(double base, int level) {
  return base * _scale(level, _damagePerLevel);
}

double applySkillLevelDuration(double base, int level) {
  return base * _scale(level, _durationPerLevel);
}

double applySkillLevelSize(double base, int level) {
  return base * _scale(level, _sizePerLevel);
}

double applySkillLevelSpeed(double base, int level) {
  return base * _scale(level, _speedPerLevel);
}

double applySkillLevelCooldown(double base, int level) {
  final scale = (1 - _cooldownPerLevel * math.max(0, level - 1))
      .clamp(_minCooldownScale, 2.0)
      .toDouble();
  return base * scale;
}

double applySkillLevelKnockback(double base, int level) {
  return base * _scale(level, _knockbackPerLevel);
}

double applySkillLevelSlowMultiplier(double baseMultiplier, int level) {
  final baseStrength = (1 - baseMultiplier).clamp(0.0, 1.0);
  final scaledStrength = baseStrength * _scale(level, _slowStrengthPerLevel);
  return (1 - scaledStrength).clamp(0.0, 1.0);
}

double applySkillLevelSlowStrength(double baseStrength, int level) {
  return baseStrength * _scale(level, _slowStrengthPerLevel);
}

double _scale(int level, double perLevel) {
  return math.max(0.0, 1 + perLevel * math.max(0, level - 1));
}
