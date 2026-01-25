import 'package:flutter/foundation.dart';

import 'area_defs.dart';
import 'character_defs.dart';
import 'contract_defs.dart';
import 'currency_defs.dart';
import 'enemy_defs.dart';
import 'ids.dart';
import 'item_defs.dart';
import 'map_background_defs.dart';
import 'meta_unlock_defs.dart';
import 'progression_track_defs.dart';
import 'selection_pool_defs.dart';
import 'skill_defs.dart';
import 'skill_upgrade_defs.dart';
import 'stat_defs.dart';
import 'status_effect_defs.dart';
import 'synergy_defs.dart';
import 'tags.dart';
import 'weapon_upgrade_defs.dart';

typedef DataLogFn = void Function(String message);

class DataValidationResult {
  DataValidationResult({List<String>? errors, List<String>? warnings})
    : errors = errors ?? <String>[],
      warnings = warnings ?? <String>[];

  final List<String> errors;
  final List<String> warnings;

  bool get hasErrors => errors.isNotEmpty;

  void log(DataLogFn logger) {
    for (final warning in warnings) {
      logger('[DataValidation][Warning] $warning');
    }
    for (final error in errors) {
      logger('[DataValidation][Error] $error');
    }
  }
}

DataValidationResult validateGameData() {
  final result = DataValidationResult();
  _checkUniqueIds(
    ids: skillDefs.map((def) => def.id),
    label: 'SkillDef',
    result: result,
  );
  _checkUniqueIds(
    ids: characterDefs.map((def) => def.id),
    label: 'CharacterDef',
    result: result,
  );
  _checkUniqueIds(
    ids: itemDefs.map((def) => def.id),
    label: 'ItemDef',
    result: result,
  );
  _checkUniqueIds(
    ids: enemyDefs.map((def) => def.id),
    label: 'EnemyDef',
    result: result,
  );
  _checkUniqueIds(
    ids: areaDefs.map((def) => def.id),
    label: 'AreaDef',
    result: result,
  );
  _checkUniqueIds(
    ids: mapBackgroundDefs.map((def) => def.id),
    label: 'MapBackgroundDef',
    result: result,
  );
  _checkUniqueIds(
    ids: skillUpgradeDefs.map((def) => def.id),
    label: 'SkillUpgradeDef',
    result: result,
  );
  _checkUniqueIds(
    ids: weaponUpgradeDefs.map((def) => def.id),
    label: 'WeaponUpgradeDef',
    result: result,
  );
  _checkUniqueIds(
    ids: statusEffectDefs.map((def) => def.id),
    label: 'StatusEffectDef',
    result: result,
  );
  _checkUniqueIds(
    ids: metaUnlockDefs.map((def) => def.id),
    label: 'MetaUnlockDef',
    result: result,
  );
  _checkUniqueIds(
    ids: contractDefs.map((def) => def.id),
    label: 'ContractDef',
    result: result,
  );
  _checkUniqueIds(
    ids: currencyDefs.map((def) => def.id),
    label: 'CurrencyDef',
    result: result,
  );
  _checkUniqueIds(
    ids: selectionPoolDefs.map((def) => def.id),
    label: 'SelectionPoolDef',
    result: result,
  );
  _checkUniqueIds(
    ids: progressionTrackDefs.map((def) => def.id),
    label: 'ProgressionTrackDef',
    result: result,
  );
  _checkUniqueIds(
    ids: synergyDefs.map((def) => def.id),
    label: 'SynergyDef',
    result: result,
  );

  for (final def in skillDefs) {
    if (_isTagSetEmpty(def.tags)) {
      result.errors.add('SkillDef ${def.id} has no tags.');
    }
    if (def.weight <= 0) {
      result.errors.add('SkillDef ${def.id} has non-positive weight.');
    }
    for (final status in def.statusEffects) {
      if (!statusEffectDefsById.containsKey(status)) {
        result.errors.add(
          'SkillDef ${def.id} references unknown status effect $status.',
        );
      }
    }
    if (def.metaUnlockId != null &&
        !metaUnlockDefsById.containsKey(def.metaUnlockId)) {
      result.errors.add(
        'SkillDef ${def.id} references missing meta unlock ${def.metaUnlockId}.',
      );
    }
  }

  for (final def in characterDefs) {
    if (!def.baseStats.containsKey(StatId.maxHp)) {
      result.errors.add('CharacterDef ${def.id} missing maxHp base stat.');
    }
    if (!def.baseStats.containsKey(StatId.maxMana)) {
      result.errors.add('CharacterDef ${def.id} missing maxMana base stat.');
    }
    if (def.movement.moveSpeed <= 0) {
      result.errors.add('CharacterDef ${def.id} has non-positive moveSpeed.');
    }
    if (def.startingSkills.length < 5) {
      result.errors.add(
        'CharacterDef ${def.id} must define at least 5 starting skills.',
      );
    }
    for (final skillId in def.startingSkills) {
      if (!skillDefsById.containsKey(skillId)) {
        result.errors.add(
          'CharacterDef ${def.id} references unknown skill $skillId.',
        );
      }
    }
  }

  for (final def in skillUpgradeDefs) {
    if (!skillDefsById.containsKey(def.skillId)) {
      result.errors.add(
        'SkillUpgradeDef ${def.id} skillId ${def.skillId} not found.',
      );
    }
    if (_isTagSetEmpty(def.tags)) {
      result.errors.add('SkillUpgradeDef ${def.id} has no tags.');
    }
    if (def.modifiers.isEmpty) {
      result.errors.add('SkillUpgradeDef ${def.id} has no modifiers.');
    }
    if (def.weight <= 0) {
      result.errors.add('SkillUpgradeDef ${def.id} has non-positive weight.');
    }
  }

  for (final def in weaponUpgradeDefs) {
    if (!skillDefsById.containsKey(def.skillId)) {
      result.errors.add(
        'WeaponUpgradeDef ${def.id} skillId ${def.skillId} not found.',
      );
    }
    if (_isTagSetEmpty(def.tags)) {
      result.errors.add('WeaponUpgradeDef ${def.id} has no tags.');
    }
    if (def.modifiers.isEmpty) {
      result.errors.add('WeaponUpgradeDef ${def.id} has no modifiers.');
    }
    if (def.weight <= 0) {
      result.errors.add('WeaponUpgradeDef ${def.id} has non-positive weight.');
    }
    if (def.tier <= 0) {
      result.errors.add('WeaponUpgradeDef ${def.id} has invalid tier.');
    }
  }

  for (final area in areaDefs) {
    if (!mapBackgroundDefsById.containsKey(area.mapBackgroundId)) {
      result.errors.add(
        'AreaDef ${area.id} references missing map background ${area.mapBackgroundId}.',
      );
    }
  }

  final tiersBySkill = <SkillId, Set<int>>{};
  for (final def in weaponUpgradeDefs) {
    tiersBySkill.putIfAbsent(def.skillId, () => <int>{}).add(def.tier);
  }
  for (final skill in skillDefs) {
    if (skill.iconId.trim().isEmpty) {
      result.errors.add('SkillDef ${skill.id} has an empty iconId.');
    }
    final tiers = tiersBySkill[skill.id];
    if (tiers == null || tiers.isEmpty) {
      result.errors.add('SkillDef ${skill.id} has no weapon upgrade tiers.');
      continue;
    }
    final maxTier = tiers.reduce((value, element) {
      return value > element ? value : element;
    });
    if (maxTier < weaponUpgradeTierCount) {
      result.errors.add(
        'SkillDef ${skill.id} has only $maxTier weapon upgrade tiers.',
      );
    }
    for (var tier = 1; tier <= maxTier; tier++) {
      if (!tiers.contains(tier)) {
        result.errors.add(
          'SkillDef ${skill.id} is missing weapon upgrade tier $tier.',
        );
      }
    }
  }

  for (final def in itemDefs) {
    if (def.modifiers.isEmpty) {
      result.errors.add('ItemDef ${def.id} has no modifiers.');
    }
    if (def.iconId.trim().isEmpty) {
      result.errors.add('ItemDef ${def.id} has an empty iconId.');
    }
    if (def.weight <= 0) {
      result.errors.add('ItemDef ${def.id} has non-positive weight.');
    }
    if (def.maxStacks != null && def.maxStacks! <= 0) {
      result.errors.add('ItemDef ${def.id} has invalid max stacks.');
    }
    if (def.metaUnlockId != null &&
        !metaUnlockDefsById.containsKey(def.metaUnlockId)) {
      result.errors.add(
        'ItemDef ${def.id} references missing meta unlock ${def.metaUnlockId}.',
      );
    }
  }

  for (final def in statusEffectDefs) {
    if (_isTagSetEmpty(def.tags)) {
      result.errors.add('StatusEffectDef ${def.id} has no tags.');
    }
  }

  for (final def in synergyDefs) {
    if (_isTagSetEmpty(def.triggerTags)) {
      result.errors.add('SynergyDef ${def.id} has no trigger tags.');
    }
    if (def.requiredStatusEffects.isEmpty) {
      result.errors.add('SynergyDef ${def.id} has no required status effects.');
    }
  }

  for (final def in metaUnlockDefs) {
    if (def.cost <= 0) {
      result.errors.add('MetaUnlockDef ${def.id} has non-positive cost.');
    }
    if (def.modifiers.isEmpty &&
        def.unlockedSkills.isEmpty &&
        def.unlockedItems.isEmpty &&
        def.unlockedEnemies.isEmpty &&
        def.unlockedContracts.isEmpty) {
      result.errors.add('MetaUnlockDef ${def.id} has no effects.');
    }
    for (final prereq in def.prerequisites) {
      if (!metaUnlockDefsById.containsKey(prereq)) {
        result.errors.add(
          'MetaUnlockDef ${def.id} references missing prerequisite $prereq.',
        );
      }
    }
    for (final skillId in def.unlockedSkills) {
      final skill = skillDefsById[skillId];
      if (skill == null) {
        result.errors.add(
          'MetaUnlockDef ${def.id} unlocks missing skill $skillId.',
        );
      } else if (skill.metaUnlockId != def.id) {
        result.errors.add(
          'MetaUnlockDef ${def.id} unlocks skill $skillId without matching '
          'metaUnlockId.',
        );
      }
    }
    for (final itemId in def.unlockedItems) {
      final item = itemDefsById[itemId];
      if (item == null) {
        result.errors.add(
          'MetaUnlockDef ${def.id} unlocks missing item $itemId.',
        );
      } else if (item.metaUnlockId != def.id) {
        result.errors.add(
          'MetaUnlockDef ${def.id} unlocks item $itemId without matching '
          'metaUnlockId.',
        );
      }
    }
    for (final enemyId in def.unlockedEnemies) {
      final enemy = enemyDefsById[enemyId];
      if (enemy == null) {
        result.errors.add(
          'MetaUnlockDef ${def.id} unlocks missing enemy $enemyId.',
        );
      } else if (enemy.metaUnlockId != def.id) {
        result.errors.add(
          'MetaUnlockDef ${def.id} unlocks enemy $enemyId without matching '
          'metaUnlockId.',
        );
      }
    }
    for (final contractId in def.unlockedContracts) {
      final contract = contractDefsById[contractId];
      if (contract == null) {
        result.errors.add(
          'MetaUnlockDef ${def.id} unlocks missing contract $contractId.',
        );
      } else if (contract.metaUnlockId != def.id) {
        result.errors.add(
          'MetaUnlockDef ${def.id} unlocks contract $contractId without '
          'matching metaUnlockId.',
        );
      }
    }
  }

  for (final def in currencyDefs) {
    if (def.name.trim().isEmpty) {
      result.errors.add('CurrencyDef ${def.id} has an empty name.');
    }
    if (def.iconId.trim().isEmpty) {
      result.errors.add('CurrencyDef ${def.id} has an empty iconId.');
    }
    if (def.colorKey.trim().isEmpty) {
      result.errors.add('CurrencyDef ${def.id} has an empty colorKey.');
    }
    if (def.dropWeight <= 0) {
      result.errors.add('CurrencyDef ${def.id} has non-positive dropWeight.');
    }
  }

  for (final def in selectionPoolDefs) {
    if (def.name.trim().isEmpty) {
      result.errors.add('SelectionPoolDef ${def.id} has an empty name.');
    }
  }

  for (final def in progressionTrackDefs) {
    if (def.name.trim().isEmpty) {
      result.errors.add('ProgressionTrackDef ${def.id} has an empty name.');
    }
    if (!currencyDefsById.containsKey(def.currencyId)) {
      result.errors.add(
        'ProgressionTrackDef ${def.id} references missing currency '
        '${def.currencyId}.',
      );
    }
    if (!selectionPoolDefsById.containsKey(def.selectionPoolId)) {
      result.errors.add(
        'ProgressionTrackDef ${def.id} references missing selection pool '
        '${def.selectionPoolId}.',
      );
    }
    if (def.levelCurve.base <= 0 || def.levelCurve.growth <= 0) {
      result.errors.add(
        'ProgressionTrackDef ${def.id} has invalid level curve values.',
      );
    }
    if (def.skipRewardFraction < 0) {
      result.errors.add(
        'ProgressionTrackDef ${def.id} has negative skipRewardFraction.',
      );
    }
  }

  for (final def in contractDefs) {
    if (def.heat <= 0) {
      result.errors.add('ContractDef ${def.id} has non-positive heat.');
    }
    if (def.rewardMultiplier < 1) {
      result.errors.add('ContractDef ${def.id} has rewardMultiplier below 1.');
    }
    if (def.metaUnlockId != null &&
        !metaUnlockDefsById.containsKey(def.metaUnlockId)) {
      result.errors.add(
        'ContractDef ${def.id} references missing meta unlock '
        '${def.metaUnlockId}.',
      );
    }
  }

  for (final def in enemyDefs) {
    if (def.spriteId != null && def.spriteId!.trim().isEmpty) {
      result.errors.add('EnemyDef ${def.id} has an empty spriteId.');
    }
    if (def.maxHp <= 0) {
      result.errors.add('EnemyDef ${def.id} has non-positive maxHp.');
    }
    if (def.moveSpeed <= 0) {
      result.errors.add('EnemyDef ${def.id} has non-positive moveSpeed.');
    }
    if (def.attackCooldown < 0) {
      result.errors.add('EnemyDef ${def.id} has negative attackCooldown.');
    }
    if (def.attackRange < 0) {
      result.errors.add('EnemyDef ${def.id} has negative attackRange.');
    }
    if (def.projectileSpeed < 0) {
      result.errors.add('EnemyDef ${def.id} has negative projectileSpeed.');
    }
    if (def.projectileDamage < 0) {
      result.errors.add('EnemyDef ${def.id} has negative projectileDamage.');
    }
    if (def.projectileSpread < 0) {
      result.errors.add('EnemyDef ${def.id} has negative projectileSpread.');
    }
    if (def.spawnCooldown < 0) {
      result.errors.add('EnemyDef ${def.id} has negative spawnCooldown.');
    }
    if (def.spawnCount < 0) {
      result.errors.add('EnemyDef ${def.id} has negative spawnCount.');
    }
    if (def.spawnRadius < 0) {
      result.errors.add('EnemyDef ${def.id} has negative spawnRadius.');
    }
    if (def.spawnRewardMultiplier < 0) {
      result.errors.add(
        'EnemyDef ${def.id} has negative spawnRewardMultiplier.',
      );
    }
    if (def.xpReward < 0) {
      result.errors.add('EnemyDef ${def.id} has negative xpReward.');
    }
    if (def.goldCurrencyReward < 0) {
      result.errors.add('EnemyDef ${def.id} has negative goldCurrencyReward.');
    }
    if (def.goldShopXpReward < 0) {
      result.errors.add('EnemyDef ${def.id} has negative goldShopXpReward.');
    }
    if (def.weight <= 0) {
      result.errors.add('EnemyDef ${def.id} has non-positive weight.');
    }
    if (def.metaUnlockId != null &&
        !metaUnlockDefsById.containsKey(def.metaUnlockId)) {
      result.errors.add(
        'EnemyDef ${def.id} references missing meta unlock '
        '${def.metaUnlockId}.',
      );
    }
    if (def.role == EnemyRole.spawner && def.spawnCount > 0) {
      if (def.spawnEnemyId == null) {
        result.warnings.add(
          'EnemyDef ${def.id} is a spawner with no spawnEnemyId.',
        );
      } else if (!enemyDefsById.containsKey(def.spawnEnemyId)) {
        result.errors.add(
          'EnemyDef ${def.id} spawnEnemyId ${def.spawnEnemyId} not found.',
        );
      }
    }
  }

  for (final def in areaDefs) {
    if (def.stageDuration <= 0) {
      result.errors.add('AreaDef ${def.id} has non-positive stageDuration.');
    }
    if (def.recommendedLevel < 0) {
      result.errors.add('AreaDef ${def.id} has negative recommendedLevel.');
    }
    if (def.mapSize.width <= 0 || def.mapSize.height <= 0) {
      result.errors.add('AreaDef ${def.id} has invalid map size.');
    }
    if (def.sections.isEmpty) {
      result.errors.add('AreaDef ${def.id} has no stage sections.');
    }
    if (def.difficultyTiers.isEmpty) {
      result.warnings.add('AreaDef ${def.id} has no difficulty tiers.');
    }
    if (def.enemyThemes.isEmpty) {
      result.warnings.add('AreaDef ${def.id} has no enemy themes.');
    }
    if (def.contractPool.isNotEmpty) {
      final seenContracts = <ContractId>{};
      for (final contract in def.contractPool) {
        if (!contractDefsById.containsKey(contract)) {
          result.errors.add(
            'AreaDef ${def.id} references missing contract $contract.',
          );
          continue;
        }
        if (!seenContracts.add(contract)) {
          result.warnings.add(
            'AreaDef ${def.id} contract pool has duplicate $contract.',
          );
        }
      }
    }

    var lastEnd = 0.0;
    for (var i = 0; i < def.sections.length; i++) {
      final section = def.sections[i];
      if (section.startTime < 0) {
        result.errors.add(
          'AreaDef ${def.id} section $i has negative startTime.',
        );
      }
      if (section.endTime <= section.startTime) {
        result.errors.add('AreaDef ${def.id} section $i has invalid endTime.');
      }
      if (section.startTime < lastEnd) {
        result.errors.add(
          'AreaDef ${def.id} section $i overlaps previous section.',
        );
      } else if (section.startTime > lastEnd) {
        result.warnings.add(
          'AreaDef ${def.id} section $i has a gap before startTime.',
        );
      }
      if (section.endTime > def.stageDuration) {
        result.errors.add(
          'AreaDef ${def.id} section $i exceeds stageDuration.',
        );
      }
      if (section.threatTier <= 0) {
        result.errors.add(
          'AreaDef ${def.id} section $i has invalid threatTier.',
        );
      }
      if (section.eliteChance < 0 || section.eliteChance > 1) {
        result.errors.add(
          'AreaDef ${def.id} section $i has invalid eliteChance.',
        );
      }
      if (section.roleWeights.isEmpty && section.enemyWeights.isEmpty) {
        result.warnings.add(
          'AreaDef ${def.id} section $i has no spawn weights.',
        );
      }
      for (final entry in section.roleWeights.entries) {
        if (entry.value <= 0) {
          result.errors.add(
            'AreaDef ${def.id} section $i has non-positive role weight.',
          );
        }
      }
      for (final entry in section.enemyWeights.entries) {
        if (entry.value <= 0) {
          result.errors.add(
            'AreaDef ${def.id} section $i has non-positive enemy weight.',
          );
        }
        if (!enemyDefsById.containsKey(entry.key)) {
          result.errors.add(
            'AreaDef ${def.id} section $i references missing enemy ${entry.key}.',
          );
        }
      }
      for (final entry in section.variantWeights.entries) {
        if (entry.value <= 0) {
          result.errors.add(
            'AreaDef ${def.id} section $i has non-positive variant weight.',
          );
        }
      }
      lastEnd = section.endTime;
    }
    if (lastEnd < def.stageDuration) {
      result.warnings.add(
        'AreaDef ${def.id} timeline ends before stageDuration.',
      );
    }
  }

  return result;
}

void validateGameDataOrThrow({DataLogFn? logger}) {
  final log = logger ?? debugPrint;
  final result = validateGameData();
  if (result.errors.isEmpty && result.warnings.isEmpty) {
    return;
  }
  result.log(log);
  assert(!result.hasErrors, 'Game data validation failed.');
}

void _checkUniqueIds<T>({
  required Iterable<T> ids,
  required String label,
  required DataValidationResult result,
}) {
  final seen = <T>{};
  for (final id in ids) {
    if (!seen.add(id)) {
      result.errors.add('$label duplicate id: $id.');
    }
  }
}

bool _isTagSetEmpty(TagSet tags) {
  return tags.elements.isEmpty &&
      tags.effects.isEmpty &&
      tags.deliveries.isEmpty;
}
