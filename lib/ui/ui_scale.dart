import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UiScale {
  const UiScale._();

  static const double minTextScale = 0.85;
  static const double maxTextScale = 1.3;
  static const String _textScaleKey = 'ui_text_scale';

  static final ValueNotifier<double> _textScale = ValueNotifier(1.0);

  static double get textScale => _textScale.value;

  static ValueListenable<double> get textScaleListenable => _textScale;

  static void setTextScale(double value) {
    final clamped = value.clamp(minTextScale, maxTextScale).toDouble();
    if (_textScale.value == clamped) {
      return;
    }
    _textScale.value = clamped;
    unawaited(_persistTextScale(clamped));
  }

  static double fontSize(double base) => base;

  static Future<void> loadTextScale() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble(_textScaleKey);
    if (stored == null) {
      return;
    }
    _textScale.value = stored.clamp(minTextScale, maxTextScale).toDouble();
  }

  static Future<void> _persistTextScale(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, value);
  }
}
