import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/experimental.dart';
import 'package:flame/text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show KeyEventResult;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/area_defs.dart';
import '../data/contract_defs.dart';
import '../data/currency_defs.dart';
import '../data/enemy_defs.dart';
import '../data/ids.dart';
import '../data/item_defs.dart';
import '../data/map_size.dart';
import '../data/progression_track_defs.dart';
import '../data/skill_defs.dart';
import '../data/skill_upgrade_defs.dart';
import '../data/stat_defs.dart';
import '../data/synergy_defs.dart';
import '../data/tags.dart';
import '../data/weapon_upgrade_defs.dart';
import '../render/damage_number_component.dart';
import '../render/enemy_component.dart';
import '../render/effect_component.dart';
import '../render/map_background_component.dart';
import '../render/player_component.dart';
import '../render/portal_component.dart';
import '../render/projectile_batch_component.dart';
import '../render/projectile_component.dart';
import '../render/pickup_component.dart';
import '../render/pickup_spark_component.dart';
import '../render/sprite_pipeline.dart';
import '../render/summon_component.dart';
import '../ui/area_select_screen.dart';
import '../ui/compendium_screen.dart';
import '../ui/death_screen.dart';
import '../ui/escape_menu_overlay.dart';
import '../ui/first_run_hints_overlay.dart';
import '../ui/flow_debug_overlay.dart';
import '../ui/hud_state.dart';
import '../ui/home_base_overlay.dart';
import '../ui/meta_unlock_screen.dart';
import '../ui/options_screen.dart';
import '../ui/selection_overlay.dart';
import '../ui/selection_state.dart';
import '../ui/start_screen.dart';
import '../ui/stats_overlay.dart';
import '../ui/stats_screen_state.dart';
import '../ui/virtual_stick_overlay.dart';
import '../ui/virtual_stick_state.dart';
import 'damage_system.dart';
import 'effect_pool.dart';
import 'effect_state.dart';
import 'effect_system.dart';
import 'enemy_pool.dart';
import 'enemy_state.dart';
import 'enemy_system.dart';
import 'game_sizes.dart';
import 'level_up_system.dart';
import 'meta_currency_wallet.dart';
import 'meta_unlocks.dart';
import 'player_state.dart';
import 'pickup_pool.dart';
import 'pickup_state.dart';
import 'progression_system.dart';
import 'projectile_pool.dart';
import 'projectile_state.dart';
import 'projectile_system.dart';
import 'skill_system.dart';
import 'spatial_grid.dart';
import 'spawn_director.dart';
import 'spawner_system.dart';
import 'game_flow_state.dart';
import 'lifesteal.dart';
import 'run_summary.dart';
import 'stage_timer.dart';
import 'stress_stats.dart';
import 'summon_pool.dart';
import 'summon_state.dart';
import 'summon_system.dart';

class HordeGame extends FlameGame with KeyboardEvents, PanDetector {
  HordeGame({this.stressTest = false})
    : super(
        world: World(),
        camera: CameraComponent.withFixedResolution(
          width: GameSizes.cameraViewportSize.width,
          height: GameSizes.cameraViewportSize.height,
        ),
      );

  static const double _fixedDelta = 1 / 60;
  static const double _playerRadius = GameSizes.playerRadius;
  static const double _playerSpeed = 120;
  static const double _playerMaxHp = 100;
  static const double _enemyRadius = GameSizes.enemyRadius;
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
  static const Map<PickupKind, String> _pickupSpriteIds = {
    PickupKind.xpOrb: 'pickup_xp_orb',
    PickupKind.goldCoin: 'pickup_gold_coin',
  };
  static const Map<CurrencyId, PickupKind> _pickupKindByCurrency = {
    CurrencyId.xp: PickupKind.xpOrb,
    CurrencyId.gold: PickupKind.goldCoin,
  };
  static const Map<PickupKind, CurrencyId> _currencyByPickupKind = {
    PickupKind.xpOrb: CurrencyId.xp,
    PickupKind.goldCoin: CurrencyId.gold,
  };
  static const double _goldPickupValueMultiplier = 0.75;
  static const double _portalRadius = 26;
  static const double _portalLockoutDuration = 0.75;
  static const double _stageWaveInterval = 3.0;
  static const int _baseStageWaveCount = 4;
  static const double _baseChampionChance = 0.05;
  static const double _pickupRadiusBase = 32;
  static const double _pickupLifetime = 8;
  static const double _pickupMagnetStartSpeed = 120;
  static const double _pickupMagnetAcceleration = 560;
  static const double _pickupMagnetMaxSpeed = 520;
  static const String _tutorialSeenPrefsKey = 'tutorial_seen';
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
  final StressStatsTracker _stressStatsTracker = StressStatsTracker();
  StressStatsSnapshot? _stressStatsSnapshot;
  late final PlayerState _playerState;
  late final PlayerComponent _playerComponent;
  final SpritePipeline _spritePipeline = SpritePipeline();
  final Vector2 _mapSize = Vector2.zero();
  late final MapBackgroundComponent _mapBackground;
  MapSize _currentMapSize = GameSizes.homeBaseMapSize;
  Color _currentMapBackground = GameSizes.homeBaseBackgroundColor;
  final Map<EnemyId, Image> _enemySprites = {};
  Image? _projectileSprite;
  final Map<PickupKind, Image?> _pickupSprites = {};
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
  late final SummonPool _summonPool;
  late final SummonSystem _summonSystem;
  late final SkillSystem _skillSystem;
  late final PickupPool _pickupPool;
  late final SpatialGrid _enemyGrid;
  late final DamageSystem _damageSystem;
  late final ProgressionSystem _progressionSystem;
  late final LevelUpSystem _levelUpSystem;
  late final PortalComponent _portalComponent = PortalComponent(
    radius: _portalRadius,
    label: 'AREA PORTAL',
  );
  final PlayerHudState _hudState = PlayerHudState();
  final SelectionState _selectionState = SelectionState();
  ProgressionTrackId? _activeSelectionTrackId;
  final StatsScreenState _statsScreenState = StatsScreenState();
  final RunSummary _runSummary = RunSummary();
  final MetaCurrencyWallet _metaWallet = MetaCurrencyWallet();
  final MetaUnlocks _metaUnlocks = MetaUnlocks();
  final List<ContractId> _activeContracts = [];
  final Map<ProjectileState, ProjectileComponent> _projectileComponents = {};
  final Map<EnemyState, EnemyComponent> _enemyComponents = {};
  final ValueNotifier<bool> highContrastTelegraphs = ValueNotifier(false);
  final Map<EffectState, EffectComponent> _effectComponents = {};
  final Map<SummonState, SummonComponent> _summonComponents = {};
  final Map<PickupState, PickupComponent> _pickupComponents = {};
  final ValueNotifier<VirtualStickState> _virtualStickState = ValueNotifier(
    const VirtualStickState.inactive(
      deadZone: _panDeadZone,
      maxRadius: _panMaxRadius,
    ),
  );
  static const bool _damageNumbersEnabled = false;
  final List<DamageNumberComponent> _damageNumberPool = [];
  final List<PickupSparkComponent> _pickupSparkPool = [];
  final TextPaint _enemyDamagePaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFFD166),
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    ),
  );
  final TextPaint _synergyPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFF6B6B),
      fontSize: 9,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
  );
  final math.Random _stressRandom = math.Random(41);
  final Vector2 _stressPosition = Vector2.zero();
  final Vector2 _stressVelocity = Vector2.zero();
  final math.Random _damageNumberRandom = math.Random(29);
  final math.Random _pickupRandom = math.Random(17);
  final math.Random _lifestealRandom = math.Random(23);
  final math.Random _combatRandom = math.Random(31);
  final math.Random _skillRandom = math.Random(37);
  final math.Random _summonRandom = math.Random(43);
  final Vector2 _damageNumberPosition = Vector2.zero();
  final Vector2 _damageNumberVelocity = Vector2.zero();
  final Vector2 _pickupSparkPosition = Vector2.zero();
  final Vector2 _portalPosition = Vector2.zero();
  double _portalLockoutTimer = 0;
  GameFlowState _flowState = GameFlowState.start;
  final ValueNotifier<GameFlowState> _flowStateNotifier = ValueNotifier(
    GameFlowState.start,
  );
  bool _inputLocked = false;
  VoidCallback? _selectionListener;
  StageTimer? _stageTimer;
  AreaDef? _activeArea;
  int _currentSectionIndex = 0;
  bool _finaleTriggered = false;
  bool _finaleActive = false;
  double _finaleTimer = 0;
  bool _runCompleted = false;
  double _contractProjectileSpeedMultiplier = 1.0;
  double _contractMoveSpeedMultiplier = 1.0;
  double _contractEliteWeightMultiplier = 1.0;
  double _contractSupportWeightMultiplier = 1.0;
  double _contractRewardMultiplier = 1.0;
  int _contractHeat = 0;
  late final List<CurrencyDef> _pickupCurrencyDefs;
  late final double _pickupCurrencyWeightTotal;
  List<String> _activeContractNames = const [];
  bool _tutorialSeen = false;
  bool _menuReturnPending = false;

  PlayerHudState get hudState => _hudState;
  SelectionState get selectionState => _selectionState;
  StatsScreenState get statsScreenState => _statsScreenState;
  GameFlowState get flowState => _flowState;
  ValueListenable<GameFlowState> get flowStateListenable => _flowStateNotifier;
  RunSummary get runSummary => _runSummary;
  bool get runCompleted => _runCompleted;
  MetaCurrencyWallet get metaWallet => _metaWallet;
  MetaUnlocks get metaUnlocks => _metaUnlocks;
  ValueListenable<VirtualStickState> get virtualStickState =>
      _virtualStickState;
  StressStatsSnapshot? get stressStatsSnapshot => _stressStatsSnapshot;

  @override
  backgroundColor() => const Color(0xFF0F1117);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _metaWallet.load();
    await _metaUnlocks.load();
    await _loadTutorialSeen();
    _selectionListener = _handleSelectionStateChanged;
    _selectionState.addListener(_selectionListener!);
    if (stressTest) {
      _flowState = GameFlowState.stage;
      _flowStateNotifier.value = _flowState;
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
    for (final entry in _pickupSpriteIds.entries) {
      final image = _spritePipeline.lookup(entry.value);
      if (image == null) {
        debugPrint('Sprite cache missing ${entry.value}.');
      }
      _pickupSprites[entry.key] = image;
    }
    _mapSize.setValues(_currentMapSize.width, _currentMapSize.height);
    _mapBackground = MapBackgroundComponent(
      size: _mapSize,
      color: _currentMapBackground,
    );
    await world.add(_mapBackground);
    _playerState = PlayerState(
      position: _mapSize / 2,
      maxHp: _playerMaxHp,
      moveSpeed: _playerSpeed,
    );
    _progressionSystem = ProgressionSystem();
    _spawnDirector = SpawnDirector(progressionSystem: _progressionSystem);
    _levelUpSystem = LevelUpSystem(random: math.Random(11));
    _playerComponent = PlayerComponent(
      state: _playerState,
      radius: _playerRadius,
      spriteImage: playerSprite,
    );
    _playerComponent.syncWithState();
    await world.add(_playerComponent);
    camera.viewfinder.anchor = Anchor.center;
    camera.setBounds(
      Rectangle.fromRect(_currentMapSize.toRect()),
      considerViewport: true,
    );
    camera.follow(_playerComponent, snap: true);
    _syncCamera();

    _updatePortalPosition();
    _portalComponent.position.setFrom(_portalPosition);
    await world.add(_portalComponent);

    _enemyPool = EnemyPool(initialCapacity: stressTest ? 600 : 48);
    _projectilePool = ProjectilePool(initialCapacity: stressTest ? 1400 : 64);
    _effectPool = EffectPool(initialCapacity: stressTest ? 180 : 32);
    _summonPool = SummonPool(initialCapacity: stressTest ? 120 : 24);
    _pickupPool = PickupPool(initialCapacity: stressTest ? 220 : 48);
    _pickupCurrencyDefs = currencyDefs
        .where((def) => def.dropWeight > 0)
        .toList(growable: false);
    _pickupCurrencyWeightTotal = _pickupCurrencyDefs.fold(
      0,
      (total, def) => total + def.dropWeight,
    );
    if (_projectileSprite != null) {
      _projectileBatchComponent = ProjectileBatchComponent(
        pool: _projectilePool,
        spriteImage: _projectileSprite!,
        color: const Color(0xFFFF8C3B),
      );
      await world.add(_projectileBatchComponent!);
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
    _summonSystem = SummonSystem(_summonPool, random: _summonRandom);
    _skillSystem = SkillSystem(
      projectilePool: _projectilePool,
      effectPool: _effectPool,
      summonPool: _summonPool,
      random: _skillRandom,
    );
    _damageSystem = DamageSystem(
      DamageEventPool(initialCapacity: 64),
      random: _combatRandom,
    );
    if (_damageNumbersEnabled) {
      for (var i = 0; i < 32; i++) {
        _damageNumberPool.add(
          DamageNumberComponent(
            textPaint: _enemyDamagePaint,
            onComplete: _releaseDamageNumber,
          ),
        );
      }
    }
    _spawnerSystem = SpawnerSystem(
      pool: _enemyPool,
      random: math.Random(7),
      arenaSize: _mapSize,
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
      unlockedMeta: _metaUnlocks.unlockedIds.toSet(),
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
    if (stressTest) {
      _stressStatsTracker.recordFrame(clampedDt);
    }
    if (_flowState == GameFlowState.homeBase) {
      _accumulator = math.min(
        _accumulator + clampedDt,
        _fixedDelta * _maxFixedStepsPerFrame,
      );
      while (_accumulator >= _fixedDelta) {
        _stepHomeBase(_fixedDelta);
        _accumulator -= _fixedDelta;
      }
      _syncCamera();
      super.update(dt);
      return;
    }
    if (_flowState != GameFlowState.stage) {
      _syncCamera();
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
    _syncCamera();
    super.update(dt);
  }

  void _step(double dt) {
    if (!_spawnerReady) {
      return;
    }
    if (_selectionState.active ||
        overlays.isActive(StatsOverlay.overlayKey) ||
        overlays.isActive(EscapeMenuOverlay.overlayKey)) {
      _playerState.movementIntent.setZero();
      _playerComponent.syncWithState();
      _syncHudState();
      return;
    }
    _runSummary.timeAlive += dt;
    _applyInput();
    _playerState.step(dt);
    _playerState.clampToBounds(
      min: Vector2(_playerRadius, _playerRadius),
      max: Vector2(_mapSize.x - _playerRadius, _mapSize.y - _playerRadius),
    );
    if (!stressTest && _stageTimer != null) {
      final stageUpdate = _stageTimer!.update(dt);
      if (stageUpdate.sectionChanged) {
        _applyStageSection();
      }
      if (stageUpdate.milestones.isNotEmpty) {
        for (final milestone in stageUpdate.milestones) {
          _handleStageMilestone(milestone);
        }
      }
      if (_stageTimer!.isComplete) {
        if (_finaleActive) {
          _finaleTimer = math.max(0, _finaleTimer - dt);
          if (_finaleTimer <= 0) {
            _finaleActive = false;
            _handleStageComplete();
            return;
          }
        } else if (!_finaleTriggered && !stressTest) {
          final finale = _activeArea?.finale;
          if (finale != null) {
            _startStageFinale(finale);
          } else {
            _handleStageComplete();
            return;
          }
        } else if (!stressTest) {
          _handleStageComplete();
          return;
        }
      }
    }
    _spawnerSystem.update(dt, _playerState.position);
    _enemySystem.update(dt, _playerState.position, _mapSize);
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
      onSummonSpawn: _handleSummonSpawn,
      onPlayerDeflect: ({required double radius, required double duration}) {
        _playerState.startDeflect(radius: radius, duration: duration);
      },
      onEnemyDamaged: _damageSystem.queueEnemyDamage,
    );
    _summonSystem.update(
      dt,
      playerState: _playerState,
      enemyPool: _enemyPool,
      enemyGrid: _enemyGrid,
      projectilePool: _projectilePool,
      onProjectileSpawn: _handleProjectileSpawn,
      onDespawn: _handleSummonDespawn,
      onEnemyDamaged: _damageSystem.queueEnemyDamage,
      onPlayerDamaged:
          (amount, {tags = const TagSet(), selfInflicted = false}) {
            _damageSystem.queuePlayerDamage(
              _playerState,
              amount,
              tags: tags,
              selfInflicted: selfInflicted,
            );
          },
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
      _mapSize,
      onDespawn: _handleProjectileDespawn,
      onEnemyHit: _damageSystem.queueEnemyDamage,
      enemyGrid: _enemyGrid,
      enemyRadius: _enemyRadius,
      playerState: _playerState,
      playerRadius: _playerRadius,
      onPlayerHit: (damage) {
        _damageSystem.queuePlayerDamage(_playerState, damage);
      },
      onSynergyTriggered: _handleSynergyTriggered,
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

    _playerComponent.syncWithState();
  }

  void _syncCamera() {
    final fovScale = (1 + _playerState.stats.value(StatId.fieldOfView))
        .clamp(0.5, 1.75)
        .toDouble();
    final zoom = (GameSizes.baseCameraZoom / fovScale)
        .clamp(GameSizes.minCameraZoom, GameSizes.maxCameraZoom)
        .toDouble();
    camera.viewfinder.zoom = zoom;
  }

  void beginHomeBaseFromStartScreen() {
    if (_flowState == GameFlowState.homeBase) {
      return;
    }
    _applyMapVisuals(
      mapSize: GameSizes.homeBaseMapSize,
      backgroundColor: GameSizes.homeBaseBackgroundColor,
    );
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
    _menuReturnPending = false;
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
    _menuReturnPending = false;
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
    _menuReturnPending = false;
    overlays.remove(StartScreen.overlayKey);
    overlays.add(MetaUnlockScreen.overlayKey);
  }

  void closeOptionsScreen() {
    overlays.remove(OptionsScreen.overlayKey);
    if (_menuReturnPending) {
      _captureStressMenuStats();
      overlays.add(EscapeMenuOverlay.overlayKey);
      _menuReturnPending = false;
      _updateInputLock();
      return;
    }
    if (_flowState != GameFlowState.start) {
      return;
    }
    overlays.add(StartScreen.overlayKey);
  }

  void closeCompendiumScreen() {
    overlays.remove(CompendiumScreen.overlayKey);
    if (_menuReturnPending) {
      _captureStressMenuStats();
      overlays.add(EscapeMenuOverlay.overlayKey);
      _menuReturnPending = false;
      _updateInputLock();
      return;
    }
    if (_flowState != GameFlowState.start) {
      return;
    }
    overlays.add(StartScreen.overlayKey);
  }

  void closeMetaUnlocksScreen() {
    overlays.remove(MetaUnlockScreen.overlayKey);
    if (_menuReturnPending) {
      _captureStressMenuStats();
      overlays.add(EscapeMenuOverlay.overlayKey);
      _menuReturnPending = false;
      _updateInputLock();
      return;
    }
    if (_flowState != GameFlowState.start) {
      return;
    }
    overlays.add(StartScreen.overlayKey);
  }

  void openOptionsFromMenu() {
    if (overlays.isActive(OptionsScreen.overlayKey)) {
      return;
    }
    _menuReturnPending = true;
    overlays.remove(EscapeMenuOverlay.overlayKey);
    overlays.add(OptionsScreen.overlayKey);
  }

  void openCompendiumFromMenu() {
    if (overlays.isActive(CompendiumScreen.overlayKey)) {
      return;
    }
    _menuReturnPending = true;
    overlays.remove(EscapeMenuOverlay.overlayKey);
    overlays.add(CompendiumScreen.overlayKey);
  }

  void openMetaUnlocksFromMenu() {
    if (overlays.isActive(MetaUnlockScreen.overlayKey)) {
      return;
    }
    _menuReturnPending = true;
    overlays.remove(EscapeMenuOverlay.overlayKey);
    overlays.add(MetaUnlockScreen.overlayKey);
  }

  void enterHomeBaseFromMenu() {
    overlays.remove(EscapeMenuOverlay.overlayKey);
    switch (_flowState) {
      case GameFlowState.start:
        beginHomeBaseFromStartScreen();
        return;
      case GameFlowState.homeBase:
        _updateInputLock();
        return;
      case GameFlowState.areaSelect:
        returnToHomeBase();
        return;
      case GameFlowState.death:
        returnToHomeBaseFromDeath();
        return;
      case GameFlowState.stage:
        returnToHomeBase();
        return;
    }
  }

  void closeEscapeMenu() {
    overlays.remove(EscapeMenuOverlay.overlayKey);
    _updateInputLock();
  }

  void continueRunFromMenu() {
    closeEscapeMenu();
  }

  void abortRunFromMenu() {
    overlays.remove(EscapeMenuOverlay.overlayKey);
    returnToHomeBase();
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
    _applyMapVisuals(
      mapSize: area.mapSize,
      backgroundColor: area.backgroundColor,
    );
    _applyContracts(contracts);
    _spawnerSystem.setUnlockedMeta(_metaUnlocks.unlockedIds.toSet());
    _resetFinaleState();
    _stageTimer = StageTimer(
      duration: area.stageDuration,
      sections: area.sections,
      milestones: area.milestones,
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
    overlays.remove(EscapeMenuOverlay.overlayKey);
    overlays.add(VirtualStickOverlay.overlayKey);
    _showFirstRunHintsIfNeeded();
    _syncHudState();
  }

  void returnToHomeBase() {
    _resetStageActors();
    _activeArea = null;
    _stageTimer = null;
    _resetFinaleState();
    _applyMapVisuals(
      mapSize: GameSizes.homeBaseMapSize,
      backgroundColor: GameSizes.homeBaseBackgroundColor,
    );
    _portalLockoutTimer = _portalLockoutDuration;
    _setFlowState(GameFlowState.homeBase);
    overlays.remove(AreaSelectScreen.overlayKey);
    overlays.remove(VirtualStickOverlay.overlayKey);
    overlays.remove(DeathScreen.overlayKey);
    overlays.remove(StatsOverlay.overlayKey);
    overlays.remove(FirstRunHintsOverlay.overlayKey);
    overlays.remove(EscapeMenuOverlay.overlayKey);
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
    _resetFinaleState();
    _applyMapVisuals(
      mapSize: GameSizes.homeBaseMapSize,
      backgroundColor: GameSizes.homeBaseBackgroundColor,
    );
    _setFlowState(GameFlowState.homeBase);
    overlays.remove(DeathScreen.overlayKey);
    overlays.remove(VirtualStickOverlay.overlayKey);
    overlays.remove(StatsOverlay.overlayKey);
    overlays.remove(FirstRunHintsOverlay.overlayKey);
    overlays.remove(EscapeMenuOverlay.overlayKey);
    overlays.add(HomeBaseOverlay.overlayKey);
    _syncHudState();
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

  void _attemptDash() {
    if (_inputLocked || _flowState != GameFlowState.stage) {
      return;
    }
    _playerState.tryDash();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      toggleEscapeMenu();
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      _attemptDash();
      return KeyEventResult.handled;
    }
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
    _virtualStickState.value = VirtualStickState(
      active: true,
      origin: Offset(_panStart!.x, _panStart!.y),
      delta: Offset.zero,
      deadZone: _panDeadZone,
      maxRadius: _panMaxRadius,
    );
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
    _virtualStickState.value = _virtualStickState.value.copyWith(
      active: true,
      origin: Offset(start.x, start.y),
      delta: Offset(_panDirection.x, _panDirection.y),
    );
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (_inputLocked) {
      return;
    }
    _isPanning = false;
    _panStart = null;
    _panDirection.setZero();
    _virtualStickState.value = const VirtualStickState.inactive(
      deadZone: _panDeadZone,
      maxRadius: _panMaxRadius,
    );
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
    world.add(component);
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
    world.add(component);
  }

  void _handleEffectDespawn(EffectState effect) {
    final component = _effectComponents.remove(effect);
    component?.removeFromParent();
  }

  void _handleSummonSpawn(SummonState summon) {
    final component = SummonComponent(state: summon);
    _summonComponents[summon] = component;
    world.add(component);
  }

  void _handleSummonDespawn(SummonState summon) {
    final component = _summonComponents.remove(summon);
    component?.removeFromParent();
  }

  void _handleEnemyDefeated(EnemyState enemy) {
    if (!stressTest) {
      _runSummary.enemiesDefeated += 1;
      if (enemy.xpReward > 0) {
        final pickupKind = _rollPickupKind();
        final pickupValue = _pickupValueForKind(pickupKind, enemy.xpReward);
        _spawnPickup(
          kind: pickupKind,
          position: enemy.position,
          value: pickupValue,
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
    world.add(component);
  }

  void _registerPickupComponent(PickupState pickup) {
    final component = PickupComponent(
      state: pickup,
      spriteImages: _pickupSprites,
    );
    _pickupComponents[pickup] = component;
    world.add(component);
  }

  PickupKind _rollPickupKind() {
    if (_pickupCurrencyDefs.isEmpty || _pickupCurrencyWeightTotal <= 0) {
      return PickupKind.xpOrb;
    }
    final roll = _pickupRandom.nextDouble() * _pickupCurrencyWeightTotal;
    var current = 0.0;
    for (final def in _pickupCurrencyDefs) {
      current += def.dropWeight;
      if (roll <= current) {
        return _pickupKindByCurrency[def.id] ?? PickupKind.xpOrb;
      }
    }
    final fallback = _pickupCurrencyDefs.last;
    return _pickupKindByCurrency[fallback.id] ?? PickupKind.xpOrb;
  }

  int _pickupValueForKind(PickupKind kind, int baseValue) {
    if (kind == PickupKind.goldCoin) {
      return math.max(1, (baseValue * _goldPickupValueMultiplier).round());
    }
    return baseValue;
  }

  void _handleEnemyDamaged(EnemyState enemy, double amount) {
    if (amount <= 0) {
      return;
    }
    tryLifesteal(
      player: _playerState,
      chance: _playerState.stats.value(StatId.lifeSteal),
      random: _lifestealRandom,
    );
    if (!_damageNumbersEnabled) {
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
      world.add(component);
    }
  }

  void _handleSynergyTriggered(SynergyDef synergy, EnemyState enemy) {
    _runSummary.synergyTriggers += 1;
    final counts = _runSummary.synergyTriggerCounts;
    counts[synergy.id] = (counts[synergy.id] ?? 0) + 1;
    if (!_damageNumbersEnabled) {
      return;
    }
    final component = _acquireDamageNumber();
    final jitterX = (_damageNumberRandom.nextDouble() - 0.5) * 8;
    final jitterY = (_damageNumberRandom.nextDouble() - 0.5) * 6;
    _damageNumberPosition.setValues(
      enemy.position.x + jitterX,
      enemy.position.y + jitterY,
    );
    _damageNumberVelocity.setValues(
      0,
      -20 - _damageNumberRandom.nextDouble() * 6,
    );
    component.reset(
      position: _damageNumberPosition,
      amount: 0,
      textPaint: _synergyPaint,
      velocity: _damageNumberVelocity,
      label: synergy.triggerLabel,
      lifespan: 0.6,
    );
    if (!component.isMounted) {
      world.add(component);
    }
  }

  void _handlePlayerDamaged(double amount) {
    if (_flowState != GameFlowState.stage) {
      return;
    }
    _runSummary.damageTaken += amount;
  }

  void _spawnPickupSpark(Vector2 position) {
    final component = _acquirePickupSpark();
    _pickupSparkPosition.setFrom(position);
    component.reset(position: _pickupSparkPosition);
    if (!component.isMounted) {
      world.add(component);
    }
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

  PickupSparkComponent _acquirePickupSpark() {
    if (_pickupSparkPool.isNotEmpty) {
      return _pickupSparkPool.removeLast();
    }
    return PickupSparkComponent(onComplete: _releasePickupSpark);
  }

  void _releasePickupSpark(PickupSparkComponent component) {
    component.removeFromParent();
    _pickupSparkPool.add(component);
  }

  void selectChoice(SelectionChoice choice) {
    final trackId = _activeSelectionTrackId;
    if (trackId == null) {
      return;
    }
    _levelUpSystem.applyChoice(
      trackId: trackId,
      choice: choice,
      playerState: _playerState,
      skillSystem: _skillSystem,
    );
    _hudState.triggerRewardMessage(_rewardMessageForChoice(choice));
    _offerSelectionIfNeeded();
  }

  void skipSelection() {
    final trackId = _activeSelectionTrackId;
    if (trackId == null) {
      return;
    }
    final rewardCurrencyAmount = _skipRewardCurrencyValue(trackId);
    final rewardCurrencyId = _currencyIdForTrack(trackId);
    final rewardMetaShards = _skipRewardMetaShardValue();
    _levelUpSystem.skipChoice(trackId: trackId, playerState: _playerState);
    if (!stressTest && rewardCurrencyAmount > 0) {
      if (rewardCurrencyId == CurrencyId.xp) {
        _runSummary.xpGained += rewardCurrencyAmount;
      }
      final gain = _progressionSystem.addCurrency(
        rewardCurrencyId,
        rewardCurrencyAmount,
      );
      if (gain != null && gain.levelsGained > 0) {
        _levelUpSystem.queueLevels(gain.trackId, gain.levelsGained);
      }
    }
    if (!stressTest && rewardMetaShards > 0) {
      _runSummary.metaCurrencyBonus += rewardMetaShards;
    }
    _hudState.triggerRewardMessage(
      _skipRewardMessage(
        rewardCurrencyAmount,
        rewardCurrencyId,
        rewardMetaShards,
      ),
    );
    _offerSelectionIfNeeded();
  }

  void rerollSelection() {
    final rerolled = _levelUpSystem.rerollChoices(
      trackId: _activeSelectionTrackId ?? ProgressionTrackId.skills,
      selectionPoolId: _activeSelectionPoolId(),
      playerState: _playerState,
      skillSystem: _skillSystem,
      unlockedMeta: _metaUnlocks.unlockedIds.toSet(),
    );
    if (rerolled) {
      _selectionState.showChoices(
        _levelUpSystem.choices,
        trackId: _activeSelectionTrackId ?? ProgressionTrackId.skills,
        rerollsRemaining: _levelUpSystem.rerollsRemaining,
        banishesRemaining: _levelUpSystem.banishesRemaining,
        skipRewardCurrencyAmount: _skipRewardCurrencyValue(
          _activeSelectionTrackId ?? ProgressionTrackId.skills,
        ),
        skipRewardCurrencyId: _currencyIdForTrack(
          _activeSelectionTrackId ?? ProgressionTrackId.skills,
        ),
        skipRewardMetaShards: _skipRewardMetaShardValue(),
      );
    }
  }

  void banishSelection(SelectionChoice choice) {
    final trackId = _activeSelectionTrackId ?? ProgressionTrackId.skills;
    final banished = _levelUpSystem.banishChoice(
      trackId: trackId,
      selectionPoolId: _activeSelectionPoolId(),
      choice: choice,
      playerState: _playerState,
      skillSystem: _skillSystem,
      unlockedMeta: _metaUnlocks.unlockedIds.toSet(),
    );
    if (banished) {
      _selectionState.showChoices(
        _levelUpSystem.choices,
        trackId: trackId,
        rerollsRemaining: _levelUpSystem.rerollsRemaining,
        banishesRemaining: _levelUpSystem.banishesRemaining,
        skipRewardCurrencyAmount: _skipRewardCurrencyValue(trackId),
        skipRewardCurrencyId: _currencyIdForTrack(trackId),
        skipRewardMetaShards: _skipRewardMetaShardValue(),
      );
    }
  }

  void _offerSelectionIfNeeded() {
    final nextTrackId = _levelUpSystem.nextPendingTrackId;
    if (nextTrackId == null) {
      _selectionState.clear();
      overlays.remove(SelectionOverlay.overlayKey);
      _activeSelectionTrackId = null;
      return;
    }
    _levelUpSystem.buildChoices(
      trackId: nextTrackId,
      selectionPoolId: _selectionPoolForTrack(nextTrackId),
      playerState: _playerState,
      skillSystem: _skillSystem,
      unlockedMeta: _metaUnlocks.unlockedIds.toSet(),
    );
    if (_levelUpSystem.hasChoices) {
      _activeSelectionTrackId = nextTrackId;
      _selectionState.showChoices(
        _levelUpSystem.choices,
        trackId: nextTrackId,
        rerollsRemaining: _levelUpSystem.rerollsRemaining,
        banishesRemaining: _levelUpSystem.banishesRemaining,
        skipRewardCurrencyAmount: _skipRewardCurrencyValue(nextTrackId),
        skipRewardCurrencyId: _currencyIdForTrack(nextTrackId),
        skipRewardMetaShards: _skipRewardMetaShardValue(),
      );
      overlays.add(SelectionOverlay.overlayKey);
    } else {
      _selectionState.clear();
      overlays.remove(SelectionOverlay.overlayKey);
      _activeSelectionTrackId = null;
    }
  }

  int _skipRewardCurrencyValue(ProgressionTrackId trackId) {
    final track = _progressionSystem.trackForId(trackId);
    final skipFraction =
        progressionTrackDefsById[trackId]?.skipRewardFraction ?? 0.2;
    final reward = (track.currencyToNext * skipFraction).round();
    return math.max(1, reward);
  }

  CurrencyId _currencyIdForTrack(ProgressionTrackId trackId) {
    return progressionTrackDefsById[trackId]?.currencyId ?? CurrencyId.xp;
  }

  SelectionPoolId _selectionPoolForTrack(ProgressionTrackId trackId) {
    return progressionTrackDefsById[trackId]?.selectionPoolId ??
        SelectionPoolId.skillPool;
  }

  SelectionPoolId _activeSelectionPoolId() {
    return _selectionPoolForTrack(
      _activeSelectionTrackId ?? ProgressionTrackId.skills,
    );
  }

  int _skipRewardMetaShardValue() {
    final reward = _playerState.stats.value(StatId.skipMetaShards).round();
    return math.max(0, reward);
  }

  String _skipRewardMessage(
    int rewardCurrencyAmount,
    CurrencyId rewardCurrencyId,
    int rewardMetaShards,
  ) {
    if (rewardCurrencyAmount <= 0 && rewardMetaShards <= 0) {
      return 'Skipped reward';
    }
    final parts = <String>[];
    if (rewardCurrencyAmount > 0) {
      parts.add(
        '+$rewardCurrencyAmount ${_currencyShortLabel(rewardCurrencyId)}',
      );
    }
    if (rewardMetaShards > 0) {
      parts.add('+$rewardMetaShards Shards');
    }
    return 'Skipped reward (${parts.join(', ')})';
  }

  String _currencyShortLabel(CurrencyId currencyId) {
    switch (currencyId) {
      case CurrencyId.xp:
        return 'XP';
      case CurrencyId.gold:
        return 'Gold';
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
      case SelectionType.weaponUpgrade:
        return 'Weapon Upgrade: ${choice.title}';
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
    final skillTrack = _progressionSystem.trackForId(ProgressionTrackId.skills);
    final itemTrack = _progressionSystem.trackForId(ProgressionTrackId.items);
    _hudState.update(
      hp: _playerState.hp,
      maxHp: _playerState.maxHp,
      level: skillTrack.level,
      xp: skillTrack.currentCurrency,
      xpToNext: skillTrack.currencyToNext,
      gold: itemTrack.currentCurrency,
      goldToNext: itemTrack.currencyToNext,
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
      dashCharges: _playerState.dashCharges,
      dashMaxCharges: _playerState.dashMaxCharges,
      dashCooldownRemaining: _playerState.dashCooldownRemaining,
      dashCooldownDuration: math.max(
        0,
        _playerState.stats.value(StatId.dashCooldown),
      ),
    );
    _statsScreenState.update(
      statValues: _collectStatValues(),
      skills: _skillSystem.skillIds,
      upgrades: _levelUpSystem.appliedUpgrades.toList(),
      weaponUpgrades: _levelUpSystem.appliedWeaponUpgrades.toList(),
      items: _levelUpSystem.appliedItems.toList(),
      rerollsRemaining: _levelUpSystem.rerollsRemaining,
      rerollsMax: _levelUpSystem.rerollsMax,
    );
  }

  void _showFirstRunHintsIfNeeded() {
    if (stressTest || _tutorialSeen) {
      return;
    }
    overlays.add(FirstRunHintsOverlay.overlayKey);
  }

  Future<void> _loadTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    _tutorialSeen = prefs.getBool(_tutorialSeenPrefsKey) ?? false;
  }

  Future<void> dismissFirstRunHints() async {
    if (!_tutorialSeen) {
      _tutorialSeen = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_tutorialSeenPrefsKey, true);
    }
    overlays.remove(FirstRunHintsOverlay.overlayKey);
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
    for (final upgradeId in _levelUpSystem.appliedWeaponUpgrades) {
      final def = weaponUpgradeDefsById[upgradeId];
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
    _virtualStickState.value = const VirtualStickState.inactive(
      deadZone: _panDeadZone,
      maxRadius: _panMaxRadius,
    );
  }

  void _setFlowState(GameFlowState state) {
    if (_flowState == state) {
      return;
    }
    _flowState = state;
    _flowStateNotifier.value = state;
    _syncPortalVisibility();
    _updateInputLock();
  }

  void _updateInputLock() {
    final locked =
        _selectionState.active ||
        overlays.isActive(StatsOverlay.overlayKey) ||
        overlays.isActive(EscapeMenuOverlay.overlayKey) ||
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

  void toggleEscapeMenu() {
    if (_selectionState.active) {
      return;
    }
    if (overlays.isActive(EscapeMenuOverlay.overlayKey)) {
      overlays.remove(EscapeMenuOverlay.overlayKey);
      _updateInputLock();
      return;
    }
    if (_flowState == GameFlowState.stage) {
      overlays.remove(StatsOverlay.overlayKey);
      _captureStressMenuStats();
      overlays.add(EscapeMenuOverlay.overlayKey);
      _updateInputLock();
      return;
    }
    if (_flowState == GameFlowState.start) {
      return;
    }
    _captureStressMenuStats();
    overlays.add(EscapeMenuOverlay.overlayKey);
    _updateInputLock();
  }

  void _captureStressMenuStats() {
    if (!stressTest) {
      return;
    }
    _stressStatsSnapshot = _stressStatsTracker.snapshot();
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
    _resetFinaleState();
    _runCompleted = false;
    _menuReturnPending = false;
    _applyMapVisuals(
      mapSize: GameSizes.homeBaseMapSize,
      backgroundColor: GameSizes.homeBaseBackgroundColor,
    );
    _setFlowState(GameFlowState.start);
    overlays.remove(VirtualStickOverlay.overlayKey);
    overlays.remove(HomeBaseOverlay.overlayKey);
    overlays.remove(AreaSelectScreen.overlayKey);
    overlays.remove(DeathScreen.overlayKey);
    overlays.remove(SelectionOverlay.overlayKey);
    overlays.remove(OptionsScreen.overlayKey);
    overlays.remove(CompendiumScreen.overlayKey);
    overlays.remove(StatsOverlay.overlayKey);
    overlays.remove(FirstRunHintsOverlay.overlayKey);
    overlays.remove(EscapeMenuOverlay.overlayKey);
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
      _stressPosition.x = _stressPosition.x.clamp(0.0, _mapSize.x);
      _stressPosition.y = _stressPosition.y.clamp(0.0, _mapSize.y);
      _stressVelocity.setValues(math.cos(angle) * 180, math.sin(angle) * 180);

      final projectile = _projectilePool.acquire();
      projectile.reset(
        position: _stressPosition,
        velocity: _stressVelocity,
        damage: 0.5,
        radius: GameSizes.projectileRadius(3),
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
      max: Vector2(_mapSize.x - _playerRadius, _mapSize.y - _playerRadius),
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

  void _applyMapVisuals({
    required MapSize mapSize,
    required Color backgroundColor,
  }) {
    _currentMapSize = mapSize;
    _currentMapBackground = backgroundColor;
    _mapSize.setValues(mapSize.width, mapSize.height);
    _mapBackground.updateAppearance(size: _mapSize, color: backgroundColor);
    _playerState.position.x = _playerState.position.x.clamp(
      _playerRadius,
      _mapSize.x - _playerRadius,
    );
    _playerState.position.y = _playerState.position.y.clamp(
      _playerRadius,
      _mapSize.y - _playerRadius,
    );
    camera.setBounds(
      Rectangle.fromRect(mapSize.toRect()),
      considerViewport: true,
    );
    if (_spawnerReady) {
      _spawnerSystem.updateArenaSize(_mapSize);
    }
    _updatePortalPosition();
    _portalComponent.position.setFrom(_portalPosition);
  }

  void _updatePortalPosition() {
    _portalPosition.setValues(_mapSize.x * 0.78, _mapSize.y * 0.25);
  }

  void _syncPortalVisibility() {
    _portalComponent.visible = _flowState == GameFlowState.homeBase;
  }

  void _resetFinaleState() {
    _finaleTriggered = false;
    _finaleActive = false;
    _finaleTimer = 0;
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

  void _startStageFinale(StageFinale finale) {
    _finaleTriggered = true;
    _finaleTimer = math.max(0, finale.duration);
    _finaleActive = _finaleTimer > 0;
    final message = finale.label.isEmpty
        ? 'FINAL WAVE!'
        : 'FINAL WAVE: ${finale.label}';
    _hudState.triggerRewardMessage(message);
    if (finale.bonusWaveCount <= 0) {
      return;
    }
    final timer = _stageTimer;
    final area = _activeArea;
    final section = timer?.currentSection;
    if (timer == null || area == null || section == null) {
      return;
    }
    final sectionDuration = section.endTime - section.startTime;
    final timeIntoSection = (timer.elapsed - section.startTime).clamp(
      0.0,
      sectionDuration,
    );
    _spawnBurstWave(
      count: finale.bonusWaveCount,
      section: section,
      sectionDuration: sectionDuration,
      timeIntoSection: timeIntoSection,
    );
  }

  void _handleStageMilestone(StageMilestone milestone) {
    final message = milestone.label.isEmpty
        ? 'MILESTONE!'
        : 'MILESTONE: ${milestone.label}';
    _hudState.triggerRewardMessage(message);
    if (!stressTest && milestone.xpReward > 0) {
      _runSummary.xpGained += milestone.xpReward;
      final gain = _progressionSystem.addCurrency(
        CurrencyId.xp,
        milestone.xpReward,
      );
      if (gain != null && gain.levelsGained > 0) {
        _levelUpSystem.queueLevels(gain.trackId, gain.levelsGained);
        _offerSelectionIfNeeded();
      }
    }
    if (milestone.bonusWaveCount <= 0) {
      return;
    }
    final timer = _stageTimer;
    final area = _activeArea;
    final section = timer?.currentSection;
    if (timer == null || area == null || section == null) {
      return;
    }
    final sectionDuration = section.endTime - section.startTime;
    final timeIntoSection = (timer.elapsed - section.startTime).clamp(
      0.0,
      sectionDuration,
    );
    _spawnBurstWave(
      count: milestone.bonusWaveCount,
      section: section,
      sectionDuration: sectionDuration,
      timeIntoSection: timeIntoSection,
    );
  }

  void _spawnBurstWave({
    required int count,
    required StageSection section,
    required double sectionDuration,
    required double timeIntoSection,
  }) {
    final tuning = _spawnDirector.tuneSection(
      section: section,
      previousSection: null,
      sectionDuration: sectionDuration,
      timeIntoSection: timeIntoSection,
    );
    final adjustedRoles = _applyContractRoleWeights(tuning.roleWeights);
    final adjustedVariants = _applyContractVariantWeights(
      tuning.variantWeights,
    );
    _spawnerSystem.spawnBurst(
      SpawnWave(
        time: 0,
        count: count,
        roleWeights: adjustedRoles.isEmpty ? null : adjustedRoles,
        enemyWeights: tuning.enemyWeights.isEmpty ? null : tuning.enemyWeights,
        variantWeights: adjustedVariants.isEmpty ? null : adjustedVariants,
      ),
      _playerState.position,
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
    for (final summon in List<SummonState>.from(_summonPool.active)) {
      _handleSummonDespawn(summon);
      _summonPool.release(summon);
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
        in world.children.whereType<DamageNumberComponent>().toList()) {
      component.removeFromParent();
      _damageNumberPool.add(component);
    }
    for (final component
        in world.children.whereType<PickupSparkComponent>().toList()) {
      component.removeFromParent();
      _pickupSparkPool.add(component);
    }
  }

  void _handlePlayerDefeated() {
    _endRun(completed: false);
  }

  void _endRun({required bool completed}) {
    _runCompleted = completed;
    _runSummary.completed = completed;
    _runSummary.skills = _skillSystem.skillIds;
    _runSummary.items = _levelUpSystem.appliedItems.toList(growable: false);
    _runSummary.upgrades = _levelUpSystem.appliedUpgrades.toList(
      growable: false,
    );
    _runSummary.weaponUpgrades = _levelUpSystem.appliedWeaponUpgrades.toList(
      growable: false,
    );
    final dropBonus = _playerState.stats.value(StatId.drops);
    final dropMultiplier = math.max(0.0, 1 + dropBonus);
    _runSummary.metaRewardMultiplier =
        _contractRewardMultiplier * dropMultiplier;
    _runSummary.finalizeMetaCurrency();
    unawaited(_metaWallet.add(_runSummary.metaCurrencyEarned));
    _resetStageActors();
    _stageTimer = null;
    _resetFinaleState();
    _selectionState.clear();
    _activeSelectionTrackId = null;
    overlays.remove(SelectionOverlay.overlayKey);
    overlays.remove(StatsOverlay.overlayKey);
    overlays.remove(EscapeMenuOverlay.overlayKey);
    _setFlowState(GameFlowState.death);
    overlays.remove(VirtualStickOverlay.overlayKey);
    overlays.remove(FirstRunHintsOverlay.overlayKey);
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
    final pickupBonus = _playerState.stats.value(StatId.pickupRadiusPercent);
    final pickupRadius = math.max(0, _pickupRadiusBase * (1 + pickupBonus));
    final collectRadius = _playerRadius + pickupRadius;
    final collectRadiusSquared = collectRadius * collectRadius;
    for (var i = _pickupPool.active.length - 1; i >= 0; i--) {
      final pickup = _pickupPool.active[i];
      if (!pickup.active) {
        continue;
      }
      pickup.age += dt;
      if (!pickup.collecting &&
          pickup.lifespan > 0 &&
          pickup.age >= pickup.lifespan) {
        _despawnPickup(pickup);
        continue;
      }
      final dx = _playerState.position.x - pickup.position.x;
      final dy = _playerState.position.y - pickup.position.y;
      final distanceSquared = dx * dx + dy * dy;
      if (!pickup.collecting && distanceSquared <= collectRadiusSquared) {
        pickup.collecting = true;
        pickup.magnetSpeed = _pickupMagnetStartSpeed;
      }
      if (!pickup.collecting) {
        continue;
      }
      if (distanceSquared <= _playerRadius * _playerRadius) {
        _collectPickup(pickup);
        continue;
      }
      final distance = math.sqrt(distanceSquared);
      if (distance <= 0) {
        continue;
      }
      pickup.magnetSpeed = math.min(
        _pickupMagnetMaxSpeed,
        pickup.magnetSpeed + _pickupMagnetAcceleration * dt,
      );
      final travel = math.min(pickup.magnetSpeed * dt, distance);
      pickup.position.x += (dx / distance) * travel;
      pickup.position.y += (dy / distance) * travel;
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
      final currencyId = _currencyByPickupKind[pickup.kind] ?? CurrencyId.xp;
      if (currencyId == CurrencyId.xp) {
        _runSummary.xpGained += pickup.value;
      }
      final gain = _progressionSystem.addCurrency(currencyId, pickup.value);
      if (gain != null && gain.levelsGained > 0) {
        _levelUpSystem.queueLevels(gain.trackId, gain.levelsGained);
        _offerSelectionIfNeeded();
      }
    }
    _spawnPickupSpark(pickup.position);
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
    _progressionSystem.reset();
    _skillSystem.resetToDefaults();
    _playerState.resetForRun();
    _playerState.applyModifiers(_metaUnlocks.activeModifiers);
    _levelUpSystem.resetForRun(playerState: _playerState);
    _activeSelectionTrackId = null;
  }

  void _revivePlayer() {
    _playerState.hp = _playerState.maxHp;
    _playerState.movementIntent.setZero();
    _playerState.position.setFrom(_mapSize / 2);
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
