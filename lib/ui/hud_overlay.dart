import 'package:flutter/material.dart';

import 'hud_state.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.hudState});

  static const String overlayKey = 'hud';

  final PlayerHudState hudState;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: AnimatedBuilder(
              animation: hudState,
              builder: (context, _) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HP ${hudState.hp.toStringAsFixed(0)}'
                        '/${hudState.maxHp.toStringAsFixed(0)}',
                        style: const TextStyle(letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'LV ${hudState.level} '
                        'XP ${hudState.xp}/${hudState.xpToNext}',
                        style: const TextStyle(letterSpacing: 0.5),
                      ),
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
}
