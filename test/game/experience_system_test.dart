import 'package:flutter_test/flutter_test.dart';

import 'package:hordesurivor/game/experience_system.dart';

void main() {
  test('accumulates experience without leveling when below threshold', () {
    final system = ExperienceSystem(baseXp: 20, xpGrowth: 10);

    final levelsGained = system.addExperience(15);

    expect(levelsGained, 0);
    expect(system.level, 1);
    expect(system.currentXp, 15);
    expect(system.xpToNext, 20);
  });

  test('levels up and rolls over excess experience', () {
    final system = ExperienceSystem(baseXp: 20, xpGrowth: 10);

    final levelsGained = system.addExperience(55);

    expect(levelsGained, 2);
    expect(system.level, 3);
    expect(system.currentXp, 5);
    expect(system.xpToNext, 40);
  });
}
