import 'package:flutter/material.dart';

import '../data/item_defs.dart';
import '../data/skill_defs.dart';
import '../data/skill_upgrade_defs.dart';
import '../data/tags.dart';
import '../game/level_up_system.dart';
import 'selection_state.dart';
import 'tag_badge.dart';
import 'ui_scale.dart';

class SelectionOverlay extends StatelessWidget {
  const SelectionOverlay({
    super.key,
    required this.selectionState,
    required this.onSelected,
  });

  static const String overlayKey = 'selection';

  final SelectionState selectionState;
  final void Function(SelectionChoice choice) onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: selectionState,
        builder: (context, _) {
          final choices = selectionState.choices;
          if (choices.isEmpty) {
            return const SizedBox.shrink();
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                color: Colors.black.withValues(alpha: 0.8),
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Choose a reward',
                        style: TextStyle(
                          fontSize: 18 * UiScale.textScale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: choices.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final choice = choices[index];
                            return _ChoiceCard(
                              choice: choice,
                              onPressed: () => onSelected(choice),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({required this.choice, required this.onPressed});

  final SelectionChoice choice;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tags = _tagsForChoice(choice);
    final badges = tagBadgesForTags(tags);
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(12),
        side: const BorderSide(color: Colors.white24),
        foregroundColor: Colors.white,
      ),
      onPressed: onPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(choice.title, style: theme.textTheme.titleMedium),
              ),
              Text(
                _labelForChoice(choice.type),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            choice.description,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          if (badges.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final badge in badges) TagBadge(data: badge)],
            ),
          ],
        ],
      ),
    );
  }
}

String _labelForChoice(SelectionType type) {
  switch (type) {
    case SelectionType.skill:
      return 'Skill';
    case SelectionType.item:
      return 'Item';
    case SelectionType.skillUpgrade:
      return 'Upgrade';
  }
}

TagSet _tagsForChoice(SelectionChoice choice) {
  switch (choice.type) {
    case SelectionType.skill:
      final skillId = choice.skillId;
      return skillId != null
          ? skillDefsById[skillId]?.tags ?? const TagSet()
          : const TagSet();
    case SelectionType.item:
      final itemId = choice.itemId;
      return itemId != null
          ? itemDefsById[itemId]?.tags ?? const TagSet()
          : const TagSet();
    case SelectionType.skillUpgrade:
      final upgradeId = choice.skillUpgradeId;
      return upgradeId != null
          ? skillUpgradeDefsById[upgradeId]?.tags ?? const TagSet()
          : const TagSet();
  }
}
