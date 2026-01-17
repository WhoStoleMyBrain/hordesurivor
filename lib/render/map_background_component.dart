import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class MapBackgroundComponent extends RectangleComponent {
  MapBackgroundComponent({required Vector2 size, required Color color})
    : super(
        position: Vector2.zero(),
        size: size.clone(),
        paint: Paint()..color = color,
        priority: -1000,
      ) {
    anchor = Anchor.topLeft;
  }

  void updateAppearance({required Vector2 size, required Color color}) {
    this.size.setFrom(size);
    paint.color = color;
  }
}
