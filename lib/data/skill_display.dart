class SkillDetailLine {
  const SkillDetailLine(this.label, this.value);

  final String label;
  final String value;

  String format() => '$label: $value';
}

SkillDetailLine cooldownLine(double seconds) {
  return durationLine('Cooldown', seconds);
}

SkillDetailLine durationLine(String label, double seconds) {
  return SkillDetailLine(label, _formatSeconds(seconds));
}

SkillDetailLine damageLine(double damage, {String label = 'Damage'}) {
  return SkillDetailLine(label, _formatNumber(damage));
}

SkillDetailLine damagePerSecondLine(double damage) {
  return SkillDetailLine('Damage per Second', _formatNumber(damage));
}

SkillDetailLine damageOverTimeLine({
  required double damage,
  required double duration,
  String label = 'Damage',
}) {
  return SkillDetailLine(
    label,
    '${_formatNumber(damage)} over ${_formatSeconds(duration)}',
  );
}

SkillDetailLine healingPerSecondLine(double healing) {
  return SkillDetailLine('Healing per Second', _formatNumber(healing));
}

SkillDetailLine projectileSpeedLine(double speed) {
  return SkillDetailLine('Projectile Speed', _formatNumber(speed));
}

SkillDetailLine projectileRadiusLine(double radius) {
  return SkillDetailLine('Projectile Radius', _formatNumber(radius));
}

SkillDetailLine beamLengthLine(double length) {
  return SkillDetailLine('Beam Length', _formatNumber(length));
}

SkillDetailLine beamWidthLine(double width) {
  return SkillDetailLine('Beam Width', _formatNumber(width));
}

SkillDetailLine groundRadiusLine(
  double radius, {
  String label = 'Area Radius',
}) {
  return SkillDetailLine(label, _formatNumber(radius));
}

SkillDetailLine rangeLine(double range, {String label = 'Range'}) {
  return SkillDetailLine(label, _formatNumber(range));
}

SkillDetailLine arcLine(double arcDegrees) {
  return SkillDetailLine('Arc', '${_formatNumber(arcDegrees)}°');
}

SkillDetailLine deflectRadiusLine(double radius) {
  return SkillDetailLine('Deflect Radius', _formatNumber(radius));
}

SkillDetailLine orbitRadiusLine(double radius) {
  return SkillDetailLine('Orbit Radius', _formatNumber(radius));
}

SkillDetailLine orbitSpeedLine(double speed) {
  return SkillDetailLine('Orbit Speed', _formatNumber(speed));
}

SkillDetailLine moveSpeedLine(double speed) {
  return SkillDetailLine('Move Speed', _formatNumber(speed));
}

SkillDetailLine slowLine({
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

SkillDetailLine igniteLine({required double dps, required double duration}) {
  return SkillDetailLine(
    'Ignite',
    '${_formatNumber(dps)} DPS for ${_formatSeconds(duration)}',
  );
}

SkillDetailLine knockbackLine({
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
