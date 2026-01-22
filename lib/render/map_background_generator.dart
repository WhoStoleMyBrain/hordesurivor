import 'dart:math' as math;
import 'dart:ui';

import '../data/map_background_defs.dart';

sealed class MapBackgroundStamp {
  const MapBackgroundStamp(this.paint);

  final Paint paint;

  void render(Canvas canvas);
}

class RectStamp extends MapBackgroundStamp {
  const RectStamp({required this.rect, required Paint paint}) : super(paint);

  final Rect rect;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(rect, paint);
  }
}

class CircleStamp extends MapBackgroundStamp {
  const CircleStamp({
    required this.center,
    required this.radius,
    required Paint paint,
  }) : super(paint);

  final Offset center;
  final double radius;

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(center, radius, paint);
  }
}

class MapBackgroundPattern {
  MapBackgroundPattern({
    required this.baseColor,
    required this.tileSize,
    required List<MapBackgroundStamp> stamps,
  }) : stamps = List.unmodifiable(stamps);

  final Color baseColor;
  final double tileSize;
  final List<MapBackgroundStamp> stamps;
}

class MapBackgroundGenerator {
  const MapBackgroundGenerator();

  MapBackgroundPattern generate(MapBackgroundDef def) {
    final rand = math.Random(def.seed);
    final tileSize = def.tileSize.toDouble();
    final stamps = <MapBackgroundStamp>[];

    for (var i = 0; i < def.speckCount; i++) {
      final size = _lerp(def.speckMinSize, def.speckMaxSize, rand.nextDouble());
      final x = rand.nextDouble() * (tileSize - size);
      final y = rand.nextDouble() * (tileSize - size);
      final color = def.speckColors[rand.nextInt(def.speckColors.length)];
      stamps.add(
        RectStamp(
          rect: Rect.fromLTWH(x, y, size, size),
          paint: Paint()..color = color,
        ),
      );
    }

    for (var i = 0; i < def.blotchCount; i++) {
      final radius = _lerp(
        def.blotchMinRadius,
        def.blotchMaxRadius,
        rand.nextDouble(),
      );
      final x = rand.nextDouble() * tileSize;
      final y = rand.nextDouble() * tileSize;
      final color = def.blotchColors[rand.nextInt(def.blotchColors.length)];
      final opacity = _lerp(0.35, 0.6, rand.nextDouble());
      stamps.add(
        CircleStamp(
          center: Offset(x, y),
          radius: radius,
          paint: Paint()..color = color.withValues(alpha: opacity),
        ),
      );
    }

    return MapBackgroundPattern(
      baseColor: def.baseColor,
      tileSize: tileSize,
      stamps: stamps,
    );
  }

  double _lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
