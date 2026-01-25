enum SkillDetailValueType {
  cooldown,
  attackCooldown,
  duration,
  damage,
  damagePerSecond,
  damageOverTime,
  healingPerSecond,
  projectileSpeed,
  projectileRadius,
  beamLength,
  beamWidth,
  groundRadius,
  range,
  arc,
  deflectRadius,
  orbitRadius,
  orbitSpeed,
  moveSpeed,
  slow,
  ignite,
  knockback,
}

class SkillDetailLine {
  const SkillDetailLine(
    this.label,
    this.value, {
    this.detailType,
    this.primaryValue,
    this.secondaryValue,
    this.scalesWithAoe = false,
  });

  final String label;
  final String value;
  final SkillDetailValueType? detailType;
  final double? primaryValue;
  final double? secondaryValue;
  final bool scalesWithAoe;

  String format() => '$label: $value';
}

SkillDetailLine cooldownLine(double seconds) {
  return SkillDetailLine(
    'Cooldown',
    _formatSeconds(seconds),
    detailType: SkillDetailValueType.cooldown,
    primaryValue: seconds,
  );
}

SkillDetailLine attackCooldownLine(double seconds) {
  return SkillDetailLine(
    'Attack Cooldown',
    _formatSeconds(seconds),
    detailType: SkillDetailValueType.attackCooldown,
    primaryValue: seconds,
  );
}

SkillDetailLine durationLine(String label, double seconds) {
  return SkillDetailLine(
    label,
    _formatSeconds(seconds),
    detailType: SkillDetailValueType.duration,
    primaryValue: seconds,
  );
}

SkillDetailLine damageLine(double damage, {String label = 'Damage'}) {
  return SkillDetailLine(
    label,
    _formatNumber(damage),
    detailType: SkillDetailValueType.damage,
    primaryValue: damage,
  );
}

SkillDetailLine damagePerSecondLine(double damage) {
  return SkillDetailLine(
    'Damage per Second',
    _formatNumber(damage),
    detailType: SkillDetailValueType.damagePerSecond,
    primaryValue: damage,
  );
}

SkillDetailLine damageOverTimeLine({
  required double damage,
  required double duration,
  String label = 'Damage',
}) {
  return SkillDetailLine(
    label,
    '${_formatNumber(damage)} over ${_formatSeconds(duration)}',
    detailType: SkillDetailValueType.damageOverTime,
    primaryValue: damage,
    secondaryValue: duration,
  );
}

SkillDetailLine healingPerSecondLine(double healing) {
  return SkillDetailLine(
    'Healing per Second',
    _formatNumber(healing),
    detailType: SkillDetailValueType.healingPerSecond,
    primaryValue: healing,
  );
}

SkillDetailLine projectileSpeedLine(double speed) {
  return SkillDetailLine(
    'Projectile Speed',
    _formatNumber(speed),
    detailType: SkillDetailValueType.projectileSpeed,
    primaryValue: speed,
  );
}

SkillDetailLine projectileRadiusLine(double radius) {
  return SkillDetailLine(
    'Projectile Radius',
    _formatNumber(radius),
    detailType: SkillDetailValueType.projectileRadius,
    primaryValue: radius,
  );
}

SkillDetailLine beamLengthLine(double length) {
  return SkillDetailLine(
    'Beam Length',
    _formatNumber(length),
    detailType: SkillDetailValueType.beamLength,
    primaryValue: length,
    scalesWithAoe: true,
  );
}

SkillDetailLine beamWidthLine(double width) {
  return SkillDetailLine(
    'Beam Width',
    _formatNumber(width),
    detailType: SkillDetailValueType.beamWidth,
    primaryValue: width,
    scalesWithAoe: true,
  );
}

SkillDetailLine groundRadiusLine(
  double radius, {
  String label = 'Area Radius',
}) {
  return SkillDetailLine(
    label,
    _formatNumber(radius),
    detailType: SkillDetailValueType.groundRadius,
    primaryValue: radius,
    scalesWithAoe: true,
  );
}

SkillDetailLine rangeLine(
  double range, {
  String label = 'Range',
  bool scalesWithAoe = false,
}) {
  return SkillDetailLine(
    label,
    _formatNumber(range),
    detailType: SkillDetailValueType.range,
    primaryValue: range,
    scalesWithAoe: scalesWithAoe,
  );
}

SkillDetailLine arcLine(double arcDegrees) {
  return SkillDetailLine(
    'Arc',
    '${_formatNumber(arcDegrees)}°',
    detailType: SkillDetailValueType.arc,
    primaryValue: arcDegrees,
  );
}

SkillDetailLine deflectRadiusLine(double radius) {
  return SkillDetailLine(
    'Deflect Radius',
    _formatNumber(radius),
    detailType: SkillDetailValueType.deflectRadius,
    primaryValue: radius,
    scalesWithAoe: true,
  );
}

SkillDetailLine orbitRadiusLine(double radius) {
  return SkillDetailLine(
    'Orbit Radius',
    _formatNumber(radius),
    detailType: SkillDetailValueType.orbitRadius,
    primaryValue: radius,
  );
}

SkillDetailLine orbitSpeedLine(double speed) {
  return SkillDetailLine(
    'Orbit Speed',
    _formatNumber(speed),
    detailType: SkillDetailValueType.orbitSpeed,
    primaryValue: speed,
  );
}

SkillDetailLine moveSpeedLine(double speed) {
  return SkillDetailLine(
    'Move Speed',
    _formatNumber(speed),
    detailType: SkillDetailValueType.moveSpeed,
    primaryValue: speed,
  );
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
    detailType: SkillDetailValueType.slow,
    primaryValue: multiplier,
    secondaryValue: duration,
  );
}

SkillDetailLine igniteLine({required double dps, required double duration}) {
  return SkillDetailLine(
    'Ignite',
    '${_formatNumber(dps)} DPS for ${_formatSeconds(duration)}',
    detailType: SkillDetailValueType.ignite,
    primaryValue: dps,
    secondaryValue: duration,
  );
}

SkillDetailLine knockbackLine({
  required double force,
  required double duration,
}) {
  return SkillDetailLine(
    'Knockback',
    '${_formatNumber(force)} force / ${_formatSeconds(duration)}',
    detailType: SkillDetailValueType.knockback,
    primaryValue: force,
    secondaryValue: duration,
  );
}

String formatSkillDetailValue(
  SkillDetailValueType type,
  double primaryValue, [
  double? secondaryValue,
]) {
  switch (type) {
    case SkillDetailValueType.cooldown:
    case SkillDetailValueType.attackCooldown:
    case SkillDetailValueType.duration:
      return _formatSeconds(primaryValue);
    case SkillDetailValueType.damage:
    case SkillDetailValueType.damagePerSecond:
    case SkillDetailValueType.healingPerSecond:
    case SkillDetailValueType.projectileSpeed:
    case SkillDetailValueType.projectileRadius:
    case SkillDetailValueType.beamLength:
    case SkillDetailValueType.beamWidth:
    case SkillDetailValueType.groundRadius:
    case SkillDetailValueType.range:
    case SkillDetailValueType.deflectRadius:
    case SkillDetailValueType.orbitRadius:
    case SkillDetailValueType.orbitSpeed:
    case SkillDetailValueType.moveSpeed:
      return _formatNumber(primaryValue);
    case SkillDetailValueType.arc:
      return '${_formatNumber(primaryValue)}°';
    case SkillDetailValueType.damageOverTime:
      return '${_formatNumber(primaryValue)} over ${_formatSeconds(secondaryValue ?? 0)}';
    case SkillDetailValueType.slow:
      final slowPercent = (1 - primaryValue).clamp(0.0, 1.0);
      return '${_formatPercent(slowPercent)} for ${_formatSeconds(secondaryValue ?? 0)}';
    case SkillDetailValueType.ignite:
      return '${_formatNumber(primaryValue)} DPS for ${_formatSeconds(secondaryValue ?? 0)}';
    case SkillDetailValueType.knockback:
      return '${_formatNumber(primaryValue)} force / ${_formatSeconds(secondaryValue ?? 0)}';
  }
}

String formatSkillNumber(double value) => _formatNumber(value);

String formatSkillSeconds(double value) => _formatSeconds(value);

String formatSkillPercent(double value) => _formatPercent(value);

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
