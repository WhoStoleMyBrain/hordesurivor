import '../data/stat_defs.dart';

class StatText {
  static String labelFor(StatId id) => _labels[id] ?? id.name;

  static String formatModifier(StatModifier modifier) {
    final value = modifier.amount;
    final sign = value >= 0 ? '+' : '';
    if (modifier.kind == ModifierKind.percent) {
      final percent = _formatPercent(value);
      return '$sign$percent ${labelFor(modifier.stat)}';
    }
    final number = _formatNumber(value);
    return '$sign$number ${labelFor(modifier.stat)}';
  }

  static String formatStatValue(StatId id, double value) {
    if (_flatStats.contains(id)) {
      return _formatNumber(value);
    }
    final sign = value >= 0 ? '+' : '';
    return '$sign${_formatPercent(value)}';
  }

  static String _formatPercent(double value) {
    final percent = value * 100;
    return '${percent.toStringAsFixed(percent % 1 == 0 ? 0 : 1)}%';
  }

  static String _formatNumber(double value) {
    return value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
  }
}

const Map<StatId, String> _labels = {
  StatId.maxHp: 'Max HP',
  StatId.damage: 'Damage',
  StatId.moveSpeed: 'Move Speed',
  StatId.dashSpeed: 'Dash Speed',
  StatId.dashDistance: 'Dash Distance',
  StatId.dashCooldown: 'Dash Cooldown',
  StatId.dashCharges: 'Dash Charges',
  StatId.dashDuration: 'Dash Duration',
  StatId.dashStartOffset: 'Dash Start Offset',
  StatId.dashEndOffset: 'Dash End Offset',
  StatId.dashInvulnerability: 'Dash Invulnerability',
  StatId.dashTeleport: 'Dash Teleport',
  StatId.defense: 'Defense',
  StatId.attackSpeed: 'Attack Speed',
  StatId.dotDamage: 'DOT Damage',
  StatId.dotDuration: 'DOT Duration',
  StatId.directHitDamage: 'Direct Hit Damage',
  StatId.aoeSize: 'AOE Size',
  StatId.meleeDamage: 'Melee Damage',
  StatId.projectileDamage: 'Projectile Damage',
  StatId.beamDamage: 'Beam Damage',
  StatId.explosionDamage: 'Explosion Damage',
  StatId.fireDamage: 'Fire Damage',
  StatId.waterDamage: 'Water Damage',
  StatId.poisonResistance: 'Poison Resistance',
  StatId.healingReceived: 'Healing Received',
  StatId.rootStrength: 'Root Strength',
  StatId.rootDuration: 'Root Duration',
  StatId.knockbackStrength: 'Knockback Strength',
  StatId.lifeSteal: 'Life Steal',
  StatId.drops: 'Drop Rate',
  StatId.rerolls: 'Rerolls',
  StatId.choiceCount: 'Choice Count',
  StatId.banishes: 'Banishes',
  StatId.skipMetaShards: 'Skip Meta Shards',
  StatId.cooldownRecovery: 'Cooldown Recovery',
  StatId.accuracy: 'Accuracy',
  StatId.pickupRadius: 'Pickup Radius',
  StatId.selfExplosionDamageTaken: 'Self Explosion Damage Taken',
  StatId.fieldOfView: 'Field of View',
};

const Set<StatId> _flatStats = {
  StatId.maxHp,
  StatId.moveSpeed,
  StatId.dashSpeed,
  StatId.dashDistance,
  StatId.dashCooldown,
  StatId.dashCharges,
  StatId.dashDuration,
  StatId.dashStartOffset,
  StatId.dashEndOffset,
  StatId.dashInvulnerability,
  StatId.dashTeleport,
  StatId.rerolls,
  StatId.choiceCount,
  StatId.banishes,
  StatId.skipMetaShards,
};
