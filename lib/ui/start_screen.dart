import 'package:flutter/material.dart';

import '../game/meta_currency_wallet.dart';
import 'start_menu_entries.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({
    super.key,
    required this.onStart,
    required this.onOptions,
    required this.onCompendium,
    required this.onMetaUnlocks,
    this.onStressTest,
    this.onExit,
    required this.wallet,
  });

  static const String overlayKey = 'start_screen';

  final VoidCallback onStart;
  final VoidCallback onOptions;
  final VoidCallback onCompendium;
  final VoidCallback onMetaUnlocks;
  final VoidCallback? onExit;
  final VoidCallback? onStressTest;
  final MetaCurrencyWallet wallet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Horde Survivor',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Prepare in the home base before choosing a stage. '
                  'Enter when you are ready.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                StartMenuEntries(
                  onStart: onStart,
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
      ),
    );
  }
}
