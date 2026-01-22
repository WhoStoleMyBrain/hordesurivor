import 'dart:math' as math;

import '../data/ids.dart';
import '../data/item_defs.dart';
import '../data/progression_track_defs.dart';
import '../data/skill_defs.dart';
import '../data/skill_upgrade_defs.dart';
import '../data/stat_defs.dart';
import '../data/tags.dart';
import '../data/weapon_upgrade_defs.dart';
import 'player_state.dart';
import 'skill_system.dart';

enum SelectionType { skill, item, skillUpgrade, weaponUpgrade }

class SelectionChoice {
  const SelectionChoice({
    required this.type,
    required this.title,
    required this.description,
    this.flavorText = '',
    this.skillId,
    this.itemId,
    this.skillUpgradeId,
    this.weaponUpgradeId,
  });

  final SelectionType type;
  final String title;
  final String description;
  final String flavorText;
  final SkillId? skillId;
  final ItemId? itemId;
  final SkillUpgradeId? skillUpgradeId;
  final String? weaponUpgradeId;
}

class LevelUpSystem {
  LevelUpSystem({
    required math.Random random,
    int baseChoiceCount = 3,
    int baseRerolls = 1,
  }) : _random = random,
       _baseChoiceCount = baseChoiceCount,
       _baseRerolls = baseRerolls;

  final math.Random _random;
  final int _baseChoiceCount;
  final int _baseRerolls;
  static const double _shopPriceGrowthRate = 1.1;
  static const SelectionChoice _shopPlaceholderChoice = SelectionChoice(
    type: SelectionType.item,
    title: 'Empty Slot',
    description: 'Purchased item.',
  );
  final List<SelectionChoice> _choices = [];
  final Set<SkillUpgradeId> _appliedUpgrades = {};
  final Set<String> _appliedWeaponUpgrades = {};
  final List<ItemId> _appliedItems = [];
  final Map<ItemId, int> _appliedItemCounts = {};
  final Set<SkillId> _banishedSkills = {};
  final Set<ItemId> _banishedItems = {};
  final Set<SkillUpgradeId> _banishedSkillUpgrades = {};
  final Set<String> _banishedWeaponUpgrades = {};
  final List<ItemId> _lockedItems = [];
  final Map<ProgressionTrackId, int> _pendingLevels = {};
  final Map<SkillId, int> _weaponUpgradeTiers = {};
  int _rerollsRemaining = 0;
  int _rerollsMax = 0;
  int _banishesRemaining = 0;
  int _banishesMax = 0;
  ProgressionTrackId? _activeTrackId;
  int _shopRerollCount = 0;
  int _rarePityChance = 0;
  int _epicPityChance = 0;

  List<SelectionChoice> get choices => List.unmodifiable(_choices);
  int pendingLevels(ProgressionTrackId trackId) => _pendingLevels[trackId] ?? 0;
  ProgressionTrackId? get activeTrackId => _activeTrackId;
  bool get hasChoices => _choices.isNotEmpty;
  int get rerollsRemaining => _rerollsRemaining;
  int get rerollsMax => _rerollsMax;
  int get banishesRemaining => _banishesRemaining;
  int get banishesMax => _banishesMax;
  Set<SkillUpgradeId> get appliedUpgrades =>
      Set<SkillUpgradeId>.unmodifiable(_appliedUpgrades);
  Set<String> get appliedWeaponUpgrades =>
      Set<String>.unmodifiable(_appliedWeaponUpgrades);
  List<ItemId> get appliedItems => List<ItemId>.unmodifiable(_appliedItems);
  Map<ItemId, int> get appliedItemCounts =>
      Map<ItemId, int>.unmodifiable(_appliedItemCounts);
  Set<ItemId> get lockedItems => Set<ItemId>.unmodifiable(_lockedItems);
  int get shopRerollCount => _shopRerollCount;

  ProgressionTrackId? get nextPendingTrackId {
    for (final track in progressionTrackDefs) {
      if ((_pendingLevels[track.id] ?? 0) > 0) {
        return track.id;
      }
    }
    return null;
  }

  void queueLevels(ProgressionTrackId trackId, int levelsGained) {
    if (levelsGained <= 0) {
      return;
    }
    _pendingLevels[trackId] = (_pendingLevels[trackId] ?? 0) + levelsGained;
  }

  void resetForRun({required PlayerState playerState}) {
    _pendingLevels.clear();
    _choices.clear();
    _appliedUpgrades.clear();
    _appliedWeaponUpgrades.clear();
    _appliedItems.clear();
    _appliedItemCounts.clear();
    _banishedSkills.clear();
    _banishedItems.clear();
    _banishedSkillUpgrades.clear();
    _banishedWeaponUpgrades.clear();
    _weaponUpgradeTiers.clear();
    _lockedItems.clear();
    _rerollsRemaining = 0;
    _rerollsMax = 0;
    _banishesRemaining = 0;
    _banishesMax = 0;
    _activeTrackId = null;
    _shopRerollCount = 0;
    _rarePityChance = 0;
    _epicPityChance = 0;
    _syncRerolls(playerState);
    _syncBanishes(playerState);
  }

  int buildChoices({
    required ProgressionTrackId trackId,
    required SelectionPoolId selectionPoolId,
    required PlayerState playerState,
    required SkillSystem skillSystem,
    required int trackLevel,
    int shopBonusChoices = 0,
    int rarityBoosts = 0,
    Set<MetaUnlockId> unlockedMeta = const {},
  }) {
    if ((_pendingLevels[trackId] ?? 0) <= 0 || _choices.isNotEmpty) {
      return 0;
    }
    if (selectionPoolId == SelectionPoolId.itemPool) {
      _shopRerollCount = 0;
    }
    final result = _buildChoicesFor(
      playerState,
      skillSystem,
      selectionPoolId,
      trackLevel,
      unlockedMeta,
      shopBonusChoices: shopBonusChoices,
      rarityBoosts: rarityBoosts,
    );
    _choices
      ..clear()
      ..addAll(result.choices);
    if (_choices.isEmpty) {
      _pendingLevels[trackId] = 0;
      _activeTrackId = null;
    } else {
      _activeTrackId = trackId;
    }
    return result.rarityBoostsApplied;
  }

  void buildStartingSkillChoices({
    required List<SkillId> startingSkills,
    required SkillSystem skillSystem,
    required Set<MetaUnlockId> unlockedMeta,
  }) {
    final candidates = <SelectionChoice>[];
    for (final skillId in startingSkills) {
      final skill = skillDefsById[skillId];
      if (skill == null) {
        continue;
      }
      if (skillSystem.hasSkill(skill.id) ||
          _banishedSkills.contains(skill.id)) {
        continue;
      }
      if (skill.metaUnlockId != null &&
          !unlockedMeta.contains(skill.metaUnlockId)) {
        continue;
      }
      candidates.add(
        SelectionChoice(
          type: SelectionType.skill,
          title: skill.name,
          description: skill.description,
          skillId: skill.id,
        ),
      );
    }
    _choices
      ..clear()
      ..addAll(candidates);
    _activeTrackId = _choices.isEmpty ? null : ProgressionTrackId.skills;
  }

  bool rerollChoices({
    required ProgressionTrackId trackId,
    required SelectionPoolId selectionPoolId,
    required PlayerState playerState,
    required SkillSystem skillSystem,
    required int trackLevel,
    int shopBonusChoices = 0,
    bool ignoreRerollLimit = false,
    Set<MetaUnlockId> unlockedMeta = const {},
  }) {
    if (_choices.isEmpty ||
        (!_shouldAllowReroll(ignoreRerollLimit)) ||
        _activeTrackId != trackId) {
      return false;
    }
    if (!ignoreRerollLimit) {
      _rerollsRemaining -= 1;
    }
    final newChoices = _buildChoicesFor(
      playerState,
      skillSystem,
      selectionPoolId,
      trackLevel,
      unlockedMeta,
      shopBonusChoices: shopBonusChoices,
    ).choices;
    _choices
      ..clear()
      ..addAll(newChoices);
    if (selectionPoolId == SelectionPoolId.itemPool) {
      _shopRerollCount += 1;
    }
    return true;
  }

  bool isItemLocked(ItemId itemId) => _lockedItems.contains(itemId);

  void setItemLocked(ItemId itemId, bool locked) {
    if (locked) {
      if (!_lockedItems.contains(itemId)) {
        _lockedItems.add(itemId);
      }
    } else {
      _lockedItems.remove(itemId);
    }
  }

  int shopRerollCost(int shopLevel) {
    final rerollBase = 5 + (shopLevel ~/ 3);
    return rerollBase + 4 * _shopRerollCount;
  }

  int itemPriceForRarity(ItemRarity rarity, int shopLevel) {
    final basePrice = switch (rarity) {
      ItemRarity.common => 6,
      ItemRarity.uncommon => 10,
      ItemRarity.rare => 16,
      ItemRarity.epic => 26,
    };
    final multiplier = math.pow(_shopPriceGrowthRate, shopLevel).toDouble();
    return math.max(1, (basePrice * multiplier).round());
  }

  void applyChoice({
    required ProgressionTrackId trackId,
    required SelectionChoice choice,
    required PlayerState playerState,
    required SkillSystem skillSystem,
  }) {
    switch (choice.type) {
      case SelectionType.item:
        final itemId = choice.itemId;
        if (itemId != null) {
          _lockedItems.remove(itemId);
          final item = itemDefsById[itemId];
          if (item != null && !_isItemCapped(item)) {
            _appliedItems.add(item.id);
            _appliedItemCounts[item.id] = _itemCount(item.id) + 1;
            playerState.applyModifiers(item.modifiers);
          }
        }
      case SelectionType.skillUpgrade:
        final upgradeId = choice.skillUpgradeId;
        if (upgradeId != null) {
          final upgrade = skillUpgradeDefsById[upgradeId];
          if (upgrade != null) {
            _appliedUpgrades.add(upgrade.id);
            playerState.applyModifiers(upgrade.modifiers);
          }
        }
      case SelectionType.weaponUpgrade:
        final upgradeId = choice.weaponUpgradeId;
        if (upgradeId != null) {
          final upgrade = weaponUpgradeDefsById[upgradeId];
          if (upgrade != null) {
            _appliedWeaponUpgrades.add(upgrade.id);
            _weaponUpgradeTiers[upgrade.skillId] = math.max(
              _weaponUpgradeTiers[upgrade.skillId] ?? 1,
              upgrade.tier,
            );
            playerState.applyModifiers(upgrade.modifiers);
          }
        }
      case SelectionType.skill:
        final skillId = choice.skillId;
        if (skillId != null) {
          skillSystem.addSkill(skillId);
        }
    }
    _syncRerolls(playerState);
    _syncBanishes(playerState);
    _pendingLevels[trackId] = math.max(0, (_pendingLevels[trackId] ?? 0) - 1);
    _choices.clear();
    _activeTrackId = null;
  }

  bool applyShopPurchase({
    required SelectionChoice choice,
    required PlayerState playerState,
  }) {
    if (choice.type != SelectionType.item) {
      return false;
    }
    final itemId = choice.itemId;
    if (itemId == null) {
      return false;
    }
    _lockedItems.remove(itemId);
    final item = itemDefsById[itemId];
    if (item != null && !_isItemCapped(item)) {
      _appliedItems.add(item.id);
      _appliedItemCounts[item.id] = _itemCount(item.id) + 1;
      playerState.applyModifiers(item.modifiers);
    }
    _syncRerolls(playerState);
    _syncBanishes(playerState);
    _replaceChoiceWithPlaceholder(choice);
    return true;
  }

  void skipChoice({
    required ProgressionTrackId trackId,
    required PlayerState playerState,
  }) {
    _syncRerolls(playerState);
    _syncBanishes(playerState);
    _pendingLevels[trackId] = math.max(0, (_pendingLevels[trackId] ?? 0) - 1);
    _choices.clear();
    _activeTrackId = null;
  }

  bool banishChoice({
    required ProgressionTrackId trackId,
    required SelectionPoolId selectionPoolId,
    required SelectionChoice choice,
    required PlayerState playerState,
    required SkillSystem skillSystem,
    required int trackLevel,
    Set<MetaUnlockId> unlockedMeta = const {},
  }) {
    if (_choices.isEmpty ||
        _banishesRemaining <= 0 ||
        _activeTrackId != trackId) {
      return false;
    }
    switch (choice.type) {
      case SelectionType.skill:
        final skillId = choice.skillId;
        if (skillId == null) {
          return false;
        }
        _banishedSkills.add(skillId);
      case SelectionType.item:
        final itemId = choice.itemId;
        if (itemId == null) {
          return false;
        }
        _banishedItems.add(itemId);
        _lockedItems.remove(itemId);
      case SelectionType.skillUpgrade:
        final upgradeId = choice.skillUpgradeId;
        if (upgradeId == null) {
          return false;
        }
        _banishedSkillUpgrades.add(upgradeId);
      case SelectionType.weaponUpgrade:
        final upgradeId = choice.weaponUpgradeId;
        if (upgradeId == null) {
          return false;
        }
        _banishedWeaponUpgrades.add(upgradeId);
    }
    _banishesRemaining = math.max(0, _banishesRemaining - 1);
    _choices
      ..clear()
      ..addAll(
        _buildChoicesFor(
          playerState,
          skillSystem,
          selectionPoolId,
          trackLevel,
          unlockedMeta,
        ).choices,
      );
    if (_choices.isEmpty) {
      _pendingLevels[trackId] = 0;
      _activeTrackId = null;
    }
    return true;
  }

  _ChoiceBuildResult _buildChoicesFor(
    PlayerState playerState,
    SkillSystem skillSystem,
    SelectionPoolId selectionPoolId,
    int trackLevel,
    Set<MetaUnlockId> unlockedMeta, {
    int shopBonusChoices = 0,
    int rarityBoosts = 0,
  }) {
    final extraChoices = playerState.stats.value(StatId.choiceCount).round();
    final bonusChoices = selectionPoolId == SelectionPoolId.itemPool
        ? shopBonusChoices
        : 0;
    final choiceCount = math.max(
      1,
      _baseChoiceCount + extraChoices + bonusChoices,
    );
    if (selectionPoolId == SelectionPoolId.itemPool) {
      return _buildItemChoices(
        skillSystem,
        choiceCount,
        trackLevel,
        unlockedMeta,
        rarityBoosts: rarityBoosts,
      );
    }
    final candidates = _buildCandidates(
      skillSystem,
      selectionPoolId,
      unlockedMeta,
    );
    candidates.shuffle(_random);
    return _ChoiceBuildResult(candidates.take(choiceCount).toList());
  }

  void _syncRerolls(PlayerState playerState) {
    final bonus = playerState.stats.value(StatId.rerolls).round();
    final maxRerolls = math.max(0, _baseRerolls + bonus);
    if (maxRerolls > _rerollsMax) {
      _rerollsRemaining += maxRerolls - _rerollsMax;
    }
    _rerollsMax = maxRerolls;
    if (_rerollsRemaining > _rerollsMax) {
      _rerollsRemaining = _rerollsMax;
    }
  }

  void _syncBanishes(PlayerState playerState) {
    final bonus = playerState.stats.value(StatId.banishes).round();
    final maxBanishes = math.max(0, bonus);
    if (maxBanishes > _banishesMax) {
      _banishesRemaining += maxBanishes - _banishesMax;
    }
    _banishesMax = maxBanishes;
    if (_banishesRemaining > _banishesMax) {
      _banishesRemaining = _banishesMax;
    }
  }

  void _replaceChoiceWithPlaceholder(SelectionChoice choice) {
    final index = _choices.indexOf(choice);
    if (index != -1) {
      _choices[index] = _shopPlaceholderChoice;
      return;
    }
    final itemId = choice.itemId;
    if (itemId == null) {
      return;
    }
    final fallbackIndex = _choices.indexWhere(
      (entry) => entry.type == SelectionType.item && entry.itemId == itemId,
    );
    if (fallbackIndex != -1) {
      _choices[fallbackIndex] = _shopPlaceholderChoice;
    }
  }

  List<SelectionChoice> _buildCandidates(
    SkillSystem skillSystem,
    SelectionPoolId selectionPoolId,
    Set<MetaUnlockId> unlockedMeta,
  ) {
    switch (selectionPoolId) {
      case SelectionPoolId.skillPool:
        final allowNewSkills = skillSystem.hasOpenSkillSlot;
        return [
          if (allowNewSkills)
            for (final skill in skillDefs)
              if (!skillSystem.hasSkill(skill.id) &&
                  !_banishedSkills.contains(skill.id) &&
                  (skill.metaUnlockId == null ||
                      unlockedMeta.contains(skill.metaUnlockId)))
                SelectionChoice(
                  type: SelectionType.skill,
                  title: skill.name,
                  description: skill.description,
                  skillId: skill.id,
                ),
          for (final upgrade in skillUpgradeDefs)
            if (skillSystem.hasSkill(upgrade.skillId) &&
                !_appliedUpgrades.contains(upgrade.id) &&
                !_banishedSkillUpgrades.contains(upgrade.id))
              SelectionChoice(
                type: SelectionType.skillUpgrade,
                title:
                    '${skillDefsById[upgrade.skillId]?.name}: ${upgrade.name}',
                description: upgrade.summary,
                skillUpgradeId: upgrade.id,
              ),
          ..._buildWeaponUpgradeCandidates(skillSystem),
        ];
      case SelectionPoolId.itemPool:
        return const [];
      case SelectionPoolId.futurePool:
        return const [];
    }
  }

  _ChoiceBuildResult _buildItemChoices(
    SkillSystem skillSystem,
    int choiceCount,
    int trackLevel,
    Set<MetaUnlockId> unlockedMeta, {
    int rarityBoosts = 0,
  }) {
    final tagBias = _buildShopTagBias(skillSystem);
    final rarityWeights = _itemRarityWeightsForLevel(trackLevel);
    _applyPityRoll(rarityWeights);
    final lockedItems = _resolveLockedItems(unlockedMeta);
    for (final item in lockedItems) {
      _resetPityForItem(item);
    }
    if (lockedItems.length > choiceCount) {
      lockedItems.removeRange(choiceCount, lockedItems.length);
      _lockedItems
        ..clear()
        ..addAll(lockedItems.map((item) => item.id));
    }
    final lockedIds = lockedItems.map((item) => item.id).toSet();
    final availableByRarity = <ItemRarity, List<ItemDef>>{
      for (final rarity in ItemRarity.values) rarity: <ItemDef>[],
    };
    for (final item in itemDefs) {
      if (_banishedItems.contains(item.id)) {
        continue;
      }
      if (lockedIds.contains(item.id)) {
        continue;
      }
      if (item.metaUnlockId != null &&
          !unlockedMeta.contains(item.metaUnlockId)) {
        continue;
      }
      if (_isItemCapped(item)) {
        continue;
      }
      availableByRarity[item.rarity]?.add(item);
    }
    if (availableByRarity.values.every((items) => items.isEmpty)) {
      return _ChoiceBuildResult([
        for (final item in lockedItems)
          SelectionChoice(
            type: SelectionType.item,
            title: item.name,
            description: item.description,
            flavorText: item.flavorText,
            itemId: item.id,
          ),
      ]);
    }
    final choices = <SelectionChoice>[];
    for (final item in lockedItems) {
      choices.add(
        SelectionChoice(
          type: SelectionType.item,
          title: item.name,
          description: item.description,
          flavorText: item.flavorText,
          itemId: item.id,
        ),
      );
    }
    while (choices.length < choiceCount) {
      _applyPityRoll(rarityWeights);
      final rarity =
          _pickForcedPityRarity(availableByRarity) ??
          _pickWeightedRarity(availableByRarity, rarityWeights);
      if (rarity == null) {
        break;
      }
      final items = availableByRarity[rarity];
      if (items == null || items.isEmpty) {
        continue;
      }
      final item = _pickWeightedItem(items, tagBias);
      if (item == null) {
        break;
      }
      items.remove(item);
      choices.add(
        SelectionChoice(
          type: SelectionType.item,
          title: item.name,
          description: item.description,
          flavorText: item.flavorText,
          itemId: item.id,
        ),
      );
      _resetPityForItem(item);
    }
    final rarityBoostsApplied = _applyRarityBoosts(
      choices,
      availableByRarity,
      tagBias,
      lockedIds,
      rarityBoosts,
    );
    return _ChoiceBuildResult(
      choices,
      rarityBoostsApplied: rarityBoostsApplied,
    );
  }

  int _applyRarityBoosts(
    List<SelectionChoice> choices,
    Map<ItemRarity, List<ItemDef>> availableByRarity,
    _TagBias tagBias,
    Set<ItemId> lockedIds,
    int rarityBoosts,
  ) {
    if (rarityBoosts <= 0 || choices.isEmpty) {
      return 0;
    }
    final boostableIndexes = <int>[];
    for (var i = 0; i < choices.length; i++) {
      final choice = choices[i];
      if (choice.type != SelectionType.item) {
        continue;
      }
      final itemId = choice.itemId;
      if (itemId == null || lockedIds.contains(itemId)) {
        continue;
      }
      final item = itemDefsById[itemId];
      if (item == null) {
        continue;
      }
      final nextRarity = _nextRarity(item.rarity);
      if (nextRarity == null) {
        continue;
      }
      final candidates = availableByRarity[nextRarity];
      if (candidates == null || candidates.isEmpty) {
        continue;
      }
      boostableIndexes.add(i);
    }
    var boostsApplied = 0;
    while (boostsApplied < rarityBoosts && boostableIndexes.isNotEmpty) {
      final pickIndex = _random.nextInt(boostableIndexes.length);
      final choiceIndex = boostableIndexes.removeAt(pickIndex);
      final choice = choices[choiceIndex];
      final itemId = choice.itemId;
      if (itemId == null) {
        continue;
      }
      final item = itemDefsById[itemId];
      if (item == null) {
        continue;
      }
      final nextRarity = _nextRarity(item.rarity);
      if (nextRarity == null) {
        continue;
      }
      final candidates = availableByRarity[nextRarity];
      if (candidates == null || candidates.isEmpty) {
        continue;
      }
      final boostedItem = _pickWeightedItem(candidates, tagBias);
      if (boostedItem == null) {
        continue;
      }
      candidates.remove(boostedItem);
      choices[choiceIndex] = SelectionChoice(
        type: SelectionType.item,
        title: boostedItem.name,
        description: boostedItem.description,
        flavorText: boostedItem.flavorText,
        itemId: boostedItem.id,
      );
      _resetPityForItem(boostedItem);
      boostsApplied += 1;
    }
    return boostsApplied;
  }

  ItemRarity? _nextRarity(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return ItemRarity.uncommon;
      case ItemRarity.uncommon:
        return ItemRarity.rare;
      case ItemRarity.rare:
        return ItemRarity.epic;
      case ItemRarity.epic:
        return null;
    }
  }

  bool _shouldAllowReroll(bool ignoreRerollLimit) {
    if (ignoreRerollLimit) {
      return true;
    }
    return _rerollsRemaining > 0;
  }

  List<ItemDef> _resolveLockedItems(Set<MetaUnlockId> unlockedMeta) {
    if (_lockedItems.isEmpty) {
      return <ItemDef>[];
    }
    final locked = <ItemDef>[];
    final nextLockedIds = <ItemId>[];
    for (final itemId in _lockedItems) {
      final item = itemDefsById[itemId];
      if (item == null) {
        continue;
      }
      if (_banishedItems.contains(item.id)) {
        continue;
      }
      if (item.metaUnlockId != null &&
          !unlockedMeta.contains(item.metaUnlockId)) {
        continue;
      }
      if (_isItemCapped(item)) {
        continue;
      }
      nextLockedIds.add(item.id);
      locked.add(item);
    }
    if (nextLockedIds.length != _lockedItems.length) {
      _lockedItems
        ..clear()
        ..addAll(nextLockedIds);
    }
    return locked;
  }

  Map<ItemRarity, int> _itemRarityWeightsForLevel(int level) {
    final normalizedLevel = math.max(1, level);
    if (normalizedLevel == 1) {
      return const {
        ItemRarity.common: 75,
        ItemRarity.uncommon: 22,
        ItemRarity.rare: 3,
        ItemRarity.epic: 0,
      };
    }
    if (normalizedLevel == 2) {
      return const {
        ItemRarity.common: 70,
        ItemRarity.uncommon: 25,
        ItemRarity.rare: 5,
        ItemRarity.epic: 0,
      };
    }
    if (normalizedLevel == 3) {
      return const {
        ItemRarity.common: 64,
        ItemRarity.uncommon: 28,
        ItemRarity.rare: 7,
        ItemRarity.epic: 1,
      };
    }
    if (normalizedLevel == 4) {
      return const {
        ItemRarity.common: 58,
        ItemRarity.uncommon: 30,
        ItemRarity.rare: 10,
        ItemRarity.epic: 2,
      };
    }
    if (normalizedLevel == 5) {
      return const {
        ItemRarity.common: 52,
        ItemRarity.uncommon: 32,
        ItemRarity.rare: 13,
        ItemRarity.epic: 3,
      };
    }
    if (normalizedLevel == 6) {
      return const {
        ItemRarity.common: 46,
        ItemRarity.uncommon: 34,
        ItemRarity.rare: 16,
        ItemRarity.epic: 4,
      };
    }
    if (normalizedLevel == 7) {
      return const {
        ItemRarity.common: 42,
        ItemRarity.uncommon: 34,
        ItemRarity.rare: 18,
        ItemRarity.epic: 6,
      };
    }
    if (normalizedLevel == 8) {
      return const {
        ItemRarity.common: 38,
        ItemRarity.uncommon: 34,
        ItemRarity.rare: 20,
        ItemRarity.epic: 8,
      };
    }
    if (normalizedLevel == 9) {
      return const {
        ItemRarity.common: 34,
        ItemRarity.uncommon: 34,
        ItemRarity.rare: 22,
        ItemRarity.epic: 10,
      };
    }
    return const {
      ItemRarity.common: 30,
      ItemRarity.uncommon: 34,
      ItemRarity.rare: 24,
      ItemRarity.epic: 12,
    };
  }

  ItemRarity? _pickWeightedRarity(
    Map<ItemRarity, List<ItemDef>> availableByRarity,
    Map<ItemRarity, int> rarityWeights,
  ) {
    var totalWeight = 0;
    for (final rarity in ItemRarity.values) {
      if ((availableByRarity[rarity]?.isNotEmpty ?? false) &&
          (rarityWeights[rarity] ?? 0) > 0) {
        totalWeight += rarityWeights[rarity] ?? 0;
      }
    }
    if (totalWeight <= 0) {
      return null;
    }
    var roll = _random.nextInt(totalWeight);
    for (final rarity in ItemRarity.values) {
      final rarityWeight = rarityWeights[rarity] ?? 0;
      if (rarityWeight <= 0 || (availableByRarity[rarity]?.isEmpty ?? true)) {
        continue;
      }
      roll -= rarityWeight;
      if (roll < 0) {
        return rarity;
      }
    }
    return null;
  }

  ItemRarity? _pickForcedPityRarity(
    Map<ItemRarity, List<ItemDef>> availableByRarity,
  ) {
    if (_epicPityChance > 300 &&
        (availableByRarity[ItemRarity.epic]?.isNotEmpty ?? false)) {
      return ItemRarity.epic;
    }
    if (_rarePityChance > 300 &&
        (availableByRarity[ItemRarity.rare]?.isNotEmpty ?? false)) {
      return ItemRarity.rare;
    }
    return null;
  }

  ItemDef? _pickWeightedItem(List<ItemDef> items, _TagBias tagBias) {
    var totalWeight = 0.0;
    for (final item in items) {
      totalWeight += _weightedItemWeight(item, tagBias);
    }
    if (totalWeight <= 0) {
      return null;
    }
    var roll = _random.nextDouble() * totalWeight;
    for (final item in items) {
      roll -= _weightedItemWeight(item, tagBias);
      if (roll < 0) {
        return item;
      }
    }
    return null;
  }

  _TagBias _buildShopTagBias(SkillSystem skillSystem) {
    final elementCounts = <ElementTag, int>{};
    final effectCounts = <EffectTag, int>{};
    final deliveryCounts = <DeliveryTag, int>{};

    void addTags(TagSet tags, [int count = 1]) {
      for (final tag in tags.elements) {
        elementCounts[tag] = (elementCounts[tag] ?? 0) + count;
      }
      for (final tag in tags.effects) {
        effectCounts[tag] = (effectCounts[tag] ?? 0) + count;
      }
      for (final tag in tags.deliveries) {
        deliveryCounts[tag] = (deliveryCounts[tag] ?? 0) + count;
      }
    }

    for (final skillId in skillSystem.skillIds) {
      final skill = skillDefsById[skillId];
      if (skill != null) {
        addTags(skill.tags);
      }
    }
    for (final entry in _appliedItemCounts.entries) {
      final item = itemDefsById[entry.key];
      if (item != null) {
        addTags(item.tags, entry.value);
      }
    }
    for (final upgradeId in _appliedUpgrades) {
      final upgrade = skillUpgradeDefsById[upgradeId];
      if (upgrade != null) {
        addTags(upgrade.tags);
      }
    }
    for (final upgradeId in _appliedWeaponUpgrades) {
      final upgrade = weaponUpgradeDefsById[upgradeId];
      if (upgrade != null) {
        addTags(upgrade.tags);
      }
    }

    return _TagBias(
      elements: {
        for (final entry in elementCounts.entries)
          if (entry.value >= 2) entry.key,
      },
      effects: {
        for (final entry in effectCounts.entries)
          if (entry.value >= 2) entry.key,
      },
      deliveries: {
        for (final entry in deliveryCounts.entries)
          if (entry.value >= 2) entry.key,
      },
    );
  }

  double _weightedItemWeight(ItemDef item, _TagBias tagBias) {
    const tagBiasPerMatch = 0.15;
    const tagBiasMax = 0.35;
    final tagMatches = tagBias.matchCount(item.tags);
    final boost = math.min(tagBiasPerMatch * tagMatches, tagBiasMax);
    return math.max(0.0, item.weight.toDouble() * (1 + boost));
  }

  bool _isItemCapped(ItemDef item) {
    final maxStacks = item.maxStacks;
    if (maxStacks == null) {
      return false;
    }
    return _itemCount(item.id) >= maxStacks;
  }

  void _applyPityRoll(Map<ItemRarity, int> rarityWeights) {
    const pityMultiplier = 2;
    _rarePityChance += (rarityWeights[ItemRarity.rare] ?? 0) * pityMultiplier;
    _epicPityChance += (rarityWeights[ItemRarity.epic] ?? 0) * pityMultiplier;
  }

  void _resetPityForItem(ItemDef item) {
    switch (item.rarity) {
      case ItemRarity.rare:
        _rarePityChance = 0;
        break;
      case ItemRarity.epic:
        _epicPityChance = 0;
        break;
      case ItemRarity.common:
      case ItemRarity.uncommon:
        break;
    }
  }

  int _itemCount(ItemId itemId) => _appliedItemCounts[itemId] ?? 0;

  List<SelectionChoice> _buildWeaponUpgradeCandidates(SkillSystem skillSystem) {
    if (skillSystem.skillIds.isEmpty) {
      return const [];
    }
    final candidates = <SelectionChoice>[];
    for (final skillId in skillSystem.skillIds) {
      final currentTier = _currentWeaponTier(skillId, skillSystem);
      final nextTier = currentTier + 1;
      final upgrade = weaponUpgradeDefsBySkillAndTier[skillId]?[nextTier];
      if (upgrade == null) {
        continue;
      }
      if (_banishedWeaponUpgrades.contains(upgrade.id)) {
        continue;
      }
      if (_appliedWeaponUpgrades.contains(upgrade.id)) {
        continue;
      }
      final skillName = skillDefsById[skillId]?.name ?? skillId.name;
      candidates.add(
        SelectionChoice(
          type: SelectionType.weaponUpgrade,
          title: '$skillName: ${upgrade.name}',
          description: upgrade.summary,
          weaponUpgradeId: upgrade.id,
        ),
      );
    }
    return candidates;
  }

  int _currentWeaponTier(SkillId skillId, SkillSystem skillSystem) {
    if (!skillSystem.hasSkill(skillId)) {
      return 0;
    }
    return math.max(1, _weaponUpgradeTiers[skillId] ?? 1);
  }
}

class _ChoiceBuildResult {
  const _ChoiceBuildResult(this.choices, {this.rarityBoostsApplied = 0});

  final List<SelectionChoice> choices;
  final int rarityBoostsApplied;
}

class _TagBias {
  const _TagBias({
    required this.elements,
    required this.effects,
    required this.deliveries,
  });

  final Set<ElementTag> elements;
  final Set<EffectTag> effects;
  final Set<DeliveryTag> deliveries;

  int matchCount(TagSet tags) {
    var matches = 0;
    for (final tag in tags.elements) {
      if (elements.contains(tag)) {
        matches += 1;
      }
    }
    for (final tag in tags.effects) {
      if (effects.contains(tag)) {
        matches += 1;
      }
    }
    for (final tag in tags.deliveries) {
      if (deliveries.contains(tag)) {
        matches += 1;
      }
    }
    return matches;
  }
}
