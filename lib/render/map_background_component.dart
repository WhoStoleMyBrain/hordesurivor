import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'map_background_generator.dart';

class MapBackgroundComponent extends PositionComponent {
  MapBackgroundComponent({
    required Vector2 size,
    required Color color,
    MapBackgroundPattern? pattern,
  }) : _paint = Paint()..color = color,
       _pattern = pattern,
       _backgroundRect = Rect.fromLTWH(0, 0, size.x, size.y),
       _tileColumns = 0,
       _tileRows = 0,
       super(position: Vector2.zero(), size: size.clone(), priority: -1000) {
    anchor = Anchor.topLeft;
    _recalculateTiles();
  }

  final Paint _paint;
  MapBackgroundPattern? _pattern;
  Rect _backgroundRect;
  int _tileColumns;
  int _tileRows;

  void updateAppearance({
    required Vector2 size,
    required Color color,
    MapBackgroundPattern? pattern,
  }) {
    this.size.setFrom(size);
    _backgroundRect = Rect.fromLTWH(0, 0, size.x, size.y);
    _paint.color = color;
    _pattern = pattern;
    _recalculateTiles();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(_backgroundRect, _paint);
    final pattern = _pattern;
    if (pattern == null || pattern.stamps.isEmpty) {
      return;
    }
    for (var row = 0; row < _tileRows; row++) {
      for (var col = 0; col < _tileColumns; col++) {
        canvas.save();
        canvas.translate(col * pattern.tileSize, row * pattern.tileSize);
        for (final stamp in pattern.stamps) {
          stamp.render(canvas);
        }
        canvas.restore();
      }
    }
  }

  void _recalculateTiles() {
    final pattern = _pattern;
    if (pattern == null || pattern.tileSize <= 0) {
      _tileColumns = 0;
      _tileRows = 0;
      return;
    }
    _tileColumns = (size.x / pattern.tileSize).ceil();
    _tileRows = (size.y / pattern.tileSize).ceil();
  }
}
