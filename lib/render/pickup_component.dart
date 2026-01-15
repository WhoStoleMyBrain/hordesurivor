import 'dart:ui';

import 'package:flame/components.dart';

import '../game/pickup_state.dart';
import 'render_scale.dart';

class PickupComponent extends PositionComponent {
  PickupComponent({
    required PickupState state,
    required Map<PickupKind, Image?> spriteImages,
    double renderScale = RenderScale.worldScale,
  }) : _state = state,
       _spriteImages = spriteImages,
       _paint = Paint()..color = const Color(0xFFE9D8A6) {
    anchor = Anchor.center;
    scale = Vector2.all(renderScale);
    _syncSprite();
  }

  final PickupState _state;
  final Map<PickupKind, Image?> _spriteImages;
  final Paint _paint;
  PickupKind? _lastKind;
  Image? _spriteImage;

  void _syncSprite() {
    _spriteImage = _spriteImages[_state.kind];
    if (_spriteImage != null) {
      size = Vector2(
        _spriteImage!.width.toDouble(),
        _spriteImage!.height.toDouble(),
      );
    } else {
      size = Vector2.all(10);
    }
  }

  @override
  void update(double dt) {
    if (_lastKind != _state.kind) {
      _lastKind = _state.kind;
      _syncSprite();
    }
    position.setFrom(_state.position);
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final image = _spriteImage;
    if (image != null) {
      final destRect = Rect.fromCenter(
        center: Offset.zero,
        width: size.x,
        height: size.y,
      );
      final srcRect = Rect.fromLTWH(
        0,
        0,
        image.width.toDouble(),
        image.height.toDouble(),
      );
      canvas.drawImageRect(image, srcRect, destRect, _paint);
    } else {
      canvas.drawCircle(Offset.zero, size.x * 0.5, _paint);
    }
  }
}
