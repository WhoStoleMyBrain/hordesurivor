import 'package:flutter_test/flutter_test.dart';

import 'package:hordesurivor/data/ids.dart';
import 'package:hordesurivor/data/map_background_defs.dart';
import 'package:hordesurivor/render/map_background_generator.dart';

String _patternSignature(MapBackgroundPattern pattern) {
  final buffer = StringBuffer();
  for (final stamp in pattern.stamps) {
    if (stamp is RectStamp) {
      buffer
        ..write('r:')
        ..write(stamp.rect.left.toStringAsFixed(3))
        ..write(',')
        ..write(stamp.rect.top.toStringAsFixed(3))
        ..write(',')
        ..write(stamp.rect.width.toStringAsFixed(3))
        ..write(',')
        ..write(stamp.rect.height.toStringAsFixed(3))
        ..write(',')
        ..write(stamp.paint.color.toARGB32())
        ..write(';');
    } else if (stamp is CircleStamp) {
      buffer
        ..write('c:')
        ..write(stamp.center.dx.toStringAsFixed(3))
        ..write(',')
        ..write(stamp.center.dy.toStringAsFixed(3))
        ..write(',')
        ..write(stamp.radius.toStringAsFixed(3))
        ..write(',')
        ..write(stamp.paint.color.toARGB32())
        ..write(';');
    }
  }
  return buffer.toString();
}

void main() {
  test('map background generator is deterministic per seed', () {
    final generator = MapBackgroundGenerator();
    final def = mapBackgroundDefsById[MapBackgroundId.ashenOutskirts]!;

    final patternA = generator.generate(def);
    final patternB = generator.generate(def);

    expect(_patternSignature(patternA), equals(_patternSignature(patternB)));
  });

  test('map background generator reflects definition counts', () {
    final generator = MapBackgroundGenerator();
    final def = mapBackgroundDefsById[MapBackgroundId.haloBreach]!;

    final pattern = generator.generate(def);
    final specks = pattern.stamps.whereType<RectStamp>().length;
    final blotches = pattern.stamps.whereType<CircleStamp>().length;

    expect(specks, def.speckCount);
    expect(blotches, def.blotchCount);
  });

  test('map background generator varies across different maps', () {
    final generator = MapBackgroundGenerator();
    final ashen = mapBackgroundDefsById[MapBackgroundId.ashenOutskirts]!;
    final halo = mapBackgroundDefsById[MapBackgroundId.haloBreach]!;

    final ashenPattern = generator.generate(ashen);
    final haloPattern = generator.generate(halo);

    expect(
      _patternSignature(ashenPattern),
      isNot(equals(_patternSignature(haloPattern))),
    );
  });
}
