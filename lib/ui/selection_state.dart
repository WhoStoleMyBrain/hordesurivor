import 'package:flutter/foundation.dart';

import '../game/level_up_system.dart';

class SelectionState extends ChangeNotifier {
  List<SelectionChoice> _choices = const [];
  int _rerollsRemaining = 0;
  int _skipRewardXp = 0;
  int _skipRewardMetaShards = 0;

  List<SelectionChoice> get choices => _choices;
  bool get active => _choices.isNotEmpty;
  int get rerollsRemaining => _rerollsRemaining;
  int get skipRewardXp => _skipRewardXp;
  int get skipRewardMetaShards => _skipRewardMetaShards;

  void showChoices(
    List<SelectionChoice> choices, {
    int rerollsRemaining = 0,
    int skipRewardXp = 0,
    int skipRewardMetaShards = 0,
  }) {
    _choices = List<SelectionChoice>.from(choices);
    _rerollsRemaining = rerollsRemaining;
    _skipRewardXp = skipRewardXp;
    _skipRewardMetaShards = skipRewardMetaShards;
    notifyListeners();
  }

  void updateRerolls(int rerollsRemaining) {
    if (_rerollsRemaining == rerollsRemaining) {
      return;
    }
    _rerollsRemaining = rerollsRemaining;
    notifyListeners();
  }

  void clear() {
    if (_choices.isEmpty &&
        _rerollsRemaining == 0 &&
        _skipRewardXp == 0 &&
        _skipRewardMetaShards == 0) {
      return;
    }
    _choices = const [];
    _rerollsRemaining = 0;
    _skipRewardXp = 0;
    _skipRewardMetaShards = 0;
    notifyListeners();
  }
}
