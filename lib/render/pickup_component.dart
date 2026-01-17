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
  Rect _spriteSourceRect = Rect.zero;
  Rect _spriteDestRect = Rect.zero;

  void _syncSprite() {
    _spriteImage = _spriteImages[_state.kind];
    if (_spriteImage != null) {
      size = Vector2(
        _spriteImage!.width.toDouble(),
        _spriteImage!.height.toDouble(),
      );
      _spriteSourceRect = Rect.fromLTWH(
        0,
        0,
        _spriteImage!.width.toDouble(),
        _spriteImage!.height.toDouble(),
      );
      _spriteDestRect = Rect.fromCenter(
        center: Offset.zero,
        width: size.x,
        height: size.y,
      );
    } else {
      size = Vector2.all(10);
      _spriteSourceRect = Rect.zero;
      _spriteDestRect = Rect.zero;
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
      canvas.drawImageRect(image, _spriteSourceRect, _spriteDestRect, _paint);
    } else {
      canvas.drawCircle(Offset.zero, size.x * 0.5, _paint);
    }
  }
}
