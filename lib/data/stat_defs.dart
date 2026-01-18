enum StatId {
  maxHp,
  hpRegen,
  damage,
  elementalDamage,
  flatDamage,
  flatElementalDamage,
  moveSpeed,
  moveSpeedPercent,
  dashSpeed,
  dashDistance,
  dashCooldown,
  dashCharges,
  dashDuration,
  dashStartOffset,
  dashEndOffset,
  dashInvulnerability,
  dashTeleport,
  defense,
  attackSpeed,
  dotDamage,
  dotDuration,
  directHitDamage,
  aoeSize,
  meleeDamage,
  projectileDamage,
  beamDamage,
  explosionDamage,
  fireDamage,
  waterDamage,
  earthDamage,
  windDamage,
  poisonDamage,
  steelDamage,
  woodDamage,
  poisonResistance,
  healingReceived,
  rootStrength,
  rootDuration,
  knockbackStrength,
  lifeSteal,
  drops,
  rerolls,
  choiceCount,
  banishes,
  skipMetaShards,
  cooldownRecovery,
  accuracy,
  pickupRadiusPercent,
  selfExplosionDamageTaken,
  fieldOfView,
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
