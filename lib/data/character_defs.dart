import 'ids.dart';
import 'stat_defs.dart';

class CharacterDef {
  const CharacterDef({
    required this.id,
    required this.name,
    required this.themeLine,
    required this.modifierLine,
    required this.spriteId,
    required this.startingSkills,
    required this.baseStats,
    required this.movement,
    required this.modifiers,
  });

  final CharacterId id;
  final String name;
  final String themeLine;
  final String modifierLine;
  final String spriteId;
  final List<SkillId> startingSkills;
  final Map<StatId, double> baseStats;
  final CharacterMovementDef movement;
  final List<StatModifier> modifiers;
}

class CharacterMovementDef {
  const CharacterMovementDef({
    required this.moveSpeed,
    required this.dashSpeed,
    required this.dashDistance,
    required this.dashCooldown,
    required this.dashCharges,
    required this.dashDuration,
    required this.dashStartOffset,
    required this.dashEndOffset,
    required this.dashInvulnerability,
    required this.dashTeleport,
  });

  final double moveSpeed;
  final double dashSpeed;
  final double dashDistance;
  final double dashCooldown;
  final int dashCharges;
  final double dashDuration;
  final double dashStartOffset;
  final double dashEndOffset;
  final double dashInvulnerability;
  final double dashTeleport;

  CharacterMovementDef copyWith({
    double? moveSpeed,
    double? dashSpeed,
    double? dashDistance,
    double? dashCooldown,
    int? dashCharges,
    double? dashDuration,
    double? dashStartOffset,
    double? dashEndOffset,
    double? dashInvulnerability,
    double? dashTeleport,
  }) {
    return CharacterMovementDef(
      moveSpeed: moveSpeed ?? this.moveSpeed,
      dashSpeed: dashSpeed ?? this.dashSpeed,
      dashDistance: dashDistance ?? this.dashDistance,
      dashCooldown: dashCooldown ?? this.dashCooldown,
      dashCharges: dashCharges ?? this.dashCharges,
      dashDuration: dashDuration ?? this.dashDuration,
      dashStartOffset: dashStartOffset ?? this.dashStartOffset,
      dashEndOffset: dashEndOffset ?? this.dashEndOffset,
      dashInvulnerability: dashInvulnerability ?? this.dashInvulnerability,
      dashTeleport: dashTeleport ?? this.dashTeleport,
    );
  }
}

const Map<StatId, double> _basePlayerStats = {StatId.maxHp: 100};

const CharacterMovementDef _basePlayerMovement = CharacterMovementDef(
  moveSpeed: 120,
  dashSpeed: 720,
  dashDistance: 60,
  dashCooldown: 3.0,
  dashCharges: 2,
  dashDuration: 0.18,
  dashStartOffset: 0,
  dashEndOffset: 0,
  dashInvulnerability: 0.18,
  dashTeleport: 0,
);

final List<CharacterDef> characterDefs = [
  CharacterDef(
    id: CharacterId.priest,
    name: 'The Priest',
    themeLine: 'Bell rites and steady chants keep the horde at bay.',
    modifierLine: 'Rite of Cadence — +Cooldown recovery / -Dodge chance',
    spriteId: 'player_priest',
    startingSkills: [
      SkillId.fireball,
      SkillId.waterjet,
      SkillId.guardianOrbs,
      SkillId.menderOrb,
      SkillId.vigilLantern,
    ],
    baseStats: Map<StatId, double>.from(_basePlayerStats)
      ..addAll({StatId.maxHp: 105}),
    movement: _basePlayerMovement.copyWith(
      moveSpeed: 118,
      dashCooldown: 2.8,
      dashInvulnerability: 0.2,
    ),
    modifiers: [
      StatModifier(stat: StatId.cooldownRecovery, amount: 0.12),
      StatModifier(stat: StatId.dodgeChance, amount: -0.05),
    ],
  ),
  CharacterDef(
    id: CharacterId.warden,
    name: 'The Warden',
    themeLine: 'Sealkeeper of heavy wards and unbroken lines.',
    modifierLine: 'Bulwark Rule — +Defense / -Attack speed',
    spriteId: 'player_warden',
    startingSkills: [
      SkillId.swordCut,
      SkillId.swordThrust,
      SkillId.swordSwing,
      SkillId.swordDeflect,
      SkillId.roots,
    ],
    baseStats: Map<StatId, double>.from(_basePlayerStats)
      ..addAll({StatId.maxHp: 130}),
    movement: _basePlayerMovement.copyWith(
      moveSpeed: 110,
      dashSpeed: 700,
      dashDistance: 54,
      dashCooldown: 3.3,
      dashCharges: 1,
    ),
    modifiers: [
      StatModifier(stat: StatId.defense, amount: 0.12),
      StatModifier(stat: StatId.attackSpeed, amount: -0.06),
    ],
  ),
  CharacterDef(
    id: CharacterId.cook,
    name: 'The Cook',
    themeLine: 'Hot soups, sharp ladles, and practical banishment.',
    modifierLine: 'Boilhouse Vow — +Drops / +Pickup range / -Max HP',
    spriteId: 'player_cook',
    startingSkills: [
      SkillId.oilBombs,
      SkillId.poisonGas,
      SkillId.fireball,
      SkillId.mineLayer,
      SkillId.processionIdol,
    ],
    baseStats: Map<StatId, double>.from(_basePlayerStats)
      ..addAll({StatId.maxHp: 90}),
    movement: _basePlayerMovement.copyWith(
      moveSpeed: 130,
      dashDistance: 66,
      dashCooldown: 2.6,
    ),
    modifiers: [
      StatModifier(stat: StatId.dropsPercent, amount: 0.18),
      StatModifier(stat: StatId.pickupRadiusPercent, amount: 0.15),
      StatModifier(stat: StatId.maxHp, amount: -8, kind: ModifierKind.flat),
    ],
  ),
];

final Map<CharacterId, CharacterDef> characterDefsById = Map.unmodifiable({
  for (final def in characterDefs) def.id: def,
});

final List<SkillId> allCharacterStartingSkills = characterDefs
    .expand((def) => def.startingSkills)
    .toSet()
    .toList(growable: false);
