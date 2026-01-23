enum StatId {
  // Core
  maxHp,
  hpRegen,
  defense,
  dodgeChance,
  shieldMax,
  shieldRegen,
  healingReceivedPercent,
  // Damage
  damagePercent,
  flatDamage,
  critChance,
  critDamagePercent,
  attackSpeed,
  cooldownRecovery,
  aoeSize,
  // DOT/Status
  dotDamagePercent,
  dotDurationPercent,
  statusApplyChance,
  statusPotencyPercent,
  statusDurationPercent,
  // Delivery
  meleeDamagePercent,
  projectileDamagePercent,
  beamDamagePercent,
  explosionDamagePercent,
  auraDamagePercent,
  groundDamagePercent,
  // Elements
  elementalDamagePercent,
  flatElementalDamage,
  fireDamagePercent,
  waterDamagePercent,
  earthDamagePercent,
  windDamagePercent,
  poisonDamagePercent,
  steelDamagePercent,
  woodDamagePercent,
  // Economy/Shop
  dropsPercent,
  pickupRadiusPercent,
  rerolls,
  choiceCount,
  banishes,
  shopDiscountPercent,
  shopRerollDiscountPercent,
  shopLockSlots,
  shopOfferRarityBias,
  shopOfferSynergyBias,
  // Theme
  sanctity,
  heresy,
  conviction,
  incenseDensity,
  paperwork,
  absolution,
  penance,
  banishmentForce,
  sigilClarity,
  holyWaterPressure,
  // Curse
  curseApplyChance,
  curseDurationPercent,
  damageVsCursedPercent,
  exorcismYieldPercent,
  // Comfort
  fieldOfView,
  accuracy,
  pickupMagnetStrength,
  threatSense,
}

enum ModifierKind { flat, percent }

class StatModifier {
  const StatModifier({
    required this.stat,
    required this.amount,
    this.kind = ModifierKind.percent,
  });

  final StatId stat;
  final double amount;
  final ModifierKind kind;
}
