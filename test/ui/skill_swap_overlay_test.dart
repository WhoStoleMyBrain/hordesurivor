import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hordesurivor/data/ids.dart';
import 'package:hordesurivor/game/skill_progression_system.dart';
import 'package:hordesurivor/ui/skill_swap_overlay.dart';
import 'package:hordesurivor/ui/skill_swap_state.dart';

void main() {
  testWidgets('skill swap overlay exposes draggable slots', (tester) async {
    final state = SkillSwapState();
    const snapshot = SkillProgressSnapshot(
      level: 1,
      currentXp: 0,
      xpToNext: 10,
    );
    state.show(
      offeredSkills: const [SkillId.waterjet],
      equippedSkills: const [SkillId.fireball],
      skillLevels: const {
        SkillId.waterjet: snapshot,
        SkillId.fireball: snapshot,
      },
      statValues: const {},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SkillSwapOverlay(
            state: state,
            skillIcons: const {},
            onConfirm: () {},
            onSkip: () {},
            cardBackground: null,
          ),
        ),
      ),
    );

    expect(find.text('Holy Water Jet'), findsOneWidget);
    expect(find.text('Censer Ember'), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) => widget is Draggable),
      findsNWidgets(2),
    );
    expect(
      find.byWidgetPredicate((widget) => widget is LongPressDraggable),
      findsNothing,
    );
  });
}
