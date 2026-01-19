import 'dart:math' as math;

import '../data/ids.dart';

class RunSummary {
  RunSummary({
    this.timeAlive = 0,
    this.enemiesDefeated = 0,
    this.xpGained = 0,
    this.goldGained = 0,
    this.damageTaken = 0,
    this.metaCurrencyEarned = 0,
    this.metaRewardMultiplier = 1.0,
    this.metaCurrencyBonus = 0,
    this.contractHeat = 0,
    this.contractNames = const [],
    this.skills = const [],
    this.items = const [],
    this.upgrades = const [],
    this.weaponUpgrades = const [],
    this.synergyTriggers = 0,
    Map<SynergyId, int>? synergyTriggerCounts,
    this.areaName,
    this.completed = false,
  }) : synergyTriggerCounts = synergyTriggerCounts ?? <SynergyId, int>{};

  double timeAlive;
  int enemiesDefeated;
  int xpGained;
  int goldGained;
  double damageTaken;
  int metaCurrencyEarned;
  double metaRewardMultiplier;
  int metaCurrencyBonus;
  int contractHeat;
  List<String> contractNames;
  List<SkillId> skills;
  List<ItemId> items;
  List<SkillUpgradeId> upgrades;
  List<String> weaponUpgrades;
  int synergyTriggers;
  Map<SynergyId, int> synergyTriggerCounts;
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
    final scaled = math.max(0, (total * metaRewardMultiplier).round());
    return math.max(0, scaled + metaCurrencyBonus);
  }

  void finalizeMetaCurrency() {
    metaCurrencyEarned = computeMetaCurrencyEarned();
  }

  void reset() {
    timeAlive = 0;
    enemiesDefeated = 0;
    xpGained = 0;
    goldGained = 0;
    damageTaken = 0;
    metaCurrencyEarned = 0;
    metaRewardMultiplier = 1.0;
    metaCurrencyBonus = 0;
    contractHeat = 0;
    contractNames = const [];
    skills = const [];
    items = const [];
    upgrades = const [];
    weaponUpgrades = const [];
    synergyTriggers = 0;
    synergyTriggerCounts = <SynergyId, int>{};
    areaName = null;
    completed = false;
  }
}
