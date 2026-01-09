import 'package:flutter/material.dart';

import '../data/meta_unlock_defs.dart';
import '../game/meta_currency_wallet.dart';
import '../game/meta_unlocks.dart';
import 'meta_shard_badge.dart';

class MetaUnlockScreen extends StatelessWidget {
  const MetaUnlockScreen({
    super.key,
    required this.wallet,
    required this.unlocks,
    required this.onClose,
  });

  static const String overlayKey = 'meta_unlock_screen';

  final MetaCurrencyWallet wallet;
  final MetaUnlocks unlocks;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.black.withValues(alpha: 0.75),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AnimatedBuilder(
                animation: Listenable.merge([wallet, unlocks]),
                builder: (context, _) {
                  final isReady = wallet.isLoaded && unlocks.isLoaded;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Meta Unlocks',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Spend Meta Shards to unlock convenience perks. '
                        'Unlocks are lateral and never grant raw damage boosts.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      MetaShardBadge(wallet: wallet),
                      const SizedBox(height: 20),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: metaUnlockDefs.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final def = metaUnlockDefs[index];
                            final unlocked = unlocks.isUnlocked(def.id);
                            final canPurchase =
                                isReady &&
                                !unlocked &&
                                wallet.balance >= def.cost;
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: unlocked
                                      ? Colors.greenAccent
                                      : Colors.white12,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          def.name,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      if (unlocked)
                                        Text(
                                          'UNLOCKED',
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                                color: Colors.greenAccent,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        )
                                      else
                                        Text(
                                          '${def.cost} shards',
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(color: Colors.white70),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    def.description,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: canPurchase
                                          ? () {
                                              unlocks.purchase(
                                                def.id,
                                                wallet: wallet,
                                              );
                                            }
                                          : null,
                                      child: Text(
                                        unlocked ? 'Owned' : 'Unlock',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: onClose,
                          child: const Text('Back'),
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
