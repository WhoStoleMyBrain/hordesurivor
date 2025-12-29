import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/services.dart';

import '../data/ids.dart';
import '../render/enemy_component.dart';
import '../render/player_component.dart';
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
  HordeGame() : super(backgroundColor: const Color(0xFF0F1117));

  static const double _fixedDelta = 1 / 60;
  static const double _playerRadius = 16;
  static const double _playerSpeed = 80;
  static const double _playerMaxHp = 100;
  static const double _enemyRadius = 14;
  static const double _enemyContactDamagePerSecond = 12;

  double _accumulator = 0;
  late final PlayerState _playerState;
  late final PlayerComponent _playerComponent;
  final SpritePipeline _spritePipeline = SpritePipeline();
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

  PlayerHudState get hudState => _hudState;
  SelectionState get selectionState => _selectionState;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprites = await _spritePipeline.loadAndGenerateFromAsset(
      'assets/sprites/recipes.json',
    );
    final playerSprite = sprites
        .where((sprite) => sprite.id == 'player_base')
        .map((sprite) => sprite.image)
        .fold<Image?>(null, (previous, image) => previous ?? image);
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

    _enemyPool = EnemyPool(initialCapacity: 48);
    _enemySystem = EnemySystem(_enemyPool);
    _enemyGrid = SpatialGrid(cellSize: 64);
    _projectilePool = ProjectilePool(initialCapacity: 64);
    _projectileSystem = ProjectileSystem(_projectilePool);
    _skillSystem = SkillSystem(projectilePool: _projectilePool);
    _damageSystem = DamageSystem(DamageEventPool(initialCapacity: 64));
    _spawnerSystem = SpawnerSystem(
      pool: _enemyPool,
      random: math.Random(7),
      arenaSize: size,
      waves: const [
        SpawnWave(time: 0, enemyId: EnemyId.imp, count: 4),
        SpawnWave(time: 2, enemyId: EnemyId.imp, count: 3),
        SpawnWave(time: 5, enemyId: EnemyId.imp, count: 5),
      ],
      onSpawn: (enemy) {
        final component = EnemyComponent(state: enemy, radius: _enemyRadius);
        _enemyComponents[enemy] = component;
        add(component);
      },
    );
    _spawnerReady = true;
    _syncHudState();
  }

  @override
  void update(double dt) {
    final clampedDt = math.min(dt, 0.25);
    _accumulator += clampedDt;
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
    _enemySystem.update(dt, _playerState.position);
    _enemyGrid.rebuild(_enemyPool.active);
    _skillSystem.update(
      dt: dt,
      playerPosition: _playerState.position,
      aimDirection: _playerState.movementIntent,
      enemyPool: _enemyPool,
      enemyGrid: _enemyGrid,
      onProjectileSpawn: _handleProjectileSpawn,
      onEnemyDamaged: _damageSystem.queueEnemyDamage,
    );
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
    );
    _damageSystem.resolve(onEnemyDefeated: _handleEnemyDefeated);
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
    if (_isPanning) {
      _playerState.movementIntent.setFrom(_panDirection);
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
    _isPanning = true;
    _panStart = info.eventPosition.game.clone();
    _panDirection.setZero();
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    final start = _panStart;
    if (start == null) {
      return;
    }
    _panDirection.setFrom(info.eventPosition.game - start);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    _isPanning = false;
    _panStart = null;
    _panDirection.setZero();
  }

  void _handleProjectileSpawn(ProjectileState projectile) {
    final component = ProjectileComponent(state: projectile);
    _projectileComponents[projectile] = component;
    add(component);
  }

  void _handleProjectileDespawn(ProjectileState projectile) {
    final component = _projectileComponents.remove(projectile);
    component?.removeFromParent();
  }

  void _handleEnemyDefeated(EnemyState enemy) {
    final levelsGained = _experienceSystem.addExperience(enemy.xpReward);
    if (levelsGained > 0) {
      _levelUpSystem.queueLevels(levelsGained);
      _offerSelectionIfNeeded();
    }
    final component = _enemyComponents.remove(enemy);
    component?.removeFromParent();
    _enemyPool.release(enemy);
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
    );
  }
}
