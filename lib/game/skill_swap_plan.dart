import '../data/ids.dart';

class SkillSwapPlan {
  const SkillSwapPlan({
    required this.equippedSkills,
    this.incomingSkillId,
    this.outgoingSkillId,
  });

  final List<SkillId> equippedSkills;
  final SkillId? incomingSkillId;
  final SkillId? outgoingSkillId;

  bool get hasSwap => incomingSkillId != null && outgoingSkillId != null;
}

SkillSwapPlan buildSkillSwapPlan({
  required List<SkillId> originalEquipped,
  required List<SkillId> currentEquipped,
  required Set<SkillId> offeredSkillIds,
}) {
  final incoming = currentEquipped.where(offeredSkillIds.contains).toList();
  final outgoing = originalEquipped
      .where((id) => !currentEquipped.contains(id))
      .toList();
  if (incoming.length != 1 || outgoing.length != 1) {
    return SkillSwapPlan(equippedSkills: List<SkillId>.from(currentEquipped));
  }
  return SkillSwapPlan(
    equippedSkills: List<SkillId>.from(currentEquipped),
    incomingSkillId: incoming.first,
    outgoingSkillId: outgoing.first,
  );
}
