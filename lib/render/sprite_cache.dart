import 'dart:ui';

import 'sprite_generator.dart';

class SpriteCache {
  final Map<String, Image> _images = {};

  Image? get(String id) => _images[id];

  void add(GeneratedSprite sprite) {
    _images[sprite.id] = sprite.image;
  }

  void addAll(Iterable<GeneratedSprite> sprites) {
    for (final sprite in sprites) {
      add(sprite);
    }
  }
}
