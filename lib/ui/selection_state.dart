import 'package:flutter/foundation.dart';

import '../data/ids.dart';
import '../game/level_up_system.dart';

class SelectionState extends ChangeNotifier {
  List<SelectionChoice> _choices = const [];
  int _rerollsRemaining = 0;
  int _banishesRemaining = 0;
  String _skipRewardLabel = 'Skip';
  ProgressionTrackId? _trackId;
  int _goldAvailable = 0;
  int _rerollCost = 0;
  int _shopLevel = 0;
  Map<ItemId, int> _itemPrices = const {};
  Set<ItemId> _lockedItems = const {};
  int _shopFreeRerolls = 0;
  int _shopDiscountTokens = 0;
  int _shopRarityBoostsApplied = 0;
  int _shopBonusChoices = 0;

  List<SelectionChoice> get choices => _choices;
  bool get active => _choices.isNotEmpty;
  int get rerollsRemaining => _rerollsRemaining;
  int get banishesRemaining => _banishesRemaining;
  String get skipRewardLabel => _skipRewardLabel;
  ProgressionTrackId? get trackId => _trackId;
  int get goldAvailable => _goldAvailable;
  int get rerollCost => _rerollCost;
  int get shopLevel => _shopLevel;
  Map<ItemId, int> get itemPrices => _itemPrices;
  Set<ItemId> get lockedItems => _lockedItems;
  int get shopFreeRerolls => _shopFreeRerolls;
  int get shopDiscountTokens => _shopDiscountTokens;
  int get shopRarityBoostsApplied => _shopRarityBoostsApplied;
  int get shopBonusChoices => _shopBonusChoices;

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
    String skipRewardLabel = 'Skip',
    int goldAvailable = 0,
    int rerollCost = 0,
    int shopLevel = 0,
    Map<ItemId, int> itemPrices = const {},
    Set<ItemId> lockedItems = const {},
    int shopFreeRerolls = 0,
    int shopDiscountTokens = 0,
    int shopRarityBoostsApplied = 0,
    int shopBonusChoices = 0,
  }) {
    _choices = List<SelectionChoice>.from(choices);
    _trackId = trackId;
    _rerollsRemaining = rerollsRemaining;
    _banishesRemaining = banishesRemaining;
    _skipRewardLabel = skipRewardLabel;
    _goldAvailable = goldAvailable;
    _rerollCost = rerollCost;
    _shopLevel = shopLevel;
    _itemPrices = Map<ItemId, int>.unmodifiable(itemPrices);
    _lockedItems = Set<ItemId>.unmodifiable(lockedItems);
    _shopFreeRerolls = shopFreeRerolls;
    _shopDiscountTokens = shopDiscountTokens;
    _shopRarityBoostsApplied = shopRarityBoostsApplied;
    _shopBonusChoices = shopBonusChoices;
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
        _skipRewardLabel == 'Skip' &&
        _trackId == null &&
        _goldAvailable == 0 &&
        _rerollCost == 0 &&
        _shopLevel == 0 &&
        _itemPrices.isEmpty &&
        _lockedItems.isEmpty &&
        _shopFreeRerolls == 0 &&
        _shopDiscountTokens == 0 &&
        _shopRarityBoostsApplied == 0 &&
        _shopBonusChoices == 0) {
      return;
    }
    _choices = const [];
    _trackId = null;
    _rerollsRemaining = 0;
    _banishesRemaining = 0;
    _skipRewardLabel = 'Skip';
    _goldAvailable = 0;
    _rerollCost = 0;
    _shopLevel = 0;
    _itemPrices = const {};
    _lockedItems = const {};
    _shopFreeRerolls = 0;
    _shopDiscountTokens = 0;
    _shopRarityBoostsApplied = 0;
    _shopBonusChoices = 0;
    notifyListeners();
  }
}
