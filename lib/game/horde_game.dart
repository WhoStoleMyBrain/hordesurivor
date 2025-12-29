import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/enemy_defs.dart';
import '../data/ids.dart';
import '../data/tags.dart';
import '../render/damage_number_component.dart';
import '../render/enemy_component.dart';
import '../render/player_component.dart';
import '../render/projectile_batch_component.dart';
import '../render/projectile_component.dart';
import '../render/sprite_pipeline.dart';
import '../ui/hud_state.dart';
import '../ui/selection_overlay.dart';
import '../ui/selection_state.dart';
import 'damage_system.dart';
import 'enemy_pool.dart';
import 'enemy_state.dart';
import 'enemy_system.dart';
import 'experience_system.dart';
import 'level_up_system.dart';
import 'player_state.dart';
import 'projectile_pool.dart';
import 'projectile_state.dart';
import 'projectile_system.dart';
import 'skill_system.dart';
import 'spatial_grid.dart';
import 'spawner_system.dart';

class HordeGame extends FlameGame with KeyboardEvents, PanDetector {
  HordeGame({this.stressTest = false})
      : super(backgroundColor: const Color(0xFF0F1117));

  static const double _fixedDelta = 1 / 60;
  static const double _playerRadius = 16;
  static const double _playerSpeed = 80;
  static const double _playerMaxHp = 100;
  static const double _enemyRadius = 14;
  static const double _enemyContactDamagePerSecond = 12;
  static const int _stressEnemyCount = 550;
  static const int _stressProjectileBurstCount = 1100;
  static const double _stressProjectileInterval = 4;
  static const int _maxFixedStepsPerFrame = 5;
  static const double _panDeadZone = 8;
  static const double _panMaxRadius = 72;
  static const String _playerSpriteId = 'player_base';
  static const String _projectileSpriteId = 'projectile_firebolt';

  double _accumulator = 0;
  double _frameTimeMs = 0;
  double _fps = 0;
  double _stressProjectileTimer = 0;
  final bool stressTest;
  late final PlayerState _playerState;
  late final PlayerComponent _playerComponent;
  final SpritePipeline _spritePipeline = SpritePipeline();
  final Map<EnemyId, Image> _enemySprites = {};
  Image? _projectileSprite;
  ProjectileBatchComponent? _projectileBatchComponent;
  final Set<LogicalKeyboardKey> _keysPressed = {};
  final Vector2 _keyboardDirection = Vector2.zero();
  final Vector2 _panDirection = Vector2.zero();
  bool _isPanning = false;
  Vector2? _panStart;
  late final EnemyPool _enemyPool;
  late final EnemySystem _enemySystem;
  late final SpawnerSystem _spawnerSystem;
  bool _spawnerReady = false;
  late final ProjectilePool _projectilePool;
  late final ProjectileSystem _projectileSystem;
  late final SkillSystem _skillSystem;
  late final SpatialGrid _enemyGrid;
  late final DamageSystem _damageSystem;
  late final ExperienceSystem _experienceSystem;
  late final LevelUpSystem _levelUpSystem;
  final PlayerHudState _hudState = PlayerHudState();
  final SelectionState _selectionState = SelectionState();
  final Map<ProjectileState, ProjectileComponent> _projectileComponents = {};
  final Map<EnemyState, EnemyComponent> _enemyComponents = {};
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
  bool _inputLocked = false;
  VoidCallback? _selectionListener;

  PlayerHudState get hudState => _hudState;
  SelectionState get selectionState => _selectionState;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _selectionListener = _handleSelectionStateChanged;
    _selectionState.addListener(_selectionListener!);
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
    _playerState = PlayerState(
      position: size / 2,
      maxHp: _playerMaxHp,
      moveSpeed: _playerSpeed,
    );
    _experienceSystem = ExperienceSystem();
    _levelUpSystem = LevelUpSystem(random: math.Random(11));
    _playerComponent = PlayerComponent(
      state: _playerState,
      radius: _playerRadius,
      spriteImage: playerSprite,
    );
    _playerComponent.syncWithState();
    await add(_playerComponent);

    _enemyPool = EnemyPool(initialCapacity: stressTest ? 600 : 48);
    _projectilePool = ProjectilePool(initialCapacity: stressTest ? 1400 : 64);
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
    );
    _enemyGrid = SpatialGrid(cellSize: 64);
    _projectileSystem = ProjectileSystem(_projectilePool);
    _skillSystem = SkillSystem(projectilePool: _projectilePool);
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
                enemyId: EnemyId.imp,
                count: _stressEnemyCount,
              ),
            ]
          : const [
              SpawnWave(
                time: 0,
                count: 4,
                roleWeights: {
                  EnemyRole.chaser: 3,
                },
              ),
              SpawnWave(
                time: 2,
                count: 3,
                roleWeights: {
                  EnemyRole.chaser: 2,
                  EnemyRole.ranged: 1,
                },
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
    );
    _spawnerReady = true;
    if (stressTest) {
      _stressProjectileTimer = _stressProjectileInterval;
      debugPrint(
        'Stress scene active: spawning $_stressEnemyCount enemies and '
        '$_stressProjectileBurstCount-projectile bursts.',
      );
    }
    _syncHudState();
  }

  @override
  void update(double dt) {
    final clampedDt = math.min(dt, 0.25);
    _frameTimeMs = clampedDt * 1000;
    _fps = clampedDt > 0 ? 1 / clampedDt : 0;
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
    if (_selectionState.active) {
      _playerState.movementIntent.setZero();
      _playerComponent.syncWithState();
      _syncHudState();
      return;
    }
    _applyInput();
    _playerState.step(dt);
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
    _damageSystem.resolve(
      onEnemyDefeated: _handleEnemyDefeated,
      onEnemyDamaged: _handleEnemyDamaged,
    );
    _syncHudState();

    _playerState.clampToBounds(
      min: Vector2(_playerRadius, _playerRadius),
      max: Vector2(size.x - _playerRadius, size.y - _playerRadius),
    );

    _playerComponent.syncWithState();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_spawnerReady) {
      _spawnerSystem.updateArenaSize(size);
    }
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
    _panStart = info.eventPosition.game.clone();
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
    _panDirection.setFrom(info.eventPosition.game - start);
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
    final component = _projectileComponents.remove(projectile);
    component?.removeFromParent();
  }

  void _handleEnemyDefeated(EnemyState enemy) {
    if (!stressTest) {
      final levelsGained = _experienceSystem.addExperience(enemy.xpReward);
      if (levelsGained > 0) {
        _levelUpSystem.queueLevels(levelsGained);
        _offerSelectionIfNeeded();
      }
    }
    final component = _enemyComponents.remove(enemy);
    component?.removeFromParent();
    _enemyPool.release(enemy);
  }

  void _registerEnemyComponent(EnemyState enemy) {
    final component = EnemyComponent(
      state: enemy,
      radius: _enemyRadius,
      spriteImage: _enemySprites[enemy.id],
    );
    _enemyComponents[enemy] = component;
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
    _offerSelectionIfNeeded();
  }

  void _offerSelectionIfNeeded() {
    _levelUpSystem.buildChoices(
      playerState: _playerState,
      skillSystem: _skillSystem,
    );
    if (_levelUpSystem.hasChoices) {
      _selectionState.showChoices(_levelUpSystem.choices);
      overlays.add(SelectionOverlay.overlayKey);
    } else {
      _selectionState.clear();
      overlays.remove(SelectionOverlay.overlayKey);
    }
  }

  void _syncHudState() {
    _hudState.update(
      hp: _playerState.hp,
      maxHp: _playerState.maxHp,
      level: _experienceSystem.level,
      xp: _experienceSystem.currentXp,
      xpToNext: _experienceSystem.xpToNext,
      showPerformance: stressTest,
      fps: _fps,
      frameTimeMs: _frameTimeMs,
    );
  }

  void _handleSelectionStateChanged() {
    final locked = _selectionState.active;
    if (_inputLocked == locked) {
      return;
    }
    _inputLocked = locked;
    if (_inputLocked) {
      _resetPointerInput();
    }
  }

  void _resetPointerInput() {
    _isPanning = false;
    _panStart = null;
    _panDirection.setZero();
    _playerState.movementIntent.setZero();
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
      _stressVelocity.setValues(
        math.cos(angle) * 180,
        math.sin(angle) * 180,
      );

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

  @override
  void onRemove() {
    if (_selectionListener != null) {
      _selectionState.removeListener(_selectionListener!);
    }
    super.onRemove();
  }
}
