import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import '../data/sprite_recipes.dart';

class GeneratedSprite {
  const GeneratedSprite({
    required this.id,
    required this.outputName,
    required this.image,
  });

  final String id;
  final String outputName;
  final Image image;
}

class SpriteGenerator {
  Future<List<GeneratedSprite>> generateAll(
    List<SpriteRecipe> recipes,
  ) async {
    final results = <GeneratedSprite>[];
    for (final recipe in recipes) {
      results.add(await generate(recipe));
    }
    return results;
  }

  Future<GeneratedSprite> generate(SpriteRecipe recipe) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final size = recipe.size.toDouble();
    final center = Offset(size / 2, size / 2);

    canvas.translate(center.dx, center.dy);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: size, height: size),
      Paint()..color = const Color(0x00000000),
    );

    final palette = _paletteToColors(recipe.palette);
    final random = math.Random(recipe.seed);

    for (final shape in recipe.shapes) {
      final color = palette[shape.colorKey] ?? const Color(0xFFFFFFFF);
      final offset = Offset(
        shape.offset.isNotEmpty ? shape.offset[0].toDouble() : 0,
        shape.offset.length > 1 ? shape.offset[1].toDouble() : 0,
      );
      switch (shape.type) {
        case 'circle':
          final radius = shape.radius?.toDouble() ?? 2;
          canvas.drawCircle(offset, radius, Paint()..color = color);
          break;
        case 'rect':
          final rectSize = shape.size ?? [2, 2];
          final rect = Rect.fromCenter(
            center: offset,
            width: rectSize[0].toDouble(),
            height: rectSize[1].toDouble(),
          );
          canvas.drawRect(rect, Paint()..color = color);
          break;
        case 'pixels':
          final points = shape.points ?? [];
          final paint = Paint()..color = color;
          for (final point in points) {
            if (point.length < 2) {
              continue;
            }
            final jitter = random.nextDouble() * 0.2 - 0.1;
            final pixelRect = Rect.fromCenter(
              center: Offset(
                point[0].toDouble() + jitter,
                point[1].toDouble() + jitter,
              ),
              width: 1,
              height: 1,
            );
            canvas.drawRect(pixelRect, paint);
          }
          break;
        default:
          break;
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(recipe.size, recipe.size);
    return GeneratedSprite(
      id: recipe.id,
      outputName: recipe.outputName,
      image: image,
    );
  }

  Map<String, Color> _paletteToColors(Map<String, String> palette) {
    return palette.map((key, value) => MapEntry(key, _parseColor(value)));
  }

  Color _parseColor(String value) {
    var cleaned = value.replaceFirst('#', '');
    if (cleaned.length == 6) {
      cleaned = 'FF$cleaned';
    }
    final parsed = int.tryParse(cleaned, radix: 16) ?? 0xFFFFFFFF;
    return Color(parsed);
  }

  Future<Uint8List> encodePng(Image image) async {
    final data = await image.toByteData(format: ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }
}
