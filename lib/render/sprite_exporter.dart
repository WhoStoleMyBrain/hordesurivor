import 'dart:io';

import 'sprite_generator.dart';

class SpriteExporter {
  SpriteExporter({SpriteGenerator? generator})
    : _generator = generator ?? SpriteGenerator();

  final SpriteGenerator _generator;

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
}
