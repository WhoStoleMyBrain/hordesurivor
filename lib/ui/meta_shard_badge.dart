import 'package:flutter/material.dart';

import '../game/meta_currency_wallet.dart';

class MetaShardBadge extends StatelessWidget {
  const MetaShardBadge({super.key, required this.wallet, this.compact = false});

  final MetaCurrencyWallet wallet;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: wallet,
      builder: (context, _) {
        final balance = wallet.balance;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: compact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                'Meta Shards',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                balance.toString(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
