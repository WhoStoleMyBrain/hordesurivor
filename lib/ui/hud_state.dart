import 'package:flutter/foundation.dart';

class PlayerHudState extends ChangeNotifier {
  double hp = 0;
  double maxHp = 0;
  int level = 1;
  int xp = 0;
  int xpToNext = 0;
  bool showPerformance = false;
  double fps = 0;
  double frameTimeMs = 0;

  void update({
    required double hp,
    required double maxHp,
    required int level,
    required int xp,
    required int xpToNext,
    required bool showPerformance,
    required double fps,
    required double frameTimeMs,
  }) {
    if (this.hp == hp &&
        this.maxHp == maxHp &&
        this.level == level &&
        this.xp == xp &&
        this.xpToNext == xpToNext &&
        this.showPerformance == showPerformance &&
        this.fps == fps &&
        this.frameTimeMs == frameTimeMs) {
      return;
    }

    this.hp = hp;
    this.maxHp = maxHp;
    this.level = level;
    this.xp = xp;
    this.xpToNext = xpToNext;
    this.showPerformance = showPerformance;
    this.fps = fps;
    this.frameTimeMs = frameTimeMs;
    notifyListeners();
  }
}
