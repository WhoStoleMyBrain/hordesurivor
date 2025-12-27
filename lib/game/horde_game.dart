import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/game.dart';

import '../render/player_component.dart';
import 'player_state.dart';

class HordeGame extends FlameGame {
  HordeGame() : super(backgroundColor: const Color(0xFF0F1117));

  static const double _fixedDelta = 1 / 60;
  static const double _playerRadius = 16;
  static const double _playerSpeed = 80;

  double _accumulator = 0;
  late final PlayerState _playerState;
  late final PlayerComponent _playerComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _playerState = PlayerState(
      position: size / 2,
      velocity: Vector2(_playerSpeed, _playerSpeed * 0.6),
    );
    _playerComponent = PlayerComponent(
      state: _playerState,
      radius: _playerRadius,
    );
    _playerComponent.syncWithState();
    await add(_playerComponent);
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
    _playerState.step(dt);

    final minX = _playerRadius;
    final minY = _playerRadius;
    final maxX = size.x - _playerRadius;
    final maxY = size.y - _playerRadius;

    if (_playerState.position.x <= minX || _playerState.position.x >= maxX) {
      _playerState.velocity.x = -_playerState.velocity.x;
    }
    if (_playerState.position.y <= minY || _playerState.position.y >= maxY) {
      _playerState.velocity.y = -_playerState.velocity.y;
    }

    _playerComponent.syncWithState();
  }
}
