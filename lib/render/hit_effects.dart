import 'dart:ui';

import 'package:flame/extensions.dart';

abstract class HitEffectRenderer {
  void render(
    Canvas canvas, {
    required double progress,
    required double radius,
    required Vector2 size,
  });
}

class PlayerHitFlashEffect implements HitEffectRenderer {
  PlayerHitFlashEffect({Color color = const Color(0xFFE35A5A)})
    : _paint = Paint()..color = color;

  final Paint _paint;

  @override
  void render(
    Canvas canvas, {
    required double progress,
    required double radius,
    required Vector2 size,
  }) {
    if (progress >= 1) {
      return;
    }
    final intensity = (1 - progress).clamp(0.0, 1.0);
    _paint.color = _paint.color.withValues(alpha: 0.55 * intensity);
    if (size.x > 0 && size.y > 0) {
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: size.x,
        height: size.y,
      );
      canvas.drawRect(rect, _paint);
    } else {
      canvas.drawCircle(Offset.zero, radius, _paint);
    }
  }
}
