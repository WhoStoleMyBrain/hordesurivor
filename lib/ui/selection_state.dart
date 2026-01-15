import 'package:flutter/foundation.dart';

import '../data/ids.dart';
import '../game/level_up_system.dart';

class SelectionState extends ChangeNotifier {
  List<SelectionChoice> _choices = const [];
  int _rerollsRemaining = 0;
  int _skipRewardCurrencyAmount = 0;
  CurrencyId _skipRewardCurrencyId = CurrencyId.xp;
  int _skipRewardMetaShards = 0;
  ProgressionTrackId? _trackId;

  List<SelectionChoice> get choices => _choices;
  bool get active => _choices.isNotEmpty;
  int get rerollsRemaining => _rerollsRemaining;
  int get skipRewardCurrencyAmount => _skipRewardCurrencyAmount;
  CurrencyId get skipRewardCurrencyId => _skipRewardCurrencyId;
  int get skipRewardMetaShards => _skipRewardMetaShards;
  ProgressionTrackId? get trackId => _trackId;

  void showChoices(
    List<SelectionChoice> choices, {
    required ProgressionTrackId trackId,
    int rerollsRemaining = 0,
    int skipRewardCurrencyAmount = 0,
    CurrencyId skipRewardCurrencyId = CurrencyId.xp,
    int skipRewardMetaShards = 0,
  }) {
    _choices = List<SelectionChoice>.from(choices);
    _trackId = trackId;
    _rerollsRemaining = rerollsRemaining;
    _skipRewardCurrencyAmount = skipRewardCurrencyAmount;
    _skipRewardCurrencyId = skipRewardCurrencyId;
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
        _skipRewardCurrencyAmount == 0 &&
        _skipRewardMetaShards == 0 &&
        _trackId == null) {
      return;
    }
    _choices = const [];
    _trackId = null;
    _rerollsRemaining = 0;
    _skipRewardCurrencyAmount = 0;
    _skipRewardCurrencyId = CurrencyId.xp;
    _skipRewardMetaShards = 0;
    notifyListeners();
  }
}
