enum StatId {
  maxHp,
  damage,
  moveSpeed,
  dashSpeed,
  dashDistance,
  dashCooldown,
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
  poisonResistance,
  healingReceived,
  rootStrength,
  rootDuration,
  knockbackStrength,
  lifeSteal,
  drops,
  rerolls,
  choiceCount,
  cooldownRecovery,
  accuracy,
  pickupRadius,
  selfExplosionDamageTaken,
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
