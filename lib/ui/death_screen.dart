import 'package:flutter/material.dart';

import '../data/ids.dart';
import '../data/item_defs.dart';
import '../data/skill_defs.dart';
import '../data/skill_upgrade_defs.dart';
import '../data/synergy_defs.dart';
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
    final skillNames = _namesForSkills(summary.skills);
    final itemNames = _namesForItems(summary.items);
    final upgradeNames = _namesForUpgrades(summary.upgrades);
    final synergyEntries = _namesForSynergies(summary.synergyTriggerCounts);
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF161A22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  completed ? 'RUN COMPLETE' : 'YOU DIED',
                  style: TextStyle(
                    fontSize: UiScale.fontSize(22),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                if (summary.areaName != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    summary.areaName!,
                    style: const TextStyle(
                      color: Colors.white70,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
                if (summary.contractHeat > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Heat ${summary.contractHeat} · '
                    'Rewards x${summary.metaRewardMultiplier.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      letterSpacing: 0.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 16),
                _StatRow(label: 'Score', value: summary.score.toString()),
                _StatRow(
                  label: 'Time Alive',
                  value: _formatDuration(summary.timeAlive),
                ),
                _StatRow(
                  label: 'Enemies Defeated',
                  value: summary.enemiesDefeated.toString(),
                ),
                _StatRow(
                  label: 'XP Gained',
                  value: summary.xpGained.toString(),
                ),
                _StatRow(
                  label: 'Meta Shards',
                  value: summary.metaCurrencyEarned.toString(),
                ),
                if (summary.contractNames.isNotEmpty)
                  _StatRow(
                    label: 'Contracts',
                    value: summary.contractNames.join(', '),
                  ),
                _MetaWalletRow(wallet: wallet),
                _StatRow(
                  label: 'Damage Taken',
                  value: summary.damageTaken.toStringAsFixed(0),
                ),
                if (summary.synergyTriggers > 0)
                  _StatRow(
                    label: 'Synergy Triggers',
                    value: summary.synergyTriggers.toString(),
                  ),
                if (skillNames.isNotEmpty ||
                    itemNames.isNotEmpty ||
                    upgradeNames.isNotEmpty ||
                    synergyEntries.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  if (skillNames.isNotEmpty)
                    _RecapSection(title: 'Skills', entries: skillNames),
                  if (itemNames.isNotEmpty)
                    _RecapSection(title: 'Items', entries: itemNames),
                  if (upgradeNames.isNotEmpty)
                    _RecapSection(title: 'Upgrades', entries: upgradeNames),
                  if (synergyEntries.isNotEmpty)
                    _RecapSection(title: 'Synergies', entries: synergyEntries),
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

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, letterSpacing: 0.4),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaWalletRow extends StatelessWidget {
  const _MetaWalletRow({required this.wallet});

  final MetaCurrencyWallet wallet;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: wallet,
      builder: (context, _) {
        return _StatRow(
          label: 'Wallet Total',
          value: wallet.balance.toString(),
        );
      },
    );
  }
}

class _RecapSection extends StatelessWidget {
  const _RecapSection({required this.title, required this.entries});

  final String title;
  final List<String> entries;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
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
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
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
