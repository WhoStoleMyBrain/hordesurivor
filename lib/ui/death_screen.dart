import 'package:flutter/material.dart';

import '../data/ids.dart';
import '../data/item_defs.dart';
import '../data/skill_defs.dart';
import '../data/skill_upgrade_defs.dart';
import '../data/synergy_defs.dart';
import '../data/weapon_upgrade_defs.dart';
import '../game/meta_currency_wallet.dart';
import '../game/run_summary.dart';
import 'ui_scale.dart';

class DeathScreen extends StatelessWidget {
  const DeathScreen({
    super.key,
    required this.summary,
    required this.completed,
    required this.onRestart,
    required this.onReturn,
    required this.wallet,
  });

  static const String overlayKey = 'death';

  final RunSummary summary;
  final bool completed;
  final VoidCallback onRestart;
  final VoidCallback onReturn;
  final MetaCurrencyWallet wallet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final titleStyle = textTheme.titleLarge?.copyWith(
      fontSize: UiScale.fontSize(22),
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    );
    final subtitleStyle = textTheme.bodyMedium?.copyWith(
      color: Colors.white70,
      letterSpacing: 0.6,
    );
    final sectionTitleStyle = textTheme.titleSmall?.copyWith(
      fontSize: UiScale.fontSize(13),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: Colors.white70,
    );
    final statLabelStyle = textTheme.bodySmall?.copyWith(
      fontSize: UiScale.fontSize(12),
      color: Colors.white70,
      letterSpacing: 0.4,
    );
    final statValueStyle = textTheme.bodySmall?.copyWith(
      fontSize: UiScale.fontSize(12),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
    );
    final skillNames = _namesForSkills(summary.skills);
    final itemNames = _namesForItems(summary.items);
    final upgradeNames = _namesForUpgrades(summary.upgrades);
    final weaponUpgradeNames = _namesForWeaponUpgrades(summary.weaponUpgrades);
    final synergyEntries = _namesForSynergies(summary.synergyTriggerCounts);
    final summaryStats = <_StatEntry>[
      _StatEntry(label: 'Score', value: summary.score.toString()),
      _StatEntry(
        label: 'Time Alive',
        value: _formatDuration(summary.timeAlive),
      ),
      _StatEntry(
        label: 'Enemies Defeated',
        value: summary.enemiesDefeated.toString(),
      ),
      _StatEntry(label: 'XP Gained', value: summary.xpGained.toString()),
      _StatEntry(
        label: 'Damage Taken',
        value: summary.damageTaken.toStringAsFixed(0),
      ),
      if (summary.synergyTriggers > 0)
        _StatEntry(
          label: 'Synergy Triggers',
          value: summary.synergyTriggers.toString(),
        ),
    ];
    final rewardStats = <_StatEntry>[
      _StatEntry(
        label: 'Meta Shards',
        value: summary.metaCurrencyEarned.toString(),
      ),
      if (summary.contractNames.isNotEmpty)
        _StatEntry(label: 'Contracts', value: summary.contractNames.join(', ')),
    ];
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      alignment: Alignment.center,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 460,
              maxHeight: constraints.maxHeight * 0.9,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF161A22),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    primary: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          completed ? 'RUN COMPLETE' : 'YOU DIED',
                          style: titleStyle,
                        ),
                        if (summary.areaName != null) ...[
                          const SizedBox(height: 6),
                          Text(summary.areaName!, style: subtitleStyle),
                        ],
                        if (summary.contractHeat > 0) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Heat ${summary.contractHeat} · '
                            'Rewards x${summary.metaRewardMultiplier.toStringAsFixed(2)}',
                            style: subtitleStyle,
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 16),
                        _StatSection(
                          title: 'Run Summary',
                          titleStyle: sectionTitleStyle,
                          entries: summaryStats,
                          labelStyle: statLabelStyle,
                          valueStyle: statValueStyle,
                        ),
                        const SizedBox(height: 12),
                        _StatSection(
                          title: 'Rewards',
                          titleStyle: sectionTitleStyle,
                          entries: rewardStats,
                          labelStyle: statLabelStyle,
                          valueStyle: statValueStyle,
                          footer: _MetaWalletRow(
                            wallet: wallet,
                            labelStyle: statLabelStyle,
                            valueStyle: statValueStyle,
                          ),
                        ),
                        if (skillNames.isNotEmpty ||
                            itemNames.isNotEmpty ||
                            upgradeNames.isNotEmpty ||
                            synergyEntries.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          if (skillNames.isNotEmpty)
                            _RecapSection(
                              title: 'Skills',
                              entries: skillNames,
                              titleStyle: sectionTitleStyle,
                            ),
                          if (itemNames.isNotEmpty)
                            _RecapSection(
                              title: 'Items',
                              entries: itemNames,
                              titleStyle: sectionTitleStyle,
                            ),
                          if (upgradeNames.isNotEmpty)
                            _RecapSection(
                              title: 'Upgrades',
                              entries: upgradeNames,
                              titleStyle: sectionTitleStyle,
                            ),
                          if (weaponUpgradeNames.isNotEmpty)
                            _RecapSection(
                              title: 'Weapon Upgrades',
                              entries: weaponUpgradeNames,
                              titleStyle: sectionTitleStyle,
                            ),
                          if (synergyEntries.isNotEmpty)
                            _RecapSection(
                              title: 'Synergies',
                              entries: synergyEntries,
                              titleStyle: sectionTitleStyle,
                            ),
                        ],
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: onReturn,
                                child: const Text('Return Home'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: onRestart,
                                child: const Text('Restart Run'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(double seconds) {
    final clamped = seconds.clamp(0, 24 * 60 * 60).toInt();
    final minutes = clamped ~/ 60;
    final secs = clamped % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  List<String> _namesForSkills(List<SkillId> ids) {
    if (ids.isEmpty) {
      return const [];
    }
    final idSet = ids.toSet();
    return [
      for (final def in skillDefs)
        if (idSet.contains(def.id)) def.name,
    ];
  }

  List<String> _namesForItems(List<ItemId> ids) {
    if (ids.isEmpty) {
      return const [];
    }
    final idSet = ids.toSet();
    return [
      for (final def in itemDefs)
        if (idSet.contains(def.id)) def.name,
    ];
  }

  List<String> _namesForUpgrades(List<SkillUpgradeId> ids) {
    if (ids.isEmpty) {
      return const [];
    }
    final idSet = ids.toSet();
    return [
      for (final def in skillUpgradeDefs)
        if (idSet.contains(def.id)) def.name,
    ];
  }

  List<String> _namesForWeaponUpgrades(List<String> ids) {
    if (ids.isEmpty) {
      return const [];
    }
    final idSet = ids.toSet();
    return [
      for (final def in weaponUpgradeDefs)
        if (idSet.contains(def.id)) def.name,
    ];
  }

  List<String> _namesForSynergies(Map<SynergyId, int> counts) {
    if (counts.isEmpty) {
      return const [];
    }
    return [
      for (final def in synergyDefs)
        if (counts[def.id] != null)
          '${def.name} ×${counts[def.id]!.toString()}',
    ];
  }
}

class _StatEntry {
  const _StatEntry({required this.label, required this.value});

  final String label;
  final String value;
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(value, style: valueStyle, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _MetaWalletRow extends StatelessWidget {
  const _MetaWalletRow({
    required this.wallet,
    required this.labelStyle,
    required this.valueStyle,
  });

  final MetaCurrencyWallet wallet;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: wallet,
      builder: (context, _) {
        return _StatRow(
          label: 'Wallet Total',
          value: wallet.balance.toString(),
          labelStyle: labelStyle,
          valueStyle: valueStyle,
        );
      },
    );
  }
}

class _RecapSection extends StatelessWidget {
  const _RecapSection({
    required this.title,
    required this.entries,
    required this.titleStyle,
  });

  final String title;
  final List<String> entries;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final entry in entries)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212733),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    entry,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: UiScale.fontSize(12),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatSection extends StatelessWidget {
  const _StatSection({
    required this.title,
    required this.titleStyle,
    required this.entries,
    required this.labelStyle,
    required this.valueStyle,
    this.footer,
  });

  final String title;
  final TextStyle? titleStyle;
  final List<_StatEntry> entries;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF1D2430),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: titleStyle),
            const SizedBox(height: 8),
            for (final entry in entries)
              _StatRow(
                label: entry.label,
                value: entry.value,
                labelStyle: labelStyle,
                valueStyle: valueStyle,
              ),
            if (footer != null) ...[const SizedBox(height: 4), footer!],
          ],
        ),
      ),
    );
  }
}
