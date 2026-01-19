import 'dart:math' as math;

import '../data/ids.dart';
import '../data/item_defs.dart';
import '../data/progression_track_defs.dart';
import '../data/skill_defs.dart';
import '../data/skill_upgrade_defs.dart';
import '../data/stat_defs.dart';
import '../data/weapon_upgrade_defs.dart';
import 'player_state.dart';
import 'skill_system.dart';

enum SelectionType { skill, item, skillUpgrade, weaponUpgrade }

class SelectionChoice {
  const SelectionChoice({
    required this.type,
    required this.title,
    required this.description,
    this.skillId,
    this.itemId,
    this.skillUpgradeId,
    this.weaponUpgradeId,
  });

  final SelectionType type;
  final String title;
  final String description;
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
  final List<SelectionChoice> _choices = [];
  final Set<SkillUpgradeId> _appliedUpgrades = {};
  final Set<String> _appliedWeaponUpgrades = {};
  final List<ItemId> _appliedItems = [];
  final Map<ItemId, int> _appliedItemCounts = {};
  final Set<SkillId> _banishedSkills = {};
  final Set<ItemId> _banishedItems = {};
  final Set<SkillUpgradeId> _banishedSkillUpgrades = {};
  final Set<String> _banishedWeaponUpgrades = {};
  final Map<ProgressionTrackId, int> _pendingLevels = {};
  final Map<SkillId, int> _weaponUpgradeTiers = {};
  int _rerollsRemaining = 0;
  int _rerollsMax = 0;
  int _banishesRemaining = 0;
  int _banishesMax = 0;
  ProgressionTrackId? _activeTrackId;

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
    _rerollsRemaining = 0;
    _rerollsMax = 0;
    _banishesRemaining = 0;
    _banishesMax = 0;
    _activeTrackId = null;
    _syncRerolls(playerState);
    _syncBanishes(playerState);
  }

  void buildChoices({
    required ProgressionTrackId trackId,
    required SelectionPoolId selectionPoolId,
    required PlayerState playerState,
    required SkillSystem skillSystem,
    required int trackLevel,
    Set<MetaUnlockId> unlockedMeta = const {},
  }) {
    if ((_pendingLevels[trackId] ?? 0) <= 0 || _choices.isNotEmpty) {
      return;
    }
    _choices
      ..clear()
      ..addAll(
        _buildChoicesFor(
          playerState,
          skillSystem,
          selectionPoolId,
          trackLevel,
          unlockedMeta,
        ),
      );
    if (_choices.isEmpty) {
      _pendingLevels[trackId] = 0;
      _activeTrackId = null;
    } else {
      _activeTrackId = trackId;
    }
  }

  bool rerollChoices({
    required ProgressionTrackId trackId,
    required SelectionPoolId selectionPoolId,
    required PlayerState playerState,
    required SkillSystem skillSystem,
    required int trackLevel,
    Set<MetaUnlockId> unlockedMeta = const {},
  }) {
    if (_choices.isEmpty ||
        _rerollsRemaining <= 0 ||
        _activeTrackId != trackId) {
      return false;
    }
    _rerollsRemaining -= 1;
    _choices
      ..clear()
      ..addAll(
        _buildChoicesFor(
          playerState,
          skillSystem,
          selectionPoolId,
          trackLevel,
          unlockedMeta,
        ),
      );
    return true;
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
        ),
      );
    if (_choices.isEmpty) {
      _pendingLevels[trackId] = 0;
      _activeTrackId = null;
    }
    return true;
  }

  List<SelectionChoice> _buildChoicesFor(
    PlayerState playerState,
    SkillSystem skillSystem,
    SelectionPoolId selectionPoolId,
    int trackLevel,
    Set<MetaUnlockId> unlockedMeta,
  ) {
    final extraChoices = playerState.stats.value(StatId.choiceCount).round();
    final choiceCount = math.max(1, _baseChoiceCount + extraChoices);
    if (selectionPoolId == SelectionPoolId.itemPool) {
      return _buildItemChoices(choiceCount, trackLevel, unlockedMeta);
    }
    final candidates = _buildCandidates(
      skillSystem,
      selectionPoolId,
      unlockedMeta,
    );
    candidates.shuffle(_random);
    return candidates.take(choiceCount).toList();
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

  List<SelectionChoice> _buildItemChoices(
    int choiceCount,
    int trackLevel,
    Set<MetaUnlockId> unlockedMeta,
  ) {
    final availableByRarity = <ItemRarity, List<ItemDef>>{
      for (final rarity in ItemRarity.values) rarity: <ItemDef>[],
    };
    for (final item in itemDefs) {
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
      availableByRarity[item.rarity]?.add(item);
    }
    if (availableByRarity.values.every((items) => items.isEmpty)) {
      return const [];
    }
    final rarityWeights = _itemRarityWeightsForLevel(trackLevel);
    final choices = <SelectionChoice>[];
    while (choices.length < choiceCount) {
      final rarity = _pickWeightedRarity(availableByRarity, rarityWeights);
      if (rarity == null) {
        break;
      }
      final items = availableByRarity[rarity];
      if (items == null || items.isEmpty) {
        continue;
      }
      final item = _pickWeightedItem(items);
      if (item == null) {
        break;
      }
      items.remove(item);
      choices.add(
        SelectionChoice(
          type: SelectionType.item,
          title: item.name,
          description: item.description,
          itemId: item.id,
        ),
      );
    }
    return choices;
  }

  Map<ItemRarity, int> _itemRarityWeightsForLevel(int level) {
    if (level <= 3) {
      return const {
        ItemRarity.common: 70,
        ItemRarity.uncommon: 25,
        ItemRarity.rare: 5,
        ItemRarity.epic: 0,
      };
    }
    if (level <= 6) {
      return const {
        ItemRarity.common: 55,
        ItemRarity.uncommon: 30,
        ItemRarity.rare: 12,
        ItemRarity.epic: 3,
      };
    }
    if (level <= 10) {
      return const {
        ItemRarity.common: 40,
        ItemRarity.uncommon: 35,
        ItemRarity.rare: 20,
        ItemRarity.epic: 5,
      };
    }
    return const {
      ItemRarity.common: 25,
      ItemRarity.uncommon: 35,
      ItemRarity.rare: 28,
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

  ItemDef? _pickWeightedItem(List<ItemDef> items) {
    var totalWeight = 0;
    for (final item in items) {
      totalWeight += item.weight;
    }
    if (totalWeight <= 0) {
      return null;
    }
    var roll = _random.nextInt(totalWeight);
    for (final item in items) {
      roll -= item.weight;
      if (roll < 0) {
        return item;
      }
    }
    return null;
  }

  bool _isItemCapped(ItemDef item) {
    final maxStacks = item.maxStacks;
    if (maxStacks == null) {
      return false;
    }
    return _itemCount(item.id) >= maxStacks;
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
