import 'package:flutter/foundation.dart';

class PlayerHudState extends ChangeNotifier {
  double hp = 0;
  double maxHp = 0;
  int level = 1;
  int xp = 0;
  int xpToNext = 0;

  void update({
    required double hp,
    required double maxHp,
    required int level,
    required int xp,
    required int xpToNext,
  }) {
    if (this.hp == hp &&
        this.maxHp == maxHp &&
        this.level == level &&
        this.xp == xp &&
        this.xpToNext == xpToNext) {
      return;
    }

    this.hp = hp;
    this.maxHp = maxHp;
    this.level = level;
    this.xp = xp;
    this.xpToNext = xpToNext;
    notifyListeners();
  }
}
