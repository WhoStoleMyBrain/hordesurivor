import 'ids.dart';
import 'skill_display.dart';
import 'tags.dart';

class ActiveSkillEffectParams {
  const ActiveSkillEffectParams({
    required this.kind,
    required this.shape,
    required this.baseDamage,
    required this.duration,
    this.radius = 0,
    this.length = 0,
    this.width = 0,
    this.arcDegrees = 0,
    this.knockbackForce = 0,
    this.knockbackDuration = 0,
    this.slowMultiplier = 1,
    this.slowDuration = 0,
    this.followsPlayer = false,
  });

  final ActiveSkillEffectKind kind;
  final ActiveSkillEffectShape shape;
  final double baseDamage;
  final double duration;
  final double radius;
  final double length;
  final double width;
  final double arcDegrees;
  final double knockbackForce;
  final double knockbackDuration;
  final double slowMultiplier;
  final double slowDuration;
  final bool followsPlayer;
}

enum ActiveSkillEffectShape { beam, ground, arc }

enum ActiveSkillEffectKind { censureBeam, bastionRing, soupSplash }

class ActiveSkillDef {
  const ActiveSkillDef({
    required this.id,
    required this.name,
    required this.description,
    required this.tags,
    required this.rarity,
    required this.cooldown,
    required this.manaCost,
    required this.iconId,
    required this.effect,
    this.displayDetails = const [],
  });

  final ActiveSkillId id;
  final String name;
  final String description;
  final TagSet tags;
  final ItemRarity rarity;
  final double cooldown;
  final double manaCost;
  final String iconId;
  final ActiveSkillEffectParams effect;
  final List<SkillDetailLine> displayDetails;
}

const _litanyEffect = ActiveSkillEffectParams(
  kind: ActiveSkillEffectKind.censureBeam,
  shape: ActiveSkillEffectShape.beam,
  baseDamage: 40,
  duration: 0.7,
  length: 160,
  width: 34,
  knockbackForce: 110,
  knockbackDuration: 0.2,
);

const _bastionEffect = ActiveSkillEffectParams(
  kind: ActiveSkillEffectKind.bastionRing,
  shape: ActiveSkillEffectShape.ground,
  baseDamage: 18,
  duration: 1.2,
  radius: 90,
  slowMultiplier: 0.6,
  slowDuration: 1.2,
  followsPlayer: true,
);

const _soupEffect = ActiveSkillEffectParams(
  kind: ActiveSkillEffectKind.soupSplash,
  shape: ActiveSkillEffectShape.arc,
  baseDamage: 70,
  duration: 0.25,
  radius: 110,
  arcDegrees: 120,
  knockbackForce: 160,
  knockbackDuration: 0.25,
);

final List<SkillDetailLine> _litanyDetails = [
  SkillDetailLine('Mana Cost', '26'),
  cooldownLine(12),
  damagePerSecondLine(40),
  durationLine('Duration', 0.7),
  beamLengthLine(160),
  beamWidthLine(34),
  SkillDetailLine('Knockback', 'Moderate'),
];

final List<SkillDetailLine> _bastionDetails = [
  SkillDetailLine('Mana Cost', '30'),
  cooldownLine(14),
  damagePerSecondLine(18),
  durationLine('Duration', 1.2),
  groundRadiusLine(90),
  SkillDetailLine('Slow', '40%'),
];

final List<SkillDetailLine> _soupDetails = [
  SkillDetailLine('Mana Cost', '20'),
  cooldownLine(10),
  damagePerSecondLine(70),
  durationLine('Duration', 0.25),
  rangeLine(110),
  arcLine(120),
  SkillDetailLine('Knockback', 'High'),
];

final List<ActiveSkillDef> activeSkillDefs = [
  ActiveSkillDef(
    id: ActiveSkillId.litanyOfCensure,
    name: 'Litany of Censure',
    description: 'Chant a binding beam that scours a line of foes.',
    tags: const TagSet(
      elements: {ElementTag.fire},
      effects: {EffectTag.aoe},
      deliveries: {DeliveryTag.beam},
    ),
    rarity: ItemRarity.rare,
    cooldown: 12,
    manaCost: 26,
    iconId: 'skill_censer_ember',
    effect: _litanyEffect,
    displayDetails: _litanyDetails,
  ),
  ActiveSkillDef(
    id: ActiveSkillId.sealOfBastion,
    name: 'Seal of Bastion',
    description: 'Raise a warding ring that slows intruders.',
    tags: const TagSet(
      elements: {ElementTag.earth},
      effects: {EffectTag.aoe, EffectTag.debuff},
      deliveries: {DeliveryTag.ground},
    ),
    rarity: ItemRarity.epic,
    cooldown: 14,
    manaCost: 30,
    iconId: 'skill_riteblade_rebuke',
    effect: _bastionEffect,
    displayDetails: _bastionDetails,
  ),
  ActiveSkillDef(
    id: ActiveSkillId.hotSoupSplash,
    name: 'Hot Soup Splash',
    description: 'Ladle a scalding cone that knocks enemies back.',
    tags: const TagSet(
      elements: {ElementTag.water},
      effects: {EffectTag.aoe},
      deliveries: {DeliveryTag.melee},
    ),
    rarity: ItemRarity.rare,
    cooldown: 10,
    manaCost: 20,
    iconId: 'skill_chair_throw',
    effect: _soupEffect,
    displayDetails: _soupDetails,
  ),
];

final Map<ActiveSkillId, ActiveSkillDef> activeSkillDefsById = Map.unmodifiable(
  {for (final def in activeSkillDefs) def.id: def},
);

List<SkillDetailLine> activeSkillDetailLinesFor(ActiveSkillId id) {
  return activeSkillDefsById[id]?.displayDetails ?? const [];
}
