import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../game/meta_currency_wallet.dart';
import 'meta_shard_badge.dart';

class StartMenuEntries extends StatelessWidget {
  const StartMenuEntries({
    super.key,
    required this.onStart,
    required this.onOptions,
    required this.onCompendium,
    required this.onMetaUnlocks,
    required this.wallet,
    this.onStressTest,
  });

  final VoidCallback onStart;
  final VoidCallback onOptions;
  final VoidCallback onCompendium;
  final VoidCallback onMetaUnlocks;
  final VoidCallback? onStressTest;
  final MetaCurrencyWallet wallet;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        if (kDebugMode && onStressTest != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onStressTest,
              child: const Text('Stress Scene (Debug)'),
            ),
          ),
        ],
      ],
    );
  }
}
