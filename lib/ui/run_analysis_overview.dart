import 'package:flutter/material.dart';

import '../data/enemy_defs.dart';
import '../data/ids.dart';
import '../data/item_defs.dart';
import '../data/skill_defs.dart';

class RunAnalysisOverview extends StatelessWidget {
  const RunAnalysisOverview({
    super.key,
    required this.timeAlive,
    required this.damageTaken,
    required this.totalDamageDealt,
    required this.damageBySkill,
    required this.activeSkills,
    required this.skillOffers,
    required this.skillPicks,
    required this.itemOffers,
    required this.itemPicks,
    required this.totalOffers,
    required this.deadOffers,
    this.title = 'Run Analysis',
  });

  final double timeAlive;
  final double damageTaken;
  final double totalDamageDealt;
  final Map<SkillId, double> damageBySkill;
  final List<SkillId> activeSkills;
  final Map<SkillId, int> skillOffers;
  final Map<SkillId, int> skillPicks;
  final Map<ItemId, int> itemOffers;
  final Map<ItemId, int> itemPicks;
  final int totalOffers;
  final int deadOffers;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: Colors.white70,
      letterSpacing: 0.3,
    );
    final valueStyle = theme.textTheme.bodySmall?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    );
    final headerStyle = theme.textTheme.titleSmall?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    );
    final dividerColor = Colors.white.withValues(alpha: 0.08);
    final totalDps = _safeRate(totalDamageDealt, timeAlive);
    final damagePerMinute = _safeRate(damageTaken, timeAlive / 60);
    final standardEnemy = enemyDefsById[EnemyId.imp];
    final standardHp = standardEnemy?.maxHp ?? 12;
    final ttkSeconds = totalDps > 0 ? standardHp / totalDps : null;
    final skillDpsEntries = _skillDpsEntries();
    final skillPickEntries = _pickRateEntries(
      skillOffers,
      skillPicks,
      (id) => skillDefsById[id]?.name ?? id.name,
    );
    final itemPickEntries = _pickRateEntries(
      itemOffers,
      itemPicks,
      (id) => itemDefsById[id]?.name ?? id.name,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: headerStyle),
        const SizedBox(height: 8),
        _StatRow(
          label: 'Total DPS',
          value: totalDps > 0 ? totalDps.toStringAsFixed(1) : '—',
          labelStyle: labelStyle,
          valueStyle: valueStyle,
        ),
        const SizedBox(height: 4),
        _StatRow(
          label: 'Damage / min',
          value: damagePerMinute > 0 ? damagePerMinute.toStringAsFixed(1) : '—',
          labelStyle: labelStyle,
          valueStyle: valueStyle,
        ),
        const SizedBox(height: 4),
        _StatRow(
          label:
              'TTK (${standardEnemy?.name ?? 'Imp'} ${standardHp.round()}hp)',
          value: ttkSeconds != null ? '${ttkSeconds.toStringAsFixed(2)}s' : '—',
          labelStyle: labelStyle,
          valueStyle: valueStyle,
        ),
        const SizedBox(height: 8),
        Text('DPS by Skill', style: labelStyle),
        const SizedBox(height: 4),
        if (skillDpsEntries.isEmpty)
          Text('No skill damage yet.', style: labelStyle)
        else
          _EntryList(entries: skillDpsEntries),
        const SizedBox(height: 8),
        Divider(color: dividerColor, height: 1),
        const SizedBox(height: 8),
        Text('Pick Rates (Skills)', style: labelStyle),
        const SizedBox(height: 4),
        if (skillPickEntries.isEmpty)
          Text('No skill offers yet.', style: labelStyle)
        else
          _EntryList(entries: skillPickEntries),
        const SizedBox(height: 8),
        Text('Pick Rates (Items)', style: labelStyle),
        const SizedBox(height: 4),
        if (itemPickEntries.isEmpty)
          Text('No item offers yet.', style: labelStyle)
        else
          _EntryList(entries: itemPickEntries),
        const SizedBox(height: 8),
        Divider(color: dividerColor, height: 1),
        const SizedBox(height: 8),
        _StatRow(
          label: 'Dead offers',
          value: totalOffers > 0
              ? '$deadOffers/$totalOffers '
                    '(${_percent(deadOffers, totalOffers)})'
              : '—',
          labelStyle: labelStyle,
          valueStyle: valueStyle,
        ),
      ],
    );
  }

  double _safeRate(double value, double duration) {
    if (duration <= 0 || value <= 0) {
      return 0;
    }
    return value / duration;
  }

  String _percent(int count, int total) {
    if (total <= 0) {
      return '0%';
    }
    final percent = (count / total) * 100;
    return '${percent.toStringAsFixed(0)}%';
  }

  List<_Entry> _skillDpsEntries() {
    final skills = activeSkills.isNotEmpty
        ? activeSkills
        : damageBySkill.keys.toList();
    final entries = <_Entry>[];
    for (final id in skills) {
      final damage = damageBySkill[id] ?? 0;
      final dps = _safeRate(damage, timeAlive);
      final name = skillDefsById[id]?.name ?? id.name;
      entries.add(
        _Entry(label: name, value: dps > 0 ? dps.toStringAsFixed(1) : '—'),
      );
    }
    entries.sort((a, b) => _sortEntryValue(b, a));
    return entries;
  }

  int _sortEntryValue(_Entry a, _Entry b) {
    final aValue = double.tryParse(a.value.replaceAll(RegExp('[^0-9.]'), ''));
    final bValue = double.tryParse(b.value.replaceAll(RegExp('[^0-9.]'), ''));
    if (aValue == null || bValue == null) {
      return a.label.compareTo(b.label);
    }
    return aValue.compareTo(bValue);
  }

  List<_Entry> _pickRateEntries<T>(
    Map<T, int> offers,
    Map<T, int> picks,
    String Function(T id) nameFor,
  ) {
    final entries = <_Entry>[];
    for (final entry in offers.entries) {
      final offered = entry.value;
      if (offered <= 0) {
        continue;
      }
      final picked = picks[entry.key] ?? 0;
      final rate = _percent(picked, offered);
      entries.add(
        _Entry(label: nameFor(entry.key), value: '$picked/$offered ($rate)'),
      );
    }
    entries.sort((a, b) => a.label.compareTo(b.label));
    return entries;
  }
}

class _Entry {
  const _Entry({required this.label, required this.value});

  final String label;
  final String value;
}

class _EntryList extends StatelessWidget {
  const _EntryList({required this.entries});

  final List<_Entry> entries;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: Colors.white70);
    final valueStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: Colors.white);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: _StatRow(
              label: entry.label,
              value: entry.value,
              labelStyle: labelStyle,
              valueStyle: valueStyle,
            ),
          ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: labelStyle)),
        const SizedBox(width: 8),
        Text(value, style: valueStyle),
      ],
    );
  }
}
