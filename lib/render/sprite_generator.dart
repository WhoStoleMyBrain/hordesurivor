// sprite_generator.dart
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import '../data/sprite_recipes.dart';

class GeneratedSprite {
  const GeneratedSprite({
    required this.id,
    required this.outputName,
    required this.image,
  });

  final String id;
  final String outputName;
  final ui.Image image;
}

/// Pixel-based sprite generator with:
/// - vector-ish primitives (circle/rect/line/arc/pixels)
/// - bitmap/pixelMap (grid-of-chars + legend)
/// - patch edits
/// - post-process passes (shadow/outline/highlight)
///
/// Output is a ui.Image, wrapped in GeneratedSprite.
/// Keeps generateAll() for your existing usage.
class SpriteGenerator {
  SpriteGenerator({bool cacheEnabled = true}) : _cacheEnabled = cacheEnabled;

  final bool _cacheEnabled;
  final Map<String, ui.Image> _cache = {};

  Future<List<GeneratedSprite>> generateAll(List<SpriteRecipe> recipes) async {
    final results = <GeneratedSprite>[];
    for (final recipe in recipes) {
      results.add(await generate(recipe));
    }
    return results;
  }

  Future<GeneratedSprite> generate(SpriteRecipe recipe) async {
    if (_cacheEnabled) {
      final cached = _cache[recipe.id];
      if (cached != null) {
        return GeneratedSprite(
          id: recipe.id,
          outputName: recipe.outputName,
          image: cached,
        );
      }
    }

    final palette = _buildPalette(recipe.palette);
    final canvas = _PixelCanvas(recipe.size, recipe.size);

    // Draw in order
    for (final shape in recipe.shapes) {
      _drawShape(canvas, shape, palette);
    }

    // Post-process in order
    for (final pass in recipe.post) {
      _applyPost(canvas, pass, palette);
    }

    final image = await _toUiImage(canvas);

    if (_cacheEnabled) {
      _cache[recipe.id] = image;
    }

    return GeneratedSprite(
      id: recipe.id,
      outputName: recipe.outputName,
      image: image,
    );
  }

  void clearCache() => _cache.clear();

  Future<Uint8List> encodePng(ui.Image image) async {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  // ----- Drawing -----

  void _drawShape(_PixelCanvas c, SpriteShape shape, Map<String, int> palette) {
    final ox = shape.offset[0];
    final oy = shape.offset[1];

    int colorFor(String key, {required int fallbackArgb}) {
      return palette[key] ?? fallbackArgb;
    }

    switch (shape) {
      case CircleShape():
        final filled = shape.filled ?? true;
        final thickness = math.max(1, shape.thickness ?? 1);
        final col = colorFor(shape.colorKey, fallbackArgb: 0xFFFFFFFF);
        if (filled) {
          c.fillCircleLocal(ox, oy, shape.radius, col);
        } else {
          c.strokeCircleLocal(ox, oy, shape.radius, thickness, col);
        }
        return;

      case RectShape():
        final filled = shape.filled ?? true;
        final thickness = math.max(1, shape.thickness ?? 1);
        final w = shape.size[0];
        final h = shape.size[1];
        final col = colorFor(shape.colorKey, fallbackArgb: 0xFFFFFFFF);
        if (filled) {
          c.fillRectLocal(ox, oy, w, h, col);
        } else {
          c.strokeRectLocal(ox, oy, w, h, thickness, col);
        }
        return;

      case LineShape():
        final thickness = math.max(1, shape.thickness ?? 1);
        final col = colorFor(shape.colorKey, fallbackArgb: 0xFFFFFFFF);
        c.drawLineLocal(
          ox + shape.start[0],
          oy + shape.start[1],
          ox + shape.end[0],
          oy + shape.end[1],
          thickness,
          col,
        );
        return;

      case ArcShape():
        final thickness = math.max(1, shape.thickness ?? 1);
        final col = colorFor(shape.colorKey, fallbackArgb: 0xFFFFFFFF);
        c.strokeArcLocal(
          ox,
          oy,
          shape.radius,
          shape.startAngle,
          shape.sweepAngle,
          thickness,
          col,
        );
        return;

      case PixelsShape():
        final col = colorFor(shape.colorKey, fallbackArgb: 0xFFFFFFFF);
        for (final p in shape.points) {
          c.setPixelLocal(ox + p[0], oy + p[1], col);
        }
        return;

      case BitmapShape():
        final map = shape.map;
        if (map.isEmpty) return;

        final h = map.length;
        final w = map.map((r) => r.length).fold<int>(0, math.max);

        // Center bitmap around the sprite center, then apply offset.
        final topLeftLocalX = ox - (w ~/ 2);
        final topLeftLocalY = oy - (h ~/ 2);

        for (var y = 0; y < h; y++) {
          final row = map[y];
          for (var x = 0; x < row.length; x++) {
            final ch = row[x];
            final legendKey = shape.legend[ch];
            if (legendKey == null || legendKey == 'transparent') continue;

            final col = colorFor(legendKey, fallbackArgb: 0xFFFFFFFF);
            c.setPixelLocal(topLeftLocalX + x, topLeftLocalY + y, col);
          }
        }
        return;

      case PatchShape():
        for (final e in shape.edits) {
          final col = colorFor(e.colorKey, fallbackArgb: 0xFFFFFFFF);
          c.setPixelLocal(ox + e.x, oy + e.y, col);
        }
        return;
    }
  }

  // ----- Post-processing -----

  void _applyPost(
    _PixelCanvas c,
    SpritePostProcess pass,
    Map<String, int> palette,
  ) {
    int colorFor(String key, {required int fallbackArgb}) {
      return palette[key] ?? fallbackArgb;
    }

    switch (pass) {
      case AutoShadowProcess():
        c.applyShadow(
          dx: pass.dx,
          dy: pass.dy,
          color: colorFor(pass.colorKey, fallbackArgb: 0x80000000),
        );
        return;

      case AutoHighlightProcess():
        c.applyHighlight(
          dx: pass.dx,
          dy: pass.dy,
          color: colorFor(pass.colorKey, fallbackArgb: 0xFFFFFFFF),
        );
        return;

      case AutoOutlineProcess():
        c.applyOutline(
          color: colorFor(pass.colorKey, fallbackArgb: 0xFF000000),
          diagonal: pass.diagonal,
        );
        return;
    }
  }

  // ----- Palette + image conversion -----

  Map<String, int> _buildPalette(Map<String, String> raw) {
    final out = <String, int>{};
    raw.forEach((k, v) {
      out[k] = _argbFromHex(v);
    });
    return out;
  }

  int _argbFromHex(String value) {
    var cleaned = value.trim().replaceFirst('#', '');
    if (cleaned.length == 6) {
      cleaned = 'FF$cleaned'; // AARRGGBB
    }
    final parsed = int.tryParse(cleaned, radix: 16);
    return parsed ?? 0xFFFFFFFF;
  }

  Future<ui.Image> _toUiImage(_PixelCanvas canvas) async {
    final rgba = canvas.toRgbaBytes();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      rgba,
      canvas.width,
      canvas.height,
      ui.PixelFormat.rgba8888,
      (img) => completer.complete(img),
    );
    return completer.future;
  }
}

/// Internal pixel canvas with sprite-local coordinates centered at (width/2,height/2).
class _PixelCanvas {
  _PixelCanvas(this.width, this.height) : _pixels = Uint32List(width * height);

  final int width;
  final int height;
  final Uint32List _pixels;

  int get _cx => width ~/ 2;
  int get _cy => height ~/ 2;

  bool _inBounds(int x, int y) => x >= 0 && y >= 0 && x < width && y < height;
  int _idx(int x, int y) => y * width + x;

  int getPixel(int x, int y) => _inBounds(x, y) ? _pixels[_idx(x, y)] : 0;

  void setPixel(int x, int y, int argb) {
    if (!_inBounds(x, y)) return;
    _pixels[_idx(x, y)] = argb;
  }

  // Sprite-local coords: origin at center
  void setPixelLocal(int lx, int ly, int argb) {
    setPixel(_cx + lx, _cy + ly, argb);
  }

  bool _isTransparent(int argb) => (argb >>> 24) == 0;

  // ----- Drawing primitives -----

  void fillCircleLocal(int cx, int cy, int r, int color) {
    final rr = r * r;
    for (var y = -r; y <= r; y++) {
      for (var x = -r; x <= r; x++) {
        if (x * x + y * y <= rr) {
          setPixelLocal(cx + x, cy + y, color);
        }
      }
    }
  }

  void strokeCircleLocal(int cx, int cy, int r, int thickness, int color) {
    final t = math.max(1, thickness);
    final outer = r * r;
    final innerR = math.max(0, r - t);
    final inner = innerR * innerR;

    for (var y = -r; y <= r; y++) {
      for (var x = -r; x <= r; x++) {
        final d = x * x + y * y;
        if (d <= outer && d >= inner) {
          setPixelLocal(cx + x, cy + y, color);
        }
      }
    }
  }

  void fillRectLocal(int cx, int cy, int w, int h, int color) {
    final halfW = w ~/ 2;
    final halfH = h ~/ 2;
    for (var y = -halfH; y < -halfH + h; y++) {
      for (var x = -halfW; x < -halfW + w; x++) {
        setPixelLocal(cx + x, cy + y, color);
      }
    }
  }

  void strokeRectLocal(int cx, int cy, int w, int h, int thickness, int color) {
    final t = math.max(1, thickness);
    final halfW = w ~/ 2;
    final halfH = h ~/ 2;

    final left = cx - halfW;
    final top = cy - halfH;
    final right = left + w - 1;
    final bottom = top + h - 1;

    for (var i = 0; i < t; i++) {
      for (var x = left + i; x <= right - i; x++) {
        setPixelLocal(x, top + i, color);
        setPixelLocal(x, bottom - i, color);
      }
      for (var y = top + i; y <= bottom - i; y++) {
        setPixelLocal(left + i, y, color);
        setPixelLocal(right - i, y, color);
      }
    }
  }

  void drawLineLocal(int x0, int y0, int x1, int y1, int thickness, int color) {
    final t = math.max(1, thickness);
    var dx = (x1 - x0).abs();
    var dy = (y1 - y0).abs();
    var sx = x0 < x1 ? 1 : -1;
    var sy = y0 < y1 ? 1 : -1;
    var err = dx - dy;

    var x = x0;
    var y = y0;

    while (true) {
      if (t == 1) {
        setPixelLocal(x, y, color);
      } else {
        fillCircleLocal(x, y, t ~/ 2, color);
      }

      if (x == x1 && y == y1) break;
      final e2 = 2 * err;
      if (e2 > -dy) {
        err -= dy;
        x += sx;
      }
      if (e2 < dx) {
        err += dx;
        y += sy;
      }
    }
  }

  /// Angles are in degrees (to match the recipe model).
  void strokeArcLocal(
    int cx,
    int cy,
    int radius,
    double startDeg,
    double sweepDeg,
    int thickness,
    int color,
  ) {
    final t = math.max(1, thickness);

    // Sample per degree; sufficient for small sprites (16/24/32).
    final steps = math.max(1, sweepDeg.abs().round());
    for (var i = 0; i <= steps; i++) {
      final deg = startDeg + (sweepDeg * (i / steps));
      final rad = deg * math.pi / 180.0;
      final x = (math.cos(rad) * radius).round();
      final y = (math.sin(rad) * radius).round();
      if (t == 1) {
        setPixelLocal(cx + x, cy + y, color);
      } else {
        fillCircleLocal(cx + x, cy + y, t ~/ 2, color);
      }
    }
  }

  // ----- Post-process -----

  /// Adds a drop shadow by projecting opaque pixels by (dx,dy) into transparent pixels.
  void applyShadow({required int dx, required int dy, required int color}) {
    final src = Uint32List.fromList(_pixels);

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final p = src[_idx(x, y)];
        if (_isTransparent(p)) continue;

        final sx = x + dx;
        final sy = y + dy;
        if (!_inBounds(sx, sy)) continue;

        if (_isTransparent(src[_idx(sx, sy)]) &&
            _isTransparent(_pixels[_idx(sx, sy)])) {
          _pixels[_idx(sx, sy)] = color;
        }
      }
    }
  }

  /// Outlines non-transparent regions by filling transparent neighbor pixels.
  void applyOutline({required int color, required bool diagonal}) {
    final src = Uint32List.fromList(_pixels);
    final dirs = diagonal
        ? const <List<int>>[
            [-1, 0],
            [1, 0],
            [0, -1],
            [0, 1],
            [-1, -1],
            [1, -1],
            [-1, 1],
            [1, 1],
          ]
        : const <List<int>>[
            [-1, 0],
            [1, 0],
            [0, -1],
            [0, 1],
          ];

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if (!_isTransparent(src[_idx(x, y)])) continue;

        var nearOpaque = false;
        for (final d in dirs) {
          final nx = x + d[0];
          final ny = y + d[1];
          if (!_inBounds(nx, ny)) continue;
          if (!_isTransparent(src[_idx(nx, ny)])) {
            nearOpaque = true;
            break;
          }
        }

        if (nearOpaque) {
          _pixels[_idx(x, y)] = color;
        }
      }
    }
  }

  /// Adds a rim highlight by projecting from opaque pixels by (dx,dy) into transparent pixels.
  void applyHighlight({required int dx, required int dy, required int color}) {
    final src = Uint32List.fromList(_pixels);

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final p = src[_idx(x, y)];
        if (_isTransparent(p)) continue;

        final hx = x + dx;
        final hy = y + dy;
        if (!_inBounds(hx, hy)) continue;

        if (_isTransparent(src[_idx(hx, hy)]) &&
            _isTransparent(_pixels[_idx(hx, hy)])) {
          _pixels[_idx(hx, hy)] = color;
        }
      }
    }
  }

  // ----- Export -----

  Uint8List toRgbaBytes() {
    final out = Uint8List(width * height * 4);
    var o = 0;
    for (var i = 0; i < _pixels.length; i++) {
      final argb = _pixels[i];
      final a = (argb >>> 24) & 0xFF;
      final r = (argb >>> 16) & 0xFF;
      final g = (argb >>> 8) & 0xFF;
      final b = (argb) & 0xFF;
      out[o++] = r;
      out[o++] = g;
      out[o++] = b;
      out[o++] = a;
    }
    return out;
  }
}
