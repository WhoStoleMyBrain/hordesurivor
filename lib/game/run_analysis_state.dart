import '../data/ids.dart';
import 'level_up_system.dart';

class RunAnalysisState {
  double totalDamageDealt = 0;
  double damageTaken = 0;
  final Map<SkillId, double> damageBySkill = {};
  final Map<SkillId, double> skillAcquiredAt = {};
  final Map<SkillId, int> skillOffers = {};
  final Map<SkillId, int> skillPicks = {};
  final Map<ItemId, int> itemOffers = {};
  final Map<ItemId, int> itemPicks = {};
  int totalOffers = 0;
  int deadOffers = 0;
  List<SkillId> activeSkills = const [];

  void reset() {
    totalDamageDealt = 0;
    damageTaken = 0;
    damageBySkill.clear();
    skillAcquiredAt.clear();
    skillOffers.clear();
    skillPicks.clear();
    itemOffers.clear();
    itemPicks.clear();
    totalOffers = 0;
    deadOffers = 0;
    activeSkills = const [];
  }

  void recordEnemyDamage(double amount, {SkillId? sourceSkillId}) {
    if (amount <= 0) {
      return;
    }
    totalDamageDealt += amount;
    if (sourceSkillId != null) {
      damageBySkill[sourceSkillId] =
          (damageBySkill[sourceSkillId] ?? 0) + amount;
    }
  }

  void recordDamageTaken(double amount) {
    if (amount <= 0) {
      return;
    }
    damageTaken += amount;
  }

  void recordOffer(List<SelectionChoice> choices) {
    if (choices.isEmpty) {
      return;
    }
    totalOffers += 1;
    for (final choice in choices) {
      final skillId = choice.skillId;
      if (skillId != null) {
        skillOffers[skillId] = (skillOffers[skillId] ?? 0) + 1;
      }
      final itemId = choice.itemId;
      if (itemId != null) {
        itemOffers[itemId] = (itemOffers[itemId] ?? 0) + 1;
      }
    }
  }

  void recordPick(SelectionChoice choice, {double? timeAlive}) {
    final skillId = choice.skillId;
    if (skillId != null) {
      skillPicks[skillId] = (skillPicks[skillId] ?? 0) + 1;
      if (timeAlive != null) {
        recordSkillAcquired(skillId, timeAlive);
      }
    }
    final itemId = choice.itemId;
    if (itemId != null) {
      itemPicks[itemId] = (itemPicks[itemId] ?? 0) + 1;
    }
  }

  void recordSkillAcquired(SkillId id, double timeAlive) {
    skillAcquiredAt.putIfAbsent(id, () => timeAlive);
  }

  void recordDeadOffer() {
    deadOffers += 1;
  }

  void setActiveSkills(List<SkillId> skills) {
    activeSkills = List<SkillId>.from(skills);
    for (final skillId in activeSkills) {
      skillAcquiredAt.putIfAbsent(skillId, () => 0);
    }
  }
}
