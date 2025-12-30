import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/sprite_batch.dart';

import '../game/projectile_pool.dart';

class ProjectileBatchComponent extends Component {
  ProjectileBatchComponent({
    required ProjectilePool pool,
    required Image spriteImage,
    required Color color,
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
       _color = color;

  final ProjectilePool _pool;
  final SpriteBatch _spriteBatch;
  final Rect _sourceRect;
  final Vector2 _anchor;
  final Color _color;

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
        color: _color,
      );
    }
    _spriteBatch.render(canvas);
  }
}
