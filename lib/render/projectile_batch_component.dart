import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

import '../game/projectile_pool.dart';
import 'render_scale.dart';

class ProjectileBatchComponent extends Component {
  ProjectileBatchComponent({
    required ProjectilePool pool,
    required Image spriteImage,
    required Color color,
    double renderScale = RenderScale.worldScale,
  }) : _pool = pool,
       _spriteBatch = SpriteBatch(spriteImage),
       _sourceRect = Rect.fromLTWH(
         0,
         0,
         spriteImage.width.toDouble(),
         spriteImage.height.toDouble(),
       ),
       _anchor = Vector2(
         spriteImage.width.toDouble() / 2,
         spriteImage.height.toDouble() / 2,
       ),
       _color = color,
       _renderScale = renderScale;

  final ProjectilePool _pool;
  final SpriteBatch _spriteBatch;
  final Rect _sourceRect;
  final Vector2 _anchor;
  final Color _color;
  final double _renderScale;

  @override
  void render(Canvas canvas) {
    _spriteBatch.clear();
    for (final projectile in _pool.active) {
      if (!projectile.active || projectile.fromEnemy) {
        continue;
      }
      _spriteBatch.add(
        source: _sourceRect,
        offset: projectile.position,
        anchor: _anchor,
        scale: _renderScale,
        color: _color,
      );
    }
    _spriteBatch.render(canvas, blendMode: BlendMode.srcOver);
  }
}
