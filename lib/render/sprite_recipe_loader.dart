import 'package:flutter/services.dart' show rootBundle;

import '../data/sprite_recipes.dart';

class SpriteRecipeLoader {
  Future<SpriteRecipeSet> loadFromAsset(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    return SpriteRecipeSet.fromJsonString(jsonString);
  }
}
