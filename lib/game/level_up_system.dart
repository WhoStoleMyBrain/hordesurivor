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
  final Set<ItemId> _appliedItems = {};
  final Map<ProgressionTrackId, int> _pendingLevels = {};
  final Map<SkillId, int> _weaponUpgradeTiers = {};
  int _rerollsRemaining = 0;
  int _rerollsMax = 0;
  ProgressionTrackId? _activeTrackId;

  List<SelectionChoice> get choices => List.unmodifiable(_choices);
  int pendingLevels(ProgressionTrackId trackId) => _pendingLevels[trackId] ?? 0;
  ProgressionTrackId? get activeTrackId => _activeTrackId;
  bool get hasChoices => _choices.isNotEmpty;
  int get rerollsRemaining => _rerollsRemaining;
  int get rerollsMax => _rerollsMax;
  Set<SkillUpgradeId> get appliedUpgrades =>
      Set<SkillUpgradeId>.unmodifiable(_appliedUpgrades);
  Set<String> get appliedWeaponUpgrades =>
      Set<String>.unmodifiable(_appliedWeaponUpgrades);
  Set<ItemId> get appliedItems => Set<ItemId>.unmodifiable(_appliedItems);

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
    _weaponUpgradeTiers.clear();
    _rerollsRemaining = 0;
    _rerollsMax = 0;
    _activeTrackId = null;
    _syncRerolls(playerState);
  }

  void buildChoices({
    required ProgressionTrackId trackId,
    required SelectionPoolId selectionPoolId,
    required PlayerState playerState,
    required SkillSystem skillSystem,
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
          if (item != null) {
            _appliedItems.add(item.id);
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
    _pendingLevels[trackId] = math.max(0, (_pendingLevels[trackId] ?? 0) - 1);
    _choices.clear();
    _activeTrackId = null;
  }

  void skipChoice({
    required ProgressionTrackId trackId,
    required PlayerState playerState,
  }) {
    _syncRerolls(playerState);
    _pendingLevels[trackId] = math.max(0, (_pendingLevels[trackId] ?? 0) - 1);
    _choices.clear();
    _activeTrackId = null;
  }

  List<SelectionChoice> _buildChoicesFor(
    PlayerState playerState,
    SkillSystem skillSystem,
    SelectionPoolId selectionPoolId,
    Set<MetaUnlockId> unlockedMeta,
  ) {
    final extraChoices = playerState.stats.value(StatId.choiceCount).round();
    final choiceCount = math.max(1, _baseChoiceCount + extraChoices);
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

  List<SelectionChoice> _buildCandidates(
    SkillSystem skillSystem,
    SelectionPoolId selectionPoolId,
    Set<MetaUnlockId> unlockedMeta,
  ) {
    switch (selectionPoolId) {
      case SelectionPoolId.skillPool:
        return [
          for (final skill in skillDefs)
            if (!skillSystem.hasSkill(skill.id) &&
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
                !_appliedUpgrades.contains(upgrade.id))
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
        return [
          for (final item in itemDefs)
            if (item.metaUnlockId == null ||
                unlockedMeta.contains(item.metaUnlockId))
              SelectionChoice(
                type: SelectionType.item,
                title: item.name,
                description: item.description,
                itemId: item.id,
              ),
        ];
      case SelectionPoolId.futurePool:
        return const [];
    }
  }

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
