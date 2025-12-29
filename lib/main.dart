import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/horde_game.dart';
import 'ui/hud_overlay.dart';
import 'ui/selection_overlay.dart';

void main() {
  runApp(const HordeSurvivorApp());
}

class HordeSurvivorApp extends StatelessWidget {
  const HordeSurvivorApp({super.key});

  @override
  Widget build(BuildContext context) {
    const stressScene = bool.fromEnvironment('STRESS_SCENE');
    return MaterialApp(
      theme: ThemeData.dark(),
      initialRoute: stressScene ? '/stress' : '/',
      routes: {
        '/': (_) => _buildGame(stressTest: false),
        '/stress': (_) => _buildGame(stressTest: true),
      },
    );
  }

  GameWidget _buildGame({required bool stressTest}) {
    return GameWidget(
      game: HordeGame(stressTest: stressTest),
      overlayBuilderMap: {
        HudOverlay.overlayKey: (_, game) =>
            HudOverlay(hudState: (game as HordeGame).hudState),
        SelectionOverlay.overlayKey: (_, game) => SelectionOverlay(
              selectionState: (game as HordeGame).selectionState,
              onSelected: game.selectChoice,
            ),
      },
      initialActiveOverlays: const [HudOverlay.overlayKey],
    );
  }
}
