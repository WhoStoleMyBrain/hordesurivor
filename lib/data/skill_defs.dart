import 'dart:math' as math;

import 'ids.dart';
import 'skill_display.dart';
import 'tags.dart';

class SkillProjectileParams {
  const SkillProjectileParams({
    required this.baseDamage,
    required this.speed,
    required this.radius,
    required this.lifespan,
    this.spreadAngles = const [],
  });

  final double baseDamage;
  final double speed;
  final double radius;
  final double lifespan;
  final List<double> spreadAngles;
}

class SkillBeamParams {
  const SkillBeamParams({
    required this.baseDamage,
    required this.duration,
    required this.length,
    required this.width,
    this.slowMultiplier,
    this.slowDuration,
    this.followsPlayer = false,
  });

  final double baseDamage;
  final double duration;
  final double length;
  final double width;
  final double? slowMultiplier;
  final double? slowDuration;
  final bool followsPlayer;
}

class SkillMeleeParams {
  const SkillMeleeParams({
    required this.baseDamage,
    required this.range,
    required this.arcDegrees,
    required this.effectDuration,
  });

  final double baseDamage;
  final double range;
  final double arcDegrees;
  final double effectDuration;
}

class SkillGroundParams {
  const SkillGroundParams({
    required this.baseDamage,
    required this.duration,
    required this.radius,
    this.slowMultiplier,
    this.slowDuration,
    this.oilDuration,
    this.followsPlayer = false,
    this.castOffset,
  });

  final double baseDamage;
  final double duration;
  final double radius;
  final double? slowMultiplier;
  final double? slowDuration;
  final double? oilDuration;
  final bool followsPlayer;
  final double? castOffset;
}

class SkillSummonParams {
  const SkillSummonParams({
    required this.lifespan,
    required this.radius,
    required this.orbitRadius,
    required this.orbitSpeed,
    this.orbitSeedOffset = 0,
    this.moveSpeed,
    this.range,
    this.damagePerSecond,
    this.projectileDamage,
    this.projectileSpeed,
    this.projectileRadius,
    this.attackCooldown,
    this.count = 1,
    this.healingPerSecond,
  });

  final double lifespan;
  final double radius;
  final double orbitRadius;
  final double orbitSpeed;
  final double orbitSeedOffset;
  final double? moveSpeed;
  final double? range;
  final double? damagePerSecond;
  final double? projectileDamage;
  final double? projectileSpeed;
  final double? projectileRadius;
  final double? attackCooldown;
  final int count;
  final double? healingPerSecond;
}

class SkillMineParams {
  const SkillMineParams({
    required this.radius,
    required this.lifespan,
    required this.spawnOffset,
    required this.triggerRadius,
    required this.blastRadius,
    required this.baseDamage,
    required this.armDuration,
  });

  final double radius;
  final double lifespan;
  final double spawnOffset;
  final double triggerRadius;
  final double blastRadius;
  final double baseDamage;
  final double armDuration;
}

class SkillIgniteParams {
  const SkillIgniteParams({
    required this.duration,
    required this.baseDamagePerSecond,
  });

  final double duration;
  final double baseDamagePerSecond;
}

class SkillDeflectParams {
  const SkillDeflectParams({required this.radius, required this.duration});

  final double radius;
  final double duration;
}

class SkillRootParams {
  const SkillRootParams({
    required this.baseStrength,
    required this.minStrength,
    required this.maxStrength,
    required this.minDurationScale,
    required this.minSlowMultiplier,
    required this.maxSlowMultiplier,
  });

  final double baseStrength;
  final double minStrength;
  final double maxStrength;
  final double minDurationScale;
  final double minSlowMultiplier;
  final double maxSlowMultiplier;
}

class SkillDef {
  const SkillDef({
    required this.id,
    required this.name,
    required this.iconId,
    this.projectileSpriteId,
    required this.description,
    required this.tags,
    required this.cooldown,
    this.projectile,
    this.beam,
    this.melee,
    this.ground,
    this.summon,
    this.mine,
    this.ignite,
    this.deflect,
    this.root,
    this.metaUnlockId,
    this.statusEffects = const {},
    this.displayDetails = const [],
    this.knockbackForce = 0,
    this.knockbackDuration = 0,
    this.weight = 1,
  });

  final SkillId id;
  final String name;
  final String iconId;
  final String? projectileSpriteId;
  final String description;
  final TagSet tags;
  final double cooldown;
  final SkillProjectileParams? projectile;
  final SkillBeamParams? beam;
  final SkillMeleeParams? melee;
  final SkillGroundParams? ground;
  final SkillSummonParams? summon;
  final SkillMineParams? mine;
  final SkillIgniteParams? ignite;
  final SkillDeflectParams? deflect;
  final SkillRootParams? root;
  final MetaUnlockId? metaUnlockId;
  final Set<StatusEffectId> statusEffects;
  final List<SkillDetailLine> displayDetails;
  final double knockbackForce;
  final double knockbackDuration;
  final int weight;
}

const _fireballCooldown = 0.6;
const _fireballProjectile = SkillProjectileParams(
  baseDamage: 8,
  speed: 220,
  radius: 4,
  lifespan: 2.0,
);
const _fireballIgnite = SkillIgniteParams(
  duration: 1.4,
  baseDamagePerSecond: 3,
);

const _waterjetCooldown = 0.7;
const _waterjetBeam = SkillBeamParams(
  baseDamage: 6,
  duration: 0.35,
  length: 140,
  width: 10,
  slowMultiplier: 0.7,
  slowDuration: 0.315,
  followsPlayer: true,
);

const _oilBombsCooldown = 1.1;
const _oilBombsProjectile = SkillProjectileParams(
  baseDamage: 4,
  speed: 160,
  radius: 6,
  lifespan: 1.4,
);
const _oilBombsGround = SkillGroundParams(
  baseDamage: 4,
  duration: 2.0,
  radius: 46,
  slowMultiplier: 0.8,
  slowDuration: 0.6,
  oilDuration: 1.2,
);

const _swordThrustCooldown = 0.8;
const _swordThrustMelee = SkillMeleeParams(
  baseDamage: 10,
  range: 58,
  arcDegrees: 30,
  effectDuration: 0.12,
);

const _swordCutCooldown = 0.9;
const _swordCutMelee = SkillMeleeParams(
  baseDamage: 12,
  range: 46,
  arcDegrees: 90,
  effectDuration: 0.14,
);

const _swordSwingCooldown = 1.2;
const _swordSwingMelee = SkillMeleeParams(
  baseDamage: 14,
  range: 52,
  arcDegrees: 140,
  effectDuration: 0.18,
);

const _swordDeflectCooldown = 1.4;
const _swordDeflectMelee = SkillMeleeParams(
  baseDamage: 8,
  range: 42,
  arcDegrees: 100,
  effectDuration: 0.16,
);
const _swordDeflectDeflect = SkillDeflectParams(radius: 55, duration: 0.18);

const _poisonGasCooldown = 1.3;
const _poisonGasGround = SkillGroundParams(
  baseDamage: 4,
  duration: 0.8,
  radius: 70,
  followsPlayer: true,
);

const _rootsCooldown = 1.2;
const _rootsGround = SkillGroundParams(
  baseDamage: 7,
  duration: 1.8,
  radius: 54,
  slowMultiplier: 0.4,
  slowDuration: 1.8,
  castOffset: 60,
);
const _rootsParams = SkillRootParams(
  baseStrength: 0.6,
  minStrength: 0.2,
  maxStrength: 0.9,
  minDurationScale: 0.1,
  minSlowMultiplier: 0.05,
  maxSlowMultiplier: 1.0,
);

const _windCutterCooldown = 0.55;
const _windCutterProjectile = SkillProjectileParams(
  baseDamage: 7,
  speed: 280,
  radius: 3,
  lifespan: 1.4,
);

const _steelShardsCooldown = 0.9;
const _steelShardsProjectile = SkillProjectileParams(
  baseDamage: 6,
  speed: 200,
  radius: 3,
  lifespan: 1.2,
  spreadAngles: [-0.2, 0.0, 0.2],
);

const _flameWaveCooldown = 1.1;
const _flameWaveBeam = SkillBeamParams(
  baseDamage: 10,
  duration: 0.45,
  length: 120,
  width: 18,
);

const _frostNovaCooldown = 1.4;
const _frostNovaGround = SkillGroundParams(
  baseDamage: 5,
  duration: 0.6,
  radius: 80,
  slowMultiplier: 0.6,
  slowDuration: 0.6,
);

const _earthSpikesCooldown = 1.3;
const _earthSpikesGround = SkillGroundParams(
  baseDamage: 9,
  duration: 0.7,
  radius: 68,
  castOffset: 72,
);

const _sporeBurstCooldown = 1.0;
const _sporeBurstProjectile = SkillProjectileParams(
  baseDamage: 5,
  speed: 170,
  radius: 5,
  lifespan: 1.6,
);
const _sporeBurstGround = SkillGroundParams(
  baseDamage: 4,
  duration: 1.4,
  radius: 50,
  slowMultiplier: 0.85,
  slowDuration: 0.4,
);

const _processionIdolCooldown = 9.5;
const _processionIdolSummon = SkillSummonParams(
  lifespan: 6,
  radius: 10,
  orbitRadius: 36,
  orbitSpeed: 2.4,
  orbitSeedOffset: math.pi * 0.7,
  moveSpeed: 120,
  range: 160,
  damagePerSecond: 9,
);

const _vigilLanternCooldown = 1.6;
const _vigilLanternSummon = SkillSummonParams(
  lifespan: double.infinity,
  radius: 8,
  orbitRadius: 44,
  orbitSpeed: 1.6,
  orbitSeedOffset: math.pi * 0.5,
  range: 220,
  projectileDamage: 6,
  projectileSpeed: 260,
  projectileRadius: 3,
  attackCooldown: 0.75,
);

const _guardianOrbsCooldown = 1.4;
const _guardianOrbsSummon = SkillSummonParams(
  lifespan: double.infinity,
  radius: 18,
  orbitRadius: 34,
  orbitSpeed: 2.8,
  orbitSeedOffset: math.pi,
  damagePerSecond: 5,
  count: 2,
);

const _menderOrbCooldown = 9.5;
const _menderOrbSummon = SkillSummonParams(
  lifespan: 6,
  radius: 14,
  orbitRadius: 38,
  orbitSpeed: 2.2,
  orbitSeedOffset: math.pi * 0.35,
  healingPerSecond: 0.32,
);

const _mineLayerCooldown = 8.0;
const _mineLayerMine = SkillMineParams(
  radius: 6,
  lifespan: 5,
  spawnOffset: 28,
  triggerRadius: 22,
  blastRadius: 36,
  baseDamage: 12,
  armDuration: 0.25,
);

const _chairThrowCooldown = 0.95;
const _chairThrowProjectile = SkillProjectileParams(
  baseDamage: 9,
  speed: 200,
  radius: 7,
  lifespan: 1.6,
);

const _absolutionSlapCooldown = 0.8;
const _absolutionSlapMelee = SkillMeleeParams(
  baseDamage: 8,
  range: 40,
  arcDegrees: 70,
  effectDuration: 0.12,
);

final List<SkillDef> skillDefs = [
  SkillDef(
    id: SkillId.fireball,
    name: 'Censer Ember',
    iconId: 'skill_censer_ember',
    projectileSpriteId: 'projectile_censer_ember',
    description: 'Fling a burning coal from the censer.',
    tags: TagSet(
      elements: {ElementTag.fire},
      deliveries: {DeliveryTag.projectile},
    ),
    cooldown: _fireballCooldown,
    projectile: _fireballProjectile,
    ignite: _fireballIgnite,
    statusEffects: {StatusEffectId.ignite},
    displayDetails: [
      cooldownLine(_fireballCooldown),
      damageLine(_fireballProjectile.baseDamage),
      projectileSpeedLine(_fireballProjectile.speed),
      rangeLine(_fireballProjectile.speed * _fireballProjectile.lifespan),
      projectileRadiusLine(_fireballProjectile.radius),
      igniteLine(
        dps: _fireballIgnite.baseDamagePerSecond,
        duration: _fireballIgnite.duration,
      ),
      knockbackLine(force: 80, duration: 0.18),
    ],
    knockbackForce: 80,
    knockbackDuration: 0.18,
  ),
  SkillDef(
    id: SkillId.waterjet,
    name: 'Holy Water Jet',
    iconId: 'skill_holy_water_jet',
    description: 'Spray a focused line of holy water.',
    tags: TagSet(elements: {ElementTag.water}, deliveries: {DeliveryTag.beam}),
    cooldown: _waterjetCooldown,
    beam: _waterjetBeam,
    statusEffects: {StatusEffectId.slow},
    displayDetails: [
      cooldownLine(_waterjetCooldown),
      damageOverTimeLine(
        damage: _waterjetBeam.baseDamage,
        duration: _waterjetBeam.duration,
      ),
      beamLengthLine(_waterjetBeam.length),
      beamWidthLine(_waterjetBeam.width),
      slowLine(
        multiplier: _waterjetBeam.slowMultiplier ?? 1,
        duration: _waterjetBeam.slowDuration ?? 0,
      ),
    ],
  ),
  SkillDef(
    id: SkillId.oilBombs,
    name: 'Anointing Oil Flasks',
    iconId: 'skill_anointing_oil',
    projectileSpriteId: 'projectile_anointing_oil',
    description: 'Lob flasks that slick the ground for later “purification.”',
    tags: TagSet(
      effects: {EffectTag.debuff},
      deliveries: {DeliveryTag.projectile, DeliveryTag.ground},
    ),
    cooldown: _oilBombsCooldown,
    projectile: _oilBombsProjectile,
    ground: _oilBombsGround,
    statusEffects: {StatusEffectId.oilSoaked, StatusEffectId.slow},
    displayDetails: [
      cooldownLine(_oilBombsCooldown),
      damageLine(_oilBombsProjectile.baseDamage),
      projectileSpeedLine(_oilBombsProjectile.speed),
      rangeLine(_oilBombsProjectile.speed * _oilBombsProjectile.lifespan),
      projectileRadiusLine(_oilBombsProjectile.radius),
      groundRadiusLine(_oilBombsGround.radius),
      durationLine('Ground Duration', _oilBombsGround.duration),
      damagePerSecondLine(
        _oilBombsGround.baseDamage / _oilBombsGround.duration,
      ),
      slowLine(
        multiplier: _oilBombsGround.slowMultiplier ?? 1,
        duration: _oilBombsGround.slowDuration ?? 0,
      ),
      durationLine('Oil Duration', _oilBombsGround.oilDuration ?? 0),
      knockbackLine(force: 60, duration: 0.16),
    ],
    knockbackForce: 60,
    knockbackDuration: 0.16,
  ),
  SkillDef(
    id: SkillId.swordThrust,
    name: 'Riteblade: Thrust',
    iconId: 'skill_riteblade_thrust',
    description: 'A precise thrust to “encourage” departure.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.mobility},
      deliveries: {DeliveryTag.melee},
    ),
    cooldown: _swordThrustCooldown,
    melee: _swordThrustMelee,
    displayDetails: [
      cooldownLine(_swordThrustCooldown),
      damageLine(_swordThrustMelee.baseDamage),
      rangeLine(_swordThrustMelee.range),
      arcLine(_swordThrustMelee.arcDegrees),
      knockbackLine(force: 120, duration: 0.2),
    ],
    knockbackForce: 120,
    knockbackDuration: 0.2,
  ),
  SkillDef(
    id: SkillId.swordCut,
    name: 'Riteblade: Cut',
    iconId: 'skill_riteblade_cut',
    description: 'A short sweeping cut of righteous steel.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.aoe},
      deliveries: {DeliveryTag.melee},
    ),
    cooldown: _swordCutCooldown,
    melee: _swordCutMelee,
    displayDetails: [
      cooldownLine(_swordCutCooldown),
      damageLine(_swordCutMelee.baseDamage),
      rangeLine(_swordCutMelee.range),
      arcLine(_swordCutMelee.arcDegrees),
      knockbackLine(force: 100, duration: 0.18),
    ],
    knockbackForce: 100,
    knockbackDuration: 0.18,
  ),
  SkillDef(
    id: SkillId.swordSwing,
    name: 'Riteblade: Swing',
    iconId: 'skill_riteblade_swing',
    description: 'A wide swing with a heavier wind-up and heavier judgement.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.aoe},
      deliveries: {DeliveryTag.melee},
    ),
    cooldown: _swordSwingCooldown,
    melee: _swordSwingMelee,
    displayDetails: [
      cooldownLine(_swordSwingCooldown),
      damageLine(_swordSwingMelee.baseDamage),
      rangeLine(_swordSwingMelee.range),
      arcLine(_swordSwingMelee.arcDegrees),
      knockbackLine(force: 135, duration: 0.22),
    ],
    knockbackForce: 135,
    knockbackDuration: 0.22,
  ),
  SkillDef(
    id: SkillId.swordDeflect,
    name: 'Riteblade: Rebuke',
    iconId: 'skill_riteblade_rebuke',
    description: 'A quick rebuke that turns back hostile projectiles.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.support},
      deliveries: {DeliveryTag.melee},
    ),
    cooldown: _swordDeflectCooldown,
    melee: _swordDeflectMelee,
    deflect: _swordDeflectDeflect,
    displayDetails: [
      cooldownLine(_swordDeflectCooldown),
      damageLine(_swordDeflectMelee.baseDamage),
      rangeLine(_swordDeflectMelee.range),
      arcLine(_swordDeflectMelee.arcDegrees),
      deflectRadiusLine(_swordDeflectDeflect.radius),
      durationLine('Deflect Duration', _swordDeflectDeflect.duration),
      knockbackLine(force: 90, duration: 0.16),
    ],
    knockbackForce: 90,
    knockbackDuration: 0.16,
  ),
  SkillDef(
    id: SkillId.poisonGas,
    name: 'Thurible Fumes',
    iconId: 'skill_thurible_fumes',
    description:
        'A lingering cloud of “cleansing” incense that hurts to breathe.',
    tags: TagSet(
      elements: {ElementTag.poison},
      effects: {EffectTag.aoe, EffectTag.dot},
      deliveries: {DeliveryTag.aura},
    ),
    cooldown: _poisonGasCooldown,
    ground: _poisonGasGround,
    displayDetails: [
      cooldownLine(_poisonGasCooldown),
      groundRadiusLine(_poisonGasGround.radius),
      damageOverTimeLine(
        damage: _poisonGasGround.baseDamage,
        duration: _poisonGasGround.duration,
      ),
    ],
  ),
  SkillDef(
    id: SkillId.roots,
    name: 'Salt Circle',
    iconId: 'skill_salt_circle',
    description: 'A harsh ring that snares anything trying to cross it.',
    tags: TagSet(
      elements: {ElementTag.earth, ElementTag.wood},
      effects: {EffectTag.debuff},
      deliveries: {DeliveryTag.ground},
    ),
    cooldown: _rootsCooldown,
    ground: _rootsGround,
    root: _rootsParams,
    statusEffects: {StatusEffectId.root},
    displayDetails: [
      cooldownLine(_rootsCooldown),
      groundRadiusLine(_rootsGround.radius),
      damageOverTimeLine(
        damage: _rootsGround.baseDamage,
        duration: _rootsGround.duration,
      ),
      slowLine(
        multiplier: _rootsGround.slowMultiplier ?? 1,
        duration: _rootsGround.slowDuration ?? 0,
        label: 'Root Slow',
      ),
      rangeLine(_rootsGround.castOffset ?? 0, label: 'Cast Offset'),
    ],
  ),
  SkillDef(
    id: SkillId.windCutter,
    name: 'Psalm: Razor Hymn',
    iconId: 'skill_razor_hymn',
    projectileSpriteId: 'projectile_razor_hymn',
    description: 'Sing a sharp verse; the air does the rest.',
    tags: TagSet(
      elements: {ElementTag.wind},
      deliveries: {DeliveryTag.projectile},
    ),
    cooldown: _windCutterCooldown,
    projectile: _windCutterProjectile,
    metaUnlockId: MetaUnlockId.fieldManual,
    displayDetails: [
      cooldownLine(_windCutterCooldown),
      damageLine(_windCutterProjectile.baseDamage),
      projectileSpeedLine(_windCutterProjectile.speed),
      rangeLine(_windCutterProjectile.speed * _windCutterProjectile.lifespan),
      projectileRadiusLine(_windCutterProjectile.radius),
      knockbackLine(force: 70, duration: 0.16),
    ],
    knockbackForce: 70,
    knockbackDuration: 0.16,
  ),
  SkillDef(
    id: SkillId.steelShards,
    name: 'Rosary Shards',
    iconId: 'skill_rosary_shards',
    projectileSpriteId: 'projectile_rosary_shard',
    description: 'Fan out blessed fragments in a tight burst.',
    tags: TagSet(
      elements: {ElementTag.steel},
      deliveries: {DeliveryTag.projectile},
    ),
    cooldown: _steelShardsCooldown,
    projectile: _steelShardsProjectile,
    metaUnlockId: MetaUnlockId.steelShardsLicense,
    displayDetails: [
      cooldownLine(_steelShardsCooldown),
      damageLine(_steelShardsProjectile.baseDamage, label: 'Shard Damage'),
      SkillDetailLine(
        'Projectiles',
        '${_steelShardsProjectile.spreadAngles.length}',
      ),
      SkillDetailLine('Spread', '±0.2 rad'),
      projectileSpeedLine(_steelShardsProjectile.speed),
      rangeLine(_steelShardsProjectile.speed * _steelShardsProjectile.lifespan),
      projectileRadiusLine(_steelShardsProjectile.radius),
      knockbackLine(force: 85, duration: 0.18),
    ],
    knockbackForce: 85,
    knockbackDuration: 0.18,
  ),
  SkillDef(
    id: SkillId.flameWave,
    name: 'Litany: Flame Sweep',
    iconId: 'skill_flame_sweep',
    description: 'A short sweeping wave of consecrated fire.',
    tags: TagSet(
      elements: {ElementTag.fire},
      effects: {EffectTag.aoe},
      deliveries: {DeliveryTag.beam},
    ),
    cooldown: _flameWaveCooldown,
    beam: _flameWaveBeam,
    metaUnlockId: MetaUnlockId.flameWaveTechnique,
    displayDetails: [
      cooldownLine(_flameWaveCooldown),
      damageOverTimeLine(
        damage: _flameWaveBeam.baseDamage,
        duration: _flameWaveBeam.duration,
      ),
      beamLengthLine(_flameWaveBeam.length),
      beamWidthLine(_flameWaveBeam.width),
    ],
  ),
  SkillDef(
    id: SkillId.frostNova,
    name: 'Rite of Chill',
    iconId: 'skill_rite_of_chill',
    description: 'A cold blessing that slows everything nearby.',
    tags: TagSet(
      elements: {ElementTag.water},
      effects: {EffectTag.aoe, EffectTag.debuff},
      deliveries: {DeliveryTag.aura},
    ),
    cooldown: _frostNovaCooldown,
    ground: _frostNovaGround,
    metaUnlockId: MetaUnlockId.frostNovaDiagram,
    statusEffects: {StatusEffectId.slow},
    displayDetails: [
      cooldownLine(_frostNovaCooldown),
      damageOverTimeLine(
        damage: _frostNovaGround.baseDamage,
        duration: _frostNovaGround.duration,
      ),
      groundRadiusLine(_frostNovaGround.radius),
      slowLine(
        multiplier: _frostNovaGround.slowMultiplier ?? 1,
        duration: _frostNovaGround.slowDuration ?? 0,
      ),
    ],
  ),
  SkillDef(
    id: SkillId.earthSpikes,
    name: 'Grave-Script Spikes',
    iconId: 'skill_gravescript_spikes',
    description: 'Inscribed ground erupts into punitive spikes.',
    tags: TagSet(
      elements: {ElementTag.earth},
      effects: {EffectTag.aoe, EffectTag.dot},
      deliveries: {DeliveryTag.ground},
    ),
    cooldown: _earthSpikesCooldown,
    ground: _earthSpikesGround,
    metaUnlockId: MetaUnlockId.earthSpikesSurvey,
    displayDetails: [
      cooldownLine(_earthSpikesCooldown),
      damageOverTimeLine(
        damage: _earthSpikesGround.baseDamage,
        duration: _earthSpikesGround.duration,
      ),
      groundRadiusLine(_earthSpikesGround.radius),
      durationLine('Spike Duration', _earthSpikesGround.duration),
      rangeLine(_earthSpikesGround.castOffset ?? 0, label: 'Cast Offset'),
    ],
  ),
  SkillDef(
    id: SkillId.sporeBurst,
    name: 'Censer Spores',
    iconId: 'skill_censer_spores',
    projectileSpriteId: 'projectile_censer_spore',
    description: 'A toxic “blessing” that lingers as a choking cloud.',
    tags: TagSet(
      elements: {ElementTag.poison},
      effects: {EffectTag.aoe, EffectTag.dot},
      deliveries: {DeliveryTag.projectile, DeliveryTag.ground},
    ),
    cooldown: _sporeBurstCooldown,
    projectile: _sporeBurstProjectile,
    ground: _sporeBurstGround,
    metaUnlockId: MetaUnlockId.sporeBurstCulture,
    displayDetails: [
      cooldownLine(_sporeBurstCooldown),
      damageLine(_sporeBurstProjectile.baseDamage),
      projectileSpeedLine(_sporeBurstProjectile.speed),
      rangeLine(_sporeBurstProjectile.speed * _sporeBurstProjectile.lifespan),
      projectileRadiusLine(_sporeBurstProjectile.radius),
      groundRadiusLine(_sporeBurstGround.radius, label: 'Cloud Radius'),
      damageOverTimeLine(
        damage: _sporeBurstGround.baseDamage,
        duration: _sporeBurstGround.duration,
        label: 'Cloud Damage',
      ),
      slowLine(
        multiplier: _sporeBurstGround.slowMultiplier ?? 1,
        duration: _sporeBurstGround.slowDuration ?? 0,
      ),
    ],
  ),
  SkillDef(
    id: SkillId.processionIdol,
    name: 'Relic: Procession Idol',
    iconId: 'skill_procession_idol',
    description: 'A small idol patrols and nudges trespassers back.',
    tags: TagSet(elements: {ElementTag.steel}, deliveries: {DeliveryTag.melee}),
    cooldown: _processionIdolCooldown,
    summon: _processionIdolSummon,
    displayDetails: [
      cooldownLine(_processionIdolCooldown),
      durationLine('Summon Duration', _processionIdolSummon.lifespan),
      damagePerSecondLine(_processionIdolSummon.damagePerSecond ?? 0),
      rangeLine(_processionIdolSummon.range ?? 0),
      orbitRadiusLine(_processionIdolSummon.orbitRadius),
      orbitSpeedLine(_processionIdolSummon.orbitSpeed),
      moveSpeedLine(_processionIdolSummon.moveSpeed ?? 0),
    ],
  ),
  SkillDef(
    id: SkillId.vigilLantern,
    name: 'Relic: Vigil Lantern',
    iconId: 'skill_vigil_lantern',
    projectileSpriteId: 'projectile_vigil_shot',
    description: 'A hovering lantern fires warding shots on its own.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.support},
      deliveries: {DeliveryTag.projectile},
    ),
    cooldown: _vigilLanternCooldown,
    summon: _vigilLanternSummon,
    displayDetails: [
      const SkillDetailLine('Summon', 'Persistent'),
      damageLine(
        _vigilLanternSummon.projectileDamage ?? 0,
        label: 'Projectile Damage',
      ),
      durationLine('Attack Cooldown', _vigilLanternSummon.attackCooldown ?? 0),
      projectileSpeedLine(_vigilLanternSummon.projectileSpeed ?? 0),
      rangeLine(_vigilLanternSummon.range ?? 0),
      projectileRadiusLine(_vigilLanternSummon.projectileRadius ?? 0),
      orbitRadiusLine(_vigilLanternSummon.orbitRadius),
      orbitSpeedLine(_vigilLanternSummon.orbitSpeed),
    ],
  ),
  SkillDef(
    id: SkillId.guardianOrbs,
    name: 'Warding Rosary',
    iconId: 'skill_warding_rosary',
    description: 'Orbiting beads keep close company and closer damage.',
    tags: TagSet(
      elements: {ElementTag.steel},
      effects: {EffectTag.support},
      deliveries: {DeliveryTag.aura},
    ),
    cooldown: _guardianOrbsCooldown,
    summon: _guardianOrbsSummon,
    displayDetails: [
      SkillDetailLine(
        'Summon',
        '${_guardianOrbsSummon.count} orbs (persistent)',
      ),
      damagePerSecondLine(_guardianOrbsSummon.damagePerSecond ?? 0),
      orbitRadiusLine(_guardianOrbsSummon.orbitRadius),
      orbitSpeedLine(_guardianOrbsSummon.orbitSpeed),
    ],
  ),
  SkillDef(
    id: SkillId.menderOrb,
    name: 'Absolving Wisp',
    iconId: 'skill_absolving_wisp',
    description: 'A patient little wisp that restores health over time.',
    tags: TagSet(
      elements: {ElementTag.wood},
      effects: {EffectTag.support},
      deliveries: {DeliveryTag.aura},
    ),
    cooldown: _menderOrbCooldown,
    summon: _menderOrbSummon,
    displayDetails: [
      cooldownLine(_menderOrbCooldown),
      durationLine('Summon Duration', _menderOrbSummon.lifespan),
      healingPerSecondLine(_menderOrbSummon.healingPerSecond ?? 0),
      orbitRadiusLine(_menderOrbSummon.orbitRadius),
      orbitSpeedLine(_menderOrbSummon.orbitSpeed),
    ],
  ),
  SkillDef(
    id: SkillId.mineLayer,
    name: 'Consecrated Wards',
    iconId: 'skill_consecrated_wards',
    description: 'Place wards that detonate when something unholy approaches.',
    tags: TagSet(
      elements: {ElementTag.fire},
      effects: {EffectTag.aoe},
      deliveries: {DeliveryTag.ground},
    ),
    cooldown: _mineLayerCooldown,
    mine: _mineLayerMine,
    displayDetails: [
      cooldownLine(_mineLayerCooldown),
      damageLine(_mineLayerMine.baseDamage, label: 'Blast Damage'),
      durationLine('Mine Duration', _mineLayerMine.lifespan),
      durationLine('Arm Time', _mineLayerMine.armDuration),
      rangeLine(_mineLayerMine.triggerRadius, label: 'Trigger Radius'),
      rangeLine(_mineLayerMine.blastRadius, label: 'Blast Radius'),
    ],
  ),
  SkillDef(
    id: SkillId.chairThrow,
    name: 'Chair Throw',
    iconId: 'skill_chair_throw',
    projectileSpriteId: 'projectile_chair_throw',
    description: 'Hurl a folding chair stamped with a binding seal.',
    tags: TagSet(
      elements: {ElementTag.wood},
      effects: {EffectTag.aoe},
      deliveries: {DeliveryTag.projectile},
    ),
    cooldown: _chairThrowCooldown,
    projectile: _chairThrowProjectile,
    displayDetails: [
      cooldownLine(_chairThrowCooldown),
      damageLine(_chairThrowProjectile.baseDamage),
      projectileSpeedLine(_chairThrowProjectile.speed),
      rangeLine(_chairThrowProjectile.speed * _chairThrowProjectile.lifespan),
      projectileRadiusLine(_chairThrowProjectile.radius),
      knockbackLine(force: 110, duration: 0.2),
    ],
    knockbackForce: 110,
    knockbackDuration: 0.2,
  ),
  SkillDef(
    id: SkillId.absolutionSlap,
    name: 'Slap of Absolution',
    iconId: 'skill_absolution_slap',
    description: 'A brisk palm strike that clears a tight arc.',
    tags: TagSet(
      elements: {ElementTag.wind},
      effects: {EffectTag.aoe},
      deliveries: {DeliveryTag.melee},
    ),
    cooldown: _absolutionSlapCooldown,
    melee: _absolutionSlapMelee,
    displayDetails: [
      cooldownLine(_absolutionSlapCooldown),
      damageLine(_absolutionSlapMelee.baseDamage),
      rangeLine(_absolutionSlapMelee.range),
      arcLine(_absolutionSlapMelee.arcDegrees),
      knockbackLine(force: 95, duration: 0.16),
    ],
    knockbackForce: 95,
    knockbackDuration: 0.16,
  ),
];

final Map<SkillId, SkillDef> skillDefsById = Map.unmodifiable({
  for (final def in skillDefs) def.id: def,
});
