import 'package:flutter/foundation.dart';

class UiScale {
  const UiScale._();

  static final ValueNotifier<double> _textScale = ValueNotifier(1.0);

  static double get textScale => _textScale.value;

  static ValueListenable<double> get textScaleListenable => _textScale;

  static void setTextScale(double value) {
    _textScale.value = value;
  }

  static double fontSize(double base) => base;
}
