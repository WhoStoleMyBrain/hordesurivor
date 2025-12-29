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
    final layerBounds = Rect.fromCenter(
      center: Offset.zero,
      width: size,
      height: size,
    );
    canvas.saveLayer(layerBounds, Paint());

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
        case 'line':
          final start = shape.start;
          final end = shape.end;
          if (start == null || end == null) {
            break;
          }
          final paint = Paint()
            ..color = color
            ..strokeWidth = (shape.thickness ?? 1).toDouble()
            ..style = PaintingStyle.stroke;
          canvas.drawLine(_offsetFromList(start), _offsetFromList(end), paint);
          break;
        case 'arc':
          final radius = shape.radius?.toDouble() ?? 0;
          if (radius <= 0) {
            break;
          }
          final rect = Rect.fromCircle(center: offset, radius: radius);
          final startAngle = (shape.startAngle ?? 0) * math.pi / 180;
          final sweepAngle = (shape.sweepAngle ?? 0) * math.pi / 180;
          final isFilled = shape.filled ?? false;
          final paint = Paint()
            ..color = color
            ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
            ..strokeWidth = (shape.thickness ?? 1).toDouble();
          canvas.drawArc(rect, startAngle, sweepAngle, isFilled, paint);
          break;
        case 'maskCircle':
          final radius = shape.radius?.toDouble() ?? 0;
          if (radius <= 0) {
            break;
          }
          final maskPaint = Paint()
            ..color = color.withAlpha(0xFF)
            ..blendMode = BlendMode.dstIn;
          canvas.drawCircle(offset, radius, maskPaint);
          break;
        case 'maskRect':
          final rectSize = shape.size ?? [0, 0];
          if (rectSize.length < 2 || rectSize[0] <= 0 || rectSize[1] <= 0) {
            break;
          }
          final rect = Rect.fromCenter(
            center: offset,
            width: rectSize[0].toDouble(),
            height: rectSize[1].toDouble(),
          );
          final maskPaint = Paint()
            ..color = color.withAlpha(0xFF)
            ..blendMode = BlendMode.dstIn;
          canvas.drawRect(rect, maskPaint);
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

    canvas.restore();
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

  Offset _offsetFromList(List<int> value) {
    if (value.length < 2) {
      return Offset.zero;
    }
    return Offset(value[0].toDouble(), value[1].toDouble());
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
