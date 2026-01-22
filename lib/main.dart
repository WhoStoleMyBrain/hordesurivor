import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide SelectionOverlay;

import 'data/data_validation.dart';
import 'data/ids.dart';
import 'game/horde_game.dart';
import 'ui/area_select_screen.dart';
import 'ui/character_select_overlay.dart';
import 'ui/compendium_screen.dart';
import 'ui/death_screen.dart';
import 'ui/escape_menu_overlay.dart';
import 'ui/first_run_hints_overlay.dart';
import 'ui/flow_debug_overlay.dart';
import 'ui/home_base_overlay.dart';
import 'ui/meta_unlock_screen.dart';
import 'ui/options_screen.dart';
import 'ui/selection_overlay.dart';
import 'ui/start_screen.dart';
import 'ui/stats_overlay.dart';
import 'ui/side_panel.dart';
import 'ui/ui_scale.dart';
import 'ui/virtual_stick_overlay.dart';
import 'game/game_flow_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UiScale.loadTextScale();
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

    return ValueListenableBuilder<double>(
      valueListenable: UiScale.textScaleListenable,
      builder: (context, textScale, _) {
        return MaterialApp(
          theme: baseTheme.copyWith(
            textTheme: baseTheme.textTheme,
            primaryTextTheme: baseTheme.primaryTextTheme,
          ),
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(textScale),
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
      },
    );
  }

  Widget _buildGame({required bool stressTest}) {
    return _GameShell(stressTest: stressTest);
  }
}

class _GameShell extends StatefulWidget {
  const _GameShell({required this.stressTest});

  final bool stressTest;

  @override
  State<_GameShell> createState() => _GameShellState();
}

class _GameShellState extends State<_GameShell> {
  late final HordeGame _game;

  @override
  void initState() {
    super.initState();
    _game = HordeGame(stressTest: widget.stressTest);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final targetWidth = constraints.maxWidth * 0.28;
        final panelWidth = math.min(360.0, math.max(240.0, targetWidth));
        return Row(
          children: [
            SizedBox(
              width: panelWidth,
              child: SidePanel(
                flowStateListenable: _game.flowStateListenable,
                hudState: _game.hudState,
                runAnalysisState: _game.runAnalysisState,
                wallet: _game.metaWallet,
                onExitStressTest: _game.stressTest
                    ? () => Navigator.of(context).pushReplacementNamed('/')
                    : null,
              ),
            ),
            Expanded(
              child: GameWidget<HordeGame>(
                game: _game,
                overlayBuilderMap: {
                  VirtualStickOverlay.overlayKey: (_, game) =>
                      VirtualStickOverlay(state: game.virtualStickState),
                  SelectionOverlay.overlayKey: (_, game) => SelectionOverlay(
                    selectionState: game.selectionState,
                    onSelected: game.selectChoice,
                    onReroll: game.rerollSelection,
                    onBanish: game.banishSelection,
                    onToggleLock: game.toggleShopLock,
                    onSkip: game.skipSelection,
                  ),
                  StatsOverlay.overlayKey: (_, game) => StatsOverlay(
                    state: game.statsScreenState,
                    onClose: game.toggleStatsOverlay,
                  ),
                  StartScreen.overlayKey: (context, game) => StartScreen(
                    onStart: game.beginHomeBaseFromStartScreen,
                    onOptions: game.openOptionsFromStartScreen,
                    onCompendium: game.openCompendiumFromStartScreen,
                    onMetaUnlocks: game.openMetaUnlocksFromStartScreen,
                    onStressTest: () =>
                        Navigator.of(context).pushReplacementNamed('/stress'),
                    wallet: game.metaWallet,
                  ),
                  OptionsScreen.overlayKey: (_, game) => OptionsScreen(
                    onClose: game.closeOptionsScreen,
                    highContrastTelegraphs: game.highContrastTelegraphs,
                    onHighContrastTelegraphsChanged:
                        game.setHighContrastTelegraphs,
                    textScale: UiScale.textScaleListenable,
                    onTextScaleChanged: UiScale.setTextScale,
                  ),
                  CompendiumScreen.overlayKey: (_, game) =>
                      CompendiumScreen(onClose: game.closeCompendiumScreen),
                  MetaUnlockScreen.overlayKey: (_, game) => MetaUnlockScreen(
                    wallet: game.metaWallet,
                    unlocks: game.metaUnlocks,
                    onClose: game.closeMetaUnlocksScreen,
                  ),
                  CharacterSelectOverlay.overlayKey: (_, game) =>
                      CharacterSelectOverlay(
                        selectedCharacterId: game.activeCharacterId,
                        characters: game.availableCharacters,
                        sprites: game.characterSprites,
                        onSelect: game.selectCharacter,
                        onClose: game.closeCharacterSelect,
                      ),
                  EscapeMenuOverlay.overlayKey: (context, game) =>
                      EscapeMenuOverlay(
                        inRun: game.flowState == GameFlowState.stage,
                        wallet: game.metaWallet,
                        onClose: game.closeEscapeMenu,
                        onEnterHomeBase: game.enterHomeBaseFromMenu,
                        onOptions: game.openOptionsFromMenu,
                        onCompendium: game.openCompendiumFromMenu,
                        onMetaUnlocks: game.openMetaUnlocksFromMenu,
                        onStressTest: () => Navigator.of(
                          context,
                        ).pushReplacementNamed('/stress'),
                        stressStats: game.stressStatsSnapshot,
                        statsState: game.statsScreenState,
                        onContinue: game.continueRunFromMenu,
                        onAbort: game.abortRunFromMenu,
                      ),
                  HomeBaseOverlay.overlayKey: (_, game) =>
                      ValueListenableBuilder<CharacterId>(
                        valueListenable: game.activeCharacterListenable,
                        builder: (context, activeCharacterId, _) {
                          return ValueListenableBuilder<bool>(
                            valueListenable: game.characterSelectorReady,
                            builder: (context, canOpen, _) {
                              return HomeBaseOverlay(
                                wallet: game.metaWallet,
                                selectedCharacterName: game.characterNameFor(
                                  activeCharacterId,
                                ),
                                canOpenCharacterSelect: canOpen,
                                onOpenCharacterSelect: game.openCharacterSelect,
                              );
                            },
                          );
                        },
                      ),
                  AreaSelectScreen.overlayKey: (_, game) => AreaSelectScreen(
                    onAreaSelected: game.beginStageFromAreaSelect,
                    onReturn: game.returnToHomeBase,
                    unlocks: game.metaUnlocks,
                  ),
                  DeathScreen.overlayKey: (_, game) => DeathScreen(
                    summary: game.runSummary,
                    completed: game.runCompleted,
                    onRestart: game.restartRunFromDeath,
                    onReturn: game.returnToHomeBaseFromDeath,
                    wallet: game.metaWallet,
                    analysisState: game.runAnalysisState,
                  ),
                  FirstRunHintsOverlay.overlayKey: (_, game) =>
                      FirstRunHintsOverlay(
                        onDismiss: game.dismissFirstRunHints,
                      ),
                  FlowDebugOverlay.overlayKey: (_, game) => FlowDebugOverlay(
                    flowState: game.flowState,
                    onSelectState: game.debugJumpToState,
                    onClose: game.toggleFlowDebugOverlay,
                  ),
                },
                initialActiveOverlays: widget.stressTest
                    ? const [VirtualStickOverlay.overlayKey]
                    : const [StartScreen.overlayKey],
              ),
            ),
          ],
        );
      },
    );
  }
}
