import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/enemy_defs.dart';
import '../data/ids.dart';
import '../data/item_defs.dart';
import '../data/skill_defs.dart';
import '../data/status_effect_defs.dart';
import '../data/tags.dart';
import 'item_rarity_style.dart';
import 'skill_detail_text.dart';
import 'stat_text.dart';
import 'tag_badge.dart';

class CompendiumScreen extends StatelessWidget {
  const CompendiumScreen({
    super.key,
    required this.onClose,
    required this.itemIcons,
  });

  static const String overlayKey = 'compendium_screen';

  final VoidCallback onClose;
  final Map<ItemId, ui.Image?> itemIcons;

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
                length: 4,
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
                        Tab(text: 'Items'),
                        Tab(text: 'Enemies'),
                        Tab(text: 'Statuses'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _SkillList(skills: skillDefs),
                          _ItemList(items: itemDefs, itemIcons: itemIcons),
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

class _ItemList extends StatelessWidget {
  const _ItemList({required this.items, required this.itemIcons});

  final List<ItemDef> items;
  final Map<ItemId, ui.Image?> itemIcons;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final badges = tagBadgesForTags(item.tags);
        final rarityLabel = itemRarityLabel(item.rarity);
        final rarityColor = itemRarityColor(item.rarity);
        return _CompendiumCard(
          title: item.name,
          description: item.description,
          details: _buildItemDetails(item),
          iconImage: itemIcons[item.id],
          showIconSlot: true,
          badges: badges,
          rarityLabel: rarityLabel,
          rarityColor: rarityColor,
        );
      },
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
          details: skillDetailBlockFor(skill.id),
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
          details: _buildEnemyDetails(enemy),
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
    this.details,
    this.iconImage,
    this.showIconSlot = false,
    required this.badges,
    this.rarityLabel,
    this.rarityColor,
  });

  final String title;
  final String description;
  final String? details;
  final ui.Image? iconImage;
  final bool showIconSlot;
  final List<TagBadgeData> badges;
  final String? rarityLabel;
  final Color? rarityColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = rarityColor?.withValues(alpha: 0.45) ?? Colors.white12;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF1C2230),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showIconSlot) ...[
                  _CompendiumIcon(image: iconImage),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (rarityLabel != null && rarityColor != null)
                  Text(
                    rarityLabel!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: rarityColor!.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            if (rarityLabel != null && rarityColor != null) ...[
              const SizedBox(height: 6),
              Text(
                'Rarity: $rarityLabel',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: rarityColor!.withValues(alpha: 0.9),
                ),
              ),
            ],
            if (details != null && details!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white60,
                  height: 1.35,
                ),
              ),
            ],
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

class _CompendiumIcon extends StatelessWidget {
  const _CompendiumIcon({required this.image});

  final ui.Image? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: image == null
          ? const Icon(
              Icons.image_not_supported,
              size: 16,
              color: Colors.white24,
            )
          : Padding(
              padding: const EdgeInsets.all(4),
              child: RawImage(image: image, fit: BoxFit.contain),
            ),
    );
  }
}

String _buildItemDetails(ItemDef item) {
  final details = [
    for (final modifier in item.modifiers) StatText.formatModifier(modifier),
  ];
  return details.map((line) => '• $line').join('\n');
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

const double _enemyContactDamagePerSecond = 12;

String _buildEnemyDetails(EnemyDef enemy) {
  final details = <String>[
    'HP: ${_formatNumber(enemy.maxHp)}',
    'XP: ${enemy.xpReward}',
    'Move Speed: ${_formatNumber(enemy.moveSpeed)}',
    'Attack: Contact (${_formatNumber(_enemyContactDamagePerSecond)} DPS)',
  ];

  details.addAll(_enemyRoleDetails(enemy));

  return details.map((line) => '• $line').join('\n');
}

List<String> _enemyRoleDetails(EnemyDef enemy) {
  switch (enemy.role) {
    case EnemyRole.ranged:
      return [
        'Attack: Projectile (${_formatNumber(enemy.projectileDamage)} dmg)',
        'Cooldown: ${_formatNumber(enemy.attackCooldown, fractionDigits: 1)}s',
        'Range: ${_formatNumber(enemy.attackRange)}',
        'Projectile Speed: ${_formatNumber(enemy.projectileSpeed)}',
        'Spread: ${_formatNumber(enemy.projectileSpread, fractionDigits: 2)}',
      ];
    case EnemyRole.spawner:
      final spawnName = enemy.spawnEnemyId != null
          ? enemyDefsById[enemy.spawnEnemyId!]?.name ?? 'Unknown'
          : 'None';
      return [
        'Spawner: ${enemy.spawnCount}× $spawnName',
        'Spawn Cooldown: ${_formatNumber(enemy.spawnCooldown, fractionDigits: 1)}s',
        'Spawn Radius: ${_formatNumber(enemy.spawnRadius)}',
      ];
    case EnemyRole.disruptor:
      final cooldown = enemy.attackCooldown * 1.4;
      final damage = enemy.projectileDamage * 0.9;
      return [
        'Attack: Curse burst (3 projectiles, ${_formatNumber(damage)} dmg)',
        'Burst Cooldown: ${_formatNumber(cooldown, fractionDigits: 1)}s',
        'Range: ${_formatNumber(enemy.attackRange)}',
        'Projectile Speed: ${_formatNumber(enemy.projectileSpeed)}',
        'Spread: ${_formatNumber(enemy.projectileSpread, fractionDigits: 2)}',
      ];
    case EnemyRole.zoner:
      final cooldown = enemy.attackCooldown * 1.7;
      final damage = enemy.projectileDamage * 0.8;
      return [
        'Attack: Burning ring (4 projectiles, ${_formatNumber(damage)} dmg)',
        'Ring Cooldown: ${_formatNumber(cooldown, fractionDigits: 1)}s',
        'Range: ${_formatNumber(enemy.attackRange)}',
        'Projectile Speed: ${_formatNumber(enemy.projectileSpeed)}',
        'Spread: ${_formatNumber(enemy.projectileSpread, fractionDigits: 2)}',
      ];
    case EnemyRole.exploder:
      final cooldown = enemy.attackCooldown * 1.3;
      final damage = enemy.projectileDamage * 1.1;
      return [
        'Attack: Detonation ring (8 projectiles, ${_formatNumber(damage)} dmg)',
        'Detonation Cooldown: ${_formatNumber(cooldown, fractionDigits: 1)}s',
        'Range: ${_formatNumber(enemy.attackRange)}',
        'Projectile Speed: ${_formatNumber(enemy.projectileSpeed)}',
        'Spread: ${_formatNumber(enemy.projectileSpread, fractionDigits: 2)}',
      ];
    case EnemyRole.supportHealer:
      final cooldown = enemy.attackCooldown * 1.8;
      final radius = enemy.attackRange * 0.75;
      return [
        'Support: Heal pulse (no damage)',
        'Pulse Cooldown: ${_formatNumber(cooldown, fractionDigits: 1)}s',
        'Pulse Radius: ${_formatNumber(radius)}',
      ];
    case EnemyRole.supportBuffer:
      final cooldown = enemy.attackCooldown * 1.8;
      final radius = enemy.attackRange * 0.8;
      return [
        'Support: Rally pulse (no damage)',
        'Pulse Cooldown: ${_formatNumber(cooldown, fractionDigits: 1)}s',
        'Pulse Radius: ${_formatNumber(radius)}',
      ];
    case EnemyRole.pattern:
      final cooldown = enemy.attackCooldown * 1.3;
      final damage = enemy.projectileDamage * 0.9;
      return [
        'Attack: Orbit volley (2 projectiles, ${_formatNumber(damage)} dmg)',
        'Volley Cooldown: ${_formatNumber(cooldown, fractionDigits: 1)}s',
        'Range: ${_formatNumber(enemy.attackRange)}',
        'Projectile Speed: ${_formatNumber(enemy.projectileSpeed)}',
        'Spread: ${_formatNumber(enemy.projectileSpread, fractionDigits: 2)}',
      ];
    case EnemyRole.elite:
      final cooldown = enemy.attackCooldown * 1.5;
      return [
        'Attack: Charge dash (contact damage)',
        'Charge Cooldown: ${_formatNumber(cooldown, fractionDigits: 1)}s',
        'Range: ${_formatNumber(enemy.attackRange)}',
      ];
    case EnemyRole.chaser:
      return const ['Attack: Melee pressure (contact damage)'];
  }
}

String _formatNumber(double value, {int fractionDigits = 0}) {
  final rounded = value.roundToDouble();
  if ((value - rounded).abs() < 0.01 && fractionDigits == 0) {
    return rounded.toInt().toString();
  }
  if ((value - rounded).abs() < 0.01 && fractionDigits > 0) {
    return rounded.toInt().toString();
  }
  return value.toStringAsFixed(fractionDigits);
}
