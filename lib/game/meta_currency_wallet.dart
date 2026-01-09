import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MetaCurrencyWallet extends ChangeNotifier {
  static const String _balanceKey = 'meta_currency_balance';

  int _balance = 0;
  bool _loaded = false;

  int get balance => _balance;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _balance = prefs.getInt(_balanceKey) ?? 0;
    _loaded = true;
    notifyListeners();
  }

  Future<void> add(int amount) async {
    if (amount <= 0) {
      return;
    }
    _balance += amount;
    notifyListeners();
    await _save();
  }

  Future<bool> spend(int amount) async {
    if (amount <= 0 || amount > _balance) {
      return false;
    }
    _balance -= amount;
    notifyListeners();
    await _save();
    return true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_balanceKey, _balance);
  }
}
