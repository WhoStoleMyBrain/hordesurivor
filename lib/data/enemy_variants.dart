import 'tags.dart';

class EnemyVariantDef {
  const EnemyVariantDef({
    required this.id,
    required this.name,
    required this.maxHpMultiplier,
    required this.moveSpeedMultiplier,
    required this.attackCooldownMultiplier,
    required this.projectileDamageMultiplier,
    required this.xpRewardMultiplier,
    required this.tintColor,
  });

  final EnemyVariant id;
  final String name;
  final double maxHpMultiplier;
  final double moveSpeedMultiplier;
  final double attackCooldownMultiplier;
  final double projectileDamageMultiplier;
  final double xpRewardMultiplier;
  final int tintColor;
}

const List<EnemyVariantDef> enemyVariantDefs = [
  EnemyVariantDef(
    id: EnemyVariant.base,
    name: 'Base',
    maxHpMultiplier: 1,
    moveSpeedMultiplier: 1,
    attackCooldownMultiplier: 1,
    projectileDamageMultiplier: 1,
    xpRewardMultiplier: 1,
    tintColor: 0xFFFFFFFF,
  ),
  EnemyVariantDef(
    id: EnemyVariant.champion,
    name: 'Champion',
    maxHpMultiplier: 1.8,
    moveSpeedMultiplier: 1.15,
    attackCooldownMultiplier: 0.85,
    projectileDamageMultiplier: 1.2,
    xpRewardMultiplier: 2,
    tintColor: 0xFFFFD24A,
  ),
];

final Map<EnemyVariant, EnemyVariantDef> enemyVariantDefsById =
    Map.unmodifiable({for (final def in enemyVariantDefs) def.id: def});
