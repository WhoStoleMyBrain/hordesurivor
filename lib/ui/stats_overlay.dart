import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/ids.dart';
import 'run_stats_content.dart';
import 'stats_screen_state.dart';
import 'ui_scale.dart';

class StatsOverlay extends StatelessWidget {
  const StatsOverlay({
    super.key,
    required this.state,
    required this.onClose,
    required this.skillIcons,
    required this.activeSkillIcons,
    required this.itemIcons,
    required this.cardBackground,
  });

  static const String overlayKey = 'stats_overlay';

  final StatsScreenState state;
  final VoidCallback onClose;
  final Map<SkillId, ui.Image?> skillIcons;
  final Map<ActiveSkillId, ui.Image?> activeSkillIcons;
  final Map<ItemId, ui.Image?> itemIcons;
  final ui.Image? cardBackground;

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
                                fontSize: UiScale.fontSize(18),
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
                      Expanded(
                        child: RunStatsContent(
                          state: state,
                          skillIcons: skillIcons,
                          activeSkillIcons: activeSkillIcons,
                          itemIcons: itemIcons,
                          cardBackground: cardBackground,
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
