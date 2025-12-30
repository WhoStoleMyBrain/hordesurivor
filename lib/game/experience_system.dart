class ExperienceSystem {
  ExperienceSystem({int startingLevel = 1, int baseXp = 20, int xpGrowth = 10})
    : _baseXp = baseXp,
      _xpGrowth = xpGrowth,
      level = startingLevel {
    xpToNext = _xpForLevel(level);
  }

  final int _baseXp;
  final int _xpGrowth;

  int level;
  int currentXp = 0;
  int xpToNext = 0;

  int addExperience(int amount) {
    if (amount <= 0) {
      return 0;
    }
    currentXp += amount;
    var levelsGained = 0;
    while (currentXp >= xpToNext) {
      currentXp -= xpToNext;
      level += 1;
      xpToNext = _xpForLevel(level);
      levelsGained += 1;
    }
    return levelsGained;
  }

  int _xpForLevel(int level) {
    return _baseXp + (level - 1) * _xpGrowth;
  }
}
