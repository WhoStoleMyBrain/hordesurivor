import 'dart:math' as math;

import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hordesurivor/data/ids.dart';
import 'package:hordesurivor/data/stat_defs.dart';
import 'package:hordesurivor/data/weapon_upgrade_defs.dart';
import 'package:hordesurivor/game/effect_pool.dart';
import 'package:hordesurivor/game/level_up_system.dart';
import 'package:hordesurivor/game/player_state.dart';
import 'package:hordesurivor/game/projectile_pool.dart';
import 'package:hordesurivor/game/skill_system.dart';
import 'package:hordesurivor/game/summon_pool.dart';

void main() {
  test('LevelUpSystem builds choice list based on choice count', () {
    final system = LevelUpSystem(random: math.Random(1));
    final playerState = PlayerState(
      position: Vector2.zero(),
      maxHp: 100,
      moveSpeed: 10,
    );
    playerState.applyModifiers(const [
      StatModifier(
        stat: StatId.choiceCount,
        amount: 1,
        kind: ModifierKind.flat,
      ),
    ]);
    final skillSystem = SkillSystem(
      projectilePool: ProjectilePool(),
      effectPool: EffectPool(),
      summonPool: SummonPool(),
    );

    system.queueLevels(ProgressionTrackId.skills, 1);
    system.buildChoices(
      trackId: ProgressionTrackId.skills,
      selectionPoolId: SelectionPoolId.skillPool,
      playerState: playerState,
      skillSystem: skillSystem,
      trackLevel: 1,
    );

    expect(system.choices.length, 4);
  });

  test('LevelUpSystem applies item modifiers to the player', () {
    final system = LevelUpSystem(random: math.Random(2));
    final playerState = PlayerState(
      position: Vector2.zero(),
      maxHp: 100,
      moveSpeed: 10,
    );
    final skillSystem = SkillSystem(
      projectilePool: ProjectilePool(),
      effectPool: EffectPool(),
      summonPool: SummonPool(),
    );
    const choice = SelectionChoice(
      type: SelectionType.item,
      title: 'Glass Catalyst',
      description: 'High output at the cost of survivability.',
      itemId: ItemId.glassCatalyst,
    );

    system.queueLevels(ProgressionTrackId.items, 1);
    system.applyChoice(
      trackId: ProgressionTrackId.items,
      choice: choice,
      playerState: playerState,
      skillSystem: skillSystem,
    );

    expect(playerState.maxHp, closeTo(100, 0.001));
    expect(playerState.stats.value(StatId.damagePercent), closeTo(0.2, 0.001));
    expect(playerState.stats.value(StatId.flatDamage), closeTo(1.0, 0.001));
    expect(playerState.stats.value(StatId.defense), closeTo(-0.09, 0.001));
  });

  test('LevelUpSystem hides locked skills and items until unlocked', () {
    final system = LevelUpSystem(random: math.Random(3), baseChoiceCount: 999);
    final playerState = PlayerState(
      position: Vector2.zero(),
      maxHp: 100,
      moveSpeed: 10,
    );
    final skillSystem = SkillSystem(
      projectilePool: ProjectilePool(),
      effectPool: EffectPool(),
      summonPool: SummonPool(),
    );

    system.queueLevels(ProgressionTrackId.skills, 1);
    system.buildChoices(
      trackId: ProgressionTrackId.skills,
      selectionPoolId: SelectionPoolId.skillPool,
      playerState: playerState,
      skillSystem: skillSystem,
      unlockedMeta: const {},
      trackLevel: 1,
    );

    expect(
      system.choices.any((choice) => choice.skillId == SkillId.windCutter),
      isFalse,
    );
    expect(
      system.choices.any((choice) => choice.itemId == ItemId.thermalCoil),
      isFalse,
    );

    system.skipChoice(
      trackId: ProgressionTrackId.skills,
      playerState: playerState,
    );
    system.queueLevels(ProgressionTrackId.items, 1);
    system.buildChoices(
      trackId: ProgressionTrackId.items,
      selectionPoolId: SelectionPoolId.itemPool,
      playerState: playerState,
      skillSystem: skillSystem,
      unlockedMeta: const {},
      trackLevel: 1,
    );

    expect(
      system.choices.any((choice) => choice.itemId == ItemId.thermalCoil),
      isFalse,
    );

    system.skipChoice(
      trackId: ProgressionTrackId.items,
      playerState: playerState,
    );
    system.queueLevels(ProgressionTrackId.skills, 1);
    system.buildChoices(
      trackId: ProgressionTrackId.skills,
      selectionPoolId: SelectionPoolId.skillPool,
      playerState: playerState,
      skillSystem: skillSystem,
      unlockedMeta: const {MetaUnlockId.fieldManual},
      trackLevel: 1,
    );

    expect(
      system.choices.any((choice) => choice.skillId == SkillId.windCutter),
      isTrue,
    );

    system.skipChoice(
      trackId: ProgressionTrackId.skills,
      playerState: playerState,
    );
    system.queueLevels(ProgressionTrackId.items, 1);
    system.buildChoices(
      trackId: ProgressionTrackId.items,
      selectionPoolId: SelectionPoolId.itemPool,
      playerState: playerState,
      skillSystem: skillSystem,
      unlockedMeta: const {MetaUnlockId.thermalCoilBlueprint},
      trackLevel: 1,
    );

    expect(
      system.choices.any((choice) => choice.itemId == ItemId.thermalCoil),
      isTrue,
    );
  });

  test('LevelUpSystem surfaces autonomous skills as choices', () {
    final system = LevelUpSystem(random: math.Random(4), baseChoiceCount: 999);
    final playerState = PlayerState(
      position: Vector2.zero(),
      maxHp: 100,
      moveSpeed: 10,
    );
    final skillSystem = SkillSystem(
      projectilePool: ProjectilePool(),
      effectPool: EffectPool(),
      summonPool: SummonPool(),
    );

    system.queueLevels(ProgressionTrackId.skills, 1);
    system.buildChoices(
      trackId: ProgressionTrackId.skills,
      selectionPoolId: SelectionPoolId.skillPool,
      playerState: playerState,
      skillSystem: skillSystem,
      trackLevel: 1,
    );

    expect(
      system.choices.any((choice) => choice.skillId == SkillId.scrapRover),
      isTrue,
    );
    expect(
      system.choices.any((choice) => choice.skillId == SkillId.arcTurret),
      isTrue,
    );
    expect(
      system.choices.any((choice) => choice.skillId == SkillId.guardianOrbs),
      isTrue,
    );
    expect(
      system.choices.any((choice) => choice.skillId == SkillId.menderOrb),
      isTrue,
    );
    expect(
      system.choices.any((choice) => choice.skillId == SkillId.mineLayer),
      isTrue,
    );
  });

  test('LevelUpSystem skips new skills when slots are full', () {
    final system = LevelUpSystem(random: math.Random(5), baseChoiceCount: 999);
    final playerState = PlayerState(
      position: Vector2.zero(),
      maxHp: 100,
      moveSpeed: 10,
    );
    final skillSystem = SkillSystem(
      projectilePool: ProjectilePool(),
      effectPool: EffectPool(),
      summonPool: SummonPool(),
      skillSlots: [],
    );
    skillSystem
      ..addSkill(SkillId.fireball)
      ..addSkill(SkillId.swordCut)
      ..addSkill(SkillId.waterjet)
      ..addSkill(SkillId.oilBombs);

    system.queueLevels(ProgressionTrackId.skills, 1);
    system.buildChoices(
      trackId: ProgressionTrackId.skills,
      selectionPoolId: SelectionPoolId.skillPool,
      playerState: playerState,
      skillSystem: skillSystem,
      trackLevel: 1,
    );

    expect(
      system.choices.any((choice) => choice.type == SelectionType.skill),
      isFalse,
    );
    expect(
      system.choices.any(
        (choice) =>
            choice.type == SelectionType.skillUpgrade ||
            choice.type == SelectionType.weaponUpgrade,
      ),
      isTrue,
    );
  });

  test('LevelUpSystem gates weapon upgrades by ownership and tier', () {
    final system = LevelUpSystem(random: math.Random(5), baseChoiceCount: 999);
    final playerState = PlayerState(
      position: Vector2.zero(),
      maxHp: 100,
      moveSpeed: 10,
    );
    final skillSystem = SkillSystem(
      projectilePool: ProjectilePool(),
      effectPool: EffectPool(),
      summonPool: SummonPool(),
      skillSlots: [],
    );

    system.queueLevels(ProgressionTrackId.skills, 1);
    system.buildChoices(
      trackId: ProgressionTrackId.skills,
      selectionPoolId: SelectionPoolId.skillPool,
      playerState: playerState,
      skillSystem: skillSystem,
      trackLevel: 1,
    );

    expect(
      system.choices.any(
        (choice) => choice.type == SelectionType.weaponUpgrade,
      ),
      isFalse,
    );

    system.skipChoice(
      trackId: ProgressionTrackId.skills,
      playerState: playerState,
    );
    skillSystem.addSkill(SkillId.fireball);
    system.queueLevels(ProgressionTrackId.skills, 1);
    system.buildChoices(
      trackId: ProgressionTrackId.skills,
      selectionPoolId: SelectionPoolId.skillPool,
      playerState: playerState,
      skillSystem: skillSystem,
      trackLevel: 1,
    );

    final tier2 = weaponUpgradeDefsBySkillAndTier[SkillId.fireball]?[2];
    final tier3 = weaponUpgradeDefsBySkillAndTier[SkillId.fireball]?[3];
    expect(
      system.choices.any((choice) => choice.weaponUpgradeId == tier2?.id),
      isTrue,
    );
    expect(
      system.choices.any((choice) => choice.weaponUpgradeId == tier3?.id),
      isFalse,
    );

    system.applyChoice(
      trackId: ProgressionTrackId.skills,
      choice: SelectionChoice(
        type: SelectionType.weaponUpgrade,
        title: tier2?.name ?? 'Tier 2',
        description: tier2?.summary ?? 'Tier 2 upgrade',
        weaponUpgradeId: tier2?.id,
      ),
      playerState: playerState,
      skillSystem: skillSystem,
    );
    system.queueLevels(ProgressionTrackId.skills, 1);
    system.buildChoices(
      trackId: ProgressionTrackId.skills,
      selectionPoolId: SelectionPoolId.skillPool,
      playerState: playerState,
      skillSystem: skillSystem,
      trackLevel: 1,
    );

    expect(
      system.choices.any((choice) => choice.weaponUpgradeId == tier2?.id),
      isFalse,
    );
    expect(
      system.choices.any((choice) => choice.weaponUpgradeId == tier3?.id),
      isTrue,
    );
  });

  test('LevelUpSystem banishes choices from future selections', () {
    final system = LevelUpSystem(random: math.Random(6), baseChoiceCount: 999);
    final playerState = PlayerState(
      position: Vector2.zero(),
      maxHp: 100,
      moveSpeed: 10,
    );
    playerState.applyModifiers(const [
      StatModifier(stat: StatId.banishes, amount: 1, kind: ModifierKind.flat),
    ]);
    system.resetForRun(playerState: playerState);
    final skillSystem = SkillSystem(
      projectilePool: ProjectilePool(),
      effectPool: EffectPool(),
      summonPool: SummonPool(),
    );

    system.queueLevels(ProgressionTrackId.skills, 1);
    system.buildChoices(
      trackId: ProgressionTrackId.skills,
      selectionPoolId: SelectionPoolId.skillPool,
      playerState: playerState,
      skillSystem: skillSystem,
      trackLevel: 1,
    );

    final choice = system.choices.firstWhere(
      (choice) => choice.type == SelectionType.skill && choice.skillId != null,
    );
    final banishedId = choice.skillId;

    final banished = system.banishChoice(
      trackId: ProgressionTrackId.skills,
      selectionPoolId: SelectionPoolId.skillPool,
      choice: choice,
      playerState: playerState,
      skillSystem: skillSystem,
      trackLevel: 1,
    );

    expect(banished, isTrue);
    expect(system.banishesRemaining, 0);
    expect(
      system.choices.any((choice) => choice.skillId == banishedId),
      isFalse,
    );

    system.skipChoice(
      trackId: ProgressionTrackId.skills,
      playerState: playerState,
    );
    system.queueLevels(ProgressionTrackId.skills, 1);
    system.buildChoices(
      trackId: ProgressionTrackId.skills,
      selectionPoolId: SelectionPoolId.skillPool,
      playerState: playerState,
      skillSystem: skillSystem,
      trackLevel: 1,
    );

    expect(
      system.choices.any((choice) => choice.skillId == banishedId),
      isFalse,
    );
  });

  test('LevelUpSystem caps item offerings by max stacks', () {
    final system = LevelUpSystem(random: math.Random(7), baseChoiceCount: 999);
    final playerState = PlayerState(
      position: Vector2.zero(),
      maxHp: 100,
      moveSpeed: 10,
    );
    final skillSystem = SkillSystem(
      projectilePool: ProjectilePool(),
      effectPool: EffectPool(),
      summonPool: SummonPool(),
    );

    for (var i = 0; i < 4; i += 1) {
      system.applyChoice(
        trackId: ProgressionTrackId.items,
        choice: const SelectionChoice(
          type: SelectionType.item,
          title: 'Glass Catalyst',
          description: 'High output at the cost of survivability.',
          itemId: ItemId.glassCatalyst,
        ),
        playerState: playerState,
        skillSystem: skillSystem,
      );
    }
    expect(system.appliedItemCounts[ItemId.glassCatalyst], 1);

    system.queueLevels(ProgressionTrackId.items, 1);
    system.buildChoices(
      trackId: ProgressionTrackId.items,
      selectionPoolId: SelectionPoolId.itemPool,
      playerState: playerState,
      skillSystem: skillSystem,
      trackLevel: 6,
    );

    expect(
      system.choices.any((choice) => choice.itemId == ItemId.glassCatalyst),
      isFalse,
    );

    system.skipChoice(
      trackId: ProgressionTrackId.items,
      playerState: playerState,
    );

    system.applyChoice(
      trackId: ProgressionTrackId.items,
      choice: const SelectionChoice(
        type: SelectionType.item,
        title: 'Volatile Mixture',
        description: 'Explosions hit harder but hurt you too.',
        itemId: ItemId.volatileMixture,
      ),
      playerState: playerState,
      skillSystem: skillSystem,
    );

    system.queueLevels(ProgressionTrackId.items, 1);
    system.buildChoices(
      trackId: ProgressionTrackId.items,
      selectionPoolId: SelectionPoolId.itemPool,
      playerState: playerState,
      skillSystem: skillSystem,
      trackLevel: 12,
    );

    expect(
      system.choices.any((choice) => choice.itemId == ItemId.volatileMixture),
      isFalse,
    );
  });
}
