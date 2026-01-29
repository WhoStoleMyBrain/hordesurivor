import 'package:flutter_test/flutter_test.dart';

import 'package:hordesurivor/data/ids.dart';
import 'package:hordesurivor/game/skill_progression_system.dart';
import 'package:hordesurivor/game/skill_swap_plan.dart';

void main() {
  group('Skill swap plan', () {
    test('does not swap when only reordering existing skills', () {
      final original = [SkillId.fireball, SkillId.waterjet];
      final current = [SkillId.waterjet, SkillId.fireball];
      final plan = buildSkillSwapPlan(
        originalEquipped: original,
        currentEquipped: current,
        offeredSkillIds: {SkillId.chairThrow, SkillId.windCutter},
      );
      expect(plan.hasSwap, isFalse);
      expect(plan.incomingSkillId, isNull);
      expect(plan.outgoingSkillId, isNull);
      expect(plan.equippedSkills, current);
    });

    test('captures a single incoming and outgoing skill', () {
      final original = [SkillId.fireball, SkillId.waterjet];
      final current = [SkillId.fireball, SkillId.chairThrow];
      final plan = buildSkillSwapPlan(
        originalEquipped: original,
        currentEquipped: current,
        offeredSkillIds: {SkillId.chairThrow, SkillId.windCutter},
      );
      expect(plan.hasSwap, isTrue);
      expect(plan.incomingSkillId, SkillId.chairThrow);
      expect(plan.outgoingSkillId, SkillId.waterjet);
    });
  });

  test('skill swap transfer grants 75% of outgoing XP to incoming skill', () {
    final progression = SkillProgressionSystem();
    progression.addDirectXp(SkillId.fireball, 1000);
    final outgoingTotal = progression.totalXpFor(SkillId.fireball);
    final transfer = progression.applySwapTransfer(
      fromSkillId: SkillId.fireball,
      toSkillId: SkillId.waterjet,
      fraction: 0.75,
    );
    expect(transfer, closeTo(outgoingTotal * 0.75, 0.01));
    expect(
      progression.totalXpFor(SkillId.waterjet),
      closeTo(outgoingTotal * 0.75, 0.01),
    );
    expect(progression.totalXpFor(SkillId.fireball), outgoingTotal);
  });
}
