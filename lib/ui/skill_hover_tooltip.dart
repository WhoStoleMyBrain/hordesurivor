import 'package:flutter/material.dart';

import '../data/ids.dart';
import '../data/skill_defs.dart';
import '../data/stat_defs.dart';
import '../game/skill_progression_system.dart';
import 'skill_detail_line_text.dart';
import 'skill_detail_text.dart';

class SkillHoverTooltip extends StatefulWidget {
  const SkillHoverTooltip({
    super.key,
    required this.skillId,
    required this.child,
    this.skillLevels = const {},
    this.statValues = const {},
  });

  final SkillId skillId;
  final Widget child;
  final Map<SkillId, SkillProgressSnapshot> skillLevels;
  final Map<StatId, double> statValues;

  @override
  State<SkillHoverTooltip> createState() => _SkillHoverTooltipState();
}

class _SkillHoverTooltipState extends State<SkillHoverTooltip> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;

  @override
  void dispose() {
    _removeEntry();
    super.dispose();
  }

  void _showEntry() {
    if (_entry != null) {
      return;
    }
    _entry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: IgnorePointer(
            child: CompositedTransformFollower(
              link: _link,
              offset: const Offset(0, -8),
              showWhenUnlinked: false,
              child: Material(
                color: Colors.transparent,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: _SkillTooltipCard(
                    skillId: widget.skillId,
                    skillLevels: widget.skillLevels,
                    statValues: widget.statValues,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  void _removeEntry() {
    _entry?.remove();
    _entry = null;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _showEntry(),
      onExit: (_) => _removeEntry(),
      child: CompositedTransformTarget(link: _link, child: widget.child),
    );
  }
}

class _SkillTooltipCard extends StatelessWidget {
  const _SkillTooltipCard({
    required this.skillId,
    required this.skillLevels,
    required this.statValues,
  });

  final SkillId skillId;
  final Map<SkillId, SkillProgressSnapshot> skillLevels;
  final Map<StatId, double> statValues;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final skill = skillDefsById[skillId];
    final snapshot = skillLevels[skillId] ?? _fallbackSnapshot(skill);
    final xpToNext = snapshot.xpToNext <= 0 ? 1 : snapshot.xpToNext;
    final progress = (snapshot.currentXp / xpToNext).clamp(0.0, 1.0);
    final detailLines = skillDetailDisplayLinesFor(skillId, statValues);

    return Container(
      width: 240,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5C4B32), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style:
            theme.textTheme.bodySmall?.copyWith(color: Colors.white70) ??
            const TextStyle(color: Colors.white70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              skill?.name ?? skillId.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFE9D7A8),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Level ${snapshot.level}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.black26,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFBADA55),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${snapshot.currentXp.toStringAsFixed(0)}'
              ' / ${snapshot.xpToNext.toStringAsFixed(0)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white60,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (skill?.description != null) ...[
              const SizedBox(height: 8),
              Text(skill!.description),
            ],
            if (detailLines.isNotEmpty) ...[
              const SizedBox(height: 6),
              for (final line in detailLines)
                SkillDetailLineText(
                  line: line,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white54,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  SkillProgressSnapshot _fallbackSnapshot(SkillDef? skill) {
    final xpToNext = skill?.leveling.levelCurve.xpForLevel(1).toDouble() ?? 60;
    return SkillProgressSnapshot(level: 1, currentXp: 0, xpToNext: xpToNext);
  }
}
