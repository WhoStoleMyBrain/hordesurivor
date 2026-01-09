import 'package:flutter/material.dart';

import '../game/meta_currency_wallet.dart';
import 'meta_shard_badge.dart';

class HomeBaseOverlay extends StatelessWidget {
  const HomeBaseOverlay({super.key, required this.wallet});

  static const String overlayKey = 'home_base_overlay';

  final MetaCurrencyWallet wallet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Home Base — walk into the portal to choose an area.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                MetaShardBadge(wallet: wallet, compact: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
