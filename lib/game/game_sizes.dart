import 'dart:ui';

import '../data/map_size.dart';

class GameSizes {
  const GameSizes._();

  static const double playerRadius = 16;
  static const double enemyRadius = 14;
  static const double projectileRadiusScale = 1.0;
  static const double baseCameraZoom = 1.35;
  static const double minCameraZoom = 0.85;
  static const double maxCameraZoom = 2.2;

  static const MapSize homeBaseMapSize = MapSize(width: 1600, height: 1100);
  static const MapSize cameraViewportSize = MapSize(width: 960, height: 540);
  static const Color homeBaseBackgroundColor = Color(0xFF0C141C);

  static double projectileRadius(double baseRadius) {
    return baseRadius * projectileRadiusScale;
  }
}
