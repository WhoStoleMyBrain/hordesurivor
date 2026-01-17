// sprite_recipe_loader.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../data/sprite_recipes.dart';

class SpriteRecipeLoader {
  Future<SpriteRecipeSet> loadFromAsset(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final jsonMap = _decodeJson(assetPath, jsonString);
    if (jsonMap == null) {
      return const SpriteRecipeSet([]);
    }

    final spriteList = jsonMap['sprites'];
    if (spriteList is! List) {
      debugPrint(
        'Sprite recipes: expected "sprites" list in $assetPath but found '
        '${spriteList.runtimeType}.',
      );
      return SpriteRecipeSet(const []);
    }

    final recipes = <SpriteRecipe>[];
    for (var index = 0; index < spriteList.length; index++) {
      final entry = spriteList[index];
      if (entry is! Map<String, dynamic>) {
        debugPrint(
          'Sprite recipes: entry $index in $assetPath is not a JSON object.',
        );
        continue;
      }

      final recipe = _parseRecipe(assetPath, index, entry);
      if (recipe == null) continue;

      final validation = _validator.validate(recipe);
      _logValidation(assetPath, recipe, validation);

      if (validation.isValid) {
        recipes.add(recipe);
      }
    }

    return SpriteRecipeSet(recipes);
  }

  Map<String, dynamic>? _decodeJson(String assetPath, String jsonString) {
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (error) {
      debugPrint(
        'Sprite recipes: failed to parse JSON from $assetPath ($error).',
      );
      return null;
    }
  }

  SpriteRecipe? _parseRecipe(
    String assetPath,
    int index,
    Map<String, dynamic> entry,
  ) {
    try {
      return SpriteRecipe.fromJson(entry);
    } catch (error) {
      debugPrint(
        'Sprite recipes: invalid recipe at index $index in $assetPath ($error).',
      );
      return null;
    }
  }

  void _logValidation(
    String assetPath,
    SpriteRecipe recipe,
    SpriteRecipeValidationResult validation,
  ) {
    for (final warning in validation.warnings) {
      debugPrint(
        'Sprite recipes: warning in ${recipe.id} ($assetPath): $warning',
      );
    }
    for (final error in validation.errors) {
      debugPrint('Sprite recipes: error in ${recipe.id} ($assetPath): $error');
    }
  }
}

class SpriteRecipeValidationResult {
  const SpriteRecipeValidationResult({
    required this.errors,
    required this.warnings,
  });

  final List<String> errors;
  final List<String> warnings;

  bool get isValid => errors.isEmpty;
}

/// Minimal validation aligned with the new generator:
/// - supports circle/rect/line/arc/pixels/bitmap(pixMap)/patch
/// - validates palette keys referenced by shapes and post-process
/// - warns when drawing likely exceeds sprite bounds
class SpriteRecipeValidator {
  SpriteRecipeValidationResult validate(SpriteRecipe recipe) {
    final errors = <String>[];
    final warnings = <String>[];

    if (recipe.id.trim().isEmpty) {
      errors.add('Recipe id is required.');
    }
    if (recipe.outputName.trim().isEmpty) {
      errors.add('outputName is required.');
    }
    if (recipe.size <= 0) {
      errors.add('size must be greater than zero.');
    }
    if (recipe.palette.isEmpty) {
      errors.add('palette must include at least one color.');
    }
    if (recipe.shapes.isEmpty) {
      errors.add('at least one shape is required.');
    }

    // Validate palette color strings early.
    for (final entry in recipe.palette.entries) {
      final key = entry.key;
      final value = entry.value;
      if (!_isValidHexColor(value)) {
        warnings.add('palette["$key"] has invalid color value "$value".');
      }
    }

    final bounds = _LocalBounds.forSize(recipe.size);

    for (var index = 0; index < recipe.shapes.length; index++) {
      final shape = recipe.shapes[index];
      final prefix = 'shape[$index]';

      if (shape.offset.length < 2) {
        errors.add('$prefix offset must include x/y values.');
        continue;
      }

      // Shape-specific validation
      switch (shape) {
        case CircleShape():
          _requirePaletteKey(
            recipe,
            shape.colorKey,
            '$prefix references missing palette color "${shape.colorKey}".',
            errors,
          );

          if (shape.radius <= 0) {
            errors.add('$prefix circle requires radius > 0.');
            break;
          }
          final t = shape.thickness;
          if (t != null && t <= 0) {
            errors.add('$prefix circle thickness must be > 0.');
          }

          final ox = shape.offset[0];
          final oy = shape.offset[1];
          final left = ox - shape.radius;
          final right = ox + shape.radius;
          final top = oy - shape.radius;
          final bottom = oy + shape.radius;

          if (!bounds.containsRect(left, top, right, bottom)) {
            warnings.add('$prefix circle exceeds canvas bounds.');
          }
          break;

        case RectShape():
          _requirePaletteKey(
            recipe,
            shape.colorKey,
            '$prefix references missing palette color "${shape.colorKey}".',
            errors,
          );

          final w = shape.size[0];
          final h = shape.size[1];
          if (w <= 0 || h <= 0) {
            errors.add('$prefix rect requires size [width,height] > 0.');
            break;
          }
          final t = shape.thickness;
          if (t != null && t <= 0) {
            errors.add('$prefix rect thickness must be > 0.');
          }

          // Match generator extents:
          // fillRectLocal uses halfW=w~/2 and draws x in [-halfW, -halfW+w-1]
          final halfW = w ~/ 2;
          final halfH = h ~/ 2;
          final ox = shape.offset[0];
          final oy = shape.offset[1];

          final left = ox - halfW;
          final right = left + w - 1;
          final top = oy - halfH;
          final bottom = top + h - 1;

          if (!bounds.containsRect(left, top, right, bottom)) {
            warnings.add('$prefix rect exceeds canvas bounds.');
          }
          break;

        case LineShape():
          _requirePaletteKey(
            recipe,
            shape.colorKey,
            '$prefix references missing palette color "${shape.colorKey}".',
            errors,
          );

          final t = shape.thickness;
          if (t != null && t <= 0) {
            errors.add('$prefix line thickness must be > 0.');
          }

          final ox = shape.offset[0];
          final oy = shape.offset[1];
          final sx = ox + shape.start[0];
          final sy = oy + shape.start[1];
          final ex = ox + shape.end[0];
          final ey = oy + shape.end[1];

          if (!bounds.containsPoint(sx, sy) || !bounds.containsPoint(ex, ey)) {
            warnings.add('$prefix line exceeds canvas bounds.');
          }
          break;

        case ArcShape():
          _requirePaletteKey(
            recipe,
            shape.colorKey,
            '$prefix references missing palette color "${shape.colorKey}".',
            errors,
          );

          if (shape.radius <= 0) {
            errors.add('$prefix arc requires radius > 0.');
          }
          final t = shape.thickness;
          if (t != null && t <= 0) {
            errors.add('$prefix arc thickness must be > 0.');
          }

          final ox = shape.offset[0];
          final oy = shape.offset[1];
          final r = shape.radius;

          // Conservative bounds: treat as a full circle.
          final left = ox - r;
          final right = ox + r;
          final top = oy - r;
          final bottom = oy + r;

          if (!bounds.containsRect(left, top, right, bottom)) {
            warnings.add('$prefix arc exceeds canvas bounds.');
          }
          break;

        case PixelsShape():
          _requirePaletteKey(
            recipe,
            shape.colorKey,
            '$prefix references missing palette color "${shape.colorKey}".',
            errors,
          );

          if (shape.points.isEmpty) {
            errors.add('$prefix pixels requires a non-empty points list.');
            break;
          }

          final ox = shape.offset[0];
          final oy = shape.offset[1];

          for (var pi = 0; pi < shape.points.length; pi++) {
            final p = shape.points[pi];
            if (p.length < 2) {
              errors.add('$prefix pixels point[$pi] missing x/y.');
              continue;
            }
            final x = ox + p[0];
            final y = oy + p[1];
            if (!bounds.containsPoint(x, y)) {
              warnings.add('$prefix pixels point[$pi] exceeds canvas bounds.');
            }
          }
          break;

        case BitmapShape():
          final map = shape.map;
          final legend = shape.legend;

          if (map.isEmpty) {
            errors.add('$prefix bitmap requires non-empty "map".');
            break;
          }
          if (legend.isEmpty) {
            errors.add('$prefix bitmap requires non-empty "legend".');
            break;
          }

          final h = map.length;
          final wMax = map
              .map((r) => r.length)
              .fold<int>(0, (a, b) => a > b ? a : b);

          // Warn about row length mismatch (makes authoring harder).
          final firstLen = map.first.length;
          if (map.any((r) => r.length != firstLen)) {
            warnings.add('$prefix bitmap has inconsistent row lengths.');
          }

          // Legend palette checks: any legend value other than "transparent" should exist.
          for (final entry in legend.entries) {
            final v = entry.value;
            if (v == 'transparent') continue;
            if (!recipe.palette.containsKey(v)) {
              errors.add(
                '$prefix bitmap legend references missing palette key "$v".',
              );
            }
          }

          // Bounds check based on generator placement:
          // topLeftLocal = offset - (w~/2, h~/2)
          final ox = shape.offset[0];
          final oy = shape.offset[1];
          final topLeftX = ox - (wMax ~/ 2);
          final topLeftY = oy - (h ~/ 2);

          final left = topLeftX;
          final right = topLeftX + (wMax - 1);
          final top = topLeftY;
          final bottom = topLeftY + (h - 1);

          if (wMax > recipe.size || h > recipe.size) {
            warnings.add(
              '$prefix bitmap dimensions ($wMax x $h) exceed sprite size ${recipe.size}.',
            );
          }
          if (!bounds.containsRect(left, top, right, bottom)) {
            warnings.add('$prefix bitmap exceeds canvas bounds.');
          }
          break;

        case PatchShape():
          if (shape.edits.isEmpty) {
            errors.add('$prefix patch requires non-empty "edits".');
            break;
          }

          final ox = shape.offset[0];
          final oy = shape.offset[1];

          for (var ei = 0; ei < shape.edits.length; ei++) {
            final e = shape.edits[ei];

            if (!recipe.palette.containsKey(e.colorKey)) {
              errors.add(
                '$prefix patch edit[$ei] references missing palette key "${e.colorKey}".',
              );
            }

            final x = ox + e.x;
            final y = oy + e.y;
            if (!bounds.containsPoint(x, y)) {
              warnings.add('$prefix patch edit[$ei] exceeds canvas bounds.');
            }
          }
          break;
      }
    }

    // Post-process validation (warn if palette key is missing; generator has fallbacks)
    for (var i = 0; i < recipe.post.length; i++) {
      final pass = recipe.post[i];
      final prefix = 'post[$i]';

      switch (pass) {
        case AutoShadowProcess():
          if (!recipe.palette.containsKey(pass.colorKey)) {
            warnings.add(
              '$prefix shadow references missing palette key "${pass.colorKey}".',
            );
          }
          break;
        case AutoHighlightProcess():
          if (!recipe.palette.containsKey(pass.colorKey)) {
            warnings.add(
              '$prefix highlight references missing palette key "${pass.colorKey}".',
            );
          }
          break;
        case AutoOutlineProcess():
          if (!recipe.palette.containsKey(pass.colorKey)) {
            warnings.add(
              '$prefix outline references missing palette key "${pass.colorKey}".',
            );
          }
          break;
      }
    }

    return SpriteRecipeValidationResult(errors: errors, warnings: warnings);
  }

  void _requirePaletteKey(
    SpriteRecipe recipe,
    String key,
    String message,
    List<String> errors,
  ) {
    if (!recipe.palette.containsKey(key)) {
      errors.add(message);
    }
  }

  bool _isValidHexColor(String value) {
    var cleaned = value.trim();
    if (cleaned.startsWith('#')) cleaned = cleaned.substring(1);
    if (cleaned.length != 6 && cleaned.length != 8) return false;
    return int.tryParse(cleaned, radix: 16) != null;
  }
}

class _LocalBounds {
  _LocalBounds({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  final int minX;
  final int maxX;
  final int minY;
  final int maxY;

  factory _LocalBounds.forSize(int size) {
    // PixelCanvas uses _cx = size~/2
    // Valid local x range: [-_cx, size-1-_cx]
    final cx = size ~/ 2;
    return _LocalBounds(
      minX: -cx,
      maxX: size - 1 - cx,
      minY: -cx,
      maxY: size - 1 - cx,
    );
  }

  bool containsPoint(int x, int y) {
    return x >= minX && x <= maxX && y >= minY && y <= maxY;
  }

  bool containsRect(int left, int top, int right, int bottom) {
    return left >= minX && right <= maxX && top >= minY && bottom <= maxY;
  }
}

final SpriteRecipeValidator _validator = SpriteRecipeValidator();
