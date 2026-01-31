import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/ids.dart';
import '../data/skill_defs.dart';
import '../data/stat_defs.dart';
import '../game/skill_progression_system.dart';
import 'scripture_card.dart';
import 'skill_detail_line_text.dart';
import 'skill_detail_text.dart';
import 'skill_swap_state.dart';
import 'tag_badge.dart';

class SkillSwapOverlay extends StatelessWidget {
  const SkillSwapOverlay({
    super.key,
    required this.state,
    required this.skillIcons,
    required this.onConfirm,
    required this.onSkip,
    required this.cardBackground,
  });

  static const String overlayKey = 'skill_swap';

  final SkillSwapState state;
  final Map<SkillId, ui.Image?> skillIcons;
  final VoidCallback onConfirm;
  final VoidCallback onSkip;
  final ui.Image? cardBackground;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        if (!state.active) {
          return const SizedBox.shrink();
        }
        final theme = Theme.of(context);
        return Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.72),
                ),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Material(
                    color: const Color(0xFF1B1A17),
                    elevation: 12,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rite of Exchange',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Drag a new skill onto a prepared skill to seal a swap. '
                              'Leaving keeps your current build.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'New skills inherit 75% of the replaced skill’s experience.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white60,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _SkillRow(
                              title: 'Offered Skills',
                              skills: state.offeredSkills,
                              isOffered: true,
                              state: state,
                              skillIcons: skillIcons,
                              statValues: state.statValues,
                              skillLevels: state.skillLevels,
                              cardBackground: cardBackground,
                            ),
                            const SizedBox(height: 20),
                            _SkillRow(
                              title: 'Prepared Skills',
                              skills: state.equippedSkills,
                              isOffered: false,
                              state: state,
                              skillIcons: skillIcons,
                              statValues: state.statValues,
                              skillLevels: state.skillLevels,
                              cardBackground: cardBackground,
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Wrap(
                                spacing: 12,
                                children: [
                                  TextButton(
                                    onPressed: onSkip,
                                    child: const Text('Keep Current Skills'),
                                  ),
                                  FilledButton(
                                    onPressed: state.hasSwap ? onConfirm : null,
                                    child: const Text('Seal the Swap'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({
    required this.title,
    required this.skills,
    required this.isOffered,
    required this.state,
    required this.skillIcons,
    required this.statValues,
    required this.skillLevels,
    required this.cardBackground,
  });

  final String title;
  final List<SkillId> skills;
  final bool isOffered;
  final SkillSwapState state;
  final Map<SkillId, ui.Image?> skillIcons;
  final Map<StatId, double> statValues;
  final Map<SkillId, SkillProgressSnapshot> skillLevels;
  final ui.Image? cardBackground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (var i = 0; i < skills.length; i++)
              _SkillSlot(
                slot: SkillSwapSlot(isOffered: isOffered, index: i),
                skillId: skills[i],
                state: state,
                skillIcons: skillIcons,
                statValues: statValues,
                skillLevels: skillLevels,
                cardBackground: cardBackground,
              ),
          ],
        ),
      ],
    );
  }
}

class _SkillSlot extends StatelessWidget {
  const _SkillSlot({
    required this.slot,
    required this.skillId,
    required this.state,
    required this.skillIcons,
    required this.statValues,
    required this.skillLevels,
    required this.cardBackground,
  });

  final SkillSwapSlot slot;
  final SkillId skillId;
  final SkillSwapState state;
  final Map<SkillId, ui.Image?> skillIcons;
  final Map<StatId, double> statValues;
  final Map<SkillId, SkillProgressSnapshot> skillLevels;
  final ui.Image? cardBackground;

  @override
  Widget build(BuildContext context) {
    final data = _DragSkillData(slot: slot, skillId: skillId);
    return DragTarget<_DragSkillData>(
      onWillAcceptWithDetails: (details) {
        final incoming = details.data;
        return incoming.slot.isOffered != slot.isOffered ||
            incoming.slot.index != slot.index;
      },
      onAcceptWithDetails: (details) {
        state.swapSlots(details.data.slot, slot);
      },
      builder: (context, candidates, _) {
        final isTargeted = candidates.isNotEmpty;
        return LongPressDraggable<_DragSkillData>(
          data: data,
          feedback: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: 240,
              child: SkillSwapCard(
                skillId: skillId,
                iconImage: skillIcons[skillId],
                statValues: statValues,
                skillLevels: skillLevels,
                emphasize: true,
                cardBackground: cardBackground,
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.35,
            child: SkillSwapCard(
              skillId: skillId,
              iconImage: skillIcons[skillId],
              statValues: statValues,
              skillLevels: skillLevels,
              highlight: isTargeted,
              cardBackground: cardBackground,
            ),
          ),
          child: SkillSwapCard(
            skillId: skillId,
            iconImage: skillIcons[skillId],
            statValues: statValues,
            skillLevels: skillLevels,
            highlight: isTargeted,
            cardBackground: cardBackground,
          ),
        );
      },
    );
  }
}

class SkillSwapCard extends StatelessWidget {
  const SkillSwapCard({
    super.key,
    required this.skillId,
    required this.iconImage,
    required this.statValues,
    required this.skillLevels,
    required this.cardBackground,
    this.highlight = false,
    this.emphasize = false,
  });

  final SkillId skillId;
  final ui.Image? iconImage;
  final Map<StatId, double> statValues;
  final Map<SkillId, SkillProgressSnapshot> skillLevels;
  final ui.Image? cardBackground;
  final bool highlight;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final def = skillDefsById[skillId];
    final snapshot =
        skillLevels[skillId] ??
        SkillProgressSnapshot(level: 1, currentXp: 0, xpToNext: 0);
    final details = skillDetailDisplayLinesFor(
      skillId,
      statValues,
      skillLevel: snapshot.level,
    );
    final tags = def?.tags;
    final badges = tags == null
        ? const <TagBadgeData>[]
        : tagBadgesForTags(tags);
    final statusBadges = def == null
        ? const <TagBadgeData>[]
        : statusBadgesForEffects(def.statusEffects);
    final borderColor = highlight
        ? Colors.amberAccent
        : emphasize
        ? Colors.white70
        : Colors.white24;
    final titleColor = scriptureStrongTextColor(cardBackground);
    final bodyColor = scriptureTextColor(cardBackground);
    final mutedColor = scriptureMutedTextColor(cardBackground);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 260),
      child: ScriptureCard(
        backgroundImage: cardBackground,
        borderColor: borderColor,
        showShadow: emphasize,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkillIcon(image: iconImage),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        def?.name ?? skillId.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        def?.description ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: bodyColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Level ${snapshot.level} · ${snapshot.currentXp.toStringAsFixed(0)}'
                        '/${snapshot.xpToNext.toStringAsFixed(0)} XP',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (details.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final line in details)
                SkillDetailLineText(
                  line: line,
                  style: theme.textTheme.bodySmall?.copyWith(color: mutedColor),
                ),
            ],
            if (badges.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final badge in badges) TagBadge(data: badge)],
              ),
            ],
            if (statusBadges.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final badge in statusBadges) TagBadge(data: badge),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SkillIcon extends StatelessWidget {
  const _SkillIcon({required this.image});

  final ui.Image? image;

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.auto_awesome, size: 18, color: Colors.white54),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: RawImage(image: image, width: 36, height: 36),
    );
  }
}

class _DragSkillData {
  const _DragSkillData({required this.slot, required this.skillId});

  final SkillSwapSlot slot;
  final SkillId skillId;
}
