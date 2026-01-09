import 'dart:math' as math;

class RunSummary {
  RunSummary({
    this.timeAlive = 0,
    this.enemiesDefeated = 0,
    this.xpGained = 0,
    this.damageTaken = 0,
    this.metaCurrencyEarned = 0,
    this.metaRewardMultiplier = 1.0,
    this.contractHeat = 0,
    this.contractNames = const [],
    this.areaName,
    this.completed = false,
  });

  double timeAlive;
  int enemiesDefeated;
  int xpGained;
  double damageTaken;
  int metaCurrencyEarned;
  double metaRewardMultiplier;
  int contractHeat;
  List<String> contractNames;
  String? areaName;
  bool completed;

  int get score {
    final completionBonus = completed ? 100 : 0;
    final raw =
        timeAlive.round() +
        enemiesDefeated +
        xpGained +
        completionBonus -
        damageTaken.round();
    return raw < 0 ? 0 : raw;
  }

  int computeMetaCurrencyEarned() {
    final timeBonus = (timeAlive / 30).floor();
    final xpBonus = (xpGained / 20).floor();
    final completionBonus = completed ? 6 : 0;
    final total = 2 + timeBonus + xpBonus + completionBonus;
    return math.max(0, (total * metaRewardMultiplier).round());
  }

  void finalizeMetaCurrency() {
    metaCurrencyEarned = computeMetaCurrencyEarned();
  }

  void reset() {
    timeAlive = 0;
    enemiesDefeated = 0;
    xpGained = 0;
    damageTaken = 0;
    metaCurrencyEarned = 0;
    metaRewardMultiplier = 1.0;
    contractHeat = 0;
    contractNames = const [];
    areaName = null;
    completed = false;
  }
}
