import 'dart:math' as math;

import '../data/ids.dart';
import '../data/item_defs.dart';
import '../data/skill_defs.dart';
import '../data/skill_upgrade_defs.dart';
import '../data/stat_defs.dart';
import 'player_state.dart';
import 'skill_system.dart';

enum SelectionType { skill, item, skillUpgrade }

class SelectionChoice {
  const SelectionChoice({
    required this.type,
    required this.title,
    required this.description,
    this.skillId,
    this.itemId,
    this.skillUpgradeId,
  });

  final SelectionType type;
  final String title;
  final String description;
  final SkillId? skillId;
  final ItemId? itemId;
  final SkillUpgradeId? skillUpgradeId;
}

class LevelUpSystem {
  LevelUpSystem({required math.Random random, int baseChoiceCount = 3})
    : _random = random,
      _baseChoiceCount = baseChoiceCount;

  final math.Random _random;
  final int _baseChoiceCount;
  final List<SelectionChoice> _choices = [];
  final Set<SkillUpgradeId> _appliedUpgrades = {};
  final Set<ItemId> _appliedItems = {};
  int _pendingLevels = 0;

  List<SelectionChoice> get choices => List.unmodifiable(_choices);
  int get pendingLevels => _pendingLevels;
  bool get hasChoices => _choices.isNotEmpty;
  Set<SkillUpgradeId> get appliedUpgrades =>
      Set<SkillUpgradeId>.unmodifiable(_appliedUpgrades);
  Set<ItemId> get appliedItems => Set<ItemId>.unmodifiable(_appliedItems);

  void queueLevels(int levelsGained) {
    if (levelsGained <= 0) {
      return;
    }
    _pendingLevels += levelsGained;
  }

  void reset() {
    _pendingLevels = 0;
    _choices.clear();
    _appliedUpgrades.clear();
    _appliedItems.clear();
  }

  void buildChoices({
    required PlayerState playerState,
    required SkillSystem skillSystem,
  }) {
    if (_pendingLevels <= 0 || _choices.isNotEmpty) {
      return;
    }
    final extraChoices = playerState.stats.value(StatId.choiceCount).round();
    final choiceCount = math.max(1, _baseChoiceCount + extraChoices);
    final candidates = _buildCandidates(skillSystem);
    candidates.shuffle(_random);
    _choices
      ..clear()
      ..addAll(candidates.take(choiceCount));
    if (_choices.isEmpty) {
      _pendingLevels = 0;
    }
  }

  void applyChoice({
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
      case SelectionType.skill:
        final skillId = choice.skillId;
        if (skillId != null) {
          skillSystem.addSkill(skillId);
        }
    }
    _pendingLevels = math.max(0, _pendingLevels - 1);
    _choices.clear();
  }

  List<SelectionChoice> _buildCandidates(SkillSystem skillSystem) {
    final candidates = <SelectionChoice>[
      for (final skill in skillDefs)
        if (!skillSystem.hasSkill(skill.id))
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
            title: '${skillDefsById[upgrade.skillId]?.name}: ${upgrade.name}',
            description: upgrade.summary,
            skillUpgradeId: upgrade.id,
          ),
      for (final item in itemDefs)
        SelectionChoice(
          type: SelectionType.item,
          title: item.name,
          description: item.description,
          itemId: item.id,
        ),
    ];
    return candidates;
  }
}
