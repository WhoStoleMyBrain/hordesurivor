import 'package:flutter/material.dart';

import 'hud_state.dart';

class ManaOrbOverlay extends StatelessWidget {
  const ManaOrbOverlay({super.key, required this.hudState});

  static const String overlayKey = 'mana_orb';

  final PlayerHudState hudState;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 16),
          child: AnimatedBuilder(
            animation: hudState,
            builder: (context, _) {
              final ratio = hudState.maxMana > 0
                  ? (hudState.mana / hudState.maxMana).clamp(0.0, 1.0)
                  : 0.0;
              return _ManaOrb(ratio: ratio);
            },
          ),
        ),
      ),
    );
  }
}

class _ManaOrb extends StatelessWidget {
  const _ManaOrb({required this.ratio});

  final double ratio;

  @override
  Widget build(BuildContext context) {
    const size = 96.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.2, -0.2),
                radius: 0.9,
                colors: [Color(0xFF102241), Color(0xFF060B16)],
              ),
              border: Border.all(color: const Color(0xFF6A7EA8), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xAA000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
          ClipOval(
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        colors: [Color(0xFF0A1429), Color(0xFF040910)],
                        radius: 0.9,
                      ),
                      border: Border.all(color: Colors.black54, width: 1),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: ratio,
                    widthFactor: 1,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)],
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: FractionallySizedBox(
                    heightFactor: 0.38,
                    widthFactor: 1,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x66FFFFFF), Color(0x00FFFFFF)],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
