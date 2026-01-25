import 'package:flutter/foundation.dart';

import '../data/tags.dart';

class PlayerHudState extends ChangeNotifier {
  double hp = 0;
  double maxHp = 0;
  int level = 1;
  int xp = 0;
  int xpToNext = 0;
  int gold = 0;
  int goldToNext = 0;
  int goldWallet = 0;
  int score = 0;
  bool showPerformance = false;
  double fps = 0;
  double frameTimeMs = 0;
  double stageElapsed = 0;
  double stageDuration = 0;
  int sectionIndex = 0;
  int sectionCount = 0;
  int threatTier = 0;
  String? sectionNote;
  TagSet buildTags = const TagSet();
  int levelUpCounter = 0;
  int rewardCounter = 0;
  String? rewardMessage;
  int contractHeat = 0;
  List<String> contractNames = const [];
  int dashCharges = 0;
  int dashMaxCharges = 0;
  double dashCooldownRemaining = 0;
  double dashCooldownDuration = 0;

  void triggerRewardMessage(String message) {
    rewardMessage = message;
    rewardCounter += 1;
    notifyListeners();
  }

  void update({
    required double hp,
    required double maxHp,
    required int level,
    required int xp,
    required int xpToNext,
    required int gold,
    required int goldToNext,
    required int goldWallet,
    required int score,
    required bool showPerformance,
    required double fps,
    required double frameTimeMs,
    required double stageElapsed,
    required double stageDuration,
    required int sectionIndex,
    required int sectionCount,
    required int threatTier,
    required String? sectionNote,
    required TagSet buildTags,
    required int contractHeat,
    required List<String> contractNames,
    required int dashCharges,
    required int dashMaxCharges,
    required double dashCooldownRemaining,
    required double dashCooldownDuration,
  }) {
    final didLevelChange = this.level != level;
    final nextLevelUpCounter = didLevelChange
        ? levelUpCounter + 1
        : levelUpCounter;
    if (this.hp == hp &&
        this.maxHp == maxHp &&
        this.level == level &&
        this.xp == xp &&
        this.xpToNext == xpToNext &&
        this.gold == gold &&
        this.goldToNext == goldToNext &&
        this.goldWallet == goldWallet &&
        this.score == score &&
        this.showPerformance == showPerformance &&
        this.fps == fps &&
        this.frameTimeMs == frameTimeMs &&
        this.stageElapsed == stageElapsed &&
        this.stageDuration == stageDuration &&
        this.sectionIndex == sectionIndex &&
        this.sectionCount == sectionCount &&
        this.threatTier == threatTier &&
        this.sectionNote == sectionNote &&
        this.buildTags.equals(buildTags) &&
        this.contractHeat == contractHeat &&
        listEquals(this.contractNames, contractNames) &&
        this.dashCharges == dashCharges &&
        this.dashMaxCharges == dashMaxCharges &&
        this.dashCooldownRemaining == dashCooldownRemaining &&
        this.dashCooldownDuration == dashCooldownDuration &&
        levelUpCounter == nextLevelUpCounter) {
      return;
    }

    this.hp = hp;
    this.maxHp = maxHp;
    this.level = level;
    this.xp = xp;
    this.xpToNext = xpToNext;
    this.gold = gold;
    this.goldToNext = goldToNext;
    this.goldWallet = goldWallet;
    this.score = score;
    this.showPerformance = showPerformance;
    this.fps = fps;
    this.frameTimeMs = frameTimeMs;
    this.stageElapsed = stageElapsed;
    this.stageDuration = stageDuration;
    this.sectionIndex = sectionIndex;
    this.sectionCount = sectionCount;
    this.threatTier = threatTier;
    this.sectionNote = sectionNote;
    this.buildTags = buildTags;
    this.contractHeat = contractHeat;
    this.contractNames = contractNames;
    this.dashCharges = dashCharges;
    this.dashMaxCharges = dashMaxCharges;
    this.dashCooldownRemaining = dashCooldownRemaining;
    this.dashCooldownDuration = dashCooldownDuration;
    levelUpCounter = nextLevelUpCounter;
    notifyListeners();
  }
}
