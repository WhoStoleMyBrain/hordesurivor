import 'package:flutter/material.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key});

  static const String overlayKey = 'hud';

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
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                'HUD: HP 100/100',
                style: TextStyle(letterSpacing: 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
