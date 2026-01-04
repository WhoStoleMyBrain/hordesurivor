import 'package:flutter/material.dart';

import '../data/ids.dart';
import '../data/item_defs.dart';
import '../data/skill_defs.dart';
import '../data/skill_upgrade_defs.dart';
import '../data/stat_defs.dart';
import 'stat_text.dart';
import 'stats_screen_state.dart';
import 'ui_scale.dart';

class StatsOverlay extends StatelessWidget {
  const StatsOverlay({super.key, required this.state, required this.onClose});

  static const String overlayKey = 'stats_overlay';

  final StatsScreenState state;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640, maxHeight: 520),
          child: Card(
            color: Colors.black.withValues(alpha: 0.85),
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AnimatedBuilder(
                animation: state,
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Run Stats',
                              style: TextStyle(
                                fontSize: 18 * UiScale.textScale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: onClose,
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Rerolls ${state.rerollsRemaining}/${state.rerollsMax}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionHeader(title: 'Stats'),
                              const SizedBox(height: 6),
                              _StatList(statValues: state.statValues),
                              const SizedBox(height: 16),
                              _SectionHeader(title: 'Skills'),
                              const SizedBox(height: 6),
                              _ChipWrap(
                                entries: [
                                  for (final id in state.skills)
                                    _TooltipEntry(
                                      label: skillDefsById[id]?.name ?? id.name,
                                      tooltip: skillDefsById[id]?.description,
                                    ),
                                  for (final id in state.upgrades)
                                    _TooltipEntry(
                                      label: _upgradeLabel(id),
                                      tooltip:
                                          skillUpgradeDefsById[id]?.summary,
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
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Press Tab to return',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
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
