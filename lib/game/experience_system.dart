class ExperienceSystem {
  ExperienceSystem({int startingLevel = 1, int baseXp = 18, int xpGrowth = 8})
    : _startingLevel = startingLevel,
      _baseXp = baseXp,
      _xpGrowth = xpGrowth,
      level = startingLevel {
    xpToNext = _xpForLevel(level);
  }

  final int _startingLevel;
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

  void reset() {
    level = _startingLevel;
    currentXp = 0;
    xpToNext = _xpForLevel(level);
  }

  int _xpForLevel(int level) {
    return _baseXp + (level - 1) * _xpGrowth;
  }
}
