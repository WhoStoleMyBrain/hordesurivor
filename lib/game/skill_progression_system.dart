import '../data/ids.dart';
import '../data/skill_defs.dart';

class SkillProgressSnapshot {
  const SkillProgressSnapshot({
    required this.level,
    required this.currentXp,
    required this.xpToNext,
  });

  final int level;
  final double currentXp;
  final double xpToNext;

  @override
  bool operator ==(Object other) {
    return other is SkillProgressSnapshot &&
        level == other.level &&
        currentXp == other.currentXp &&
        xpToNext == other.xpToNext;
  }

  @override
  int get hashCode => Object.hash(level, currentXp, xpToNext);
}

class SkillLevelUpEvent {
  const SkillLevelUpEvent({required this.skillId, required this.level});

  final SkillId skillId;
  final int level;
}

class SkillProgressionSystem {
  final Map<SkillId, _SkillProgressState> _states = {};
  final List<SkillLevelUpEvent> _pendingLevelUps = [];

  void reset() {
    _states.clear();
    _pendingLevelUps.clear();
  }

  void syncSkills(List<SkillId> activeSkills) {
    for (final id in activeSkills) {
      _ensureState(id);
    }
  }

  void update(double dt, List<SkillId> activeSkills) {
    _pendingLevelUps.clear();
    for (final id in activeSkills) {
      final def = skillDefsById[id];
      if (def == null) {
        continue;
      }
      final state = _ensureState(id);
      state.tick(dt, def.leveling, (level) {
        _pendingLevelUps.add(SkillLevelUpEvent(skillId: id, level: level));
      });
    }
  }

  void addDamage(SkillId skillId, double amount) {
    if (amount <= 0) {
      return;
    }
    final def = skillDefsById[skillId];
    if (def == null) {
      return;
    }
    final state = _ensureState(skillId);
    state.addDamage(amount, def.leveling, (level) {
      _pendingLevelUps.add(SkillLevelUpEvent(skillId: skillId, level: level));
    });
  }

  void addHealing(SkillId skillId, double amount) {
    if (amount <= 0) {
      return;
    }
    final def = skillDefsById[skillId];
    if (def == null) {
      return;
    }
    final state = _ensureState(skillId);
    state.addHealing(amount, def.leveling, (level) {
      _pendingLevelUps.add(SkillLevelUpEvent(skillId: skillId, level: level));
    });
  }

  void addCast(SkillId skillId) {
    final def = skillDefsById[skillId];
    if (def == null) {
      return;
    }
    final state = _ensureState(skillId);
    state.addCast(def.leveling, (level) {
      _pendingLevelUps.add(SkillLevelUpEvent(skillId: skillId, level: level));
    });
  }

  void addKill(SkillId skillId, {required bool elite, required bool boss}) {
    final def = skillDefsById[skillId];
    if (def == null) {
      return;
    }
    final state = _ensureState(skillId);
    state.addKill(
      def.leveling,
      elite: elite,
      boss: boss,
      onLevelUp: (level) {
        _pendingLevelUps.add(SkillLevelUpEvent(skillId: skillId, level: level));
      },
    );
  }

  double totalXpFor(SkillId skillId) {
    final def = skillDefsById[skillId];
    final state = _states[skillId];
    if (def == null || state == null) {
      return 0;
    }
    var total = 0.0;
    for (var level = 1; level < state.level; level++) {
      total += def.leveling.levelCurve.xpForLevel(level).toDouble();
    }
    total += state.currentXp;
    return total;
  }

  void addDirectXp(SkillId skillId, double amount) {
    if (amount <= 0) {
      return;
    }
    final def = skillDefsById[skillId];
    if (def == null) {
      return;
    }
    final state = _ensureState(skillId);
    state.addRawXp(amount, def.leveling, (level) {
      _pendingLevelUps.add(SkillLevelUpEvent(skillId: skillId, level: level));
    });
  }

  double applySwapTransfer({
    required SkillId fromSkillId,
    required SkillId toSkillId,
    double fraction = 0.75,
  }) {
    if (fraction <= 0) {
      return 0;
    }
    final transferAmount = totalXpFor(fromSkillId) * fraction;
    if (transferAmount <= 0) {
      return 0;
    }
    addDirectXp(toSkillId, transferAmount);
    return transferAmount;
  }

  List<SkillLevelUpEvent> consumeLevelUps() {
    if (_pendingLevelUps.isEmpty) {
      return const [];
    }
    final output = List<SkillLevelUpEvent>.from(_pendingLevelUps);
    _pendingLevelUps.clear();
    return output;
  }

  Map<SkillId, SkillProgressSnapshot> buildSnapshots() {
    return {
      for (final entry in _states.entries) entry.key: entry.value.snapshot(),
    };
  }

  _SkillProgressState _ensureState(SkillId id) {
    return _states.putIfAbsent(id, () => _SkillProgressState(level: 1));
  }
}

class _SkillProgressState {
  _SkillProgressState({required this.level}) : currentXp = 0, xpToNext = 0;

  int level;
  double currentXp;
  double xpToNext;

  double _damageCapRemainingSecond = 0;
  double _damageCapRemainingFive = 0;
  double _damageCapTimerSecond = 0;
  double _damageCapTimerFive = 0;

  double _healCapRemainingSecond = 0;
  double _healCapRemainingFive = 0;
  double _healCapTimerSecond = 0;
  double _healCapTimerFive = 0;

  double _castCapRemainingFive = 0;
  double _castCapTimerFive = 0;

  void tick(
    double dt,
    SkillLevelingDef leveling,
    void Function(int) onLevelUp,
  ) {
    _resetCaps(dt, leveling);
    final timeXp = leveling.timeXpPerSecond * dt;
    if (timeXp > 0) {
      _addXp(timeXp, leveling, onLevelUp);
    }
  }

  void addDamage(
    double amount,
    SkillLevelingDef leveling,
    void Function(int) onLevelUp,
  ) {
    final baseXp = amount * leveling.damageXpPerPoint;
    if (baseXp <= 0) {
      return;
    }
    final allowed = _applyCaps(
      baseXp,
      leveling.damageXpCapPerSecond,
      leveling.damageXpCapPerFiveSeconds,
      capSecondRemaining: () => _damageCapRemainingSecond,
      capSecondConsume: (value) => _damageCapRemainingSecond = value,
      capFiveRemaining: () => _damageCapRemainingFive,
      capFiveConsume: (value) => _damageCapRemainingFive = value,
    );
    if (allowed > 0) {
      _addXp(allowed, leveling, onLevelUp);
    }
  }

  void addHealing(
    double amount,
    SkillLevelingDef leveling,
    void Function(int) onLevelUp,
  ) {
    final baseXp = amount * leveling.healXpPerPoint;
    if (baseXp <= 0) {
      return;
    }
    final allowed = _applyCaps(
      baseXp,
      leveling.healXpCapPerSecond,
      leveling.healXpCapPerFiveSeconds,
      capSecondRemaining: () => _healCapRemainingSecond,
      capSecondConsume: (value) => _healCapRemainingSecond = value,
      capFiveRemaining: () => _healCapRemainingFive,
      capFiveConsume: (value) => _healCapRemainingFive = value,
    );
    if (allowed > 0) {
      _addXp(allowed, leveling, onLevelUp);
    }
  }

  void addCast(SkillLevelingDef leveling, void Function(int) onLevelUp) {
    if (leveling.castXp <= 0) {
      return;
    }
    var allowed = leveling.castXp;
    if (leveling.castXpCapPerFiveSeconds > 0) {
      if (_castCapRemainingFive <= 0) {
        return;
      }
      allowed = allowed.clamp(0, _castCapRemainingFive);
      _castCapRemainingFive -= allowed;
    }
    if (allowed > 0) {
      _addXp(allowed, leveling, onLevelUp);
    }
  }

  void addKill(
    SkillLevelingDef leveling, {
    required bool elite,
    required bool boss,
    required void Function(int) onLevelUp,
  }) {
    var bonus = leveling.killXp;
    if (elite) {
      bonus += leveling.eliteKillXp;
    }
    if (boss) {
      bonus += leveling.bossKillXp;
    }
    if (bonus <= 0) {
      return;
    }
    _addXp(bonus, leveling, onLevelUp);
  }

  void addRawXp(
    double amount,
    SkillLevelingDef leveling,
    void Function(int) onLevelUp,
  ) {
    _addXp(amount, leveling, onLevelUp);
  }

  SkillProgressSnapshot snapshot() {
    return SkillProgressSnapshot(
      level: level,
      currentXp: currentXp,
      xpToNext: xpToNext,
    );
  }

  void _resetCaps(double dt, SkillLevelingDef leveling) {
    if (leveling.damageXpCapPerSecond > 0) {
      if (_damageCapRemainingSecond <= 0 && _damageCapTimerSecond <= 0) {
        _damageCapRemainingSecond = leveling.damageXpCapPerSecond;
      }
      _damageCapTimerSecond += dt;
      if (_damageCapTimerSecond >= 1) {
        _damageCapTimerSecond -= 1;
        _damageCapRemainingSecond = leveling.damageXpCapPerSecond;
      }
    }
    if (leveling.damageXpCapPerFiveSeconds > 0) {
      if (_damageCapRemainingFive <= 0 && _damageCapTimerFive <= 0) {
        _damageCapRemainingFive = leveling.damageXpCapPerFiveSeconds;
      }
      _damageCapTimerFive += dt;
      if (_damageCapTimerFive >= 5) {
        _damageCapTimerFive -= 5;
        _damageCapRemainingFive = leveling.damageXpCapPerFiveSeconds;
      }
    }
    if (leveling.healXpCapPerSecond > 0) {
      if (_healCapRemainingSecond <= 0 && _healCapTimerSecond <= 0) {
        _healCapRemainingSecond = leveling.healXpCapPerSecond;
      }
      _healCapTimerSecond += dt;
      if (_healCapTimerSecond >= 1) {
        _healCapTimerSecond -= 1;
        _healCapRemainingSecond = leveling.healXpCapPerSecond;
      }
    }
    if (leveling.healXpCapPerFiveSeconds > 0) {
      if (_healCapRemainingFive <= 0 && _healCapTimerFive <= 0) {
        _healCapRemainingFive = leveling.healXpCapPerFiveSeconds;
      }
      _healCapTimerFive += dt;
      if (_healCapTimerFive >= 5) {
        _healCapTimerFive -= 5;
        _healCapRemainingFive = leveling.healXpCapPerFiveSeconds;
      }
    }
    if (leveling.castXpCapPerFiveSeconds > 0) {
      if (_castCapRemainingFive <= 0 && _castCapTimerFive <= 0) {
        _castCapRemainingFive = leveling.castXpCapPerFiveSeconds;
      }
      _castCapTimerFive += dt;
      if (_castCapTimerFive >= 5) {
        _castCapTimerFive -= 5;
        _castCapRemainingFive = leveling.castXpCapPerFiveSeconds;
      }
    }
    if (xpToNext <= 0) {
      xpToNext = leveling.levelCurve.xpForLevel(level).toDouble();
    }
  }

  double _applyCaps(
    double amount,
    double capPerSecond,
    double capPerFiveSeconds, {
    required double Function() capSecondRemaining,
    required void Function(double) capSecondConsume,
    required double Function() capFiveRemaining,
    required void Function(double) capFiveConsume,
  }) {
    var allowed = amount;
    if (capPerSecond > 0) {
      final remaining = capSecondRemaining();
      if (remaining <= 0) {
        return 0;
      }
      allowed = allowed.clamp(0, remaining);
      capSecondConsume(remaining - allowed);
    }
    if (capPerFiveSeconds > 0) {
      final remaining = capFiveRemaining();
      if (remaining <= 0) {
        return 0;
      }
      allowed = allowed.clamp(0, remaining);
      capFiveConsume(remaining - allowed);
    }
    return allowed;
  }

  void _addXp(
    double amount,
    SkillLevelingDef leveling,
    void Function(int) onLevelUp,
  ) {
    if (amount <= 0) {
      return;
    }
    currentXp += amount;
    if (xpToNext <= 0) {
      xpToNext = leveling.levelCurve.xpForLevel(level).toDouble();
    }
    while (currentXp >= xpToNext) {
      currentXp -= xpToNext;
      level += 1;
      xpToNext = leveling.levelCurve.xpForLevel(level).toDouble();
      onLevelUp(level);
    }
  }
}
