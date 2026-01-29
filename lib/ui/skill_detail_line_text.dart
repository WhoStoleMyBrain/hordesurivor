import 'package:flutter/material.dart';

import 'skill_detail_text.dart';

class SkillDetailLineText extends StatelessWidget {
  const SkillDetailLineText({
    super.key,
    required this.line,
    this.style,
    this.showBullet = false,
  });

  final SkillDetailDisplayLine line;
  final TextStyle? style;
  final bool showBullet;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? DefaultTextStyle.of(context).style;
    final actualValue = line.actualValue ?? line.baseValue;
    final actualColor = line.hasChange
        ? (line.isBetter ? Colors.greenAccent : Colors.redAccent)
        : baseStyle.color;
    final labelPrefix = showBullet ? '• ' : '';
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$labelPrefix${line.label}: ', style: baseStyle),
          TextSpan(
            text: actualValue,
            style: baseStyle.copyWith(color: actualColor),
          ),
          TextSpan(
            text: ' (${line.baseValue})',
            style: baseStyle.copyWith(color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

class SkillLevelBonusLineText extends StatelessWidget {
  const SkillLevelBonusLineText({super.key, required this.line, this.style});

  final SkillLevelModifierLine line;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? DefaultTextStyle.of(context).style;
    final color = line.isBetter ? Colors.greenAccent : Colors.redAccent;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${line.label}: ', style: baseStyle),
          TextSpan(
            text: line.deltaValue,
            style: baseStyle.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
