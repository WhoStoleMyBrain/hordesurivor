import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

import '../data/ids.dart';
import '../game/projectile_pool.dart';
import 'render_scale.dart';

class ProjectileSpriteEntry {
  ProjectileSpriteEntry(Image image)
    : spriteBatch = SpriteBatch(image),
      sourceRect = Rect.fromLTWH(
        0,
        0,
        image.width.toDouble(),
        image.height.toDouble(),
      ),
      anchor = Vector2(image.width.toDouble() / 2, image.height.toDouble() / 2);

  final SpriteBatch spriteBatch;
  final Rect sourceRect;
  final Vector2 anchor;

  void clear() => spriteBatch.clear();

  void add({
    required Vector2 offset,
    required double scale,
    required Color color,
  }) {
    spriteBatch.add(
      source: sourceRect,
      offset: offset,
      anchor: anchor,
      scale: scale,
      color: color,
    );
  }

  void render(Canvas canvas) {
    spriteBatch.render(canvas, blendMode: BlendMode.srcOver);
  }
}

class ProjectileBatchComponent extends Component {
  ProjectileBatchComponent({
    required ProjectilePool pool,
    required Image spriteImage,
    required Color color,
    Map<SkillId, Image> skillSpriteImages = const {},
    double renderScale = RenderScale.worldScale,
  }) : _pool = pool,
       _defaultSprite = ProjectileSpriteEntry(spriteImage),
       _skillSprites = {
         for (final entry in skillSpriteImages.entries)
           entry.key: ProjectileSpriteEntry(entry.value),
       },
       _color = color,
       _renderScale = renderScale;

  final ProjectilePool _pool;
  final ProjectileSpriteEntry _defaultSprite;
  final Map<SkillId, ProjectileSpriteEntry> _skillSprites;
  final Color _color;
  final double _renderScale;

  @override
  void render(Canvas canvas) {
    _defaultSprite.clear();
    for (final sprite in _skillSprites.values) {
      sprite.clear();
    }
    for (final projectile in _pool.active) {
      if (!projectile.active || projectile.fromEnemy) {
        continue;
      }
      final sprite = projectile.sourceSkillId == null
          ? _defaultSprite
          : _skillSprites[projectile.sourceSkillId] ?? _defaultSprite;
      sprite.add(
        offset: projectile.position,
        scale: _renderScale,
        color: _color,
      );
    }
    _defaultSprite.render(canvas);
    for (final sprite in _skillSprites.values) {
      sprite.render(canvas);
    }
  }
}
