import 'package:flame/extensions.dart';

class MapSize {
  const MapSize({required this.width, required this.height});

  final double width;
  final double height;

  Vector2 toVector2() => Vector2(width, height);

  Rect toRect() => Rect.fromLTWH(0, 0, width, height);
}
