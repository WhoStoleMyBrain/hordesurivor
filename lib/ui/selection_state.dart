import 'package:flutter/foundation.dart';

import '../game/level_up_system.dart';

class SelectionState extends ChangeNotifier {
  List<SelectionChoice> _choices = const [];

  List<SelectionChoice> get choices => _choices;
  bool get active => _choices.isNotEmpty;

  void showChoices(List<SelectionChoice> choices) {
    _choices = List<SelectionChoice>.from(choices);
    notifyListeners();
  }

  void clear() {
    if (_choices.isEmpty) {
      return;
    }
    _choices = const [];
    notifyListeners();
  }
}
