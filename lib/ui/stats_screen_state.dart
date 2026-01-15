import 'package:flutter/foundation.dart';

import '../data/ids.dart';
import '../data/stat_defs.dart';

class StatsScreenState extends ChangeNotifier {
  Map<StatId, double> statValues = const {};
  List<SkillId> skills = const [];
  List<SkillUpgradeId> upgrades = const [];
  List<String> weaponUpgrades = const [];
  List<ItemId> items = const [];
  int rerollsRemaining = 0;
  int rerollsMax = 0;

  void update({
    required Map<StatId, double> statValues,
    required List<SkillId> skills,
    required List<SkillUpgradeId> upgrades,
    required List<String> weaponUpgrades,
    required List<ItemId> items,
    required int rerollsRemaining,
    required int rerollsMax,
  }) {
    if (mapEquals(this.statValues, statValues) &&
        listEquals(this.skills, skills) &&
        listEquals(this.upgrades, upgrades) &&
        listEquals(this.weaponUpgrades, weaponUpgrades) &&
        listEquals(this.items, items) &&
        this.rerollsRemaining == rerollsRemaining &&
        this.rerollsMax == rerollsMax) {
      return;
    }
    this.statValues = Map<StatId, double>.from(statValues);
    this.skills = List<SkillId>.from(skills);
    this.upgrades = List<SkillUpgradeId>.from(upgrades);
    this.weaponUpgrades = List<String>.from(weaponUpgrades);
    this.items = List<ItemId>.from(items);
    this.rerollsRemaining = rerollsRemaining;
    this.rerollsMax = rerollsMax;
    notifyListeners();
  }
}
