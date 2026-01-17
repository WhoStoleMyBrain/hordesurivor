import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../game/game_flow_state.dart';
import '../game/meta_currency_wallet.dart';
import 'hud_overlay.dart';
import 'hud_state.dart';
import 'meta_shard_badge.dart';

class SidePanel extends StatelessWidget {
  const SidePanel({
    super.key,
    required this.flowStateListenable,
    required this.hudState,
    required this.wallet,
    this.onExitStressTest,
  });

  final ValueListenable<GameFlowState> flowStateListenable;
  final PlayerHudState hudState;
  final MetaCurrencyWallet wallet;
  final VoidCallback? onExitStressTest;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GameFlowState>(
      valueListenable: flowStateListenable,
      builder: (context, flowState, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: flowState == GameFlowState.stage
              ? HudSidePanel(
                  key: const ValueKey('hud'),
                  hudState: hudState,
                  onExitStressTest: onExitStressTest,
                )
              : HubSidePanel(
                  key: const ValueKey('hub'),
                  flowState: flowState,
                  wallet: wallet,
                ),
        );
      },
    );
  }
}

class HudSidePanel extends StatelessWidget {
  const HudSidePanel({
    super.key,
    required this.hudState,
    this.onExitStressTest,
  });

  final PlayerHudState hudState;
  final VoidCallback? onExitStressTest;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0D141C),
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
      ),
      child: SafeArea(
        right: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Run HUD',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: HudStatsContent(
                  hudState: hudState,
                  onExitStressTest: onExitStressTest,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HubSidePanel extends StatelessWidget {
  const HubSidePanel({
    super.key,
    required this.flowState,
    required this.wallet,
  });

  final GameFlowState flowState;
  final MetaCurrencyWallet wallet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = _HubContent.forState(flowState);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0D141C),
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
      ),
      child: SafeArea(
        right: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                content.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              MetaShardBadge(wallet: wallet),
              const SizedBox(height: 16),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.sectionTitle,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final item in content.items) ...[
                        _HubItemRow(icon: item.icon, text: item.text),
                        if (item != content.items.last)
                          const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Text(
                content.footer,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubItemRow extends StatelessWidget {
  const _HubItemRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}

class _HubContent {
  const _HubContent({
    required this.title,
    required this.subtitle,
    required this.sectionTitle,
    required this.items,
    required this.footer,
  });

  final String title;
  final String subtitle;
  final String sectionTitle;
  final List<_HubItem> items;
  final String footer;

  static _HubContent forState(GameFlowState flowState) {
    switch (flowState) {
      case GameFlowState.homeBase:
        return _HubContent(
          title: 'Home Base',
          subtitle: 'Prepare for the next run and tune your loadout path.',
          sectionTitle: 'Next Steps',
          items: const [
            _HubItem(
              Icons.door_front_door_outlined,
              'Walk into the portal to select a combat area.',
            ),
            _HubItem(
              Icons.auto_awesome,
              'Spend Meta Shards in Meta Unlocks for new options.',
            ),
            _HubItem(
              Icons.settings,
              'Adjust controls and UI scale from the menu.',
            ),
          ],
          footer:
              'You can pause anytime with Esc to access options and compendium.',
        );
      case GameFlowState.areaSelect:
        return _HubContent(
          title: 'Area Selection',
          subtitle:
              'Choose a destination and optional Contracts for extra rewards.',
          sectionTitle: 'Tips',
          items: const [
            _HubItem(
              Icons.map_outlined,
              'Each area has a distinct enemy mix and pacing.',
            ),
            _HubItem(
              Icons.local_fire_department_outlined,
              'Contracts raise Heat and boost Meta Shards.',
            ),
            _HubItem(
              Icons.check_circle_outline,
              'Select an area to launch into the run.',
            ),
          ],
          footer: 'Heat is opt-in—stack only the pressure you want.',
        );
      case GameFlowState.death:
        return _HubContent(
          title: 'Run Complete',
          subtitle: 'Review your recap and return to base when ready.',
          sectionTitle: 'What to do',
          items: const [
            _HubItem(
              Icons.analytics_outlined,
              'Scan your build recap for tag synergy hints.',
            ),
            _HubItem(
              Icons.home_outlined,
              'Return to the Home Base to start another run.',
            ),
          ],
          footer: 'Meta Shards are added automatically after each run.',
        );
      case GameFlowState.start:
        return _HubContent(
          title: 'Welcome',
          subtitle: 'Step into the Home Base to begin your journey.',
          sectionTitle: 'Getting Started',
          items: const [
            _HubItem(Icons.play_arrow, 'Press Start to enter the Home Base.'),
            _HubItem(
              Icons.menu_book_outlined,
              'Check the compendium for skills and tags.',
            ),
          ],
          footer: 'Your progress is saved between runs.',
        );
      case GameFlowState.stage:
        return _HubContent(
          title: 'Run HUD',
          subtitle: 'Track your stats and progress during combat.',
          sectionTitle: 'Status',
          items: const [],
          footer: '',
        );
    }
  }
}

class _HubItem {
  const _HubItem(this.icon, this.text);

  final IconData icon;
  final String text;
}
