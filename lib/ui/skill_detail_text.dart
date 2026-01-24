import 'package:hordesurivor/data/data.dart';

List<SkillDetailLine> skillDetailLinesFor(SkillId id) {
  return skillDefsById[id]?.displayDetails ?? const [];
}

List<String> skillDetailTextLinesFor(SkillId id) {
  return skillDetailLinesFor(
    id,
  ).map((detail) => detail.format()).toList(growable: false);
}

String skillDetailBlockFor(SkillId id) {
  final lines = skillDetailLinesFor(id);
  if (lines.isEmpty) {
    return '';
  }
  return lines.map((detail) => '• ${detail.format()}').join('\n');
}
