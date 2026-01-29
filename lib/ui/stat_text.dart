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
  StatId.maxMana: 'Max Mana',
  StatId.hpRegen: 'HP Regen',
  StatId.manaRegen: 'Mana Regen',
  StatId.defense: 'Defense',
  StatId.dodgeChance: 'Dodge Chance',
  StatId.shieldMax: 'Shield Max',
  StatId.shieldRegen: 'Shield Regen',
  StatId.healingReceivedPercent: 'Healing Received',
  StatId.damagePercent: 'Global Damage',
  StatId.flatDamage: 'Flat Damage',
  StatId.critChance: 'Crit Chance',
  StatId.critDamagePercent: 'Crit Damage',
  StatId.attackSpeed: 'Attack Speed',
  StatId.moveSpeedPercent: 'Move Speed',
  StatId.aoeSize: 'AOE Size',
  StatId.dotDamagePercent: 'DOT Damage',
  StatId.dotDurationPercent: 'DOT Duration',
  StatId.statusApplyChance: 'Status Apply Chance',
  StatId.statusPotencyPercent: 'Status Potency',
  StatId.statusDurationPercent: 'Status Duration',
  StatId.meleeDamagePercent: 'Melee Damage',
  StatId.projectileDamagePercent: 'Projectile Damage',
  StatId.beamDamagePercent: 'Beam Damage',
  StatId.explosionDamagePercent: 'Explosion Damage',
  StatId.auraDamagePercent: 'Aura Damage',
  StatId.groundDamagePercent: 'Ground Damage',
  StatId.elementalDamagePercent: 'Elemental Damage',
  StatId.flatElementalDamage: 'Flat Elemental Damage',
  StatId.fireDamagePercent: 'Fire Damage',
  StatId.waterDamagePercent: 'Water Damage',
  StatId.earthDamagePercent: 'Earth Damage',
  StatId.windDamagePercent: 'Wind Damage',
  StatId.poisonDamagePercent: 'Poison Damage',
  StatId.steelDamagePercent: 'Steel Damage',
  StatId.woodDamagePercent: 'Wood Damage',
  StatId.dropsPercent: 'Drop Rate',
  StatId.pickupRadiusPercent: 'Pickup Radius',
  StatId.rerolls: 'Rerolls',
  StatId.choiceCount: 'Choice Count',
  StatId.banishes: 'Banishes',
  StatId.shopDiscountPercent: 'Shop Discount',
  StatId.shopRerollDiscountPercent: 'Shop Reroll Discount',
  StatId.shopLockSlots: 'Shop Lock Slots',
  StatId.shopOfferRarityBias: 'Shop Offer Rarity Bias',
  StatId.shopOfferSynergyBias: 'Shop Offer Synergy Bias',
  StatId.sanctity: 'Sanctity',
  StatId.heresy: 'Heresy',
  StatId.conviction: 'Conviction',
  StatId.incenseDensity: 'Incense Density',
  StatId.paperwork: 'Paperwork',
  StatId.absolution: 'Absolution',
  StatId.penance: 'Penance',
  StatId.banishmentForce: 'Banishment Force',
  StatId.sigilClarity: 'Sigil Clarity',
  StatId.holyWaterPressure: 'Holy Water Pressure',
  StatId.curseApplyChance: 'Curse Apply Chance',
  StatId.curseDurationPercent: 'Curse Duration',
  StatId.damageVsCursedPercent: 'Damage vs Cursed',
  StatId.exorcismYieldPercent: 'Exorcism Yield',
  StatId.fieldOfView: 'Field of View',
  StatId.accuracy: 'Accuracy',
  StatId.pickupMagnetStrength: 'Pickup Magnet Strength',
  StatId.threatSense: 'Threat Sense',
};

const Set<StatId> _flatStats = {
  StatId.maxHp,
  StatId.maxMana,
  StatId.hpRegen,
  StatId.manaRegen,
  StatId.shieldMax,
  StatId.shieldRegen,
  StatId.flatDamage,
  StatId.flatElementalDamage,
  StatId.rerolls,
  StatId.choiceCount,
  StatId.banishes,
  StatId.shopLockSlots,
};
