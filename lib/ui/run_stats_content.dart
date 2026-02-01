import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/active_skill_defs.dart';
import '../data/character_defs.dart';
import '../data/ids.dart';
import '../data/item_defs.dart';
import '../data/skill_defs.dart';
import '../data/skill_upgrade_defs.dart';
import '../data/stat_defs.dart';
import '../data/tags.dart';
import '../data/weapon_upgrade_defs.dart';
import '../game/skill_progression_system.dart';
import 'scripture_card.dart';
import 'skill_hover_tooltip.dart';
import 'stat_baseline.dart';
import 'stat_text.dart';
import 'stats_screen_state.dart';

class RunStatsContent extends StatelessWidget {
  const RunStatsContent({
    super.key,
    required this.state,
    required this.skillIcons,
    required this.activeSkillIcons,
    required this.itemIcons,
    required this.cardBackground,
  });

  final StatsScreenState state;
  final Map<SkillId, ui.Image?> skillIcons;
  final Map<ActiveSkillId, ui.Image?> activeSkillIcons;
  final Map<ItemId, ui.Image?> itemIcons;
  final ui.Image? cardBackground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CharacterHeader(
            characterId: state.activeCharacterId,
            sprite: state.activeCharacterSprite,
            rerollsRemaining: state.rerollsRemaining,
            rerollsMax: state.rerollsMax,
          ),
          const SizedBox(height: 12),
          TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: const Color(0xFFE9D7A8),
            labelStyle: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Stats'),
              Tab(text: 'Skills'),
              Tab(text: 'Upgrades'),
              Tab(text: 'Items'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              children: [
                _OverviewTab(state: state),
                _StatsTab(
                  statValues: state.statValues,
                  baselineValues: baselineStatValues(state.activeCharacterId),
                ),
                _SkillsTab(
                  skills: state.skills,
                  skillIcons: skillIcons,
                  activeSkillId: state.activeSkillId,
                  activeSkillIcons: activeSkillIcons,
                  skillLevels: state.skillLevels,
                  statValues: state.statValues,
                  cardBackground: cardBackground,
                ),
                _UpgradesTab(
                  skillUpgrades: state.upgrades,
                  weaponUpgrades: state.weaponUpgrades,
                  cardBackground: cardBackground,
                ),
                _ItemsTab(
                  items: state.items,
                  itemIcons: itemIcons,
                  cardBackground: cardBackground,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterHeader extends StatelessWidget {
  const _CharacterHeader({
    required this.characterId,
    required this.sprite,
    required this.rerollsRemaining,
    required this.rerollsMax,
  });

  final CharacterId characterId;
  final ui.Image? sprite;
  final int rerollsRemaining;
  final int rerollsMax;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final character = characterDefsById[characterId] ?? characterDefs.first;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1410),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6A5638)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF120C09),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF4C3924)),
            ),
            child: sprite == null
                ? const Icon(Icons.person, color: Colors.white54)
                : RawImage(image: sprite),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  character.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFE9D7A8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  character.themeLine,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rerolls $rerollsRemaining/$rerollsMax',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.state});

  final StatsScreenState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      children: [
        _SectionHeader(title: 'Build Snapshot'),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _StatChip(label: 'Skills', value: state.skills.length.toString()),
            _StatChip(
              label: 'Skill Upgrades',
              value: state.upgrades.length.toString(),
            ),
            _StatChip(
              label: 'Weapon Upgrades',
              value: state.weaponUpgrades.length.toString(),
            ),
            _StatChip(label: 'Items', value: state.items.length.toString()),
          ],
        ),
        const SizedBox(height: 12),
        _SectionHeader(title: 'Active Skill'),
        const SizedBox(height: 6),
        Text(
          state.activeSkillId == null
              ? 'No active skill equipped.'
              : (activeSkillDefsById[state.activeSkillId]?.name ??
                    state.activeSkillId!.name),
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
        ),
        const SizedBox(height: 16),
        _SectionHeader(title: 'Build Tags'),
        const SizedBox(height: 6),
        if (state.buildTags.isEmpty)
          Text(
            'No tags yet. Pick skills and rites to shape your rules.',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
          )
        else
          _TagWrap(tags: state.buildTags),
        const SizedBox(height: 16),
        _SectionHeader(title: 'Run Guidance'),
        const SizedBox(height: 6),
        Text(
          'Pause to read every rite and tool. Stack tags with intent for faster clears.',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
        ),
      ],
    );
  }
}

class _StatsTab extends StatelessWidget {
  const _StatsTab({required this.statValues, required this.baselineValues});

  final Map<StatId, double> statValues;
  final Map<StatId, double> baselineValues;

  @override
  Widget build(BuildContext context) {
    final categories = _statCategories();
    return ListView(
      children: [
        for (final category in categories)
          _StatCategoryTile(
            title: category.title,
            stats: category.stats,
            statValues: statValues,
            baselineValues: baselineValues,
            initiallyExpanded: category.initiallyExpanded,
          ),
      ],
    );
  }
}

class _SkillsTab extends StatelessWidget {
  const _SkillsTab({
    required this.skills,
    required this.skillIcons,
    required this.activeSkillId,
    required this.activeSkillIcons,
    required this.skillLevels,
    required this.statValues,
    required this.cardBackground,
  });

  final List<SkillId> skills;
  final Map<SkillId, ui.Image?> skillIcons;
  final ActiveSkillId? activeSkillId;
  final Map<ActiveSkillId, ui.Image?> activeSkillIcons;
  final Map<SkillId, SkillProgressSnapshot> skillLevels;
  final Map<StatId, double> statValues;
  final ui.Image? cardBackground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (skills.isEmpty && activeSkillId == null) {
      return Center(
        child: Text(
          'No skills yet. Seek rites to begin your litany.',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
        ),
      );
    }
    return ListView.separated(
      itemCount: skills.length + (activeSkillId == null ? 0 : 1),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (activeSkillId != null && index == 0) {
          final activeDef = activeSkillDefsById[activeSkillId];
          final tags = activeDef?.tags ?? const TagSet();
          return _InfoCard(
            title: activeDef?.name ?? activeSkillId!.name,
            subtitle: activeDef?.description ?? 'Details unavailable.',
            footer: _tagsLine(tags),
            iconWidget: _IconSlot(
              image: activeSkillIcons[activeSkillId],
              placeholder: Icons.flash_on,
            ),
            placeholder: Icons.flash_on,
            showIconSlot: true,
            cardBackground: cardBackground,
          );
        }
        final skillIndex = activeSkillId == null ? index : index - 1;
        final id = skills[skillIndex];
        final skill = skillDefsById[id];
        final tags = skill?.tags ?? const TagSet();
        return _InfoCard(
          title: skill?.name ?? id.name,
          subtitle: skill?.description ?? 'Details unavailable.',
          footer: _tagsLine(tags),
          iconWidget: SkillHoverTooltip(
            skillId: id,
            skillLevels: skillLevels,
            statValues: statValues,
            cardBackground: cardBackground,
            child: _IconSlot(
              image: skillIcons[id],
              placeholder: Icons.auto_fix_high,
            ),
          ),
          placeholder: Icons.auto_fix_high,
          showIconSlot: true,
          cardBackground: cardBackground,
        );
      },
    );
  }
}

class _UpgradesTab extends StatelessWidget {
  const _UpgradesTab({
    required this.skillUpgrades,
    required this.weaponUpgrades,
    required this.cardBackground,
  });

  final List<SkillUpgradeId> skillUpgrades;
  final List<String> weaponUpgrades;
  final ui.Image? cardBackground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (skillUpgrades.isEmpty && weaponUpgrades.isEmpty) {
      return Center(
        child: Text(
          'No upgrades yet. Grow your rites to unlock more power.',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
        ),
      );
    }
    return ListView(
      children: [
        _SectionHeader(title: 'Skill Upgrades'),
        const SizedBox(height: 6),
        if (skillUpgrades.isEmpty)
          Text(
            'None',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
          )
        else
          ...skillUpgrades.map(
            (id) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _InfoCard(
                title: _upgradeLabel(id),
                subtitle:
                    skillUpgradeDefsById[id]?.summary ?? 'Details unavailable.',
                cardBackground: cardBackground,
              ),
            ),
          ),
        const SizedBox(height: 12),
        _SectionHeader(title: 'Weapon Upgrades'),
        const SizedBox(height: 6),
        if (weaponUpgrades.isEmpty)
          Text(
            'None',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
          )
        else
          ...weaponUpgrades.map(
            (id) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _InfoCard(
                title: _weaponUpgradeLabel(id),
                subtitle:
                    weaponUpgradeDefsById[id]?.summary ??
                    'Details unavailable.',
                cardBackground: cardBackground,
              ),
            ),
          ),
      ],
    );
  }
}

class _ItemsTab extends StatelessWidget {
  const _ItemsTab({
    required this.items,
    required this.itemIcons,
    required this.cardBackground,
  });

  final List<ItemId> items;
  final Map<ItemId, ui.Image?> itemIcons;
  final ui.Image? cardBackground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No rites taken yet. Spend gold to bind new rules.',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
        ),
      );
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final id = items[index];
        final item = itemDefsById[id];
        final tags = item?.tags ?? const TagSet();
        return _InfoCard(
          title: item?.name ?? id.name,
          subtitle: _itemDetails(id),
          footer: _tagsLine(tags),
          icon: itemIcons[id],
          placeholder: Icons.local_offer,
          showIconSlot: true,
          cardBackground: cardBackground,
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _StatCategoryTile extends StatelessWidget {
  const _StatCategoryTile({
    required this.title,
    required this.stats,
    required this.statValues,
    required this.baselineValues,
    required this.initiallyExpanded,
  });

  final String title;
  final List<StatId> stats;
  final Map<StatId, double> statValues;
  final Map<StatId, double> baselineValues;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
        children: [
          for (final stat in stats)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: _StatValueRow(
                statId: stat,
                value: StatText.formatStatValue(stat, statValues[stat] ?? 0),
                valueColor: statDeltaColor(
                  value: statValues[stat] ?? 0,
                  baseline: baselineValues[stat] ?? 0,
                  neutral: Colors.white70,
                  better: Colors.greenAccent,
                  worse: Colors.redAccent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCategory {
  const _StatCategory({
    required this.title,
    required this.stats,
    this.initiallyExpanded = false,
  });

  final String title;
  final List<StatId> stats;
  final bool initiallyExpanded;
}

class _StatValueRow extends StatelessWidget {
  const _StatValueRow({
    required this.statId,
    required this.value,
    required this.valueColor,
  });

  final StatId statId;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: Colors.white70);
    return Tooltip(
      message: StatText.tooltipFor(statId),
      waitDuration: const Duration(milliseconds: 300),
      child: Row(
        children: [
          Expanded(child: Text(StatText.labelFor(statId), style: textStyle)),
          Text(value, style: textStyle?.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}

List<_StatCategory> _statCategories() {
  return [
    _StatCategory(
      title: 'Core',
      stats: [
        StatId.maxHp,
        StatId.maxMana,
        StatId.hpRegen,
        StatId.manaRegen,
        StatId.defense,
        StatId.dodgeChance,
        StatId.shieldMax,
        StatId.shieldRegen,
        StatId.healingReceivedPercent,
      ],
      initiallyExpanded: true,
    ),
    _StatCategory(
      title: 'Damage',
      stats: [
        StatId.damagePercent,
        StatId.flatDamage,
        StatId.critChance,
        StatId.critDamagePercent,
        StatId.attackSpeed,
        StatId.aoeSize,
      ],
      initiallyExpanded: true,
    ),
    _StatCategory(
      title: 'Status & DOT',
      stats: [
        StatId.dotDamagePercent,
        StatId.dotDurationPercent,
        StatId.statusApplyChance,
        StatId.statusPotencyPercent,
        StatId.statusDurationPercent,
      ],
    ),
    _StatCategory(
      title: 'Delivery',
      stats: [
        StatId.meleeDamagePercent,
        StatId.projectileDamagePercent,
        StatId.beamDamagePercent,
        StatId.explosionDamagePercent,
        StatId.auraDamagePercent,
        StatId.groundDamagePercent,
      ],
    ),
    _StatCategory(
      title: 'Elements',
      stats: [
        StatId.elementalDamagePercent,
        StatId.flatElementalDamage,
        StatId.fireDamagePercent,
        StatId.waterDamagePercent,
        StatId.earthDamagePercent,
        StatId.windDamagePercent,
        StatId.poisonDamagePercent,
        StatId.steelDamagePercent,
        StatId.woodDamagePercent,
      ],
    ),
    _StatCategory(
      title: 'Economy & Selection',
      stats: [
        StatId.dropsPercent,
        StatId.pickupRadiusPercent,
        StatId.rerolls,
        StatId.choiceCount,
        StatId.banishes,
        StatId.shopDiscountPercent,
        StatId.shopRerollDiscountPercent,
        StatId.shopLockSlots,
        StatId.shopOfferRarityBias,
        StatId.shopOfferSynergyBias,
      ],
    ),
    _StatCategory(
      title: 'Rites',
      stats: [
        StatId.sanctity,
        StatId.heresy,
        StatId.conviction,
        StatId.incenseDensity,
        StatId.paperwork,
        StatId.absolution,
        StatId.penance,
        StatId.banishmentForce,
        StatId.sigilClarity,
        StatId.holyWaterPressure,
      ],
    ),
    _StatCategory(
      title: 'Curses',
      stats: [
        StatId.curseApplyChance,
        StatId.curseDurationPercent,
        StatId.damageVsCursedPercent,
        StatId.exorcismYieldPercent,
      ],
    ),
    _StatCategory(
      title: 'Comfort',
      stats: [
        StatId.fieldOfView,
        StatId.accuracy,
        StatId.pickupMagnetStrength,
        StatId.threatSense,
      ],
    ),
  ];
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.subtitle,
    this.footer,
    this.icon,
    this.iconWidget,
    this.placeholder,
    this.showIconSlot = false,
    this.cardBackground,
  });

  final String title;
  final String subtitle;
  final String? footer;
  final ui.Image? icon;
  final Widget? iconWidget;
  final IconData? placeholder;
  final bool showIconSlot;
  final ui.Image? cardBackground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleColor = scriptureStrongTextColor(cardBackground);
    final bodyColor = scriptureTextColor(cardBackground);
    final mutedColor = scriptureMutedTextColor(cardBackground);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(color: bodyColor),
        ),
        if (footer != null) ...[
          const SizedBox(height: 6),
          Text(
            footer!,
            style: theme.textTheme.bodySmall?.copyWith(color: mutedColor),
          ),
        ],
      ],
    );
    return ScriptureCard(
      backgroundImage: cardBackground,
      showShadow: false,
      child: showIconSlot
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconWidget ??
                    _IconSlot(
                      image: icon,
                      placeholder: placeholder ?? Icons.image_not_supported,
                    ),
                const SizedBox(width: 12),
                Expanded(child: content),
              ],
            )
          : content,
    );
  }
}

class _IconSlot extends StatelessWidget {
  const _IconSlot({required this.image, required this.placeholder});

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

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF221A14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF4C3924)),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.white70),
      ),
    );
  }
}

class _TagWrap extends StatelessWidget {
  const _TagWrap({required this.tags});

  final TagSet tags;

  @override
  Widget build(BuildContext context) {
    final entries = <String>[
      ...tags.elements.map(_tagLabel),
      ...tags.effects.map(_tagLabel),
      ...tags.deliveries.map(_tagLabel),
    ];
    if (entries.isEmpty) {
      return Text(
        'None',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.white54),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        for (final entry in entries)
          Chip(
            label: Text(entry),
            backgroundColor: Colors.white12,
            labelStyle: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white),
          ),
      ],
    );
  }
}

String _itemDetails(ItemId id) {
  final item = itemDefsById[id];
  if (item == null) {
    return id.name;
  }
  final modifierLines = item.modifiers
      .map((modifier) => StatText.formatModifier(modifier))
      .join('\n');
  if (modifierLines.isEmpty) {
    return item.description;
  }
  return '${item.description}\n$modifierLines';
}

String _upgradeLabel(SkillUpgradeId id) {
  final upgrade = skillUpgradeDefsById[id];
  if (upgrade == null) {
    return id.name;
  }
  final skillName =
      skillDefsById[upgrade.skillId]?.name ?? upgrade.skillId.name;
  return '$skillName: ${upgrade.name}';
}

String _weaponUpgradeLabel(String id) {
  final upgrade = weaponUpgradeDefsById[id];
  if (upgrade == null) {
    return id;
  }
  final skillName =
      skillDefsById[upgrade.skillId]?.name ?? upgrade.skillId.name;
  return '$skillName: ${upgrade.name}';
}

String _tagsLine(TagSet tags) {
  if (tags.isEmpty) {
    return 'Tags: None';
  }
  final parts = <String>[
    ...tags.elements.map(_tagLabel),
    ...tags.effects.map(_tagLabel),
    ...tags.deliveries.map(_tagLabel),
  ];
  return 'Tags: ${parts.join(', ')}';
}

String _tagLabel(dynamic tag) {
  final name = tag is Enum ? tag.name : tag.toString();
  switch (name) {
    case 'aoe':
      return 'AOE';
    case 'dot':
      return 'DOT';
    default:
      return name
          .replaceAllMapped(
            RegExp(r'([a-z])([A-Z])'),
            (match) => '${match.group(1)} ${match.group(2)}',
          )
          .replaceFirstMapped(
            RegExp(r'^[a-z]'),
            (match) => match.group(0)!.toUpperCase(),
          );
  }
}
