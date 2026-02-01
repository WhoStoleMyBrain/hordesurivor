import 'package:flutter/material.dart';

import '../data/active_skill_defs.dart';
import '../data/character_defs.dart';
import '../data/skill_defs.dart';
import '../data/stat_defs.dart';
import '../data/ids.dart';
import 'dart:ui' as ui;

class CharacterSelectOverlay extends StatelessWidget {
  const CharacterSelectOverlay({
    super.key,
    required this.selectedCharacterId,
    required this.characters,
    required this.sprites,
    required this.onSelect,
    required this.onClose,
  });

  static const String overlayKey = 'character_select_overlay';

  final CharacterId selectedCharacterId;
  final List<CharacterDef> characters;
  final Map<CharacterId, ui.Image?> sprites;
  final ValueChanged<CharacterId> onSelect;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1410),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF6A5638)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Character Altar',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: const Color(0xFFE9D7A8),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close),
                        color: Colors.white70,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose an exorcist to anchor your rites.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: characters.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final character = characters[index];
                        final selected = character.id == selectedCharacterId;
                        return _CharacterCard(
                          character: character,
                          sprite: sprites[character.id],
                          selected: selected,
                          onSelect: () => onSelect(character.id),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({
    required this.character,
    required this.sprite,
    required this.selected,
    required this.onSelect,
  });

  final CharacterDef character;
  final ui.Image? sprite;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = selected
        ? const Color(0xFFE9D7A8)
        : const Color(0xFF3B2F1F);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF221A14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor, width: selected ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  ],
                ),
              ),
              FilledButton(
                onPressed: selected ? null : onSelect,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFBFA77A),
                  foregroundColor: const Color(0xFF1B1208),
                ),
                child: Text(selected ? 'Selected' : 'Choose'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: character.startingSkills
                .map((skillId) {
                  final skillName =
                      skillDefsById[skillId]?.name ??
                      skillId.name.replaceAllMapped(
                        RegExp(r'[A-Z]'),
                        (match) => ' ${match.group(0)}',
                      );
                  return _TagChip(label: skillName.trim());
                })
                .toList(growable: false),
          ),
          const SizedBox(height: 8),
          Text(
            'Active Skill',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white60,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _TagChip(
                label:
                    activeSkillDefsById[character.startingActiveSkill]?.name ??
                    character.startingActiveSkill.name,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            character.modifierLine,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFFBFA77A),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: _statLines(character)
                .map((line) => _StatChip(label: line.label, value: line.value))
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  List<_StatLine> _statLines(CharacterDef character) {
    final stats = character.baseStats;
    final movement = character.movement;
    return [
      _StatLine(
        label: 'HP',
        value: _formatStat(stats[StatId.maxHp], decimals: 0),
      ),
      _StatLine(
        label: 'Mana',
        value: _formatStat(stats[StatId.maxMana], decimals: 0),
      ),
      _StatLine(
        label: 'Move Speed',
        value: _formatStat(movement.moveSpeed, decimals: 0),
      ),
      _StatLine(
        label: 'Dash Charges',
        value: _formatStat(movement.dashCharges.toDouble(), decimals: 0),
      ),
      _StatLine(
        label: 'Dash Cooldown',
        value: _formatStat(movement.dashCooldown, decimals: 1),
      ),
    ];
  }

  String _formatStat(double? value, {required int decimals}) {
    final fallback = decimals == 0 ? '0' : '0.0';
    if (value == null) {
      return fallback;
    }
    if (decimals == 0) {
      return value.round().toString();
    }
    return value.toStringAsFixed(decimals);
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2118),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4C3924)),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: const Color(0xFFE9D7A8),
        ),
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1510),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3B2F1F)),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
      ),
    );
  }
}

class _StatLine {
  const _StatLine({required this.label, required this.value});

  final String label;
  final String value;
}
