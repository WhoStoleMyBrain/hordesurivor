import 'package:flutter/foundation.dart';

import '../data/ids.dart';
import '../game/level_up_system.dart';

class SelectionState extends ChangeNotifier {
  List<SelectionChoice> _choices = const [];
  int _rerollsRemaining = 0;
  int _banishesRemaining = 0;
  int _skipRewardCurrencyAmount = 0;
  CurrencyId _skipRewardCurrencyId = CurrencyId.xp;
  int _skipRewardMetaShards = 0;
  ProgressionTrackId? _trackId;
  int _goldAvailable = 0;
  int _rerollCost = 0;
  int _shopLevel = 0;
  Map<ItemId, int> _itemPrices = const {};
  Set<ItemId> _lockedItems = const {};

  List<SelectionChoice> get choices => _choices;
  bool get active => _choices.isNotEmpty;
  int get rerollsRemaining => _rerollsRemaining;
  int get banishesRemaining => _banishesRemaining;
  int get skipRewardCurrencyAmount => _skipRewardCurrencyAmount;
  CurrencyId get skipRewardCurrencyId => _skipRewardCurrencyId;
  int get skipRewardMetaShards => _skipRewardMetaShards;
  ProgressionTrackId? get trackId => _trackId;
  int get goldAvailable => _goldAvailable;
  int get rerollCost => _rerollCost;
  int get shopLevel => _shopLevel;
  Map<ItemId, int> get itemPrices => _itemPrices;
  Set<ItemId> get lockedItems => _lockedItems;

  int? priceForChoice(SelectionChoice choice) {
    if (choice.type != SelectionType.item) {
      return null;
    }
    final itemId = choice.itemId;
    if (itemId == null) {
      return null;
    }
    return _itemPrices[itemId];
  }

  void showChoices(
    List<SelectionChoice> choices, {
    required ProgressionTrackId trackId,
    int rerollsRemaining = 0,
    int banishesRemaining = 0,
    int skipRewardCurrencyAmount = 0,
    CurrencyId skipRewardCurrencyId = CurrencyId.xp,
    int skipRewardMetaShards = 0,
    int goldAvailable = 0,
    int rerollCost = 0,
    int shopLevel = 0,
    Map<ItemId, int> itemPrices = const {},
    Set<ItemId> lockedItems = const {},
  }) {
    _choices = List<SelectionChoice>.from(choices);
    _trackId = trackId;
    _rerollsRemaining = rerollsRemaining;
    _banishesRemaining = banishesRemaining;
    _skipRewardCurrencyAmount = skipRewardCurrencyAmount;
    _skipRewardCurrencyId = skipRewardCurrencyId;
    _skipRewardMetaShards = skipRewardMetaShards;
    _goldAvailable = goldAvailable;
    _rerollCost = rerollCost;
    _shopLevel = shopLevel;
    _itemPrices = Map<ItemId, int>.unmodifiable(itemPrices);
    _lockedItems = Set<ItemId>.unmodifiable(lockedItems);
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
        _banishesRemaining == 0 &&
        _skipRewardCurrencyAmount == 0 &&
        _skipRewardMetaShards == 0 &&
        _trackId == null &&
        _goldAvailable == 0 &&
        _rerollCost == 0 &&
        _shopLevel == 0 &&
        _itemPrices.isEmpty &&
        _lockedItems.isEmpty) {
      return;
    }
    _choices = const [];
    _trackId = null;
    _rerollsRemaining = 0;
    _banishesRemaining = 0;
    _skipRewardCurrencyAmount = 0;
    _skipRewardCurrencyId = CurrencyId.xp;
    _skipRewardMetaShards = 0;
    _goldAvailable = 0;
    _rerollCost = 0;
    _shopLevel = 0;
    _itemPrices = const {};
    _lockedItems = const {};
    notifyListeners();
  }
}
