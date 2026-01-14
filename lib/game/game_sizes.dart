class GameSizes {
  const GameSizes._();

  static const double playerRadius = 16;
  static const double enemyRadius = 14;
  static const double projectileRadiusScale = 1.0;

  static double projectileRadius(double baseRadius) {
    return baseRadius * projectileRadiusScale;
  }
}
