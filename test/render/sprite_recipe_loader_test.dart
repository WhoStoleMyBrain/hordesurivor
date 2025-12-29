import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hordesurivor/data/sprite_recipes.dart';
import 'package:hordesurivor/render/sprite_generator.dart';
import 'package:hordesurivor/render/sprite_recipe_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const assetKey = 'assets/sprites/test_recipes.json';

  setUp(() {
    ServicesBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (message) async {
        final key = utf8.decode(message!.buffer.asUint8List());
        if (key != assetKey) {
          return null;
        }
        const payload = '''
{
  "sprites": [
    {
      "id": "player_test",
      "kind": "player",
      "outputName": "player_test.png",
      "size": 8,
      "seed": 42,
      "palette": {
        "main": "#FF0000"
      },
      "shapes": [
        { "type": "rect", "color": "main", "offset": [0, 0], "size": [4, 4] }
      ]
    },
    {
      "id": "invalid_missing_palette",
      "kind": "enemy",
      "outputName": "invalid.png",
      "size": 8,
      "seed": 1,
      "palette": {},
      "shapes": [
        { "type": "circle", "color": "main", "offset": [0, 0], "radius": 2 }
      ]
    }
  ]
}
''';
        final bytes = Uint8List.fromList(utf8.encode(payload));
        return ByteData.view(bytes.buffer);
      },
    );
  });

  tearDown(() {
    ServicesBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      null,
    );
  });

  test('loads valid sprite recipes and skips invalid ones', () async {
    final loader = SpriteRecipeLoader();
    final recipeSet = await loader.loadFromAsset(assetKey);

    expect(recipeSet.recipes, hasLength(1));
    expect(recipeSet.recipes.first.id, 'player_test');
  });

  test('sprite generation is deterministic for the same seed', () async {
    const recipe = SpriteRecipe(
      id: 'deterministic',
      kind: SpriteKind.player,
      outputName: 'deterministic.png',
      size: 8,
      seed: 7,
      palette: {'main': '#FFFFFF'},
      shapes: [
        SpriteShape(
          type: 'pixels',
          colorKey: 'main',
          offset: [0, 0],
          points: [
            [0, 0],
            [1, 0],
            [0, 1]
          ],
        )
      ],
    );
    final generator = SpriteGenerator();

    final first = await generator.generate(recipe);
    final second = await generator.generate(recipe);

    final firstBytes = await generator.encodePng(first.image);
    final secondBytes = await generator.encodePng(second.image);

    expect(firstBytes, equals(secondBytes));
  });
}
