import 'package:flutter/material.dart';

import '../data/ids.dart';
import '../data/item_defs.dart';
import '../data/skill_defs.dart';
import '../data/skill_upgrade_defs.dart';
import '../data/stat_defs.dart';
import '../data/weapon_upgrade_defs.dart';
import 'stat_text.dart';
import 'stats_screen_state.dart';

class RunStatsContent extends StatelessWidget {
  const RunStatsContent({super.key, required this.state});

  final StatsScreenState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rerolls ${state.rerollsRemaining}/${state.rerollsMax}',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 12),
        _SectionHeader(title: 'Stats'),
        const SizedBox(height: 6),
        _StatList(statValues: state.statValues),
        const SizedBox(height: 16),
        _SectionHeader(title: 'Attacks'),
        const SizedBox(height: 6),
        _SubsectionHeader(title: 'Skills'),
        const SizedBox(height: 6),
        _ChipWrap(
          entries: [
            for (final id in state.skills)
              _TooltipEntry(
                label: skillDefsById[id]?.name ?? id.name,
                tooltip: skillDefsById[id]?.description,
              ),
          ],
        ),
        const SizedBox(height: 12),
        _SubsectionHeader(title: 'Upgrades'),
        const SizedBox(height: 6),
        _ChipWrap(
          entries: [
            for (final id in state.upgrades)
              _TooltipEntry(
                label: _upgradeLabel(id),
                tooltip: skillUpgradeDefsById[id]?.summary,
              ),
          ],
        ),
        const SizedBox(height: 12),
        _SubsectionHeader(title: 'Weapon Upgrades'),
        const SizedBox(height: 6),
        _ChipWrap(
          entries: [
            for (final id in state.weaponUpgrades)
              _TooltipEntry(
                label: _weaponUpgradeLabel(id),
                tooltip: weaponUpgradeDefsById[id]?.summary,
              ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionHeader(title: 'Items'),
        const SizedBox(height: 6),
        _ChipWrap(
          entries: [
            for (final id in state.items)
              _TooltipEntry(
                label: itemDefsById[id]?.name ?? id.name,
                tooltip: _itemTooltip(id),
              ),
          ],
        ),
      ],
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

class _SubsectionHeader extends StatelessWidget {
  const _SubsectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: Colors.white70),
    );
  }
}

class _StatList extends StatelessWidget {
  const _StatList({required this.statValues});

  final Map<StatId, double> statValues;

  @override
  Widget build(BuildContext context) {
    final entries = statValues.entries.toList()
      ..sort((a, b) => a.key.index.compareTo(b.key.index));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in entries)
          Text(
            '${StatText.labelFor(entry.key)}: '
            '${StatText.formatStatValue(entry.key, entry.value)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
      ],
    );
  }
}

class _TooltipEntry {
  const _TooltipEntry({required this.label, this.tooltip});

  final String label;
  final String? tooltip;
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({required this.entries});

  final List<_TooltipEntry> entries;

  @override
  Widget build(BuildContext context) {
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
          Tooltip(
            message: entry.tooltip ?? entry.label,
            child: Chip(
              label: Text(entry.label),
              backgroundColor: Colors.white12,
              labelStyle: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white),
            ),
          ),
      ],
    );
  }
}

String _itemTooltip(ItemId id) {
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
