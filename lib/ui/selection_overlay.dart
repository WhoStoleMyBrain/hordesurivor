import 'package:flutter/material.dart';

import '../data/ids.dart';
import '../data/item_defs.dart';
import '../data/skill_defs.dart';
import '../data/skill_upgrade_defs.dart';
import '../data/synergy_defs.dart';
import '../data/tags.dart';
import '../data/weapon_upgrade_defs.dart';
import '../game/level_up_system.dart';
import 'selection_state.dart';
import 'stat_text.dart';
import 'tag_badge.dart';
import 'ui_scale.dart';

class SelectionOverlay extends StatelessWidget {
  const SelectionOverlay({
    super.key,
    required this.selectionState,
    required this.onSelected,
    required this.onReroll,
    required this.onBanish,
    required this.onToggleLock,
    required this.onSkip,
  });

  static const String overlayKey = 'selection';

  final SelectionState selectionState;
  final void Function(SelectionChoice choice) onSelected;
  final VoidCallback onReroll;
  final void Function(SelectionChoice choice) onBanish;
  final void Function(SelectionChoice choice) onToggleLock;
  final VoidCallback onSkip;

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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _headerTitleForTrack(selectionState.trackId),
                              style: TextStyle(
                                fontSize: UiScale.fontSize(18),
                                fontWeight: FontWeight.bold,
                                color: _headerColorForTrack(
                                  selectionState.trackId,
                                ),
                              ),
                            ),
                          ),
                          if (selectionState.trackId ==
                              ProgressionTrackId.items)
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Text(
                                'Gold: ${selectionState.goldAvailable}',
                                style: TextStyle(
                                  fontSize: UiScale.fontSize(13),
                                  color: Colors.amberAccent,
                                ),
                              ),
                            ),
                          _RerollButton(
                            remaining: selectionState.rerollsRemaining,
                            cost: selectionState.rerollCost,
                            goldAvailable: selectionState.goldAvailable,
                            isShop:
                                selectionState.trackId ==
                                ProgressionTrackId.items,
                            freeRerolls: selectionState.shopFreeRerolls,
                            onPressed:
                                (selectionState.trackId ==
                                        ProgressionTrackId.items
                                    ? (selectionState.shopFreeRerolls > 0 ||
                                          selectionState.goldAvailable >=
                                              selectionState.rerollCost)
                                    : selectionState.rerollsRemaining > 0)
                                ? onReroll
                                : null,
                          ),
                        ],
                      ),
                      if (selectionState.trackId ==
                          ProgressionTrackId.items) ...[
                        const SizedBox(height: 8),
                        _ShopBonusRow(selectionState: selectionState),
                      ],
                      const SizedBox(height: 12),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: choices.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final choice = choices[index];
                            final isPlaceholder =
                                choice.type == SelectionType.item &&
                                choice.itemId == null;
                            return _ChoiceCard(
                              choice: choice,
                              onPressed: isPlaceholder
                                  ? null
                                  : () => onSelected(choice),
                              banishesRemaining:
                                  selectionState.banishesRemaining,
                              goldAvailable: selectionState.goldAvailable,
                              price: selectionState.priceForChoice(choice),
                              locked: selectionState.lockedItems.contains(
                                choice.itemId,
                              ),
                              isPlaceholder: isPlaceholder,
                              onBanish:
                                  selectionState.banishesRemaining > 0 &&
                                      !isPlaceholder
                                  ? () => onBanish(choice)
                                  : null,
                              onToggleLock:
                                  selectionState.trackId ==
                                          ProgressionTrackId.items &&
                                      !isPlaceholder
                                  ? () => onToggleLock(choice)
                                  : null,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SkipButton(
                        label: selectionState.skipRewardLabel,
                        onPressed: onSkip,
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

class _RerollButton extends StatelessWidget {
  const _RerollButton({
    required this.remaining,
    required this.onPressed,
    required this.cost,
    required this.goldAvailable,
    required this.isShop,
    required this.freeRerolls,
  });

  final int remaining;
  final VoidCallback? onPressed;
  final int cost;
  final int goldAvailable;
  final bool isShop;
  final int freeRerolls;

  @override
  Widget build(BuildContext context) {
    final canAfford = !isShop || freeRerolls > 0 || goldAvailable >= cost;
    final label = isShop
        ? freeRerolls > 0
              ? 'Reroll - Free x$freeRerolls'
              : 'Reroll - ${cost}g'
        : 'Reroll ($remaining)';
    return TextButton(
      onPressed: canAfford ? onPressed : null,
      child: Text(label),
    );
  }
}

class _ShopBonusRow extends StatelessWidget {
  const _ShopBonusRow({required this.selectionState});

  final SelectionState selectionState;

  @override
  Widget build(BuildContext context) {
    final labels = <String>[];
    if (selectionState.shopFreeRerolls > 0) {
      labels.add('Free rerolls: ${selectionState.shopFreeRerolls}');
    }
    if (selectionState.shopDiscountTokens > 0) {
      labels.add(
        'Discount tokens: ${selectionState.shopDiscountTokens} (-25%)',
      );
    }
    if (selectionState.shopRarityBoostsApplied > 0) {
      labels.add(
        'Rarity boosts: +${selectionState.shopRarityBoostsApplied} tier',
      );
    }
    if (selectionState.shopBonusChoices > 0) {
      labels.add('Bonus slots: +${selectionState.shopBonusChoices}');
    }
    if (labels.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        for (final label in labels)
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.choice,
    required this.onPressed,
    required this.banishesRemaining,
    required this.goldAvailable,
    required this.price,
    required this.locked,
    required this.isPlaceholder,
    this.onBanish,
    this.onToggleLock,
  });

  final SelectionChoice choice;
  final VoidCallback? onPressed;
  final int banishesRemaining;
  final int goldAvailable;
  final int? price;
  final bool locked;
  final bool isPlaceholder;
  final VoidCallback? onBanish;
  final VoidCallback? onToggleLock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tags = _tagsForChoice(choice);
    final badges = tagBadgesForTags(tags);
    final statusEffects = _statusEffectsForChoice(choice);
    final statusBadges = statusBadgesForEffects(statusEffects);
    final statChanges = _statChangesForChoice(choice);
    final synergies = _synergyHintsForTags(tags);
    final canAfford = price == null || goldAvailable >= price!;
    final priceLabel = price == null ? null : '${price}g';
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(12),
        side: const BorderSide(color: Colors.white24),
        foregroundColor: Colors.white,
      ),
      onPressed: canAfford ? onPressed : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  choice.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isPlaceholder ? Colors.white54 : null,
                  ),
                ),
              ),
              if (locked)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.lock, size: 14, color: Colors.amberAccent),
                ),
              if (priceLabel != null)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    priceLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: canAfford ? Colors.amberAccent : Colors.redAccent,
                    ),
                  ),
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
            style: theme.textTheme.bodySmall?.copyWith(
              color: isPlaceholder ? Colors.white38 : Colors.white70,
            ),
          ),
          if (statChanges.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final line in statChanges)
              Text(
                line,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white60,
                ),
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
          if (synergies.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final line in synergies)
              Text(
                line,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
          ],
          if (onBanish != null || onToggleLock != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 8,
                children: [
                  if (onToggleLock != null)
                    TextButton(
                      onPressed: onToggleLock,
                      child: Text(locked ? 'Unlock' : 'Lock'),
                    ),
                  if (onBanish != null)
                    TextButton(
                      onPressed: onBanish,
                      child: Text('Banish ($banishesRemaining)'),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(onPressed: onPressed, child: Text(label)),
    );
  }
}

String _headerTitleForTrack(ProgressionTrackId? trackId) {
  switch (trackId) {
    case ProgressionTrackId.skills:
      return 'Choose a Skill Reward';
    case ProgressionTrackId.items:
      return 'Choose an Item Reward';
    case null:
      return 'Choose a reward';
  }
}

Color _headerColorForTrack(ProgressionTrackId? trackId) {
  switch (trackId) {
    case ProgressionTrackId.skills:
      return Colors.lightBlueAccent;
    case ProgressionTrackId.items:
      return Colors.amberAccent;
    case null:
      return Colors.white;
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
    case SelectionType.weaponUpgrade:
      return 'Weapon Upgrade';
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
    case SelectionType.weaponUpgrade:
      final upgradeId = choice.weaponUpgradeId;
      return upgradeId != null
          ? weaponUpgradeDefsById[upgradeId]?.tags ?? const TagSet()
          : const TagSet();
  }
}

Set<StatusEffectId> _statusEffectsForChoice(SelectionChoice choice) {
  switch (choice.type) {
    case SelectionType.skill:
      final skillId = choice.skillId;
      return skillId != null
          ? skillDefsById[skillId]?.statusEffects ?? const {}
          : const {};
    case SelectionType.item:
    case SelectionType.skillUpgrade:
    case SelectionType.weaponUpgrade:
      return const {};
  }
}

List<String> _statChangesForChoice(SelectionChoice choice) {
  switch (choice.type) {
    case SelectionType.item:
      final itemId = choice.itemId;
      if (itemId == null) {
        return const [];
      }
      final item = itemDefsById[itemId];
      if (item == null) {
        return const [];
      }
      return [
        for (final modifier in item.modifiers)
          StatText.formatModifier(modifier),
      ];
    case SelectionType.skillUpgrade:
      final upgradeId = choice.skillUpgradeId;
      if (upgradeId == null) {
        return const [];
      }
      final upgrade = skillUpgradeDefsById[upgradeId];
      if (upgrade == null) {
        return const [];
      }
      return [
        for (final modifier in upgrade.modifiers)
          StatText.formatModifier(modifier),
      ];
    case SelectionType.weaponUpgrade:
      final upgradeId = choice.weaponUpgradeId;
      if (upgradeId == null) {
        return const [];
      }
      final upgrade = weaponUpgradeDefsById[upgradeId];
      if (upgrade == null) {
        return const [];
      }
      return [
        for (final modifier in upgrade.modifiers)
          StatText.formatModifier(modifier),
      ];
    case SelectionType.skill:
      return const [];
  }
}

List<String> _synergyHintsForTags(TagSet tags) {
  if (tags.isEmpty) {
    return const [];
  }
  final hints = <String>[];
  for (final synergy in synergyDefs) {
    if (synergy.matchesTags(tags)) {
      hints.add('Synergy: ${synergy.selectionHint}');
    }
  }
  return hints;
}
