import 'ids.dart';

class ContractDef {
  const ContractDef({
    required this.id,
    required this.name,
    required this.description,
    required this.heat,
    required this.rewardMultiplier,
    this.enemyProjectileSpeedMultiplier = 1.0,
    this.enemyMoveSpeedMultiplier = 1.0,
    this.eliteWeightMultiplier = 1.0,
    this.supportRoleWeightMultiplier = 1.0,
  });

  final ContractId id;
  final String name;
  final String description;
  final int heat;
  final double rewardMultiplier;
  final double enemyProjectileSpeedMultiplier;
  final double enemyMoveSpeedMultiplier;
  final double eliteWeightMultiplier;
  final double supportRoleWeightMultiplier;
}

const List<ContractDef> contractDefs = [
  ContractDef(
    id: ContractId.volleyPressure,
    name: 'Volley Pressure',
    description: 'Enemy projectiles travel faster, tightening dodges.',
    heat: 1,
    rewardMultiplier: 1.1,
    enemyProjectileSpeedMultiplier: 1.25,
  ),
  ContractDef(
    id: ContractId.eliteSurge,
    name: 'Elite Surge',
    description: 'Champion enemies appear more frequently.',
    heat: 2,
    rewardMultiplier: 1.2,
    eliteWeightMultiplier: 1.6,
  ),
  ContractDef(
    id: ContractId.supportUplink,
    name: 'Support Uplink',
    description: 'Support units reinforce enemy formations.',
    heat: 1,
    rewardMultiplier: 1.1,
    supportRoleWeightMultiplier: 1.5,
  ),
  ContractDef(
    id: ContractId.relentlessAdvance,
    name: 'Relentless Advance',
    description: 'Enemies close in faster, shrinking safe spacing.',
    heat: 1,
    rewardMultiplier: 1.1,
    enemyMoveSpeedMultiplier: 1.2,
  ),
  ContractDef(
    id: ContractId.coordinatedAssault,
    name: 'Coordinated Assault',
    description: 'Support lines tighten as volleys accelerate.',
    heat: 2,
    rewardMultiplier: 1.2,
    enemyProjectileSpeedMultiplier: 1.2,
    supportRoleWeightMultiplier: 1.4,
  ),
  ContractDef(
    id: ContractId.hardenedOnslaught,
    name: 'Hardened Onslaught',
    description: 'Champions surge forward with faster advance.',
    heat: 2,
    rewardMultiplier: 1.2,
    enemyMoveSpeedMultiplier: 1.15,
    eliteWeightMultiplier: 1.4,
  ),
  ContractDef(
    id: ContractId.crossfireRush,
    name: 'Crossfire Rush',
    description: 'Enemy volleys and advances quicken together.',
    heat: 2,
    rewardMultiplier: 1.2,
    enemyProjectileSpeedMultiplier: 1.2,
    enemyMoveSpeedMultiplier: 1.1,
  ),
  ContractDef(
    id: ContractId.siegeFormation,
    name: 'Siege Formation',
    description: 'Support lines advance in tighter, faster formations.',
    heat: 2,
    rewardMultiplier: 1.2,
    enemyMoveSpeedMultiplier: 1.15,
    supportRoleWeightMultiplier: 1.5,
  ),
];

final Map<ContractId, ContractDef> contractDefsById = Map.unmodifiable({
  for (final def in contractDefs) def.id: def,
});
