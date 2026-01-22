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
    required this.modifiers,
  });

  final CharacterId id;
  final String name;
  final String themeLine;
  final String modifierLine;
  final String spriteId;
  final List<SkillId> startingSkills;
  final Map<StatId, double> baseStats;
  final List<StatModifier> modifiers;
}

const Map<StatId, double> _basePlayerStats = {
  StatId.maxHp: 100,
  StatId.moveSpeed: 120,
  StatId.dashSpeed: 720,
  StatId.dashDistance: 60,
  StatId.dashCooldown: 3.0,
  StatId.dashCharges: 2,
  StatId.dashDuration: 0.18,
  StatId.dashStartOffset: 0,
  StatId.dashEndOffset: 0,
  StatId.dashInvulnerability: 0.18,
  StatId.dashTeleport: 0,
};

final List<CharacterDef> characterDefs = [
  CharacterDef(
    id: CharacterId.priest,
    name: 'The Priest',
    themeLine: 'Bell rites and steady chants keep the horde at bay.',
    modifierLine: 'Rite of Cadence — +Cooldown recovery / -Move speed',
    spriteId: 'player_priest',
    startingSkills: [SkillId.fireball, SkillId.guardianOrbs],
    baseStats: Map<StatId, double>.from(_basePlayerStats)
      ..addAll({
        StatId.maxHp: 105,
        StatId.moveSpeed: 118,
        StatId.dashCooldown: 2.8,
        StatId.dashInvulnerability: 0.2,
      }),
    modifiers: [
      StatModifier(stat: StatId.cooldownRecovery, amount: 0.12),
      StatModifier(stat: StatId.moveSpeedPercent, amount: -0.05),
    ],
  ),
  CharacterDef(
    id: CharacterId.warden,
    name: 'The Warden',
    themeLine: 'Sealkeeper of heavy wards and unbroken lines.',
    modifierLine: 'Bulwark Rule — +Defense / -Attack speed',
    spriteId: 'player_warden',
    startingSkills: [SkillId.swordCut, SkillId.roots],
    baseStats: Map<StatId, double>.from(_basePlayerStats)
      ..addAll({
        StatId.maxHp: 130,
        StatId.moveSpeed: 110,
        StatId.dashSpeed: 700,
        StatId.dashDistance: 54,
        StatId.dashCooldown: 3.3,
        StatId.dashCharges: 1,
      }),
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
    startingSkills: [SkillId.oilBombs, SkillId.flameWave],
    baseStats: Map<StatId, double>.from(_basePlayerStats)
      ..addAll({
        StatId.maxHp: 90,
        StatId.moveSpeed: 130,
        StatId.dashDistance: 66,
        StatId.dashCooldown: 2.6,
      }),
    modifiers: [
      StatModifier(stat: StatId.drops, amount: 0.18),
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
