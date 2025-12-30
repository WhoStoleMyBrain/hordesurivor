import 'dart:convert';

/// Sprite recipe data loaded from JSON rule files (see assets/sprites/recipes.json).
///
/// Each recipe defines the output name, size, palette, and shape list so the
/// generator can build images without touching gameplay logic.
class SpriteRecipeSet {
  const SpriteRecipeSet(this.recipes);

  final List<SpriteRecipe> recipes;

  factory SpriteRecipeSet.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'] as List<dynamic>? ?? [];
    return SpriteRecipeSet(
      sprites
          .map((entry) => SpriteRecipe.fromJson(entry as Map<String, dynamic>))
          .toList(),
    );
  }

  factory SpriteRecipeSet.fromJsonString(String jsonString) {
    return SpriteRecipeSet.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  Map<String, SpriteRecipe> toRecipeMap() {
    return {for (final recipe in recipes) recipe.id: recipe};
  }
}

enum SpriteKind { player, enemy, item, skill, ground, projectile, pickup }

SpriteKind spriteKindFromString(String value) {
  return SpriteKind.values.firstWhere(
    (kind) => kind.name == value,
    orElse: () => SpriteKind.item,
  );
}

class SpriteRecipe {
  const SpriteRecipe({
    required this.id,
    required this.kind,
    required this.outputName,
    required this.size,
    required this.seed,
    required this.palette,
    required this.shapes,
  });

  final String id;
  final SpriteKind kind;
  final String outputName;
  final int size;
  final int seed;
  final Map<String, String> palette;
  final List<SpriteShape> shapes;

  factory SpriteRecipe.fromJson(Map<String, dynamic> json) {
    final paletteJson = json['palette'] as Map<String, dynamic>? ?? {};
    return SpriteRecipe(
      id: json['id'] as String,
      kind: spriteKindFromString(json['kind'] as String),
      outputName: json['outputName'] as String,
      size: json['size'] as int,
      seed: json['seed'] as int? ?? 0,
      palette: paletteJson.map((key, value) => MapEntry(key, value as String)),
      shapes: (json['shapes'] as List<dynamic>? ?? [])
          .map((shape) => SpriteShape.fromJson(shape as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SpriteShape {
  const SpriteShape({
    required this.type,
    required this.colorKey,
    required this.offset,
    this.radius,
    this.size,
    this.points,
    this.start,
    this.end,
    this.thickness,
    this.startAngle,
    this.sweepAngle,
    this.filled,
  });

  final String type;
  final String colorKey;
  final List<int> offset;
  final int? radius;
  final List<int>? size;
  final List<List<int>>? points;
  final List<int>? start;
  final List<int>? end;
  final int? thickness;
  final double? startAngle;
  final double? sweepAngle;
  final bool? filled;

  factory SpriteShape.fromJson(Map<String, dynamic> json) {
    return SpriteShape(
      type: json['type'] as String,
      colorKey: json['color'] as String,
      offset: (json['offset'] as List<dynamic>? ?? [0, 0])
          .map((value) => value as int)
          .toList(),
      radius: json['radius'] as int?,
      size: (json['size'] as List<dynamic>?)
          ?.map((value) => value as int)
          .toList(),
      points: (json['points'] as List<dynamic>?)
          ?.map(
            (point) =>
                (point as List<dynamic>).map((value) => value as int).toList(),
          )
          .toList(),
      start: (json['start'] as List<dynamic>?)
          ?.map((value) => value as int)
          .toList(),
      end: (json['end'] as List<dynamic>?)
          ?.map((value) => value as int)
          .toList(),
      thickness: json['thickness'] as int?,
      startAngle: (json['startAngle'] as num?)?.toDouble(),
      sweepAngle: (json['sweepAngle'] as num?)?.toDouble(),
      filled: json['filled'] as bool?,
    );
  }
}
