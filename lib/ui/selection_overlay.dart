import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/ids.dart';
import '../data/item_defs.dart';
import '../data/skill_defs.dart';
import '../data/skill_upgrade_defs.dart';
import '../data/stat_defs.dart';
import '../data/synergy_defs.dart';
import '../data/tags.dart';
import '../data/weapon_upgrade_defs.dart';
import '../game/level_up_system.dart';
import 'item_rarity_style.dart';
import 'selection_state.dart';
import 'skill_detail_text.dart';
import 'stat_baseline.dart';
import 'stats_screen_state.dart';
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
    required this.skillIcons,
    required this.itemIcons,
    required this.statsState,
  });

  static const String overlayKey = 'selection';

  final SelectionState selectionState;
  final void Function(SelectionChoice choice) onSelected;
  final VoidCallback onReroll;
  final void Function(SelectionChoice choice) onBanish;
  final void Function(SelectionChoice choice) onToggleLock;
  final VoidCallback onSkip;
  final Map<SkillId, ui.Image?> skillIcons;
  final Map<ItemId, ui.Image?> itemIcons;
  final StatsScreenState statsState;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([selectionState, statsState]),
          builder: (context, _) {
            final choices = selectionState.choices;
            if (choices.isEmpty) {
              return const SizedBox.shrink();
            }
            final isShop = selectionState.trackId == ProgressionTrackId.items;
            if (isShop) {
              return _ShopOverlayLayout(
                selectionState: selectionState,
                statsState: statsState,
                onSelected: onSelected,
                onReroll: onReroll,
                onBanish: onBanish,
                onToggleLock: onToggleLock,
                onSkip: onSkip,
                skillIcons: skillIcons,
                itemIcons: itemIcons,
              );
            }
            const choiceCardWidth = 280.0;
            const choiceListHeight = 260.0;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
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
                          child: SizedBox(
                            height: choiceListHeight,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: choices.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final choice = choices[index];
                                final isPlaceholder =
                                    choice.type == SelectionType.item &&
                                    choice.itemId == null;
                                return SizedBox(
                                  width: choiceCardWidth,
                                  child: _ChoiceCard(
                                    choice: choice,
                                    iconImage: _iconForChoice(
                                      choice,
                                      skillIcons,
                                      itemIcons,
                                    ),
                                    statValues: statsState.statValues,
                                    onPressed: isPlaceholder
                                        ? null
                                        : () => onSelected(choice),
                                    banishesRemaining:
                                        selectionState.banishesRemaining,
                                    goldAvailable: selectionState.goldAvailable,
                                    price: selectionState.priceForChoice(
                                      choice,
                                    ),
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
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        if (selectionState.skipEnabled) ...[
                          const SizedBox(height: 12),
                          _SkipButton(
                            label: selectionState.skipRewardLabel,
                            onPressed: onSkip,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ShopOverlayLayout extends StatelessWidget {
  const _ShopOverlayLayout({
    required this.selectionState,
    required this.statsState,
    required this.onSelected,
    required this.onReroll,
    required this.onBanish,
    required this.onToggleLock,
    required this.onSkip,
    required this.skillIcons,
    required this.itemIcons,
  });

  final SelectionState selectionState;
  final StatsScreenState statsState;
  final void Function(SelectionChoice choice) onSelected;
  final VoidCallback onReroll;
  final void Function(SelectionChoice choice) onBanish;
  final void Function(SelectionChoice choice) onToggleLock;
  final VoidCallback onSkip;
  final Map<SkillId, ui.Image?> skillIcons;
  final Map<ItemId, ui.Image?> itemIcons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final choices = selectionState.choices;
    return Container(
      color: Colors.black.withValues(alpha: 0.88),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Sanctum Shop',
                        style: TextStyle(
                          fontSize: UiScale.fontSize(20),
                          fontWeight: FontWeight.bold,
                          color: Colors.amberAccent,
                        ),
                      ),
                    ),
                    if (selectionState.shopLevel > 0)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _ShopBadge(
                          label: 'Tier ${selectionState.shopLevel}',
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(
                        'Gold: ${selectionState.goldAvailable}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.amberAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _RerollButton(
                      remaining: selectionState.rerollsRemaining,
                      cost: selectionState.rerollCost,
                      goldAvailable: selectionState.goldAvailable,
                      isShop: true,
                      freeRerolls: selectionState.shopFreeRerolls,
                      onPressed:
                          selectionState.shopFreeRerolls > 0 ||
                              selectionState.goldAvailable >=
                                  selectionState.rerollCost
                          ? onReroll
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _ShopBonusRow(selectionState: selectionState),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Rites',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 260,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: choices.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final choice = choices[index];
                              final isPlaceholder =
                                  choice.type == SelectionType.item &&
                                  choice.itemId == null;
                              return SizedBox(
                                width: 280,
                                child: _ChoiceCard(
                                  choice: choice,
                                  iconImage: _iconForChoice(
                                    choice,
                                    skillIcons,
                                    itemIcons,
                                  ),
                                  statValues: statsState.statValues,
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
                                  onToggleLock: !isPlaceholder
                                      ? () => onToggleLock(choice)
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Prepared Skills',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _ShopSkillRow(
                          skills: statsState.skills,
                          skillIcons: skillIcons,
                        ),
                        const SizedBox(height: 12),
                        if (selectionState.skipEnabled)
                          Align(
                            alignment: Alignment.centerRight,
                            child: _SkipButton(
                              label: selectionState.skipRewardLabel,
                              onPressed: onSkip,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(flex: 1, child: _ShopStatsPanel(state: statsState)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: _OwnedItemsBar(
              items: statsState.items,
              itemIcons: itemIcons,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopBadge extends StatelessWidget {
  const _ShopBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2214),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF6A5638)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: const Color(0xFFE9D7A8),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ShopSkillRow extends StatelessWidget {
  const _ShopSkillRow({required this.skills, required this.skillIcons});

  final List<SkillId> skills;
  final Map<SkillId, ui.Image?> skillIcons;

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return Text(
        'No skills prepared yet.',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.white54),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final skillId in skills)
          Tooltip(
            waitDuration: const Duration(milliseconds: 250),
            preferBelow: false,
            decoration: _tooltipDecoration(),
            richMessage: _skillTooltip(skillId),
            child: _MiniIcon(
              image: skillIcons[skillId],
              placeholder: Icons.auto_fix_high,
            ),
          ),
      ],
    );
  }
}

class _OwnedItemsBar extends StatelessWidget {
  const _OwnedItemsBar({required this.items, required this.itemIcons});

  final List<ItemId> items;
  final Map<ItemId, ui.Image?> itemIcons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF120C09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A2B1B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Owned Rites',
            style: theme.textTheme.titleSmall?.copyWith(
              color: const Color(0xFFE9D7A8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Text(
              'No rites claimed yet.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final itemId in items)
                  Tooltip(
                    waitDuration: const Duration(milliseconds: 250),
                    preferBelow: false,
                    decoration: _tooltipDecoration(),
                    richMessage: _itemTooltip(itemId),
                    child: _MiniIcon(
                      image: itemIcons[itemId],
                      placeholder: Icons.local_offer,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MiniIcon extends StatelessWidget {
  const _MiniIcon({required this.image, required this.placeholder});

  final ui.Image? image;
  final IconData placeholder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: image == null
          ? Icon(placeholder, size: 18, color: Colors.white54)
          : Padding(
              padding: const EdgeInsets.all(4),
              child: RawImage(image: image, fit: BoxFit.contain),
            ),
    );
  }
}

class _ShopStatsPanel extends StatelessWidget {
  const _ShopStatsPanel({required this.state});

  final StatsScreenState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 3,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF181210),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3A2B1B)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Run Intel',
              style: theme.textTheme.titleSmall?.copyWith(
                color: const Color(0xFFE9D7A8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: const Color(0xFFE9D7A8),
              labelStyle: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Stats'),
                Tab(text: 'Skills'),
                Tab(text: 'Items'),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                children: [
                  _ShopStatsList(
                    statValues: state.statValues,
                    baselineValues: baselineStatValues(state.activeCharacterId),
                  ),
                  _ShopSkillList(skills: state.skills),
                  _ShopItemList(items: state.items),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopStatsList extends StatelessWidget {
  const _ShopStatsList({
    required this.statValues,
    required this.baselineValues,
  });

  final Map<StatId, double> statValues;
  final Map<StatId, double> baselineValues;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = statValues.entries.toList()
      ..sort(
        (a, b) => StatText.labelFor(a.key).compareTo(StatText.labelFor(b.key)),
      );
    return ListView(
      children: [
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    StatText.labelFor(entry.key),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ),
                Text(
                  StatText.formatStatValue(entry.key, entry.value),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statDeltaColor(
                      value: entry.value,
                      baseline: baselineValues[entry.key] ?? 0,
                      neutral: Colors.white,
                      better: Colors.greenAccent,
                      worse: Colors.redAccent,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ShopSkillList extends StatelessWidget {
  const _ShopSkillList({required this.skills});

  final List<SkillId> skills;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (skills.isEmpty) {
      return Text(
        'No skills equipped yet.',
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
      );
    }
    return ListView.separated(
      itemCount: skills.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final skillId = skills[index];
        final skill = skillDefsById[skillId];
        return Text(
          skill?.name ?? skillId.name,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
        );
      },
    );
  }
}

class _ShopItemList extends StatelessWidget {
  const _ShopItemList({required this.items});

  final List<ItemId> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return Text(
        'No rites claimed yet.',
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
      );
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final itemId = items[index];
        final item = itemDefsById[itemId];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item?.name ?? itemId.name,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            if (item != null)
              Text(
                item.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
              ),
          ],
        );
      },
    );
  }
}

BoxDecoration _tooltipDecoration() {
  return BoxDecoration(
    color: Colors.black.withValues(alpha: 0.9),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.white24),
  );
}

TextSpan _skillTooltip(SkillId skillId) {
  final skill = skillDefsById[skillId];
  final lines = <String>[];
  if (skill != null) {
    lines.add(skill.description);
  }
  lines.addAll(skillDetailTextLinesFor(skillId));
  return TextSpan(
    children: [
      TextSpan(
        text: skill?.name ?? skillId.name,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: UiScale.fontSize(12),
        ),
      ),
      if (lines.isNotEmpty)
        TextSpan(
          text: '\n${lines.join('\n')}',
          style: TextStyle(
            color: Colors.white70,
            fontSize: UiScale.fontSize(11),
          ),
        ),
    ],
  );
}

TextSpan _itemTooltip(ItemId itemId) {
  final item = itemDefsById[itemId];
  final modifierLines = item == null
      ? const <String>[]
      : [
          for (final modifier in item.modifiers)
            StatText.formatModifier(modifier),
        ];
  return TextSpan(
    children: [
      TextSpan(
        text: item?.name ?? itemId.name,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: UiScale.fontSize(12),
        ),
      ),
      if (item != null)
        TextSpan(
          text: '\n${item.description}',
          style: TextStyle(
            color: Colors.white70,
            fontSize: UiScale.fontSize(11),
          ),
        ),
      if (modifierLines.isNotEmpty)
        TextSpan(
          text: '\n${modifierLines.join('\n')}',
          style: TextStyle(
            color: Colors.white60,
            fontSize: UiScale.fontSize(11),
          ),
        ),
    ],
  );
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
    required this.iconImage,
    required this.statValues,
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
  final ui.Image? iconImage;
  final Map<StatId, double> statValues;
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
    final skillDetails = _skillDetailsForChoice(choice, statValues);
    final synergies = _synergyHintsForTags(tags);
    final canAfford = price == null || goldAvailable >= price!;
    final priceLabel = price == null ? null : '${price}g';
    final rarity = _rarityForChoice(choice);
    final rarityLabel = rarity == null ? null : itemRarityLabel(rarity);
    final rarityColor = rarity == null ? null : itemRarityColor(rarity);
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(12),
        side: BorderSide(
          color: (rarityColor ?? Colors.white24).withValues(alpha: 0.55),
        ),
        foregroundColor: Colors.white,
      ),
      onPressed: canAfford ? onPressed : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ChoiceIcon(image: iconImage, isPlaceholder: isPlaceholder),
              const SizedBox(width: 10),
              Expanded(
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
                            child: Icon(
                              Icons.lock,
                              size: 14,
                              color: Colors.amberAccent,
                            ),
                          ),
                        if (priceLabel != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Text(
                              priceLabel,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: canAfford
                                    ? Colors.amberAccent
                                    : Colors.redAccent,
                              ),
                            ),
                          ),
                        if (rarityLabel != null && rarityColor != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Text(
                              rarityLabel,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: rarityColor.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
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
                    if (choice.flavorText.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        choice.flavorText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
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
          if (skillDetails.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final line in skillDetails)
              _SkillDetailLineText(
                line: line,
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

class _SkillDetailLineText extends StatelessWidget {
  const _SkillDetailLineText({required this.line, this.style});

  final SkillDetailDisplayLine line;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? DefaultTextStyle.of(context).style;
    if (!line.hasChange) {
      return Text('${line.label}: ${line.baseValue}', style: baseStyle);
    }
    final actualColor = line.isBetter ? Colors.greenAccent : Colors.redAccent;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${line.label}: ', style: baseStyle),
          TextSpan(
            text: line.actualValue,
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

class _ChoiceIcon extends StatelessWidget {
  const _ChoiceIcon({required this.image, required this.isPlaceholder});

  final ui.Image? image;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    final tint = isPlaceholder ? Colors.white24 : Colors.white54;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: image == null
          ? Icon(Icons.image_not_supported, size: 16, color: tint)
          : Padding(
              padding: const EdgeInsets.all(4),
              child: RawImage(image: image, fit: BoxFit.contain),
            ),
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

ItemRarity? _rarityForChoice(SelectionChoice choice) {
  if (choice.type != SelectionType.item) {
    return null;
  }
  final itemId = choice.itemId;
  if (itemId == null) {
    return null;
  }
  return itemDefsById[itemId]?.rarity;
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

ui.Image? _iconForChoice(
  SelectionChoice choice,
  Map<SkillId, ui.Image?> skillIcons,
  Map<ItemId, ui.Image?> itemIcons,
) {
  switch (choice.type) {
    case SelectionType.skill:
      final skillId = choice.skillId;
      return skillId != null ? skillIcons[skillId] : null;
    case SelectionType.item:
      final itemId = choice.itemId;
      return itemId != null ? itemIcons[itemId] : null;
    case SelectionType.skillUpgrade:
      final upgradeId = choice.skillUpgradeId;
      if (upgradeId == null) {
        return null;
      }
      final upgrade = skillUpgradeDefsById[upgradeId];
      return upgrade == null ? null : skillIcons[upgrade.skillId];
    case SelectionType.weaponUpgrade:
      final upgradeId = choice.weaponUpgradeId;
      if (upgradeId == null) {
        return null;
      }
      final upgrade = weaponUpgradeDefsById[upgradeId];
      return upgrade == null ? null : skillIcons[upgrade.skillId];
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

List<SkillDetailDisplayLine> _skillDetailsForChoice(
  SelectionChoice choice,
  Map<StatId, double> statValues,
) {
  switch (choice.type) {
    case SelectionType.skill:
      final skillId = choice.skillId;
      if (skillId == null) {
        return const [];
      }
      return skillDetailDisplayLinesFor(skillId, statValues);
    case SelectionType.skillUpgrade:
    case SelectionType.weaponUpgrade:
    case SelectionType.item:
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
