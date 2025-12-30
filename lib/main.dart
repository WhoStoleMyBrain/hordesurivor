import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide SelectionOverlay;

import 'data/data_validation.dart';
import 'game/horde_game.dart';
import 'ui/area_select_screen.dart';
import 'ui/hud_overlay.dart';
import 'ui/home_base_overlay.dart';
import 'ui/options_screen.dart';
import 'ui/selection_overlay.dart';
import 'ui/start_screen.dart';

void main() {
  validateGameDataOrThrow();
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
        StartScreen.overlayKey: (_, game) => StartScreen(
          onStart: (game as HordeGame).beginHomeBaseFromStartScreen,
          onOptions: (game as HordeGame).openOptionsFromStartScreen,
        ),
        OptionsScreen.overlayKey: (_, game) => OptionsScreen(
          onClose: (game as HordeGame).closeOptionsFromStartScreen,
        ),
        HomeBaseOverlay.overlayKey: (_, __) => const HomeBaseOverlay(),
        AreaSelectScreen.overlayKey: (_, game) => AreaSelectScreen(
          onAreaSelected: (game as HordeGame).beginStageFromAreaSelect,
          onReturn: game.returnToHomeBase,
        ),
      },
      initialActiveOverlays: stressTest
          ? const [HudOverlay.overlayKey]
          : const [StartScreen.overlayKey],
    );
  }
}
