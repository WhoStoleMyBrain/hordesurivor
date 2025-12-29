import 'package:flutter_test/flutter_test.dart';

import 'package:hordesurivor/data/data_validation.dart';

void main() {
  test('game data validates without errors', () {
    final result = validateGameData();

    expect(result.errors, isEmpty);
  });
}
