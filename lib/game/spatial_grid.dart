import 'package:flame/extensions.dart';

import 'enemy_state.dart';

class SpatialGrid {
  SpatialGrid({required this.cellSize});

  final double cellSize;
  final Map<int, List<EnemyState>> _cells = {};
  final List<int> _activeKeys = [];

  void rebuild(Iterable<EnemyState> enemies) {
    clear();
    for (final enemy in enemies) {
      if (!enemy.active) {
        continue;
      }
      _insert(enemy);
    }
  }

  void clear() {
    for (final key in _activeKeys) {
      _cells[key]?.clear();
    }
    _activeKeys.clear();
  }

  List<EnemyState> queryCircle(
    Vector2 center,
    double radius,
    List<EnemyState> output,
  ) {
    output.clear();
    final minX = ((center.x - radius) / cellSize).floor();
    final maxX = ((center.x + radius) / cellSize).floor();
    final minY = ((center.y - radius) / cellSize).floor();
    final maxY = ((center.y + radius) / cellSize).floor();
    for (var y = minY; y <= maxY; y++) {
      for (var x = minX; x <= maxX; x++) {
        final cell = _cells[_hash(x, y)];
        if (cell == null || cell.isEmpty) {
          continue;
        }
        output.addAll(cell);
      }
    }
    return output;
  }

  void _insert(EnemyState enemy) {
    final cellX = (enemy.position.x / cellSize).floor();
    final cellY = (enemy.position.y / cellSize).floor();
    final key = _hash(cellX, cellY);
    final cell = _cells.putIfAbsent(key, () => []);
    if (cell.isEmpty) {
      _activeKeys.add(key);
    }
    cell.add(enemy);
  }

  int _hash(int x, int y) {
    return (x * 73856093) ^ (y * 19349663);
  }
}
