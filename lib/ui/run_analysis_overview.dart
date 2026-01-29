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
    required this.skillAcquiredAt,
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
  final Map<SkillId, double> skillAcquiredAt;
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
    final skillDamageEntries = _skillDamageEntries();
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
        Text('Skill Damage (since acquisition)', style: labelStyle),
        const SizedBox(height: 4),
        if (skillDamageEntries.isEmpty)
          Text('No skill damage yet.', style: labelStyle)
        else ...[
          _SkillDamageHeader(labelStyle: labelStyle),
          const SizedBox(height: 6),
          _SkillDamageList(
            entries: skillDamageEntries,
            labelStyle: labelStyle,
            valueStyle: valueStyle,
          ),
        ],
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

  List<_SkillDamageEntry> _skillDamageEntries() {
    final skills = activeSkills.isNotEmpty
        ? activeSkills
        : damageBySkill.keys.toList();
    final entries = <_SkillDamageEntry>[];
    for (final id in skills) {
      final damage = damageBySkill[id] ?? 0;
      final acquiredAt = skillAcquiredAt[id] ?? 0;
      final timeActive = timeAlive > acquiredAt ? timeAlive - acquiredAt : 0.0;
      final dps = _safeRate(damage, timeActive);
      final name = skillDefsById[id]?.name ?? id.name;
      final percent = totalDamageDealt > 0 ? damage / totalDamageDealt : 0.0;
      entries.add(
        _SkillDamageEntry(
          name: name,
          damage: damage,
          dps: dps,
          percent: percent,
        ),
      );
    }
    entries.sort((a, b) {
      final compareDamage = b.damage.compareTo(a.damage);
      if (compareDamage != 0) {
        return compareDamage;
      }
      return a.name.compareTo(b.name);
    });
    return entries;
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

class _SkillDamageEntry {
  const _SkillDamageEntry({
    required this.name,
    required this.damage,
    required this.dps,
    required this.percent,
  });

  final String name;
  final double damage;
  final double dps;
  final double percent;
}

class _SkillDamageHeader extends StatelessWidget {
  const _SkillDamageHeader({this.labelStyle});

  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final headerStyle = labelStyle?.copyWith(
      color: Colors.white60,
      fontWeight: FontWeight.w600,
    );
    return Row(
      children: [
        Expanded(child: Text('Skill', style: headerStyle)),
        SizedBox(
          width: 72,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text('Total', style: headerStyle),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 64,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text('DPS', style: headerStyle),
          ),
        ),
      ],
    );
  }
}

class _SkillDamageList extends StatelessWidget {
  const _SkillDamageList({
    required this.entries,
    this.labelStyle,
    this.valueStyle,
  });

  final List<_SkillDamageEntry> entries;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _SkillDamageRow(
              entry: entry,
              labelStyle: labelStyle,
              valueStyle: valueStyle,
            ),
          ),
      ],
    );
  }
}

class _SkillDamageRow extends StatelessWidget {
  const _SkillDamageRow({
    required this.entry,
    this.labelStyle,
    this.valueStyle,
  });

  final _SkillDamageEntry entry;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final percent = entry.percent.clamp(0.0, 1.0);
    final damageText = _formatCompact(entry.damage, fractionDigits: 0);
    final dpsText = _formatCompact(entry.dps, fractionDigits: 1);
    final percentText = '${(percent * 100).toStringAsFixed(0)}%';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(entry.name, style: labelStyle)),
            SizedBox(
              width: 72,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(damageText, style: valueStyle),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 64,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(dpsText, style: valueStyle),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: _DamageBar(percent: percent)),
            const SizedBox(width: 8),
            Text(percentText, style: labelStyle),
          ],
        ),
      ],
    );
  }
}

class _DamageBar extends StatelessWidget {
  const _DamageBar({required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    final fillColor = Colors.orangeAccent.withValues(alpha: 0.8);
    final trackColor = Colors.white.withValues(alpha: 0.12);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * percent;
        return Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 6,
              width: width,
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        );
      },
    );
  }
}

String _formatCompact(double value, {int fractionDigits = 1}) {
  if (value >= 1000000) {
    return '${_trimZero((value / 1000000).toStringAsFixed(fractionDigits))}M';
  }
  if (value >= 1000) {
    return '${_trimZero((value / 1000).toStringAsFixed(fractionDigits))}k';
  }
  if (fractionDigits <= 0) {
    return value.toStringAsFixed(0);
  }
  return _trimZero(value.toStringAsFixed(fractionDigits));
}

String _trimZero(String value) {
  return value.replaceAll(RegExp(r'\.0$'), '');
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
