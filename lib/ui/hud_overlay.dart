import 'package:flutter/material.dart';

import 'hud_state.dart';
import 'tag_badge.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.hudState});

  static const String overlayKey = 'hud';

  final PlayerHudState hudState;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: AnimatedBuilder(
              animation: hudState,
              builder: (context, _) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hudState.buildTags.isNotEmpty) ...[
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final badge in tagBadgesForTags(
                              hudState.buildTags,
                            ))
                              TagBadge(data: badge),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        'HP ${hudState.hp.toStringAsFixed(0)}'
                        '/${hudState.maxHp.toStringAsFixed(0)}',
                        style: const TextStyle(letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'LV ${hudState.level} '
                        'XP ${hudState.xp}/${hudState.xpToNext}',
                        style: const TextStyle(letterSpacing: 0.5),
                      ),
                      if (hudState.stageDuration > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          'SCORE ${hudState.score}',
                          style: const TextStyle(letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'TIME ${_formatTimer(hudState.stageElapsed)}'
                          ' / ${_formatTimer(hudState.stageDuration)}',
                          style: const TextStyle(letterSpacing: 0.5),
                        ),
                        Text(
                          'SECTION ${hudState.sectionIndex + 1}'
                          '/${hudState.sectionCount}',
                          style: const TextStyle(letterSpacing: 0.5),
                        ),
                        Text(
                          'THREAT TIER ${hudState.threatTier}',
                          style: const TextStyle(letterSpacing: 0.5),
                        ),
                        if (hudState.sectionNote != null &&
                            hudState.sectionNote!.isNotEmpty)
                          Text(
                            hudState.sectionNote!,
                            style: const TextStyle(
                              color: Colors.white70,
                              letterSpacing: 0.4,
                            ),
                          ),
                      ],
                      if (hudState.showPerformance) ...[
                        const SizedBox(height: 4),
                        Text(
                          'FPS ${hudState.fps.toStringAsFixed(1)} '
                          '(${hudState.frameTimeMs.toStringAsFixed(1)} ms)',
                          style: const TextStyle(letterSpacing: 0.5),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimer(double seconds) {
    final clamped = seconds.clamp(0, 24 * 60 * 60).toInt();
    final minutes = clamped ~/ 60;
    final secs = clamped % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
