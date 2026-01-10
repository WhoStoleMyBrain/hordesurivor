import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show KeyEventResult;
import 'package:flutter/services.dart';

import '../data/contract_defs.dart';
import '../data/enemy_defs.dart';
import '../data/ids.dart';
import '../data/item_defs.dart';
import '../data/skill_defs.dart';
import '../data/skill_upgrade_defs.dart';
import '../data/stat_defs.dart';
import '../data/tags.dart';
import '../data/area_defs.dart';
import '../render/damage_number_component.dart';
import '../render/enemy_component.dart';
import '../render/effect_component.dart';
import '../render/player_component.dart';
import '../render/portal_component.dart';
import '../render/projectile_batch_component.dart';
import '../render/projectile_component.dart';
import '../render/pickup_component.dart';
import '../render/sprite_pipeline.dart';
import '../ui/area_select_screen.dart';
import '../ui/compendium_screen.dart';
import '../ui/death_screen.dart';
import '../ui/flow_debug_overlay.dart';
import '../ui/hud_overlay.dart';
import '../ui/hud_state.dart';
import '../ui/home_base_overlay.dart';
import '../ui/meta_unlock_screen.dart';
import '../ui/options_screen.dart';
import '../ui/selection_overlay.dart';
import '../ui/selection_state.dart';
import '../ui/start_screen.dart';
import '../ui/stats_overlay.dart';
import '../ui/stats_screen_state.dart';
import 'damage_system.dart';
import 'effect_pool.dart';
import 'effect_state.dart';
import 'effect_system.dart';
import 'enemy_pool.dart';
import 'enemy_state.dart';
import 'enemy_system.dart';
import 'experience_system.dart';
import 'level_up_system.dart';
import 'meta_currency_wallet.dart';
import 'meta_unlocks.dart';
import 'player_state.dart';
import 'pickup_pool.dart';
import 'pickup_state.dart';
import 'projectile_pool.dart';
import 'projectile_state.dart';
import 'projectile_system.dart';
import 'skill_system.dart';
import 'spatial_grid.dart';
import 'spawn_director.dart';
import 'spawner_system.dart';
import 'game_flow_state.dart';
import 'run_summary.dart';
import 'stage_timer.dart';

class HordeGame extends FlameGame with KeyboardEvents, PanDetector {
  HordeGame({this.stressTest = false}) : super();

  static const double _fixedDelta = 1 / 60;
  static const double _playerRadius = 16;
  static const double _playerSpeed = 80;
  static const double _playerMaxHp = 100;
  static const double _enemyRadius = 14;
  static const double _enemyContactDamagePerSecond = 12;
  static const int _stressWaveFrontlineCount = 260;
  static const int _stressWaveMixedCount = 200;
  static const int _stressWaveEliteCount = 90;
  static const int _stressEnemyCount =
      _stressWaveFrontlineCount + _stressWaveMixedCount + _stressWaveEliteCount;
  static const int _stressProjectileBurstCount = 1100;
  static const double _stressProjectileInterval = 4;
  static const int _maxFixedStepsPerFrame = 5;
  static const double _panDeadZone = 8;
  static const double _panMaxRadius = 72;
  static const String _playerSpriteId = 'player_base';
  static const String _projectileSpriteId = 'projectile_firebolt';
  static const String _pickupSpriteId = 'pickup_xp_orb';
  static const double _portalRadius = 26;
  static const double _portalLockoutDuration = 0.75;
  static const double _stageWaveInterval = 3.0;
  static const int _baseStageWaveCount = 4;
  static const double _baseChampionChance = 0.05;
  static const double _pickupRadiusBase = 32;
  static const double _pickupLifetime = 8;
  static const TagSet _igniteDamageTags = TagSet(
    elements: {ElementTag.fire},
    effects: {EffectTag.dot},
  );

  double _accumulator = 0;
  double _frameTimeMs = 0;
  double _fps = 0;
  double _stressProjectileTimer = 0;
  double _telegraphOpacityMultiplier = 1.0;
  final bool stressTest;
  late final PlayerState _playerState;
  late final PlayerComponent _playerComponent;
  final SpritePipeline _spritePipeline = SpritePipeline();
  final Map<EnemyId, Image> _enemySprites = {};
  Image? _projectileSprite;
  Image? _pickupSprite;
  ProjectileBatchComponent? _projectileBatchComponent;
  final Set<LogicalKeyboardKey> _keysPressed = {};
  final Vector2 _keyboardDirection = Vector2.zero();
  final Vector2 _panDirection = Vector2.zero();
  bool _isPanning = false;
  Vector2? _panStart;
  late final EnemyPool _enemyPool;
  late final EnemySystem _enemySystem;
  late final SpawnerSystem _spawnerSystem;
  late final SpawnDirector _spawnDirector;
  bool _spawnerReady = false;
  late final ProjectilePool _projectilePool;
  late final ProjectileSystem _projectileSystem;
  late final EffectPool _effectPool;
  late final EffectSystem _effectSystem;
  late final SkillSystem _skillSystem;
  late final PickupPool _pickupPool;
  late final SpatialGrid _enemyGrid;
  late final DamageSystem _damageSystem;
  late final ExperienceSystem _experienceSystem;
  late final LevelUpSystem _levelUpSystem;
  late final PortalComponent _portalComponent = PortalComponent(
    radius: _portalRadius,
    label: 'AREA PORTAL',
  );
  final PlayerHudState _hudState = PlayerHudState();
  final SelectionState _selectionState = SelectionState();
  final StatsScreenState _statsScreenState = StatsScreenState();
  final RunSummary _runSummary = RunSummary();
  final MetaCurrencyWallet _metaWallet = MetaCurrencyWallet();
  final MetaUnlocks _metaUnlocks = MetaUnlocks();
  final List<ContractId> _activeContracts = [];
  final Map<ProjectileState, ProjectileComponent> _projectileComponents = {};
  final Map<EnemyState, EnemyComponent> _enemyComponents = {};
  final ValueNotifier<bool> highContrastTelegraphs = ValueNotifier(false);
  final Map<EffectState, EffectComponent> _effectComponents = {};
  final Map<PickupState, PickupComponent> _pickupComponents = {};
  final List<DamageNumberComponent> _damageNumberPool = [];
  final TextPaint _enemyDamagePaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFFD166),
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    ),
  );
  final math.Random _stressRandom = math.Random(41);
  final Vector2 _stressPosition = Vector2.zero();
  final Vector2 _stressVelocity = Vector2.zero();
  final math.Random _damageNumberRandom = math.Random(29);
  final Vector2 _damageNumberPosition = Vector2.zero();
  final Vector2 _damageNumberVelocity = Vector2.zero();
  final Vector2 _portalPosition = Vector2.zero();
  double _portalLockoutTimer = 0;
  GameFlowState _flowState = GameFlowState.start;
  bool _inputLocked = false;
  VoidCallback? _selectionListener;
  StageTimer? _stageTimer;
  AreaDef? _activeArea;
  int _currentSectionIndex = 0;
  bool _runCompleted = false;
  double _contractProjectileSpeedMultiplier = 1.0;
  double _contractMoveSpeedMultiplier = 1.0;
  double _contractEliteWeightMultiplier = 1.0;
  double _contractSupportWeightMultiplier = 1.0;
  double _contractRewardMultiplier = 1.0;
  int _contractHeat = 0;
  List<String> _activeContractNames = const [];

  PlayerHudState get hudState => _hudState;
  SelectionState get selectionState => _selectionState;
  StatsScreenState get statsScreenState => _statsScreenState;
  GameFlowState get flowState => _flowState;
  RunSummary get runSummary => _runSummary;
  bool get runCompleted => _runCompleted;
  MetaCurrencyWallet get metaWallet => _metaWallet;
  MetaUnlocks get metaUnlocks => _metaUnlocks;

  @override
  backgroundColor() => const Color(0xFF0F1117);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _metaWallet.load();
    await _metaUnlocks.load();
    _selectionListener = _handleSelectionStateChanged;
    _selectionState.addListener(_selectionListener!);
    if (stressTest) {
      _flowState = GameFlowState.stage;
    }
    await _spritePipeline.loadAndGenerateFromAsset(
      'assets/sprites/recipes.json',
    );
    final playerSprite = _spritePipeline.lookup(_playerSpriteId);
    if (playerSprite == null) {
      debugPrint('Sprite cache missing $_playerSpriteId.');
    }
    for (final def in enemyDefs) {
      final spriteId = def.spriteId;
      if (spriteId == null) {
        continue;
      }
      final spriteImage = _spritePipeline.lookup(spriteId);
      if (spriteImage == null) {
        debugPrint('Sprite cache missing $spriteId for ${def.id}.');
        continue;
      }
      _enemySprites[def.id] = spriteImage;
    }
    _projectileSprite = _spritePipeline.lookup(_projectileSpriteId);
    if (_projectileSprite == null) {
      debugPrint('Sprite cache missing $_projectileSpriteId.');
    }
    _pickupSprite = _spritePipeline.lookup(_pickupSpriteId);
    if (_pickupSprite == null) {
      debugPrint('Sprite cache missing $_pickupSpriteId.');
    }
    _playerState = PlayerState(
      position: size / 2,
      maxHp: _playerMaxHp,
      moveSpeed: _playerSpeed,
    );
    _experienceSystem = ExperienceSystem();
    _spawnDirector = SpawnDirector(experienceSystem: _experienceSystem);
    _levelUpSystem = LevelUpSystem(random: math.Random(11));
    _playerComponent = PlayerComponent(
      state: _playerState,
      radius: _playerRadius,
      spriteImage: playerSprite,
    );
    _playerComponent.syncWithState();
    await add(_playerComponent);

    _updatePortalPosition();
    _portalComponent.position.setFrom(_portalPosition);
    await add(_portalComponent);

    _enemyPool = EnemyPool(initialCapacity: stressTest ? 600 : 48);
    _projectilePool = ProjectilePool(initialCapacity: stressTest ? 1400 : 64);
    _effectPool = EffectPool(initialCapacity: stressTest ? 180 : 32);
    _pickupPool = PickupPool(initialCapacity: stressTest ? 220 : 48);
    if (_projectileSprite != null) {
      _projectileBatchComponent = ProjectileBatchComponent(
        pool: _projectilePool,
        spriteImage: _projectileSprite!,
        color: const Color(0xFFFF8C3B),
      );
      await add(_projectileBatchComponent!);
    }
    _enemySystem = EnemySystem(
      pool: _enemyPool,
      projectilePool: _projectilePool,
      random: math.Random(19),
      onProjectileSpawn: _handleProjectileSpawn,
      onSpawn: _registerEnemyComponent,
      onSelfDestruct: _handleEnemySelfDestruct,
      championChance: _baseChampionChance,
    );
    _enemyGrid = SpatialGrid(cellSize: 64);
    _projectileSystem = ProjectileSystem(_projectilePool);
    _effectSystem = EffectSystem(_effectPool);
    _skillSystem = SkillSystem(
      projectilePool: _projectilePool,
      effectPool: _effectPool,
    );
    _damageSystem = DamageSystem(DamageEventPool(initialCapacity: 64));
    for (var i = 0; i < 32; i++) {
      _damageNumberPool.add(
        DamageNumberComponent(
          textPaint: _enemyDamagePaint,
          onComplete: _releaseDamageNumber,
        ),
      );
    }
    _spawnerSystem = SpawnerSystem(
      pool: _enemyPool,
      random: math.Random(7),
      arenaSize: size,
      waves: stressTest
          ? const [
              SpawnWave(
                time: 0,
                count: _stressWaveFrontlineCount,
                roleWeights: {
                  EnemyRole.chaser: 5,
                  EnemyRole.ranged: 3,
                  EnemyRole.spawner: 2,
                },
                variantWeights: {
                  EnemyVariant.base: 6,
                  EnemyVariant.champion: 1,
                },
              ),
              SpawnWave(
                time: 3,
                count: _stressWaveMixedCount,
                roleWeights: {
                  EnemyRole.disruptor: 2,
                  EnemyRole.zoner: 2,
                  EnemyRole.supportHealer: 1,
                  EnemyRole.supportBuffer: 1,
                  EnemyRole.pattern: 1,
                  EnemyRole.ranged: 2,
                },
                variantWeights: {
                  EnemyVariant.base: 5,
                  EnemyVariant.champion: 1,
                },
              ),
              SpawnWave(
                time: 6,
                count: _stressWaveEliteCount,
                enemyWeights: {
                  EnemyId.hellknight: 2,
                  EnemyId.archonLancer: 2,
                  EnemyId.cinderling: 3,
                  EnemyId.warden: 2,
                },
                variantWeights: {
                  EnemyVariant.base: 4,
                  EnemyVariant.champion: 1,
                },
              ),
            ]
          : const [
              SpawnWave(time: 0, count: 4, roleWeights: {EnemyRole.chaser: 3}),
              SpawnWave(
                time: 2,
                count: 3,
                roleWeights: {EnemyRole.chaser: 2, EnemyRole.ranged: 1},
              ),
              SpawnWave(
                time: 5,
                count: 5,
                roleWeights: {
                  EnemyRole.chaser: 3,
                  EnemyRole.ranged: 2,
                  EnemyRole.spawner: 1,
                },
              ),
            ],
      onSpawn: _registerEnemyComponent,
      championChance: _baseChampionChance,
    );
    _spawnerReady = true;
    if (stressTest) {
      _stressProjectileTimer = _stressProjectileInterval;
      debugPrint(
        'Stress scene active: spawning $_stressEnemyCount enemies and '
        '$_stressProjectileBurstCount-projectile bursts.',
      );
    }
    setHighContrastTelegraphs(highContrastTelegraphs.value);
    _updateInputLock();
    _syncHudState();
    _syncPortalVisibility();
  }

  @override
  void update(double dt) {
    final clampedDt = math.min(dt, 0.25);
    _frameTimeMs = clampedDt * 1000;
    _fps = clampedDt > 0 ? 1 / clampedDt : 0;
    if (_flowState == GameFlowState.homeBase) {
      _accumulator = math.min(
        _accumulator + clampedDt,
        _fixedDelta * _maxFixedStepsPerFrame,
      );
      while (_accumulator >= _fixedDelta) {
        _stepHomeBase(_fixedDelta);
        _accumulator -= _fixedDelta;
      }
      super.update(dt);
      return;
    }
    if (_flowState != GameFlowState.stage) {
      super.update(dt);
      return;
    }
    _accumulator = math.min(
      _accumulator + clampedDt,
      _fixedDelta * _maxFixedStepsPerFrame,
    );
    while (_accumulator >= _fixedDelta) {
      _step(_fixedDelta);
      _accumulator -= _fixedDelta;
    }
    super.update(dt);
  }

  void _step(double dt) {
    if (!_spawnerReady) {
      return;
    }
    if (_selectionState.active || overlays.isActive(StatsOverlay.overlayKey)) {
      _playerState.movementIntent.setZero();
      _playerComponent.syncWithState();
      _syncHudState();
      return;
    }
    _runSummary.timeAlive += dt;
    _applyInput();
    _playerState.step(dt);
    if (!stressTest && _stageTimer != null) {
      final sectionChanged = _stageTimer!.update(dt);
      if (sectionChanged) {
        _applyStageSection();
      }
      if (_stageTimer!.isComplete) {
        _handleStageComplete();
        return;
      }
    }
    _spawnerSystem.update(dt, _playerState.position);
    _enemySystem.update(dt, _playerState.position, size);
    _enemyGrid.rebuild(_enemyPool.active);
    _skillSystem.update(
      dt: dt,
      playerPosition: _playerState.position,
      aimDirection: _playerState.movementIntent,
      stats: _playerState.stats,
      enemyPool: _enemyPool,
      enemyGrid: _enemyGrid,
      onProjectileSpawn: _handleProjectileSpawn,
      onEffectSpawn: _handleEffectSpawn,
      onProjectileDespawn: _handleProjectileDespawn,
      onPlayerImpulse:
          ({
            required double dx,
            required double dy,
            required double speed,
            required double duration,
          }) {
            _playerState.addImpulse(
              dx: dx,
              dy: dy,
              speed: speed,
              duration: duration,
            );
          },
      onPlayerDeflect: ({required double radius, required double duration}) {
        _playerState.startDeflect(radius: radius, duration: duration);
      },
      onEnemyDamaged: _damageSystem.queueEnemyDamage,
    );
    if (stressTest) {
      _spawnStressProjectiles(dt);
    }
    final contactRadius = _playerRadius + _enemyRadius;
    final contactRadiusSquared = contactRadius * contactRadius;
    for (final enemy in _enemyPool.active) {
      if (!enemy.active) {
        continue;
      }
      final dx = enemy.position.x - _playerState.position.x;
      final dy = enemy.position.y - _playerState.position.y;
      final distanceSquared = dx * dx + dy * dy;
      if (distanceSquared <= contactRadiusSquared) {
        _damageSystem.queuePlayerDamage(
          _playerState,
          _enemyContactDamagePerSecond * dt,
        );
      }
    }
    _projectileSystem.update(
      dt,
      size,
      onDespawn: _handleProjectileDespawn,
      onEnemyHit: _damageSystem.queueEnemyDamage,
      enemyGrid: _enemyGrid,
      enemyRadius: _enemyRadius,
      playerState: _playerState,
      playerRadius: _playerRadius,
      onPlayerHit: (damage) {
        _damageSystem.queuePlayerDamage(_playerState, damage);
      },
    );
    _effectSystem.update(
      dt,
      enemyPool: _enemyPool,
      enemyGrid: _enemyGrid,
      playerPosition: _playerState.position,
      onDespawn: _handleEffectDespawn,
      onEnemyDamaged: _damageSystem.queueEnemyDamage,
    );
    _applyEnemyStatusDamage(dt);
    _damageSystem.resolve(
      onEnemyDefeated: _handleEnemyDefeated,
      onEnemyDamaged: _handleEnemyDamaged,
      onPlayerDamaged: _handlePlayerDamaged,
      onPlayerDefeated: _handlePlayerDefeated,
    );
    _updatePickups(dt);
    _syncHudState();

    _playerState.clampToBounds(
      min: Vector2(_playerRadius, _playerRadius),
      max: Vector2(size.x - _playerRadius, size.y - _playerRadius),
    );

    _playerComponent.syncWithState();
  }

  void beginHomeBaseFromStartScreen() {
    if (_flowState == GameFlowState.homeBase) {
      return;
    }
    _setFlowState(GameFlowState.homeBase);
    overlays.remove(StartScreen.overlayKey);
    overlays.remove(OptionsScreen.overlayKey);
    overlays.remove(CompendiumScreen.overlayKey);
    overlays.remove(MetaUnlockScreen.overlayKey);
    overlays.add(HomeBaseOverlay.overlayKey);
    _syncHudState();
  }

  void openOptionsFromStartScreen() {
    if (_flowState != GameFlowState.start) {
      return;
    }
    if (overlays.isActive(OptionsScreen.overlayKey)) {
      return;
    }
    overlays.remove(StartScreen.overlayKey);
    overlays.add(OptionsScreen.overlayKey);
  }

  void openCompendiumFromStartScreen() {
    if (_flowState != GameFlowState.start) {
      return;
    }
    if (overlays.isActive(CompendiumScreen.overlayKey)) {
      return;
    }
    overlays.remove(StartScreen.overlayKey);
    overlays.add(CompendiumScreen.overlayKey);
  }

  void openMetaUnlocksFromStartScreen() {
    if (_flowState != GameFlowState.start) {
      return;
    }
    if (overlays.isActive(MetaUnlockScreen.overlayKey)) {
      return;
    }
    overlays.remove(StartScreen.overlayKey);
    overlays.add(MetaUnlockScreen.overlayKey);
  }

  void closeOptionsFromStartScreen() {
    if (_flowState != GameFlowState.start) {
      return;
    }
    overlays.remove(OptionsScreen.overlayKey);
    overlays.add(StartScreen.overlayKey);
  }

  void closeCompendiumFromStartScreen() {
    if (_flowState != GameFlowState.start) {
      return;
    }
    overlays.remove(CompendiumScreen.overlayKey);
    overlays.add(StartScreen.overlayKey);
  }

  void closeMetaUnlocksFromStartScreen() {
    if (_flowState != GameFlowState.start) {
      return;
    }
    overlays.remove(MetaUnlockScreen.overlayKey);
    overlays.add(StartScreen.overlayKey);
  }

  void setHighContrastTelegraphs(bool enabled) {
    highContrastTelegraphs.value = enabled;
    _telegraphOpacityMultiplier = enabled ? 1.4 : 1.0;
    for (final component in _enemyComponents.values) {
      component.applyTelegraphOpacity(_telegraphOpacityMultiplier);
    }
  }

  void beginStageFromAreaSelect(AreaDef area, List<ContractId> contracts) {
    _activeArea = area;
    _applyContracts(contracts);
    _stageTimer = StageTimer(
      duration: area.stageDuration,
      sections: area.sections,
    );
    _currentSectionIndex = 0;
    _applyStageSection(force: true);
    _selectionState.clear();
    overlays.remove(SelectionOverlay.overlayKey);
    overlays.remove(StatsOverlay.overlayKey);
    _resetPlayerProgression();
    _resetRunSummary();
    _runSummary.areaName = area.name;
    _runSummary.contractHeat = _contractHeat;
    _runSummary.metaRewardMultiplier = _contractRewardMultiplier;
    _runSummary.contractNames = _activeContracts
        .map((id) => contractDefsById[id]?.name ?? id.name)
        .toList(growable: false);
    _revivePlayer();
    _resetStageActors();
    _setFlowState(GameFlowState.stage);
    overlays.remove(AreaSelectScreen.overlayKey);
    overlays.remove(HomeBaseOverlay.overlayKey);
    overlays.remove(DeathScreen.overlayKey);
    overlays.add(HudOverlay.overlayKey);
    _syncHudState();
  }

  void returnToHomeBase() {
    _resetStageActors();
    _activeArea = null;
    _stageTimer = null;
    _portalLockoutTimer = _portalLockoutDuration;
    _setFlowState(GameFlowState.homeBase);
    overlays.remove(AreaSelectScreen.overlayKey);
    overlays.remove(HudOverlay.overlayKey);
    overlays.remove(DeathScreen.overlayKey);
    overlays.remove(StatsOverlay.overlayKey);
    overlays.add(HomeBaseOverlay.overlayKey);
    _syncHudState();
  }

  void restartRunFromDeath() {
    final area = _activeArea;
    if (area == null) {
      returnToHomeBaseFromDeath();
      return;
    }
    beginStageFromAreaSelect(area, _activeContracts.toList(growable: false));
  }

  void returnToHomeBaseFromDeath() {
    _resetStageActors();
    _activeArea = null;
    _stageTimer = null;
    _setFlowState(GameFlowState.homeBase);
    overlays.remove(DeathScreen.overlayKey);
    overlays.remove(HudOverlay.overlayKey);
    overlays.remove(StatsOverlay.overlayKey);
    overlays.add(HomeBaseOverlay.overlayKey);
    _syncHudState();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_spawnerReady) {
      _spawnerSystem.updateArenaSize(size);
    }
    _updatePortalPosition();
    _portalComponent.position.setFrom(_portalPosition);
  }

  void _applyInput() {
    if (_inputLocked) {
      _playerState.movementIntent.setZero();
      return;
    }
    if (_isPanning) {
      final length = _panDirection.length;
      if (length <= _panDeadZone) {
        _playerState.movementIntent.setZero();
        return;
      }
      final clampedLength = length.clamp(_panDeadZone, _panMaxRadius);
      final scaledMagnitude =
          (clampedLength - _panDeadZone) / (_panMaxRadius - _panDeadZone);
      _playerState.movementIntent
        ..setFrom(_panDirection)
        ..normalize()
        ..scale(scaledMagnitude);
      return;
    }

    var x = 0.0;
    var y = 0.0;
    if (_keysPressed.contains(LogicalKeyboardKey.keyA) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      x -= 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.keyD) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      x += 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.keyW) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      y -= 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.keyS) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      y += 1;
    }
    _keyboardDirection.setValues(x, y);
    _playerState.movementIntent.setFrom(_keyboardDirection);
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.f1) {
      toggleFlowDebugOverlay();
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.tab ||
            event.logicalKey == LogicalKeyboardKey.keyI)) {
      toggleStatsOverlay();
      return KeyEventResult.handled;
    }
    if (_inputLocked) {
      _keysPressed.clear();
      _keyboardDirection.setZero();
      return KeyEventResult.handled;
    }
    _keysPressed
      ..clear()
      ..addAll(keysPressed);
    return KeyEventResult.handled;
  }

  @override
  void onPanStart(DragStartInfo info) {
    if (_inputLocked) {
      return;
    }
    _isPanning = true;
    _panStart = info.eventPosition.widget.clone();
    _panDirection.setZero();
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (_inputLocked) {
      return;
    }
    final start = _panStart;
    if (start == null) {
      return;
    }
    _panDirection.setFrom(info.eventPosition.widget - start);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (_inputLocked) {
      return;
    }
    _isPanning = false;
    _panStart = null;
    _panDirection.setZero();
  }

  void _handleProjectileSpawn(ProjectileState projectile) {
    if (_projectileBatchComponent != null && !projectile.fromEnemy) {
      return;
    }
    final component = ProjectileComponent(
      state: projectile,
      color: projectile.fromEnemy
          ? const Color(0xFF7AA2F7)
          : const Color(0xFFFF8C3B),
      spriteImage: projectile.fromEnemy ? null : _projectileSprite,
    );
    _projectileComponents[projectile] = component;
    add(component);
  }

  void _handleProjectileDespawn(ProjectileState projectile) {
    if (projectile.spawnImpactEffect && projectile.impactEffectKind != null) {
      final effect = _effectPool.acquire();
      effect.reset(
        kind: projectile.impactEffectKind!,
        shape: projectile.impactEffectShape,
        position: projectile.position,
        direction: projectile.impactDirection,
        radius: projectile.impactEffectRadius,
        length: projectile.impactEffectLength,
        width: projectile.impactEffectWidth,
        duration: projectile.impactEffectDuration,
        damagePerSecond: projectile.impactEffectDamagePerSecond,
        slowMultiplier: projectile.impactEffectSlowMultiplier,
        slowDuration: projectile.impactEffectSlowDuration,
        oilDuration: projectile.impactEffectOilDuration,
      );
      _handleEffectSpawn(effect);
    }
    final component = _projectileComponents.remove(projectile);
    component?.removeFromParent();
  }

  void _handleEffectSpawn(EffectState effect) {
    final component = EffectComponent(state: effect);
    _effectComponents[effect] = component;
    add(component);
  }

  void _handleEffectDespawn(EffectState effect) {
    final component = _effectComponents.remove(effect);
    component?.removeFromParent();
  }

  void _handleEnemyDefeated(EnemyState enemy) {
    if (!stressTest) {
      _runSummary.enemiesDefeated += 1;
      if (enemy.xpReward > 0) {
        _spawnPickup(
          kind: PickupKind.xpOrb,
          position: enemy.position,
          value: enemy.xpReward,
        );
      }
    }
    final component = _enemyComponents.remove(enemy);
    component?.removeFromParent();
    _enemyPool.release(enemy);
  }

  void _handleEnemySelfDestruct(EnemyState enemy) {
    if (!enemy.active) {
      return;
    }
    final damage = enemy.hp > 1 ? enemy.hp : 1.0;
    _damageSystem.queueEnemyDamage(enemy, damage);
  }

  void _registerEnemyComponent(EnemyState enemy) {
    final component = EnemyComponent(
      state: enemy,
      radius: _enemyRadius,
      spriteImage: _enemySprites[enemy.id],
      telegraphOpacityMultiplier: _telegraphOpacityMultiplier,
    );
    _enemyComponents[enemy] = component;
    add(component);
  }

  void _registerPickupComponent(PickupState pickup) {
    final component = PickupComponent(
      state: pickup,
      spriteImage: _pickupSprite,
    );
    _pickupComponents[pickup] = component;
    add(component);
  }

  void _handleEnemyDamaged(EnemyState enemy, double amount) {
    if (amount <= 0) {
      return;
    }
    final component = _acquireDamageNumber();
    final jitterX = (_damageNumberRandom.nextDouble() - 0.5) * 10;
    final jitterY = (_damageNumberRandom.nextDouble() - 0.5) * 6;
    _damageNumberPosition.setValues(
      enemy.position.x + jitterX,
      enemy.position.y + jitterY,
    );
    _damageNumberVelocity.setValues(
      0,
      -18 - _damageNumberRandom.nextDouble() * 8,
    );
    component.reset(
      position: _damageNumberPosition,
      amount: amount,
      textPaint: _enemyDamagePaint,
      velocity: _damageNumberVelocity,
    );
    if (!component.isMounted) {
      add(component);
    }
  }

  void _handlePlayerDamaged(double amount) {
    if (_flowState != GameFlowState.stage) {
      return;
    }
    _runSummary.damageTaken += amount;
  }

  DamageNumberComponent _acquireDamageNumber() {
    if (_damageNumberPool.isNotEmpty) {
      return _damageNumberPool.removeLast();
    }
    return DamageNumberComponent(
      textPaint: _enemyDamagePaint,
      onComplete: _releaseDamageNumber,
    );
  }

  void _releaseDamageNumber(DamageNumberComponent component) {
    component.removeFromParent();
    _damageNumberPool.add(component);
  }

  void selectChoice(SelectionChoice choice) {
    _levelUpSystem.applyChoice(
      choice: choice,
      playerState: _playerState,
      skillSystem: _skillSystem,
    );
    _hudState.triggerRewardMessage(_rewardMessageForChoice(choice));
    _offerSelectionIfNeeded();
  }

  void rerollSelection() {
    final rerolled = _levelUpSystem.rerollChoices(
      playerState: _playerState,
      skillSystem: _skillSystem,
    );
    if (rerolled) {
      _selectionState.showChoices(
        _levelUpSystem.choices,
        rerollsRemaining: _levelUpSystem.rerollsRemaining,
      );
    }
  }

  void _offerSelectionIfNeeded() {
    _levelUpSystem.buildChoices(
      playerState: _playerState,
      skillSystem: _skillSystem,
    );
    if (_levelUpSystem.hasChoices) {
      _selectionState.showChoices(
        _levelUpSystem.choices,
        rerollsRemaining: _levelUpSystem.rerollsRemaining,
      );
      overlays.add(SelectionOverlay.overlayKey);
    } else {
      _selectionState.clear();
      overlays.remove(SelectionOverlay.overlayKey);
    }
  }

  String _rewardMessageForChoice(SelectionChoice choice) {
    switch (choice.type) {
      case SelectionType.skill:
        return 'Skill: ${choice.title}';
      case SelectionType.item:
        return 'Item: ${choice.title}';
      case SelectionType.skillUpgrade:
        return 'Upgrade: ${choice.title}';
    }
  }

  void _syncHudState() {
    final stageTimer = _stageTimer;
    String? sectionNote;
    var threatTier = 0;
    if (_flowState == GameFlowState.stage && stageTimer != null) {
      final activeArea = _activeArea;
      if (activeArea != null) {
        final index = stageTimer.currentSectionIndex;
        if (index >= 0 && index < activeArea.sections.length) {
          final section = activeArea.sections[index];
          sectionNote = section.note;
          threatTier = section.threatTier;
        }
      }
    }
    final inStage = _flowState == GameFlowState.stage && stageTimer != null;
    final buildTags = _collectBuildTags();
    _hudState.update(
      hp: _playerState.hp,
      maxHp: _playerState.maxHp,
      level: _experienceSystem.level,
      xp: _experienceSystem.currentXp,
      xpToNext: _experienceSystem.xpToNext,
      score: inStage ? _runSummary.score : 0,
      showPerformance: stressTest,
      fps: _fps,
      frameTimeMs: _frameTimeMs,
      stageElapsed: inStage ? stageTimer.elapsed : 0,
      stageDuration: inStage ? stageTimer.duration : 0,
      sectionIndex: inStage ? stageTimer.currentSectionIndex : 0,
      sectionCount: inStage ? stageTimer.sectionCount : 0,
      threatTier: inStage ? threatTier : 0,
      sectionNote: inStage ? sectionNote : null,
      buildTags: buildTags,
      contractHeat: inStage ? _contractHeat : 0,
      contractNames: inStage ? _activeContractNames : const [],
    );
    _statsScreenState.update(
      statValues: _collectStatValues(),
      skills: _skillSystem.skillIds,
      upgrades: _levelUpSystem.appliedUpgrades.toList(),
      items: _levelUpSystem.appliedItems.toList(),
      rerollsRemaining: _levelUpSystem.rerollsRemaining,
      rerollsMax: _levelUpSystem.rerollsMax,
    );
  }

  void _applyEnemyStatusDamage(double dt) {
    for (final enemy in _enemyPool.active) {
      if (!enemy.active) {
        continue;
      }
      if (enemy.igniteTimer > 0 && enemy.igniteDamagePerSecond > 0) {
        final tickDuration = math.min(dt, enemy.igniteTimer);
        if (tickDuration > 0) {
          _damageSystem.queueEnemyDamage(
            enemy,
            enemy.igniteDamagePerSecond * tickDuration,
            tags: _igniteDamageTags,
          );
        }
      }
      enemy.updateStatusTimers(dt);
    }
  }

  TagSet _collectBuildTags() {
    var tags = const TagSet();
    for (final skillId in _skillSystem.skillIds) {
      final def = skillDefsById[skillId];
      if (def != null) {
        tags = tags.merge(def.tags);
      }
    }
    for (final upgradeId in _levelUpSystem.appliedUpgrades) {
      final def = skillUpgradeDefsById[upgradeId];
      if (def != null) {
        tags = tags.merge(def.tags);
      }
    }
    for (final itemId in _levelUpSystem.appliedItems) {
      final def = itemDefsById[itemId];
      if (def != null) {
        tags = tags.merge(def.tags);
      }
    }
    return tags;
  }

  Map<StatId, double> _collectStatValues() {
    final values = <StatId, double>{};
    for (final stat in StatId.values) {
      final value = _playerState.stats.value(stat);
      if (stat == StatId.maxHp || stat == StatId.moveSpeed) {
        values[stat] = value;
        continue;
      }
      if (value.abs() > 0.0001) {
        values[stat] = value;
      }
    }
    return values;
  }

  void _handleSelectionStateChanged() {
    _updateInputLock();
  }

  void _resetPointerInput() {
    _isPanning = false;
    _panStart = null;
    _panDirection.setZero();
    _playerState.movementIntent.setZero();
  }

  void _setFlowState(GameFlowState state) {
    if (_flowState == state) {
      return;
    }
    _flowState = state;
    _syncPortalVisibility();
    _updateInputLock();
  }

  void _updateInputLock() {
    final locked =
        _selectionState.active ||
        overlays.isActive(StatsOverlay.overlayKey) ||
        !(_flowState == GameFlowState.stage ||
            _flowState == GameFlowState.homeBase);
    if (_inputLocked == locked) {
      return;
    }
    _inputLocked = locked;
    if (_inputLocked) {
      _keysPressed.clear();
      _keyboardDirection.setZero();
      _resetPointerInput();
    }
  }

  void toggleFlowDebugOverlay() {
    if (overlays.isActive(FlowDebugOverlay.overlayKey)) {
      overlays.remove(FlowDebugOverlay.overlayKey);
      return;
    }
    overlays.add(FlowDebugOverlay.overlayKey);
  }

  void toggleStatsOverlay() {
    if (_flowState != GameFlowState.stage || _selectionState.active) {
      return;
    }
    if (overlays.isActive(StatsOverlay.overlayKey)) {
      overlays.remove(StatsOverlay.overlayKey);
    } else {
      overlays.add(StatsOverlay.overlayKey);
    }
    _updateInputLock();
  }

  void debugJumpToState(GameFlowState state) {
    switch (state) {
      case GameFlowState.start:
        _resetToStart();
        _refreshFlowDebugOverlay();
        return;
      case GameFlowState.homeBase:
        beginHomeBaseFromStartScreen();
        _refreshFlowDebugOverlay();
        return;
      case GameFlowState.areaSelect:
        beginHomeBaseFromStartScreen();
        _enterAreaSelect();
        _refreshFlowDebugOverlay();
        return;
      case GameFlowState.stage:
        beginStageFromAreaSelect(areaDefs.first, const []);
        _refreshFlowDebugOverlay();
        return;
      case GameFlowState.death:
        _endRun(completed: false);
        _refreshFlowDebugOverlay();
        return;
    }
  }

  void _resetToStart() {
    _resetStageActors();
    _selectionState.clear();
    _activeArea = null;
    _stageTimer = null;
    _runCompleted = false;
    _setFlowState(GameFlowState.start);
    overlays.remove(HudOverlay.overlayKey);
    overlays.remove(HomeBaseOverlay.overlayKey);
    overlays.remove(AreaSelectScreen.overlayKey);
    overlays.remove(DeathScreen.overlayKey);
    overlays.remove(SelectionOverlay.overlayKey);
    overlays.remove(OptionsScreen.overlayKey);
    overlays.remove(CompendiumScreen.overlayKey);
    overlays.remove(StatsOverlay.overlayKey);
    overlays.add(StartScreen.overlayKey);
    _syncHudState();
  }

  void _refreshFlowDebugOverlay() {
    if (!overlays.isActive(FlowDebugOverlay.overlayKey)) {
      return;
    }
    overlays.remove(FlowDebugOverlay.overlayKey);
    overlays.add(FlowDebugOverlay.overlayKey);
  }

  void _spawnStressProjectiles(double dt) {
    _stressProjectileTimer -= dt;
    if (_stressProjectileTimer > 0) {
      return;
    }
    _stressProjectileTimer = _stressProjectileInterval;

    for (var i = 0; i < _stressProjectileBurstCount; i++) {
      final angle = _stressRandom.nextDouble() * math.pi * 2;
      final radius = _stressRandom.nextDouble() * 240;
      _stressPosition
        ..setValues(math.cos(angle) * radius, math.sin(angle) * radius)
        ..add(_playerState.position);
      _stressPosition.x = _stressPosition.x.clamp(0.0, size.x);
      _stressPosition.y = _stressPosition.y.clamp(0.0, size.y);
      _stressVelocity.setValues(math.cos(angle) * 180, math.sin(angle) * 180);

      final projectile = _projectilePool.acquire();
      projectile.reset(
        position: _stressPosition,
        velocity: _stressVelocity,
        damage: 0.5,
        radius: 3,
        lifespan: 1.8,
        fromEnemy: true,
      );
      _handleProjectileSpawn(projectile);
    }
  }

  void _stepHomeBase(double dt) {
    _applyInput();
    _playerState.step(dt);
    _playerState.clampToBounds(
      min: Vector2(_playerRadius, _playerRadius),
      max: Vector2(size.x - _playerRadius, size.y - _playerRadius),
    );
    _playerComponent.syncWithState();
    _syncHudState();

    if (_portalLockoutTimer > 0) {
      _portalLockoutTimer = math.max(0, _portalLockoutTimer - dt);
    }

    final dx = _playerState.position.x - _portalPosition.x;
    final dy = _playerState.position.y - _portalPosition.y;
    final distanceSquared = dx * dx + dy * dy;
    final triggerRadius = _portalRadius + _playerRadius;
    if (_portalLockoutTimer <= 0 &&
        distanceSquared <= triggerRadius * triggerRadius) {
      _enterAreaSelect();
    }
  }

  void _enterAreaSelect() {
    if (_flowState == GameFlowState.areaSelect) {
      return;
    }
    _setFlowState(GameFlowState.areaSelect);
    overlays.remove(HomeBaseOverlay.overlayKey);
    overlays.add(AreaSelectScreen.overlayKey);
  }

  void _updatePortalPosition() {
    _portalPosition.setValues(size.x * 0.78, size.y * 0.25);
  }

  void _syncPortalVisibility() {
    _portalComponent.visible = _flowState == GameFlowState.homeBase;
  }

  void _applyStageSection({bool force = false}) {
    final timer = _stageTimer;
    final area = _activeArea;
    if (timer == null || area == null) {
      return;
    }
    final sectionIndex = timer.currentSectionIndex;
    if (!force && sectionIndex == _currentSectionIndex) {
      return;
    }
    final previousIndex = _currentSectionIndex;
    _currentSectionIndex = sectionIndex;
    final section = area.sections[sectionIndex];
    final previousSection =
        previousIndex >= 0 && previousIndex < area.sections.length
        ? area.sections[previousIndex]
        : null;
    final sectionDuration = section.endTime - section.startTime;
    _spawnerSystem.resetWaves(
      _buildSectionWaves(
        section: section,
        previousSection: previousSection,
        sectionDuration: sectionDuration,
        sectionIndex: sectionIndex,
      ),
    );
  }

  List<SpawnWave> _buildSectionWaves({
    required StageSection section,
    StageSection? previousSection,
    required double sectionDuration,
    required int sectionIndex,
  }) {
    if (section.roleWeights.isEmpty && section.enemyWeights.isEmpty) {
      return const [];
    }
    final waves = <SpawnWave>[];
    final count = _baseStageWaveCount + sectionIndex;
    var time = 0.0;
    while (time < sectionDuration) {
      final tuning = _spawnDirector.tuneSection(
        section: section,
        previousSection: previousSection,
        sectionDuration: sectionDuration,
        timeIntoSection: time,
      );
      final adjustedRoles = _applyContractRoleWeights(tuning.roleWeights);
      final adjustedVariants = _applyContractVariantWeights(
        tuning.variantWeights,
      );
      waves.add(
        SpawnWave(
          time: time,
          count: count,
          roleWeights: adjustedRoles.isEmpty ? null : adjustedRoles,
          enemyWeights: tuning.enemyWeights.isEmpty
              ? null
              : tuning.enemyWeights,
          variantWeights: adjustedVariants.isEmpty ? null : adjustedVariants,
        ),
      );
      time += _stageWaveInterval;
    }
    return waves;
  }

  void _handleStageComplete() {
    _endRun(completed: true);
  }

  Map<EnemyRole, int> _applyContractRoleWeights(
    Map<EnemyRole, int> roleWeights,
  ) {
    if (roleWeights.isEmpty || _contractSupportWeightMultiplier == 1.0) {
      return roleWeights;
    }
    final adjusted = Map<EnemyRole, int>.from(roleWeights);
    for (final role in const [
      EnemyRole.supportHealer,
      EnemyRole.supportBuffer,
    ]) {
      final weight = adjusted[role];
      if (weight == null || weight <= 0) {
        continue;
      }
      adjusted[role] = math.max(
        1,
        (weight * _contractSupportWeightMultiplier).round(),
      );
    }
    return adjusted;
  }

  Map<EnemyVariant, int> _applyContractVariantWeights(
    Map<EnemyVariant, int> variantWeights,
  ) {
    if (variantWeights.isEmpty || _contractEliteWeightMultiplier == 1.0) {
      return variantWeights;
    }
    final adjusted = Map<EnemyVariant, int>.from(variantWeights);
    final championWeight = adjusted[EnemyVariant.champion];
    if (championWeight != null && championWeight > 0) {
      adjusted[EnemyVariant.champion] = math.max(
        1,
        (championWeight * _contractEliteWeightMultiplier).round(),
      );
    }
    return adjusted;
  }

  void _resetStageActors() {
    for (final projectile in List<ProjectileState>.from(
      _projectilePool.active,
    )) {
      _handleProjectileDespawn(projectile);
      _projectilePool.release(projectile);
    }
    for (final effect in List<EffectState>.from(_effectPool.active)) {
      _handleEffectDespawn(effect);
      _effectPool.release(effect);
    }
    for (final pickup in List<PickupState>.from(_pickupPool.active)) {
      _despawnPickup(pickup);
    }
    for (final enemy in List<EnemyState>.from(_enemyPool.active)) {
      final component = _enemyComponents.remove(enemy);
      component?.removeFromParent();
      _enemyPool.release(enemy);
    }
    for (final component
        in children.whereType<DamageNumberComponent>().toList()) {
      component.removeFromParent();
      _damageNumberPool.add(component);
    }
  }

  void _handlePlayerDefeated() {
    _endRun(completed: false);
  }

  void _endRun({required bool completed}) {
    _runCompleted = completed;
    _runSummary.completed = completed;
    final dropBonus = _playerState.stats.value(StatId.drops);
    final dropMultiplier = math.max(0.0, 1 + dropBonus);
    _runSummary.metaRewardMultiplier =
        _contractRewardMultiplier * dropMultiplier;
    _runSummary.finalizeMetaCurrency();
    unawaited(_metaWallet.add(_runSummary.metaCurrencyEarned));
    _resetStageActors();
    _stageTimer = null;
    _selectionState.clear();
    overlays.remove(SelectionOverlay.overlayKey);
    overlays.remove(StatsOverlay.overlayKey);
    _setFlowState(GameFlowState.death);
    overlays.remove(HudOverlay.overlayKey);
    overlays.add(DeathScreen.overlayKey);
    _syncHudState();
  }

  void _resetRunSummary() {
    _runSummary.reset();
    _runCompleted = false;
  }

  void _updatePickups(double dt) {
    if (_pickupPool.active.isEmpty) {
      return;
    }
    final pickupBonus = _playerState.stats.value(StatId.pickupRadius);
    final pickupRadius = math.max(0, _pickupRadiusBase * (1 + pickupBonus));
    final collectRadius = _playerRadius + pickupRadius;
    final collectRadiusSquared = collectRadius * collectRadius;
    for (var i = _pickupPool.active.length - 1; i >= 0; i--) {
      final pickup = _pickupPool.active[i];
      if (!pickup.active) {
        continue;
      }
      pickup.age += dt;
      if (pickup.lifespan > 0 && pickup.age >= pickup.lifespan) {
        _despawnPickup(pickup);
        continue;
      }
      final dx = pickup.position.x - _playerState.position.x;
      final dy = pickup.position.y - _playerState.position.y;
      if (dx * dx + dy * dy <= collectRadiusSquared) {
        _collectPickup(pickup);
      }
    }
  }

  void _spawnPickup({
    required PickupKind kind,
    required Vector2 position,
    required int value,
  }) {
    final pickup = _pickupPool.acquire();
    pickup.reset(
      kind: kind,
      position: position,
      value: value,
      lifespan: _pickupLifetime,
    );
    _registerPickupComponent(pickup);
  }

  void _collectPickup(PickupState pickup) {
    if (!stressTest) {
      _runSummary.xpGained += pickup.value;
      final levelsGained = _experienceSystem.addExperience(pickup.value);
      if (levelsGained > 0) {
        _levelUpSystem.queueLevels(levelsGained);
        _offerSelectionIfNeeded();
      }
    }
    _despawnPickup(pickup);
  }

  void _despawnPickup(PickupState pickup) {
    final component = _pickupComponents.remove(pickup);
    component?.removeFromParent();
    _pickupPool.release(pickup);
  }

  void _applyContracts(List<ContractId> contracts) {
    _activeContracts
      ..clear()
      ..addAll(contracts);
    _contractProjectileSpeedMultiplier = 1.0;
    _contractMoveSpeedMultiplier = 1.0;
    _contractEliteWeightMultiplier = 1.0;
    _contractSupportWeightMultiplier = 1.0;
    _contractRewardMultiplier = 1.0;
    _contractHeat = 0;
    final nextContractNames = <String>[];
    for (final contractId in _activeContracts) {
      final def = contractDefsById[contractId];
      if (def == null) {
        continue;
      }
      _contractHeat += def.heat;
      _contractRewardMultiplier *= def.rewardMultiplier;
      _contractProjectileSpeedMultiplier *= def.enemyProjectileSpeedMultiplier;
      _contractMoveSpeedMultiplier *= def.enemyMoveSpeedMultiplier;
      _contractEliteWeightMultiplier *= def.eliteWeightMultiplier;
      _contractSupportWeightMultiplier *= def.supportRoleWeightMultiplier;
      nextContractNames.add(def.name);
    }
    _activeContractNames = List.unmodifiable(nextContractNames);
    _enemySystem.setProjectileSpeedMultiplier(
      _contractProjectileSpeedMultiplier,
    );
    _spawnerSystem.setProjectileSpeedMultiplier(
      _contractProjectileSpeedMultiplier,
    );
    _enemySystem.setMoveSpeedMultiplier(_contractMoveSpeedMultiplier);
    _spawnerSystem.setMoveSpeedMultiplier(_contractMoveSpeedMultiplier);
    final eliteChance = _baseChampionChance * _contractEliteWeightMultiplier;
    _enemySystem.setChampionChance(eliteChance);
    _spawnerSystem.setChampionChance(eliteChance);
  }

  void _resetPlayerProgression() {
    _experienceSystem.reset();
    _skillSystem.resetToDefaults();
    _playerState.resetForRun();
    _playerState.applyModifiers(_metaUnlocks.activeModifiers);
    _levelUpSystem.resetForRun(playerState: _playerState);
  }

  void _revivePlayer() {
    _playerState.hp = _playerState.maxHp;
    _playerState.movementIntent.setZero();
    _playerState.position.setFrom(size / 2);
    _playerComponent.syncWithState();
  }

  @override
  void onRemove() {
    if (_selectionListener != null) {
      _selectionState.removeListener(_selectionListener!);
    }
    super.onRemove();
  }
}
