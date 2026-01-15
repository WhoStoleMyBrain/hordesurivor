import 'dart:math' as math;

import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hordesurivor/data/ids.dart';
import 'package:hordesurivor/data/stat_defs.dart';
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

    expect(playerState.maxHp, closeTo(80, 0.001));
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
}
