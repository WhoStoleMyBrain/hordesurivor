import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/ids.dart';
import '../data/meta_unlock_defs.dart';
import '../data/stat_defs.dart';
import 'meta_currency_wallet.dart';

class MetaUnlocks extends ChangeNotifier {
  static const String _unlocksKey = 'meta_unlocks';

  final Set<MetaUnlockId> _unlocked = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  bool isUnlocked(MetaUnlockId id) => _unlocked.contains(id);

  Iterable<MetaUnlockId> get unlockedIds => Set.unmodifiable(_unlocked);

  bool canUnlock(MetaUnlockId id) {
    final def = metaUnlockDefsById[id];
    if (def == null) {
      return false;
    }
    if (def.prerequisites.isEmpty) {
      return true;
    }
    return def.prerequisites.any(_unlocked.contains);
  }

  List<StatModifier> get activeModifiers => [
    for (final id in _unlocked) ...?metaUnlockDefsById[id]?.modifiers,
  ];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_unlocksKey) ?? const [];
    _unlocked
      ..clear()
      ..addAll(_parseUnlocks(stored));
    _loaded = true;
    notifyListeners();
  }

  Future<bool> purchase(
    MetaUnlockId id, {
    required MetaCurrencyWallet wallet,
  }) async {
    if (isUnlocked(id)) {
      return false;
    }
    final def = metaUnlockDefsById[id];
    if (def == null) {
      return false;
    }
    if (!canUnlock(id)) {
      return false;
    }
    final spent = await wallet.spend(def.cost);
    if (!spent) {
      return false;
    }
    _unlocked.add(id);
    notifyListeners();
    await _save();
    return true;
  }

  Iterable<MetaUnlockId> _parseUnlocks(List<String> raw) sync* {
    for (final entry in raw) {
      try {
        final id = MetaUnlockId.values.byName(entry);
        if (metaUnlockDefsById.containsKey(id)) {
          yield id;
        }
      } on ArgumentError {
        continue;
      }
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _unlocked.map((id) => id.name).toList();
    await prefs.setStringList(_unlocksKey, encoded);
  }
}
