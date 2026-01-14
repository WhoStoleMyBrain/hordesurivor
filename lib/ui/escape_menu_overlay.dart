import 'package:flutter/material.dart';

import '../game/meta_currency_wallet.dart';
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
    this.onStressTest,
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
  final VoidCallback? onStressTest;
  final StatsScreenState? statsState;
  final VoidCallback? onContinue;
  final VoidCallback? onAbort;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: SafeArea(
        child: Center(
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
                            inRun ? 'Paused' : 'Menu',
                            style: TextStyle(
                              fontSize: UiScale.fontSize(20),
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
                    if (inRun)
                      Expanded(
                        child: AnimatedBuilder(
                          animation: statsState!,
                          builder: (context, _) {
                            return SingleChildScrollView(
                              child: RunStatsContent(state: statsState!),
                            );
                          },
                        ),
                      )
                    else
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
                                wallet: wallet,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (inRun)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onContinue,
                              child: const Text('Continue Run'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onAbort,
                              child: const Text('Abort Run'),
                            ),
                          ),
                        ],
                      )
                    else
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
        ),
      ),
    );
  }
}
