import 'dart:ui';

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

  Image? lookup(String id) => cache.get(id);
}
