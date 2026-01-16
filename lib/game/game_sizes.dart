class GameSizes {
  const GameSizes._();

  static const double playerRadius = 16;
  static const double enemyRadius = 14;
  static const double projectileRadiusScale = 1.0;
  static const double baseCameraZoom = 1.35;
  static const double minCameraZoom = 0.85;
  static const double maxCameraZoom = 2.2;

  static double projectileRadius(double baseRadius) {
    return baseRadius * projectileRadiusScale;
  }
}
