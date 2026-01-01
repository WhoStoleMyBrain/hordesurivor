import 'package:flutter/material.dart';

import '../data/enemy_defs.dart';
import '../data/skill_defs.dart';
import '../data/status_effect_defs.dart';
import '../data/tags.dart';
import 'tag_badge.dart';

class CompendiumScreen extends StatelessWidget {
  const CompendiumScreen({super.key, required this.onClose});

  static const String overlayKey = 'compendium_screen';

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760, maxHeight: 600),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF151A24),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: DefaultTabController(
                length: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Compendium',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onClose,
                          icon: const Icon(Icons.close),
                          tooltip: 'Back',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const TabBar(
                      tabs: [
                        Tab(text: 'Skills'),
                        Tab(text: 'Enemies'),
                        Tab(text: 'Statuses'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _SkillList(skills: skillDefs),
                          _EnemyList(enemies: enemyDefs),
                          _StatusList(statusEffects: statusEffectDefs),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkillList extends StatelessWidget {
  const _SkillList({required this.skills});

  final List<SkillDef> skills;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: skills.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final skill = skills[index];
        final badges = tagBadgesForTags(skill.tags);
        return _CompendiumCard(
          title: skill.name,
          description: skill.description,
          badges: badges,
        );
      },
    );
  }
}

class _EnemyList extends StatelessWidget {
  const _EnemyList({required this.enemies});

  final List<EnemyDef> enemies;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: enemies.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final enemy = enemies[index];
        final badges = [_factionBadge(enemy.faction), _roleBadge(enemy.role)];
        return _CompendiumCard(
          title: enemy.name,
          description: enemy.description,
          badges: badges,
        );
      },
    );
  }
}

class _StatusList extends StatelessWidget {
  const _StatusList({required this.statusEffects});

  final List<StatusEffectDef> statusEffects;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: statusEffects.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final effect = statusEffects[index];
        final badges = tagBadgesForTags(effect.tags);
        return _CompendiumCard(
          title: effect.name,
          description: effect.description,
          badges: badges,
        );
      },
    );
  }
}

class _CompendiumCard extends StatelessWidget {
  const _CompendiumCard({
    required this.title,
    required this.description,
    required this.badges,
  });

  final String title;
  final String description;
  final List<TagBadgeData> badges;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF1C2230),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            if (badges.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final badge in badges) TagBadge(data: badge)],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

TagBadgeData _factionBadge(Faction faction) {
  switch (faction) {
    case Faction.demons:
      return TagBadgeData(
        label: 'Demons',
        icon: Icons.whatshot,
        color: const Color(0xFFE85D75),
      );
    case Faction.angels:
      return TagBadgeData(
        label: 'Angels',
        icon: Icons.star,
        color: const Color(0xFF9AD1FF),
      );
  }
}

TagBadgeData _roleBadge(EnemyRole role) {
  switch (role) {
    case EnemyRole.chaser:
      return TagBadgeData(
        label: 'Chaser',
        icon: Icons.directions_run,
        color: const Color(0xFFBEE3F8),
      );
    case EnemyRole.ranged:
      return TagBadgeData(
        label: 'Ranged',
        icon: Icons.gps_fixed,
        color: const Color(0xFFFFC6A8),
      );
    case EnemyRole.spawner:
      return TagBadgeData(
        label: 'Spawner',
        icon: Icons.hub,
        color: const Color(0xFFB5E48C),
      );
    case EnemyRole.disruptor:
      return TagBadgeData(
        label: 'Disruptor',
        icon: Icons.auto_fix_high,
        color: const Color(0xFFF9C74F),
      );
    case EnemyRole.zoner:
      return TagBadgeData(
        label: 'Zoner',
        icon: Icons.radar,
        color: const Color(0xFFBDB2FF),
      );
    case EnemyRole.elite:
      return TagBadgeData(
        label: 'Elite',
        icon: Icons.shield,
        color: const Color(0xFFFFAFCC),
      );
    case EnemyRole.exploder:
      return TagBadgeData(
        label: 'Exploder',
        icon: Icons.flash_on,
        color: const Color(0xFFFFD166),
      );
    case EnemyRole.supportHealer:
      return TagBadgeData(
        label: 'Support: Heal',
        icon: Icons.healing,
        color: const Color(0xFF80ED99),
      );
    case EnemyRole.supportBuffer:
      return TagBadgeData(
        label: 'Support: Buff',
        icon: Icons.campaign,
        color: const Color(0xFF90DBF4),
      );
    case EnemyRole.pattern:
      return TagBadgeData(
        label: 'Pattern',
        icon: Icons.timeline,
        color: const Color(0xFFA5A5FF),
      );
  }
}
