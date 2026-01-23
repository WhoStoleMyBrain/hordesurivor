import 'package:hordesurivor/data/data.dart';

import '../data/ids.dart';

class SkillDetailLine {
  const SkillDetailLine(this.label, this.value);

  final String label;
  final String value;

  String format() => '$label: $value';
}

List<SkillDetailLine> skillDetailLinesFor(SkillId id) {
  switch (id) {
    case SkillId.fireball:
      return [
        _cooldownLine(0.6),
        _damageLine(8),
        _projectileSpeedLine(220),
        _rangeLine(440),
        _projectileRadiusLine(4),
        _igniteLine(dps: 3, duration: 1.4),
        _knockbackLine(force: 80, duration: 0.18),
      ];
    case SkillId.waterjet:
      return [
        _cooldownLine(0.7),
        _damageOverTimeLine(damage: 6, duration: 0.35),
        _beamLengthLine(140),
        _beamWidthLine(10),
        _slowLine(multiplier: 0.7, duration: 0.315),
      ];
    case SkillId.oilBombs:
      return [
        _cooldownLine(1.1),
        _damageLine(4),
        _projectileSpeedLine(160),
        _rangeLine(224),
        _projectileRadiusLine(6),
        _groundRadiusLine(46),
        _durationLine('Ground Duration', 2.0),
        _damagePerSecondLine(2),
        _slowLine(multiplier: 0.8, duration: 0.6),
        _durationLine('Oil Duration', 1.2),
        _knockbackLine(force: 60, duration: 0.16),
      ];
    case SkillId.swordThrust:
      return [
        _cooldownLine(0.8),
        _damageLine(10),
        _rangeLine(58),
        _arcLine(30),
        _knockbackLine(force: 120, duration: 0.2),
      ];
    case SkillId.swordCut:
      return [
        _cooldownLine(0.9),
        _damageLine(12),
        _rangeLine(46),
        _arcLine(90),
        _knockbackLine(force: 100, duration: 0.18),
      ];
    case SkillId.swordSwing:
      return [
        _cooldownLine(1.2),
        _damageLine(14),
        _rangeLine(52),
        _arcLine(140),
        _knockbackLine(force: 135, duration: 0.22),
      ];
    case SkillId.swordDeflect:
      return [
        _cooldownLine(1.4),
        _damageLine(8),
        _rangeLine(42),
        _arcLine(100),
        _deflectRadiusLine(55),
        _durationLine('Deflect Duration', 0.18),
        _knockbackLine(force: 90, duration: 0.16),
      ];
    case SkillId.poisonGas:
      return [
        _cooldownLine(1.3),
        _groundRadiusLine(70),
        _damageOverTimeLine(damage: 4, duration: 0.8),
      ];
    case SkillId.roots:
      return [
        _cooldownLine(1.2),
        _groundRadiusLine(54),
        _damageOverTimeLine(damage: 7, duration: 1.8),
        _slowLine(multiplier: 0.4, duration: 1.8, label: 'Root Slow'),
        _rangeLine(60, label: 'Cast Offset'),
      ];
    case SkillId.windCutter:
      return [
        _cooldownLine(0.55),
        _damageLine(7),
        _projectileSpeedLine(280),
        _rangeLine(392),
        _projectileRadiusLine(3),
        _knockbackLine(force: 70, duration: 0.16),
      ];
    case SkillId.steelShards:
      return [
        _cooldownLine(0.9),
        _damageLine(6, label: 'Shard Damage'),
        const SkillDetailLine('Projectiles', '3'),
        const SkillDetailLine('Spread', '±0.2 rad'),
        _projectileSpeedLine(200),
        _rangeLine(240),
        _projectileRadiusLine(3),
        _knockbackLine(force: 85, duration: 0.18),
      ];
    case SkillId.flameWave:
      return [
        _cooldownLine(1.1),
        _damageOverTimeLine(damage: 10, duration: 0.45),
        _beamLengthLine(120),
        _beamWidthLine(18),
      ];
    case SkillId.frostNova:
      return [
        _cooldownLine(1.4),
        _damageOverTimeLine(damage: 5, duration: 0.6),
        _groundRadiusLine(80),
        _slowLine(multiplier: 0.6, duration: 0.6),
      ];
    case SkillId.earthSpikes:
      return [
        _cooldownLine(1.3),
        _damageOverTimeLine(damage: 9, duration: 0.7),
        _groundRadiusLine(68),
        _durationLine('Spike Duration', 0.7),
        _rangeLine(72, label: 'Cast Offset'),
      ];
    case SkillId.sporeBurst:
      return [
        _cooldownLine(1.0),
        _damageLine(5),
        _projectileSpeedLine(170),
        _rangeLine(272),
        _projectileRadiusLine(5),
        _groundRadiusLine(50, label: 'Cloud Radius'),
        _damageOverTimeLine(damage: 4, duration: 1.4, label: 'Cloud Damage'),
        _slowLine(multiplier: 0.85, duration: 0.4),
      ];
    case SkillId.processionIdol:
      return [
        _cooldownLine(9.5),
        _durationLine('Summon Duration', 6),
        _damagePerSecondLine(9),
        _rangeLine(160),
        _orbitRadiusLine(36),
        _orbitSpeedLine(2.4),
        _moveSpeedLine(120),
      ];
    case SkillId.vigilLantern:
      return [
        const SkillDetailLine('Summon', 'Persistent'),
        _damageLine(6, label: 'Projectile Damage'),
        _durationLine('Attack Cooldown', 0.75),
        _projectileSpeedLine(260),
        _rangeLine(220),
        _projectileRadiusLine(3),
        _orbitRadiusLine(44),
        _orbitSpeedLine(1.6),
      ];
    case SkillId.guardianOrbs:
      return [
        const SkillDetailLine('Summon', '2 orbs (persistent)'),
        _damagePerSecondLine(5),
        _orbitRadiusLine(34),
        _orbitSpeedLine(2.8),
      ];
    case SkillId.menderOrb:
      return [
        _cooldownLine(9.5),
        _durationLine('Summon Duration', 6),
        _healingPerSecondLine(0.32),
        _orbitRadiusLine(38),
        _orbitSpeedLine(2.2),
      ];
    case SkillId.mineLayer:
      return [
        _cooldownLine(8.0),
        _damageLine(12, label: 'Blast Damage'),
        _durationLine('Mine Duration', 5),
        _durationLine('Arm Time', 0.25),
        _rangeLine(22, label: 'Trigger Radius'),
        _rangeLine(36, label: 'Blast Radius'),
      ];
    case SkillId.chairThrow:
      return [
        _cooldownLine(0.95),
        _damageLine(9),
        _projectileSpeedLine(200),
        _rangeLine(320),
        _projectileRadiusLine(7),
        _knockbackLine(force: 110, duration: 0.2),
      ];
    case SkillId.absolutionSlap:
      return [
        _cooldownLine(0.8),
        _damageLine(8),
        _rangeLine(40),
        _arcLine(70),
        _knockbackLine(force: 95, duration: 0.16),
      ];
  }
}

List<String> skillDetailTextLinesFor(SkillId id) {
  return skillDetailLinesFor(
    id,
  ).map((detail) => detail.format()).toList(growable: false);
}

String skillDetailBlockFor(SkillId id) {
  final lines = skillDetailLinesFor(id);
  if (lines.isEmpty) {
    return '';
  }
  return lines.map((detail) => '• ${detail.format()}').join('\n');
}

SkillDetailLine _cooldownLine(double seconds) {
  return _durationLine('Cooldown', seconds);
}

SkillDetailLine _durationLine(String label, double seconds) {
  return SkillDetailLine(label, _formatSeconds(seconds));
}

SkillDetailLine _damageLine(double damage, {String label = 'Damage'}) {
  return SkillDetailLine(label, _formatNumber(damage));
}

SkillDetailLine _damagePerSecondLine(double damage) {
  return SkillDetailLine('Damage per Second', _formatNumber(damage));
}

SkillDetailLine _damageOverTimeLine({
  required double damage,
  required double duration,
  String label = 'Damage',
}) {
  return SkillDetailLine(
    label,
    '${_formatNumber(damage)} over ${_formatSeconds(duration)}',
  );
}

SkillDetailLine _healingPerSecondLine(double healing) {
  return SkillDetailLine('Healing per Second', _formatNumber(healing));
}

SkillDetailLine _projectileSpeedLine(double speed) {
  return SkillDetailLine('Projectile Speed', _formatNumber(speed));
}

SkillDetailLine _projectileRadiusLine(double radius) {
  return SkillDetailLine('Projectile Radius', _formatNumber(radius));
}

SkillDetailLine _beamLengthLine(double length) {
  return SkillDetailLine('Beam Length', _formatNumber(length));
}

SkillDetailLine _beamWidthLine(double width) {
  return SkillDetailLine('Beam Width', _formatNumber(width));
}

SkillDetailLine _groundRadiusLine(
  double radius, {
  String label = 'Area Radius',
}) {
  return SkillDetailLine(label, _formatNumber(radius));
}

SkillDetailLine _rangeLine(double range, {String label = 'Range'}) {
  return SkillDetailLine(label, _formatNumber(range));
}

SkillDetailLine _arcLine(double arcDegrees) {
  return SkillDetailLine('Arc', '${_formatNumber(arcDegrees)}°');
}

SkillDetailLine _deflectRadiusLine(double radius) {
  return SkillDetailLine('Deflect Radius', _formatNumber(radius));
}

SkillDetailLine _orbitRadiusLine(double radius) {
  return SkillDetailLine('Orbit Radius', _formatNumber(radius));
}

SkillDetailLine _orbitSpeedLine(double speed) {
  return SkillDetailLine('Orbit Speed', _formatNumber(speed));
}

SkillDetailLine _moveSpeedLine(double speed) {
  return SkillDetailLine('Move Speed', _formatNumber(speed));
}

SkillDetailLine _slowLine({
  required double multiplier,
  required double duration,
  String label = 'Slow',
}) {
  final slowPercent = (1 - multiplier).clamp(0.0, 1.0);
  return SkillDetailLine(
    label,
    '${_formatPercent(slowPercent)} for ${_formatSeconds(duration)}',
  );
}

SkillDetailLine _igniteLine({required double dps, required double duration}) {
  return SkillDetailLine(
    'Ignite',
    '${_formatNumber(dps)} DPS for ${_formatSeconds(duration)}',
  );
}

SkillDetailLine _knockbackLine({
  required double force,
  required double duration,
}) {
  return SkillDetailLine(
    'Knockback',
    '${_formatNumber(force)} force / ${_formatSeconds(duration)}',
  );
}

String _formatNumber(double value) {
  final fractionDigits = _fractionDigits(value);
  return value.toStringAsFixed(fractionDigits);
}

String _formatSeconds(double value) {
  return '${_formatNumber(value)}s';
}

String _formatPercent(double value) {
  final percent = value * 100;
  final fractionDigits = _fractionDigits(percent);
  return '${percent.toStringAsFixed(fractionDigits)}%';
}

int _fractionDigits(double value) {
  if (value % 1 == 0) {
    return 0;
  }
  if ((value * 10) % 1 == 0) {
    return 1;
  }
  return 2;
}
