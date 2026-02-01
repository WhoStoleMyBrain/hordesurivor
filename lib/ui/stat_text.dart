import '../data/stat_defs.dart';

class StatText {
  static String labelFor(StatId id) => _labels[id] ?? id.name;

  static String descriptionFor(StatId id) => _descriptions[id] ?? '';

  static String tooltipFor(StatId id) =>
      '${labelFor(id)}\n${descriptionFor(id)}';

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

const Map<StatId, String> _descriptions = {
  StatId.maxHp: 'Maximum health before defeat. Formula: max(1, stat value).',
  StatId.maxMana:
      'Maximum mana available for skills. Formula: max(0, stat value).',
  StatId.hpRegen:
      'Regenerates HP per second based on regen points. Formula: ln(1 + points) / ln(1 + 10).',
  StatId.manaRegen:
      'Regenerates mana per second based on regen points. Formula: ln(1 + points) / ln(1 + 10).',
  StatId.defense:
      'Reduces incoming damage. Damage is multiplied by (1 - Defense), clamped to 0.05–3.0.',
  StatId.dodgeChance:
      'Chance to ignore a hit entirely. Clamped to 0–85% before rolling.',
  StatId.shieldMax: 'Reserved for a future shielding system (not applied yet).',
  StatId.shieldRegen:
      'Reserved for a future shielding system (not applied yet).',
  StatId.healingReceivedPercent:
      'Scales healing received. Multiplier = max(0.1, 1 + Healing Received).',
  StatId.damagePercent:
      'Adds to the global damage multiplier for all skills. Total damage = base * (1 + Global + tag bonuses) + flat.',
  StatId.flatDamage: 'Flat damage added to all skills after multipliers.',
  StatId.critChance:
      'Reserved for a future critical hit system (not applied yet).',
  StatId.critDamagePercent:
      'Reserved for a future critical hit system (not applied yet).',
  StatId.attackSpeed:
      'Speeds up skill cooldowns and attack cadence. Cooldown scale = max(0.1, 1 + Attack Speed).',
  StatId.moveSpeedPercent:
      'Scales movement speed. Move speed = base * (1 + Move Speed), clamped to >= 0.',
  StatId.aoeSize:
      'Scales area effects (radius/width/length). AOE scale = max(0.25, 1 + AOE Size).',
  StatId.dotDamagePercent:
      'Adds to the damage multiplier for skills tagged DOT.',
  StatId.dotDurationPercent:
      'Reserved for future DOT duration scaling (not applied yet).',
  StatId.statusApplyChance:
      'Reserved for chance-based status application (not applied yet).',
  StatId.statusPotencyPercent:
      'Increases status strength. Currently adds to root strength before clamping.',
  StatId.statusDurationPercent:
      'Scales status duration. Currently applied to roots with a minimum duration scale.',
  StatId.meleeDamagePercent:
      'Adds to the damage multiplier for melee-tagged skills.',
  StatId.projectileDamagePercent:
      'Adds to the damage multiplier for projectile-tagged skills.',
  StatId.beamDamagePercent:
      'Adds to the damage multiplier for beam-tagged skills.',
  StatId.explosionDamagePercent:
      'Adds to the damage multiplier for explosion-tagged effects (currently applied alongside ground damage).',
  StatId.auraDamagePercent:
      'Adds to the damage multiplier for aura-tagged skills.',
  StatId.groundDamagePercent:
      'Adds to the damage multiplier for ground-tagged effects.',
  StatId.elementalDamagePercent:
      'Adds to the damage multiplier when a skill has any elemental tag.',
  StatId.flatElementalDamage:
      'Flat damage added when a skill has any elemental tag.',
  StatId.fireDamagePercent:
      'Adds to the damage multiplier for fire-tagged skills.',
  StatId.waterDamagePercent:
      'Adds to the damage multiplier for water-tagged skills.',
  StatId.earthDamagePercent:
      'Adds to the damage multiplier for earth-tagged skills.',
  StatId.windDamagePercent:
      'Adds to the damage multiplier for wind-tagged skills.',
  StatId.poisonDamagePercent:
      'Adds to the damage multiplier for poison-tagged skills.',
  StatId.steelDamagePercent:
      'Adds to the damage multiplier for steel-tagged skills.',
  StatId.woodDamagePercent:
      'Adds to the damage multiplier for wood-tagged skills.',
  StatId.dropsPercent:
      'Boosts Meta Shard rewards at run end. Reward multiplier = 1 + Drop Rate.',
  StatId.pickupRadiusPercent:
      'Scales pickup radius. Pickup radius = base 32 * (1 + Pickup Radius).',
  StatId.rerolls:
      'Adds rerolls to reward selections. Rounded to the nearest integer.',
  StatId.choiceCount:
      'Adds extra choices on reward selections. Rounded to the nearest integer.',
  StatId.banishes:
      'Adds banish tokens on reward selections. Rounded to the nearest integer.',
  StatId.shopDiscountPercent:
      'Reserved for shop price discounts (not applied yet).',
  StatId.shopRerollDiscountPercent:
      'Reserved for shop reroll discounts (not applied yet).',
  StatId.shopLockSlots: 'Reserved for shop lock slots (not applied yet).',
  StatId.shopOfferRarityBias:
      'Reserved for shop rarity bias (not applied yet).',
  StatId.shopOfferSynergyBias:
      'Reserved for shop synergy bias (not applied yet).',
  StatId.sanctity: 'Reserved for rite-based effects (not applied yet).',
  StatId.heresy: 'Reserved for rite-based effects (not applied yet).',
  StatId.conviction: 'Reserved for rite-based effects (not applied yet).',
  StatId.incenseDensity: 'Reserved for rite-based effects (not applied yet).',
  StatId.paperwork: 'Reserved for rite-based effects (not applied yet).',
  StatId.absolution:
      'Chance per enemy hit to heal 1 HP. Chance is clamped to 0–100%.',
  StatId.penance: 'Reserved for rite-based effects (not applied yet).',
  StatId.banishmentForce:
      'Scales knockback force on skills. Knockback scale = max(0.1, 1 + Banishment Force).',
  StatId.sigilClarity: 'Reserved for rite-based effects (not applied yet).',
  StatId.holyWaterPressure:
      'Reserved for rite-based effects (not applied yet).',
  StatId.curseApplyChance: 'Reserved for curse application (not applied yet).',
  StatId.curseDurationPercent:
      'Reserved for curse duration scaling (not applied yet).',
  StatId.damageVsCursedPercent:
      'Reserved for bonus damage vs cursed targets (not applied yet).',
  StatId.exorcismYieldPercent:
      'Reserved for exorcism yield bonuses (not applied yet).',
  StatId.fieldOfView:
      'Scales camera zoom. FOV scale = clamp(1 + Field of View, 0.5–1.75); zoom = baseZoom / FOV scale.',
  StatId.accuracy:
      'Reduces aim jitter. Spread scale = clamp(1 - Accuracy, 0–2.5).',
  StatId.pickupMagnetStrength:
      'Reserved for pickup magnet strength (not applied yet).',
  StatId.threatSense: 'Reserved for threat sensing (not applied yet).',
};
