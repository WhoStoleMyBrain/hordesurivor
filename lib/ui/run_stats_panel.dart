import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/ids.dart';
import 'run_stats_content.dart';
import 'stats_screen_state.dart';
import 'ui_scale.dart';

class RunStatsPanel extends StatelessWidget {
  const RunStatsPanel({
    super.key,
    required this.state,
    required this.skillIcons,
    required this.itemIcons,
    required this.cardBackground,
  });

  final StatsScreenState state;
  final Map<SkillId, ui.Image?> skillIcons;
  final Map<ItemId, ui.Image?> itemIcons;
  final ui.Image? cardBackground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0D141C),
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
      ),
      child: SafeArea(
        right: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AnimatedBuilder(
            animation: state,
            builder: (context, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Run Stats',
                    style: TextStyle(
                      fontSize: UiScale.fontSize(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: RunStatsContent(
                      state: state,
                      skillIcons: skillIcons,
                      itemIcons: itemIcons,
                      cardBackground: cardBackground,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
