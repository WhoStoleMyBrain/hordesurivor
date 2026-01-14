import 'package:flutter/material.dart';

import 'hud_state.dart';
import 'tag_badge.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.hudState, this.onExitStressTest});

  static const String overlayKey = 'hud';

  final PlayerHudState hudState;
  final VoidCallback? onExitStressTest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
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
                final statLabelStyle = theme.labelMedium?.copyWith(
                  color: Colors.white70,
                  letterSpacing: 0.6,
                );
                final statValueStyle = theme.bodyMedium?.copyWith(
                  color: Colors.white,
                  letterSpacing: 0.6,
                );
                final mutedStyle = theme.bodySmall?.copyWith(
                  color: Colors.white70,
                  letterSpacing: 0.4,
                );
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
                        const SizedBox(height: 8),
                      ],
                      _HudStatRow(
                        label: 'HP',
                        value:
                            '${hudState.hp.toStringAsFixed(0)}'
                            '/${hudState.maxHp.toStringAsFixed(0)}',
                        labelStyle: statLabelStyle,
                        valueStyle: statValueStyle,
                      ),
                      const SizedBox(height: 4),
                      _HudStatRow(
                        label: 'LV',
                        value: '${hudState.level}',
                        labelStyle: statLabelStyle,
                        valueStyle: statValueStyle,
                      ),
                      const SizedBox(height: 2),
                      _HudStatRow(
                        label: 'XP',
                        value: '${hudState.xp}/${hudState.xpToNext}',
                        labelStyle: statLabelStyle,
                        valueStyle: statValueStyle,
                      ),
                      if (hudState.contractHeat > 0) ...[
                        const SizedBox(height: 6),
                        _HudStatRow(
                          label: 'HEAT',
                          value: '${hudState.contractHeat}',
                          labelStyle: statLabelStyle,
                          valueStyle: statValueStyle,
                        ),
                        if (hudState.contractNames.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              hudState.contractNames.join(', '),
                              style: mutedStyle,
                            ),
                          ),
                      ],
                      if (hudState.levelUpCounter > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
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
                                fontSize: theme.labelLarge?.fontSize,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ),
                      if (hudState.rewardMessage != null &&
                          hudState.rewardMessage!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
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
                                fontSize: theme.labelMedium?.fontSize,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      if (hudState.stageDuration > 0) ...[
                        const SizedBox(height: 8),
                        _HudStatRow(
                          label: 'SCORE',
                          value: '${hudState.score}',
                          labelStyle: statLabelStyle,
                          valueStyle: statValueStyle,
                        ),
                        const SizedBox(height: 4),
                        _HudStatRow(
                          label: 'TIME',
                          value:
                              '${_formatTimer(hudState.stageElapsed)}'
                              ' / ${_formatTimer(hudState.stageDuration)}',
                          labelStyle: statLabelStyle,
                          valueStyle: statValueStyle,
                        ),
                        const SizedBox(height: 2),
                        _HudStatRow(
                          label: 'SECTION',
                          value:
                              '${hudState.sectionIndex + 1}'
                              '/${hudState.sectionCount}',
                          labelStyle: statLabelStyle,
                          valueStyle: statValueStyle,
                        ),
                        const SizedBox(height: 2),
                        _HudStatRow(
                          label: 'THREAT',
                          value: '${hudState.threatTier}',
                          labelStyle: statLabelStyle,
                          valueStyle: statValueStyle,
                        ),
                        if (hudState.sectionNote != null &&
                            hudState.sectionNote!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              hudState.sectionNote!,
                              style: mutedStyle,
                            ),
                          ),
                      ],
                      if (hudState.showPerformance) ...[
                        const SizedBox(height: 8),
                        _HudStatRow(
                          label: 'FPS',
                          value:
                              '${hudState.fps.toStringAsFixed(1)} '
                              '(${hudState.frameTimeMs.toStringAsFixed(1)} ms)',
                          labelStyle: statLabelStyle,
                          valueStyle: statValueStyle,
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

class _HudStatRow extends StatelessWidget {
  const _HudStatRow({
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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            value,
            style: valueStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
