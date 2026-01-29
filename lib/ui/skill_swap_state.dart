import 'package:flutter/foundation.dart';

import '../data/ids.dart';
import '../data/stat_defs.dart';
import '../game/skill_progression_system.dart';
import '../game/skill_swap_plan.dart';

class SkillSwapSlot {
  const SkillSwapSlot({required this.isOffered, required this.index});

  final bool isOffered;
  final int index;
}

class SkillSwapState extends ChangeNotifier {
  bool _active = false;
  List<SkillId> _offeredSkills = const [];
  List<SkillId> _equippedSkills = const [];
  Set<SkillId> _originalEquipped = const {};
  Set<SkillId> _offeredSkillIds = const {};
  Map<SkillId, SkillProgressSnapshot> _skillLevels = const {};
  Map<StatId, double> _statValues = const {};

  bool get active => _active;
  List<SkillId> get offeredSkills => _offeredSkills;
  List<SkillId> get equippedSkills => _equippedSkills;
  Map<SkillId, SkillProgressSnapshot> get skillLevels => _skillLevels;
  Map<StatId, double> get statValues => _statValues;
  SkillSwapPlan get plan => buildSkillSwapPlan(
    originalEquipped: _originalEquipped.toList(),
    currentEquipped: _equippedSkills,
    offeredSkillIds: _offeredSkillIds,
  );

  bool get hasSwap => plan.hasSwap;

  void show({
    required List<SkillId> offeredSkills,
    required List<SkillId> equippedSkills,
    required Map<SkillId, SkillProgressSnapshot> skillLevels,
    required Map<StatId, double> statValues,
  }) {
    _active = true;
    _offeredSkills = List<SkillId>.from(offeredSkills);
    _equippedSkills = List<SkillId>.from(equippedSkills);
    _originalEquipped = equippedSkills.toSet();
    _offeredSkillIds = offeredSkills.toSet();
    _skillLevels = Map<SkillId, SkillProgressSnapshot>.from(skillLevels);
    _statValues = Map<StatId, double>.from(statValues);
    notifyListeners();
  }

  void clear() {
    if (!_active &&
        _offeredSkills.isEmpty &&
        _equippedSkills.isEmpty &&
        _originalEquipped.isEmpty &&
        _offeredSkillIds.isEmpty &&
        _skillLevels.isEmpty &&
        _statValues.isEmpty) {
      return;
    }
    _active = false;
    _offeredSkills = const [];
    _equippedSkills = const [];
    _originalEquipped = const {};
    _offeredSkillIds = const {};
    _skillLevels = const {};
    _statValues = const {};
    notifyListeners();
  }

  void swapSlots(SkillSwapSlot from, SkillSwapSlot to) {
    if (!_active) {
      return;
    }
    if (from.isOffered == to.isOffered && from.index == to.index) {
      return;
    }
    final sourceList = from.isOffered ? _offeredSkills : _equippedSkills;
    final targetList = to.isOffered ? _offeredSkills : _equippedSkills;
    if (from.index < 0 ||
        from.index >= sourceList.length ||
        to.index < 0 ||
        to.index >= targetList.length) {
      return;
    }
    if (from.isOffered && !to.isOffered) {
      final existingOfferedIndex = _equippedSkills.indexWhere(
        _offeredSkillIds.contains,
      );
      if (existingOfferedIndex != -1 && existingOfferedIndex != to.index) {
        return;
      }
    }
    final sourceSkill = sourceList[from.index];
    final targetSkill = targetList[to.index];
    sourceList[from.index] = targetSkill;
    targetList[to.index] = sourceSkill;
    notifyListeners();
  }
}
