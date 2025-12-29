import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'sprite_pipeline.dart';

class SpriteGenDemo extends FlameGame {
  /// Demo game for previewing runtime-generated sprites.
  ///
  /// The default workflow generates sprites at runtime and caches them via
  /// [SpritePipeline]. Provide [exportDirectory] to optionally export the
  /// generated images during development for inspection or asset baking.
  SpriteGenDemo({
    this.exportDirectory,
  }) : super(backgroundColor: const Color(0xFF0B0D12));

  final String? exportDirectory;
  final SpritePipeline _pipeline = SpritePipeline();
  final List<SpriteComponent> _components = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprites = await _pipeline.loadAndGenerateFromAsset(
      'assets/sprites/recipes.json',
    );
    if (exportDirectory != null) {
      await _pipeline.exportToDirectory(
        sprites: sprites,
        directoryPath: exportDirectory!,
      );
      debugPrint('Exported ${sprites.length} sprites to $exportDirectory');
    }

    const padding = 12.0;
    var x = padding;
    var y = padding;
    var rowHeight = 0.0;

    for (final sprite in sprites) {
      final component = SpriteComponent(
        sprite: Sprite(sprite.image),
        size: Vector2(sprite.image.width.toDouble(), sprite.image.height.toDouble()),
        position: Vector2(x, y),
      )..anchor = Anchor.topLeft;
      await add(component);
      _components.add(component);

      x += component.size.x + padding;
      rowHeight = mathMax(rowHeight, component.size.y);
      if (x + component.size.x > size.x - padding) {
        x = padding;
        y += rowHeight + padding;
        rowHeight = 0;
      }
    }
  }

  double mathMax(double a, double b) => a > b ? a : b;
}
