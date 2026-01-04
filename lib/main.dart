import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide SelectionOverlay;

import 'data/data_validation.dart';
import 'game/horde_game.dart';
import 'ui/area_select_screen.dart';
import 'ui/compendium_screen.dart';
import 'ui/death_screen.dart';
import 'ui/flow_debug_overlay.dart';
import 'ui/hud_overlay.dart';
import 'ui/home_base_overlay.dart';
import 'ui/options_screen.dart';
import 'ui/selection_overlay.dart';
import 'ui/start_screen.dart';
import 'ui/stats_overlay.dart';
import 'ui/ui_scale.dart';

void main() {
  validateGameDataOrThrow();
  runApp(const HordeSurvivorApp());
}

class HordeSurvivorApp extends StatelessWidget {
  const HordeSurvivorApp({super.key});

  @override
  Widget build(BuildContext context) {
    const stressScene = bool.fromEnvironment('STRESS_SCENE');
    final baseTheme = ThemeData.dark();
    final scaledTextTheme = baseTheme.textTheme.apply(
      fontSizeFactor: UiScale.textScale,
    );
    return MaterialApp(
      theme: baseTheme.copyWith(
        textTheme: scaledTextTheme,
        primaryTextTheme: baseTheme.primaryTextTheme.apply(
          fontSizeFactor: UiScale.textScale,
        ),
      ),
      initialRoute: stressScene ? '/stress' : '/',
      routes: {
        '/': (_) => _buildGame(stressTest: false),
        '/stress': (_) => _buildGame(stressTest: true),
      },
    );
  }

  GameWidget<HordeGame> _buildGame({required bool stressTest}) {
    return GameWidget<HordeGame>(
      game: HordeGame(stressTest: stressTest),
      overlayBuilderMap: {
        HudOverlay.overlayKey: (_, game) => HudOverlay(hudState: game.hudState),
        SelectionOverlay.overlayKey: (_, game) => SelectionOverlay(
          selectionState: game.selectionState,
          onSelected: game.selectChoice,
          onReroll: game.rerollSelection,
        ),
        StatsOverlay.overlayKey: (_, game) => StatsOverlay(
          state: game.statsScreenState,
          onClose: game.toggleStatsOverlay,
        ),
        StartScreen.overlayKey: (_, game) => StartScreen(
          onStart: game.beginHomeBaseFromStartScreen,
          onOptions: game.openOptionsFromStartScreen,
          onCompendium: game.openCompendiumFromStartScreen,
        ),
        OptionsScreen.overlayKey: (_, game) => OptionsScreen(
          onClose: game.closeOptionsFromStartScreen,
          highContrastTelegraphs: game.highContrastTelegraphs,
          onHighContrastTelegraphsChanged: game.setHighContrastTelegraphs,
        ),
        CompendiumScreen.overlayKey: (_, game) =>
            CompendiumScreen(onClose: game.closeCompendiumFromStartScreen),
        HomeBaseOverlay.overlayKey: (_, _) => const HomeBaseOverlay(),
        AreaSelectScreen.overlayKey: (_, game) => AreaSelectScreen(
          onAreaSelected: game.beginStageFromAreaSelect,
          onReturn: game.returnToHomeBase,
        ),
        DeathScreen.overlayKey: (_, game) => DeathScreen(
          summary: game.runSummary,
          completed: game.runCompleted,
          onRestart: game.restartRunFromDeath,
          onReturn: game.returnToHomeBaseFromDeath,
        ),
        FlowDebugOverlay.overlayKey: (_, game) => FlowDebugOverlay(
          flowState: game.flowState,
          onSelectState: game.debugJumpToState,
          onClose: game.toggleFlowDebugOverlay,
        ),
      },
      initialActiveOverlays: stressTest
          ? const [HudOverlay.overlayKey]
          : const [StartScreen.overlayKey],
    );
  }
}
