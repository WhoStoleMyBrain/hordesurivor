import 'package:flutter/material.dart';

import 'hud_state.dart';
import 'tag_badge.dart';
import 'ui_scale.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.hudState, this.onExitStressTest});

  static const String overlayKey = 'hud';

  final PlayerHudState hudState;
  final VoidCallback? onExitStressTest;

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
                      if (hudState.contractHeat > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          'HEAT ${hudState.contractHeat}',
                          style: const TextStyle(letterSpacing: 0.5),
                        ),
                        if (hudState.contractNames.isNotEmpty)
                          Text(
                            hudState.contractNames.join(', '),
                            style: const TextStyle(
                              color: Colors.white70,
                              letterSpacing: 0.4,
                            ),
                          ),
                      ],
                      if (hudState.levelUpCounter > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: TweenAnimationBuilder<double>(
                            key: ValueKey(hudState.levelUpCounter),
                            tween: Tween(begin: 1.0, end: 0.0),
                            duration: const Duration(milliseconds: 1200),
                            builder: (context, value, child) {
                              if (value <= 0.02) {
                                return const SizedBox.shrink();
                              }
                              return Opacity(opacity: value, child: child);
                            },
                            child: Text(
                              'LEVEL UP!',
                              style: TextStyle(
                                color: Colors.amberAccent,
                                fontSize: UiScale.fontSize(14),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ),
                      if (hudState.rewardMessage != null &&
                          hudState.rewardMessage!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: TweenAnimationBuilder<double>(
                            key: ValueKey(hudState.rewardCounter),
                            tween: Tween(begin: 1.0, end: 0.0),
                            duration: const Duration(milliseconds: 1400),
                            builder: (context, value, child) {
                              if (value <= 0.02) {
                                return const SizedBox.shrink();
                              }
                              return Opacity(opacity: value, child: child);
                            },
                            child: Text(
                              hudState.rewardMessage!,
                              style: TextStyle(
                                color: Colors.lightGreenAccent,
                                fontSize: UiScale.fontSize(12),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
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
                      if (hudState.showPerformance &&
                          onExitStressTest != null) ...[
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: onExitStressTest,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            foregroundColor: Colors.white70,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text(
                            'Return to Start',
                            style: TextStyle(letterSpacing: 0.4),
                          ),
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
