import 'package:flutter/foundation.dart';

import 'enemy_defs.dart';
import 'item_defs.dart';
import 'skill_defs.dart';
import 'tags.dart';

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
    ids: itemDefs.map((def) => def.id),
    label: 'ItemDef',
    result: result,
  );
  _checkUniqueIds(
    ids: enemyDefs.map((def) => def.id),
    label: 'EnemyDef',
    result: result,
  );

  for (final def in skillDefs) {
    if (_isTagSetEmpty(def.tags)) {
      result.errors.add('SkillDef ${def.id} has no tags.');
    }
    if (def.weight <= 0) {
      result.errors.add('SkillDef ${def.id} has non-positive weight.');
    }
  }

  for (final def in itemDefs) {
    if (def.modifiers.isEmpty) {
      result.errors.add('ItemDef ${def.id} has no modifiers.');
    }
    if (def.weight <= 0) {
      result.errors.add('ItemDef ${def.id} has non-positive weight.');
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
    if (def.xpReward < 0) {
      result.errors.add('EnemyDef ${def.id} has negative xpReward.');
    }
    if (def.weight <= 0) {
      result.errors.add('EnemyDef ${def.id} has non-positive weight.');
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
