import 'dart:io';
import 'dart:ui';

import '../data/sprite_recipes.dart';
import 'sprite_cache.dart';
import 'sprite_generator.dart';
import 'sprite_recipe_loader.dart';

class SpritePipeline {
  SpritePipeline({
    SpriteRecipeLoader? loader,
    SpriteGenerator? generator,
  })  : _loader = loader ?? SpriteRecipeLoader(),
        _generator = generator ?? SpriteGenerator();

  final SpriteRecipeLoader _loader;
  final SpriteGenerator _generator;
  final SpriteCache cache = SpriteCache();

  Future<List<GeneratedSprite>> loadAndGenerateFromAsset(
    String assetPath,
  ) async {
    final recipeSet = await _loader.loadFromAsset(assetPath);
    final generated = await _generator.generateAll(recipeSet.recipes);
    cache.addAll(generated);
    return generated;
  }

  Future<void> exportToDirectory({
    required List<GeneratedSprite> sprites,
    required String directoryPath,
  }) async {
    final dir = Directory(directoryPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    for (final sprite in sprites) {
      final pngBytes = await _generator.encodePng(sprite.image);
      final file = File('${dir.path}/${sprite.outputName}');
      await file.writeAsBytes(pngBytes, flush: true);
    }
  }

  Image? lookup(String id) => cache.get(id);
}
