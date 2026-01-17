// sprite_recipes.dart
import 'dart:convert';

/// Sprite recipe data loaded from JSON rule files (see assets/sprites/recipes.json).
///
/// This version supports:
/// - bitmap/pixelMap layers (grid-of-chars) with a legend -> palette keys
/// - patch edits (single pixel edits) for clean diffs / quick tweaks
/// - post-processing passes (auto shadow, auto outline, auto highlight)
class SpriteRecipeSet {
  const SpriteRecipeSet(this.recipes);

  final List<SpriteRecipe> recipes;

  factory SpriteRecipeSet.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'] as List<dynamic>? ?? const [];
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
    required this.post,
  });

  final String id;
  final SpriteKind kind;
  final String outputName;
  final int size;
  final int seed;

  /// palette keys -> hex colors (e.g. "#RRGGBB" or "#AARRGGBB")
  /// Recommended keys: primary, shadow, accent, outline, highlight
  final Map<String, String> palette;

  final List<SpriteShape> shapes;

  /// Post-process passes applied in order.
  final List<SpritePostProcess> post;

  factory SpriteRecipe.fromJson(Map<String, dynamic> json) {
    final paletteJson = json['palette'] as Map<String, dynamic>? ?? const {};
    final shapesJson = json['shapes'] as List<dynamic>? ?? const [];
    final postJson = json['post'] as List<dynamic>? ?? const [];

    return SpriteRecipe(
      id: json['id'] as String,
      kind: spriteKindFromString(json['kind'] as String),
      outputName: json['outputName'] as String,
      size: json['size'] as int,
      seed: json['seed'] as int? ?? 0,
      palette: paletteJson.map((k, v) => MapEntry(k, v as String)),
      shapes: shapesJson
          .map((s) => SpriteShape.fromJson(s as Map<String, dynamic>))
          .toList(),
      post: postJson
          .map((p) => SpritePostProcess.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// ----- Shapes -----

sealed class SpriteShape {
  const SpriteShape({required this.type, required this.offset});

  final String type;

  /// Offset in sprite-local coordinates with origin at sprite center.
  /// x right, y down.
  final List<int> offset;

  factory SpriteShape.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final offset = (json['offset'] as List<dynamic>? ?? const [0, 0])
        .map((v) => v as int)
        .toList();

    switch (type) {
      case 'circle':
        return CircleShape.fromJson(json, offset);
      case 'rect':
        return RectShape.fromJson(json, offset);
      case 'line':
        return LineShape.fromJson(json, offset);
      case 'arc':
        return ArcShape.fromJson(json, offset);
      case 'pixels':
        return PixelsShape.fromJson(json, offset);
      case 'bitmap':
      case 'pixelMap':
        return BitmapShape.fromJson(json, offset);
      case 'patch':
        return PatchShape.fromJson(json, offset);
      default:
        throw FormatException('Unknown shape type: $type');
    }
  }
}

class CircleShape extends SpriteShape {
  const CircleShape({
    required super.offset,
    required this.colorKey,
    required this.radius,
    this.filled,
    this.thickness,
  }) : super(type: 'circle');

  final String colorKey;
  final int radius;

  /// default true
  final bool? filled;

  /// used when filled == false; default 1
  final int? thickness;

  factory CircleShape.fromJson(Map<String, dynamic> json, List<int> offset) {
    return CircleShape(
      offset: offset,
      colorKey: json['color'] as String,
      radius: json['radius'] as int,
      filled: json['filled'] as bool?,
      thickness: json['thickness'] as int?,
    );
  }
}

class RectShape extends SpriteShape {
  const RectShape({
    required super.offset,
    required this.colorKey,
    required this.size,
    this.filled,
    this.thickness,
  }) : super(type: 'rect');

  final String colorKey;

  /// [width, height]
  final List<int> size;

  /// default true
  final bool? filled;

  /// used when filled == false; default 1
  final int? thickness;

  factory RectShape.fromJson(Map<String, dynamic> json, List<int> offset) {
    return RectShape(
      offset: offset,
      colorKey: json['color'] as String,
      size: (json['size'] as List<dynamic>).map((v) => v as int).toList(),
      filled: json['filled'] as bool?,
      thickness: json['thickness'] as int?,
    );
  }
}

class LineShape extends SpriteShape {
  const LineShape({
    required super.offset,
    required this.colorKey,
    required this.start,
    required this.end,
    this.thickness,
  }) : super(type: 'line');

  final String colorKey;
  final List<int> start;
  final List<int> end;
  final int? thickness;

  factory LineShape.fromJson(Map<String, dynamic> json, List<int> offset) {
    return LineShape(
      offset: offset,
      colorKey: json['color'] as String,
      start: (json['start'] as List<dynamic>).map((v) => v as int).toList(),
      end: (json['end'] as List<dynamic>).map((v) => v as int).toList(),
      thickness: json['thickness'] as int?,
    );
  }
}

class ArcShape extends SpriteShape {
  const ArcShape({
    required super.offset,
    required this.colorKey,
    required this.radius,
    required this.startAngle,
    required this.sweepAngle,
    this.thickness,
  }) : super(type: 'arc');

  final String colorKey;
  final int radius;

  /// Degrees, not radians (to match your existing JSON examples).
  final double startAngle;
  final double sweepAngle;

  final int? thickness;

  factory ArcShape.fromJson(Map<String, dynamic> json, List<int> offset) {
    return ArcShape(
      offset: offset,
      colorKey: json['color'] as String,
      radius: json['radius'] as int,
      startAngle: (json['startAngle'] as num).toDouble(),
      sweepAngle: (json['sweepAngle'] as num).toDouble(),
      thickness: json['thickness'] as int?,
    );
  }
}

class PixelsShape extends SpriteShape {
  const PixelsShape({
    required super.offset,
    required this.colorKey,
    required this.points,
  }) : super(type: 'pixels');

  final String colorKey;

  /// Points in sprite-local coords, relative to [offset].
  final List<List<int>> points;

  factory PixelsShape.fromJson(Map<String, dynamic> json, List<int> offset) {
    final points = (json['points'] as List<dynamic>? ?? const [])
        .map((p) => (p as List<dynamic>).map((v) => v as int).toList())
        .toList();

    return PixelsShape(
      offset: offset,
      colorKey: json['color'] as String,
      points: points,
    );
  }
}

class BitmapShape extends SpriteShape {
  const BitmapShape({
    required super.offset,
    required this.map,
    required this.legend,
  }) : super(type: 'bitmap');

  /// Row strings. Usually 16 rows of length 16 for 16x16 sprites.
  final List<String> map;

  /// character -> palette key, or "transparent"
  final Map<String, String> legend;

  factory BitmapShape.fromJson(Map<String, dynamic> json, List<int> offset) {
    final rawMap = (json['map'] as List<dynamic>? ?? const [])
        .map((row) => row as String)
        .toList();

    final legendJson = json['legend'] as Map<String, dynamic>? ?? const {};
    final legend = legendJson.map(
      (k, v) => MapEntry(k.toString(), v as String),
    );

    return BitmapShape(offset: offset, map: rawMap, legend: legend);
  }
}

class PatchShape extends SpriteShape {
  const PatchShape({required super.offset, required this.edits})
    : super(type: 'patch');

  /// Edits in sprite-local coords (origin center), relative to [offset].
  final List<PatchEdit> edits;

  factory PatchShape.fromJson(Map<String, dynamic> json, List<int> offset) {
    final editsJson = json['edits'] as List<dynamic>? ?? const [];
    return PatchShape(
      offset: offset,
      edits: editsJson
          .map((e) => PatchEdit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PatchEdit {
  const PatchEdit({required this.x, required this.y, required this.colorKey});

  final int x;
  final int y;
  final String colorKey;

  factory PatchEdit.fromJson(Map<String, dynamic> json) {
    return PatchEdit(
      x: json['x'] as int,
      y: json['y'] as int,
      colorKey: json['color'] as String,
    );
  }
}

/// ----- Post-process passes -----

sealed class SpritePostProcess {
  const SpritePostProcess(this.type);

  final String type;

  factory SpritePostProcess.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'shadow':
        return AutoShadowProcess.fromJson(json);
      case 'outline':
        return AutoOutlineProcess.fromJson(json);
      case 'highlight':
        return AutoHighlightProcess.fromJson(json);
      default:
        throw FormatException('Unknown post-process type: $type');
    }
  }
}

class AutoShadowProcess extends SpritePostProcess {
  const AutoShadowProcess({this.dx = 1, this.dy = 1, this.colorKey = 'shadow'})
    : super('shadow');

  final int dx;
  final int dy;

  /// palette key to use for the shadow pixels
  final String colorKey;

  factory AutoShadowProcess.fromJson(Map<String, dynamic> json) {
    return AutoShadowProcess(
      dx: (json['dx'] as int?) ?? 1,
      dy: (json['dy'] as int?) ?? 1,
      colorKey: (json['color'] as String?) ?? 'shadow',
    );
  }
}

class AutoOutlineProcess extends SpritePostProcess {
  const AutoOutlineProcess({this.colorKey = 'outline', this.diagonal = true})
    : super('outline');

  /// palette key to use for outline pixels
  final String colorKey;

  /// if true, considers diagonal neighbors too
  final bool diagonal;

  factory AutoOutlineProcess.fromJson(Map<String, dynamic> json) {
    return AutoOutlineProcess(
      colorKey: (json['color'] as String?) ?? 'outline',
      diagonal: (json['diagonal'] as bool?) ?? true,
    );
  }
}

class AutoHighlightProcess extends SpritePostProcess {
  const AutoHighlightProcess({
    this.dx = -1,
    this.dy = -1,
    this.colorKey = 'highlight',
  }) : super('highlight');

  final int dx;
  final int dy;

  /// palette key to use for highlight pixels
  final String colorKey;

  factory AutoHighlightProcess.fromJson(Map<String, dynamic> json) {
    return AutoHighlightProcess(
      dx: (json['dx'] as int?) ?? -1,
      dy: (json['dy'] as int?) ?? -1,
      colorKey: (json['color'] as String?) ?? 'highlight',
    );
  }
}
