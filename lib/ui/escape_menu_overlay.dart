import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../game/stress_stats.dart';
import '../game/meta_currency_wallet.dart';
import '../data/ids.dart';
import 'run_stats_content.dart';
import 'start_menu_entries.dart';
import 'stats_screen_state.dart';
import 'ui_scale.dart';

class EscapeMenuOverlay extends StatelessWidget {
  const EscapeMenuOverlay({
    super.key,
    required this.inRun,
    required this.wallet,
    required this.onClose,
    required this.onEnterHomeBase,
    required this.onOptions,
    required this.onCompendium,
    required this.onMetaUnlocks,
    required this.skillIcons,
    required this.activeSkillIcons,
    required this.itemIcons,
    required this.cardBackground,
    this.onStressTest,
    this.onExit,
    this.stressStats,
    this.statsState,
    this.onContinue,
    this.onAbort,
  }) : assert(
         !inRun ||
             (statsState != null && onContinue != null && onAbort != null),
       );

  static const String overlayKey = 'escape_menu_overlay';

  final bool inRun;
  final MetaCurrencyWallet wallet;
  final VoidCallback onClose;
  final VoidCallback onEnterHomeBase;
  final VoidCallback onOptions;
  final VoidCallback onCompendium;
  final VoidCallback onMetaUnlocks;
  final Map<SkillId, ui.Image?> skillIcons;
  final Map<ActiveSkillId, ui.Image?> activeSkillIcons;
  final Map<ItemId, ui.Image?> itemIcons;
  final ui.Image? cardBackground;
  final VoidCallback? onStressTest;
  final VoidCallback? onExit;
  final StressStatsSnapshot? stressStats;
  final StatsScreenState? statsState;
  final VoidCallback? onContinue;
  final VoidCallback? onAbort;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: SafeArea(
        child: inRun
            ? _InRunMenuLayout(
                onClose: onClose,
                onContinue: onContinue!,
                onAbort: onAbort!,
                statsState: statsState!,
                stressStats: stressStats,
                skillIcons: skillIcons,
                activeSkillIcons: activeSkillIcons,
                itemIcons: itemIcons,
                cardBackground: cardBackground,
              )
            : _OutOfRunMenuLayout(
                wallet: wallet,
                onClose: onClose,
                onEnterHomeBase: onEnterHomeBase,
                onOptions: onOptions,
                onCompendium: onCompendium,
                onMetaUnlocks: onMetaUnlocks,
                onStressTest: onStressTest,
                onExit: onExit,
              ),
      ),
    );
  }
}

class _InRunMenuLayout extends StatelessWidget {
  const _InRunMenuLayout({
    required this.onClose,
    required this.onContinue,
    required this.onAbort,
    required this.statsState,
    required this.stressStats,
    required this.skillIcons,
    required this.activeSkillIcons,
    required this.itemIcons,
    required this.cardBackground,
  });

  final VoidCallback onClose;
  final VoidCallback onContinue;
  final VoidCallback onAbort;
  final StatsScreenState statsState;
  final StressStatsSnapshot? stressStats;
  final Map<SkillId, ui.Image?> skillIcons;
  final Map<ActiveSkillId, ui.Image?> activeSkillIcons;
  final Map<ItemId, ui.Image?> itemIcons;
  final ui.Image? cardBackground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: statsState,
      builder: (context, _) {
        return Container(
          color: Colors.black.withValues(alpha: 0.88),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Paused',
                        style: TextStyle(
                          fontSize: UiScale.fontSize(20),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFE9D7A8),
                        ),
                      ),
                    ),
                    TextButton(onPressed: onClose, child: const Text('Close')),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (stressStats != null) ...[
                              _InRunPanel(
                                child: _StressStatsSection(stats: stressStats!),
                              ),
                              const SizedBox(height: 12),
                            ],
                            Expanded(
                              child: _InRunPanel(
                                child: RunStatsContent(
                                  state: statsState,
                                  skillIcons: skillIcons,
                                  activeSkillIcons: activeSkillIcons,
                                  itemIcons: itemIcons,
                                  cardBackground: cardBackground,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: _InRunActionPanel(
                          onContinue: onContinue,
                          onAbort: onAbort,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Press Esc to return',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InRunPanel extends StatelessWidget {
  const _InRunPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF181210),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A2B1B)),
      ),
      child: child,
    );
  }
}

class _InRunActionPanel extends StatelessWidget {
  const _InRunActionPanel({required this.onContinue, required this.onAbort});

  final VoidCallback onContinue;
  final VoidCallback onAbort;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF181210),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A2B1B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Run Actions',
            style: theme.textTheme.titleSmall?.copyWith(
              color: const Color(0xFFE9D7A8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              child: const Text('Continue Run'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onAbort,
              child: const Text('Abort Run'),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Review tabs to see your build, tags, and run stats.',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

class _OutOfRunMenuLayout extends StatelessWidget {
  const _OutOfRunMenuLayout({
    required this.wallet,
    required this.onClose,
    required this.onEnterHomeBase,
    required this.onOptions,
    required this.onCompendium,
    required this.onMetaUnlocks,
    required this.onStressTest,
    required this.onExit,
  });

  final MetaCurrencyWallet wallet;
  final VoidCallback onClose;
  final VoidCallback onEnterHomeBase;
  final VoidCallback onOptions;
  final VoidCallback onCompendium;
  final VoidCallback onMetaUnlocks;
  final VoidCallback? onStressTest;
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 560),
        child: Card(
          color: Colors.black.withValues(alpha: 0.85),
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: UiScale.fontSize(20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(onPressed: onClose, child: const Text('Close')),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Review your build options or head to the home base.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 16),
                        StartMenuEntries(
                          onStart: onEnterHomeBase,
                          onOptions: onOptions,
                          onCompendium: onCompendium,
                          onMetaUnlocks: onMetaUnlocks,
                          onStressTest: onStressTest,
                          onExit: onExit,
                          wallet: wallet,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Press Esc to return',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StressStatsSection extends StatelessWidget {
  const _StressStatsSection({required this.stats});

  final StressStatsSnapshot stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stress Metrics',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _StressStatRow(label: 'Frames', value: '${stats.frameCount}'),
        _StressStatRow(
          label: 'Avg FPS',
          value: stats.averageFps.toStringAsFixed(1),
        ),
        _StressStatRow(
          label: 'Min / Max FPS',
          value:
              '${stats.minFps.toStringAsFixed(1)}'
              ' / ${stats.maxFps.toStringAsFixed(1)}',
        ),
        _StressStatRow(
          label: 'Avg Frame',
          value: '${stats.averageFrameMs.toStringAsFixed(1)} ms',
        ),
        _StressStatRow(
          label: 'Worst Frame',
          value: '${stats.worstFrameMs.toStringAsFixed(1)} ms',
        ),
        _StressStatRow(
          label: 'Slow Frames',
          value:
              '${stats.slowFrameCount}'
              ' (>${stats.slowFrameThresholdMs.toStringAsFixed(1)} ms)',
        ),
      ],
    );
  }
}

class _StressStatRow extends StatelessWidget {
  const _StressStatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
