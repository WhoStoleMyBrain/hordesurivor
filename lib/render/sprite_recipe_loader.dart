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
      return const SpriteRecipeSet([]);
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
      if (recipe == null) {
        continue;
      }
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
        'Sprite recipes: invalid recipe at index $index in $assetPath '
        '($error).',
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
      debugPrint(
        'Sprite recipes: error in ${recipe.id} ($assetPath): $error',
      );
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

    final halfSize = recipe.size / 2;
    for (var index = 0; index < recipe.shapes.length; index++) {
      final shape = recipe.shapes[index];
      final prefix = 'shape[$index]';
      if (!_allowedTypes.contains(shape.type)) {
        errors.add('$prefix has unsupported type "${shape.type}".');
        continue;
      }
      if (!recipe.palette.containsKey(shape.colorKey)) {
        errors.add('$prefix references missing palette color "${shape.colorKey}".');
      }
      if (shape.offset.length < 2) {
        errors.add('$prefix offset must include x/y values.');
      }
      switch (shape.type) {
        case 'circle':
          _validateCircle(shape, halfSize, prefix, errors, warnings);
          break;
        case 'rect':
          _validateRect(shape, halfSize, prefix, errors, warnings);
          break;
        case 'line':
          _validateLine(shape, halfSize, prefix, errors, warnings);
          break;
        case 'arc':
          _validateArc(shape, halfSize, prefix, errors, warnings);
          break;
        case 'maskCircle':
          _validateMaskCircle(shape, halfSize, prefix, errors, warnings);
          break;
        case 'maskRect':
          _validateMaskRect(shape, halfSize, prefix, errors, warnings);
          break;
        case 'pixels':
          _validatePixels(shape, halfSize, prefix, errors, warnings);
          break;
      }
    }

    return SpriteRecipeValidationResult(errors: errors, warnings: warnings);
  }

  void _validateCircle(
    SpriteShape shape,
    double halfSize,
    String prefix,
    List<String> errors,
    List<String> warnings,
  ) {
    final radius = shape.radius;
    if (radius == null || radius <= 0) {
      errors.add('$prefix circle requires a radius greater than zero.');
      return;
    }
    final offsetX = shape.offset.isNotEmpty ? shape.offset[0] : 0;
    final offsetY = shape.offset.length > 1 ? shape.offset[1] : 0;
    if (_isOutOfBounds(offsetX, offsetY, radius.toDouble(), halfSize)) {
      warnings.add('$prefix circle exceeds canvas bounds.');
    }
  }

  void _validateRect(
    SpriteShape shape,
    double halfSize,
    String prefix,
    List<String> errors,
    List<String> warnings,
  ) {
    final rectSize = shape.size;
    if (rectSize == null || rectSize.length < 2) {
      errors.add('$prefix rect requires a size [width, height].');
      return;
    }
    if (rectSize[0] <= 0 || rectSize[1] <= 0) {
      errors.add('$prefix rect size must be greater than zero.');
    }
    final offsetX = shape.offset.isNotEmpty ? shape.offset[0] : 0;
    final offsetY = shape.offset.length > 1 ? shape.offset[1] : 0;
    final halfWidth = rectSize[0] / 2;
    final halfHeight = rectSize[1] / 2;
    if (offsetX.abs() + halfWidth > halfSize ||
        offsetY.abs() + halfHeight > halfSize) {
      warnings.add('$prefix rect exceeds canvas bounds.');
    }
  }

  void _validatePixels(
    SpriteShape shape,
    double halfSize,
    String prefix,
    List<String> errors,
    List<String> warnings,
  ) {
    final points = shape.points;
    if (points == null || points.isEmpty) {
      errors.add('$prefix pixels requires a non-empty points list.');
      return;
    }
    for (var pointIndex = 0; pointIndex < points.length; pointIndex++) {
      final point = points[pointIndex];
      if (point.length < 2) {
        errors.add('$prefix pixels point[$pointIndex] missing x/y.');
        continue;
      }
      if (point[0].abs() > halfSize || point[1].abs() > halfSize) {
        warnings.add(
          '$prefix pixels point[$pointIndex] exceeds canvas bounds.',
        );
      }
    }
  }

  void _validateLine(
    SpriteShape shape,
    double halfSize,
    String prefix,
    List<String> errors,
    List<String> warnings,
  ) {
    final start = shape.start;
    final end = shape.end;
    if (start == null || start.length < 2) {
      errors.add('$prefix line requires a start [x, y].');
      return;
    }
    if (end == null || end.length < 2) {
      errors.add('$prefix line requires an end [x, y].');
      return;
    }
    final thickness = shape.thickness;
    if (thickness != null && thickness <= 0) {
      errors.add('$prefix line thickness must be greater than zero.');
    }
    if (start[0].abs() > halfSize ||
        start[1].abs() > halfSize ||
        end[0].abs() > halfSize ||
        end[1].abs() > halfSize) {
      warnings.add('$prefix line exceeds canvas bounds.');
    }
  }

  void _validateArc(
    SpriteShape shape,
    double halfSize,
    String prefix,
    List<String> errors,
    List<String> warnings,
  ) {
    final radius = shape.radius;
    if (radius == null || radius <= 0) {
      errors.add('$prefix arc requires a radius greater than zero.');
    }
    if (shape.startAngle == null || shape.sweepAngle == null) {
      errors.add('$prefix arc requires startAngle and sweepAngle.');
    }
    final thickness = shape.thickness;
    if (thickness != null && thickness <= 0) {
      errors.add('$prefix arc thickness must be greater than zero.');
    }
    final offsetX = shape.offset.isNotEmpty ? shape.offset[0] : 0;
    final offsetY = shape.offset.length > 1 ? shape.offset[1] : 0;
    if (radius != null &&
        _isOutOfBounds(offsetX, offsetY, radius.toDouble(), halfSize)) {
      warnings.add('$prefix arc exceeds canvas bounds.');
    }
  }

  void _validateMaskCircle(
    SpriteShape shape,
    double halfSize,
    String prefix,
    List<String> errors,
    List<String> warnings,
  ) {
    final radius = shape.radius;
    if (radius == null || radius <= 0) {
      errors.add('$prefix maskCircle requires a radius greater than zero.');
      return;
    }
    final offsetX = shape.offset.isNotEmpty ? shape.offset[0] : 0;
    final offsetY = shape.offset.length > 1 ? shape.offset[1] : 0;
    if (_isOutOfBounds(offsetX, offsetY, radius.toDouble(), halfSize)) {
      warnings.add('$prefix maskCircle exceeds canvas bounds.');
    }
  }

  void _validateMaskRect(
    SpriteShape shape,
    double halfSize,
    String prefix,
    List<String> errors,
    List<String> warnings,
  ) {
    final rectSize = shape.size;
    if (rectSize == null || rectSize.length < 2) {
      errors.add('$prefix maskRect requires a size [width, height].');
      return;
    }
    if (rectSize[0] <= 0 || rectSize[1] <= 0) {
      errors.add('$prefix maskRect size must be greater than zero.');
    }
    final offsetX = shape.offset.isNotEmpty ? shape.offset[0] : 0;
    final offsetY = shape.offset.length > 1 ? shape.offset[1] : 0;
    final halfWidth = rectSize[0] / 2;
    final halfHeight = rectSize[1] / 2;
    if (offsetX.abs() + halfWidth > halfSize ||
        offsetY.abs() + halfHeight > halfSize) {
      warnings.add('$prefix maskRect exceeds canvas bounds.');
    }
  }

  bool _isOutOfBounds(
    int offsetX,
    int offsetY,
    double radius,
    double halfSize,
  ) {
    return offsetX.abs() + radius > halfSize ||
        offsetY.abs() + radius > halfSize;
  }

  static const Set<String> _allowedTypes = {
    'circle',
    'rect',
    'line',
    'arc',
    'maskCircle',
    'maskRect',
    'pixels',
  };
}

final SpriteRecipeValidator _validator = SpriteRecipeValidator();
