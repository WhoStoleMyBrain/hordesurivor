import 'package:flutter/foundation.dart';

import 'dart:ui' as ui;

import '../data/character_defs.dart';
import '../data/ids.dart';
import '../data/stat_defs.dart';
import '../data/tags.dart';
import '../game/skill_progression_system.dart';

class StatsScreenState extends ChangeNotifier {
  Map<StatId, double> statValues = const {};
  List<SkillId> skills = const [];
  Map<SkillId, SkillProgressSnapshot> skillLevels = const {};
  List<SkillUpgradeId> upgrades = const [];
  List<String> weaponUpgrades = const [];
  List<ItemId> items = const [];
  int rerollsRemaining = 0;
  int rerollsMax = 0;
  CharacterId activeCharacterId = characterDefs.first.id;
  ui.Image? activeCharacterSprite;
  TagSet buildTags = const TagSet();

  void update({
    required Map<StatId, double> statValues,
    required List<SkillId> skills,
    required Map<SkillId, SkillProgressSnapshot> skillLevels,
    required List<SkillUpgradeId> upgrades,
    required List<String> weaponUpgrades,
    required List<ItemId> items,
    required int rerollsRemaining,
    required int rerollsMax,
    required CharacterId activeCharacterId,
    required ui.Image? activeCharacterSprite,
    required TagSet buildTags,
  }) {
    if (mapEquals(this.statValues, statValues) &&
        listEquals(this.skills, skills) &&
        mapEquals(this.skillLevels, skillLevels) &&
        listEquals(this.upgrades, upgrades) &&
        listEquals(this.weaponUpgrades, weaponUpgrades) &&
        listEquals(this.items, items) &&
        this.rerollsRemaining == rerollsRemaining &&
        this.rerollsMax == rerollsMax &&
        this.activeCharacterId == activeCharacterId &&
        this.activeCharacterSprite == activeCharacterSprite &&
        this.buildTags.equals(buildTags)) {
      return;
    }
    this.statValues = Map<StatId, double>.from(statValues);
    this.skills = List<SkillId>.from(skills);
    this.skillLevels = Map<SkillId, SkillProgressSnapshot>.from(skillLevels);
    this.upgrades = List<SkillUpgradeId>.from(upgrades);
    this.weaponUpgrades = List<String>.from(weaponUpgrades);
    this.items = List<ItemId>.from(items);
    this.rerollsRemaining = rerollsRemaining;
    this.rerollsMax = rerollsMax;
    this.activeCharacterId = activeCharacterId;
    this.activeCharacterSprite = activeCharacterSprite;
    this.buildTags = buildTags;
    notifyListeners();
  }
}
