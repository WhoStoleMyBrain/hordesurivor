import 'package:flutter/material.dart';

import '../game/meta_currency_wallet.dart';
import 'meta_shard_badge.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({
    super.key,
    required this.onStart,
    required this.onOptions,
    required this.onCompendium,
    required this.onMetaUnlocks,
    required this.wallet,
  });

  static const String overlayKey = 'start_screen';

  final VoidCallback onStart;
  final VoidCallback onOptions;
  final VoidCallback onCompendium;
  final VoidCallback onMetaUnlocks;
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
                MetaShardBadge(wallet: wallet),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onStart,
                    child: const Text('Enter Home Base'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onOptions,
                    child: const Text('Options'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onCompendium,
                    child: const Text('Compendium'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onMetaUnlocks,
                    child: const Text('Meta Unlocks'),
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
