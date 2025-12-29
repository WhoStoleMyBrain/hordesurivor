import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/services.dart';

import '../data/ids.dart';
import '../render/enemy_component.dart';
import '../render/player_component.dart';
import '../render/projectile_component.dart';
import '../render/sprite_pipeline.dart';
import 'enemy_pool.dart';
import 'enemy_system.dart';
import 'player_state.dart';
import 'projectile_pool.dart';
import 'projectile_state.dart';
import 'projectile_system.dart';
import 'skill_system.dart';
import 'spawner_system.dart';

class HordeGame extends FlameGame with KeyboardEvents, PanDetector {
  HordeGame() : super(backgroundColor: const Color(0xFF0F1117));

  static const double _fixedDelta = 1 / 60;
  static const double _playerRadius = 16;
  static const double _playerSpeed = 80;
  static const double _playerMaxHp = 100;
  static const double _enemyRadius = 14;

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
  final Map<ProjectileState, ProjectileComponent> _projectileComponents = {};

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
    _playerComponent = PlayerComponent(
      state: _playerState,
      radius: _playerRadius,
      spriteImage: playerSprite,
    );
    _playerComponent.syncWithState();
    await add(_playerComponent);

    _enemyPool = EnemyPool(initialCapacity: 48);
    _enemySystem = EnemySystem(_enemyPool);
    _projectilePool = ProjectilePool(initialCapacity: 64);
    _projectileSystem = ProjectileSystem(_projectilePool);
    _skillSystem = SkillSystem(projectilePool: _projectilePool);
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
        add(EnemyComponent(state: enemy, radius: _enemyRadius));
      },
    );
    _spawnerReady = true;
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
    _applyInput();
    _playerState.step(dt);
    _spawnerSystem.update(dt, _playerState.position);
    _enemySystem.update(dt, _playerState.position);
    _skillSystem.update(
      dt: dt,
      playerPosition: _playerState.position,
      aimDirection: _playerState.movementIntent,
      enemyPool: _enemyPool,
      onProjectileSpawn: _handleProjectileSpawn,
    );
    _projectileSystem.update(
      dt,
      size,
      onDespawn: _handleProjectileDespawn,
    );

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
}
