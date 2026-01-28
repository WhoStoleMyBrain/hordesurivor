class LevelCurve {
  const LevelCurve({required this.base, required this.growth});

  final int base;
  final int growth;

  int xpForLevel(int level) {
    return base + (level - 1) * growth;
  }
}
