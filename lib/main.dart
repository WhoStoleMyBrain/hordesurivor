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
import 'ui/meta_unlock_screen.dart';
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
    final baseTheme = ThemeData.dark().copyWith(
      textTheme: ThemeData.dark().textTheme.copyWith(
        displayLarge: ThemeData.dark().textTheme.displayLarge?.copyWith(
          fontSize: 40,
        ),
        displayMedium: ThemeData.dark().textTheme.displayMedium?.copyWith(
          fontSize: 36,
        ),
        displaySmall: ThemeData.dark().textTheme.displaySmall?.copyWith(
          fontSize: 30,
        ),
        headlineLarge: ThemeData.dark().textTheme.headlineLarge?.copyWith(
          fontSize: 28,
        ),
        headlineMedium: ThemeData.dark().textTheme.headlineMedium?.copyWith(
          fontSize: 24,
        ),
        headlineSmall: ThemeData.dark().textTheme.headlineSmall?.copyWith(
          fontSize: 20,
        ),
        titleLarge: ThemeData.dark().textTheme.titleLarge?.copyWith(
          fontSize: 18,
        ),
        titleMedium: ThemeData.dark().textTheme.titleMedium?.copyWith(
          fontSize: 16,
        ),
        titleSmall: ThemeData.dark().textTheme.titleSmall?.copyWith(
          fontSize: 14,
        ),
        bodyLarge: ThemeData.dark().textTheme.bodyLarge?.copyWith(fontSize: 14),
        bodyMedium: ThemeData.dark().textTheme.bodyMedium?.copyWith(
          fontSize: 12,
        ),
        bodySmall: ThemeData.dark().textTheme.bodySmall?.copyWith(fontSize: 10),
        labelLarge: ThemeData.dark().textTheme.labelLarge?.copyWith(
          fontSize: 14,
        ),
        labelMedium: ThemeData.dark().textTheme.labelMedium?.copyWith(
          fontSize: 12,
        ),
        labelSmall: ThemeData.dark().textTheme.labelSmall?.copyWith(
          fontSize: 10,
        ),
      ),
    );

    return MaterialApp(
      theme: baseTheme.copyWith(
        textTheme: baseTheme.textTheme,
        primaryTextTheme: baseTheme.primaryTextTheme,
      ),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(UiScale.textScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
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
          onMetaUnlocks: game.openMetaUnlocksFromStartScreen,
          wallet: game.metaWallet,
        ),
        OptionsScreen.overlayKey: (_, game) => OptionsScreen(
          onClose: game.closeOptionsFromStartScreen,
          highContrastTelegraphs: game.highContrastTelegraphs,
          onHighContrastTelegraphsChanged: game.setHighContrastTelegraphs,
        ),
        CompendiumScreen.overlayKey: (_, game) =>
            CompendiumScreen(onClose: game.closeCompendiumFromStartScreen),
        MetaUnlockScreen.overlayKey: (_, game) => MetaUnlockScreen(
          wallet: game.metaWallet,
          unlocks: game.metaUnlocks,
          onClose: game.closeMetaUnlocksFromStartScreen,
        ),
        HomeBaseOverlay.overlayKey: (_, game) =>
            HomeBaseOverlay(wallet: game.metaWallet),
        AreaSelectScreen.overlayKey: (_, game) => AreaSelectScreen(
          onAreaSelected: game.beginStageFromAreaSelect,
          onReturn: game.returnToHomeBase,
        ),
        DeathScreen.overlayKey: (_, game) => DeathScreen(
          summary: game.runSummary,
          completed: game.runCompleted,
          onRestart: game.restartRunFromDeath,
          onReturn: game.returnToHomeBaseFromDeath,
          wallet: game.metaWallet,
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
