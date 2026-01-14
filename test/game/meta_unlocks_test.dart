import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hordesurivor/data/ids.dart';
import 'package:hordesurivor/game/meta_currency_wallet.dart';
import 'package:hordesurivor/game/meta_unlocks.dart';

void main() {
  test('MetaUnlocks enforce prerequisite connections', () async {
    SharedPreferences.setMockInitialValues({});
    final wallet = MetaCurrencyWallet();
    final unlocks = MetaUnlocks();

    await wallet.load();
    await unlocks.load();
    await wallet.add(200);

    final blockedPurchase = await unlocks.purchase(
      MetaUnlockId.extraReroll,
      wallet: wallet,
    );
    expect(blockedPurchase, isFalse);
    expect(unlocks.isUnlocked(MetaUnlockId.extraReroll), isFalse);

    final rootPurchase = await unlocks.purchase(
      MetaUnlockId.fieldManual,
      wallet: wallet,
    );
    expect(rootPurchase, isTrue);
    expect(unlocks.isUnlocked(MetaUnlockId.fieldManual), isTrue);

    final rerollPurchase = await unlocks.purchase(
      MetaUnlockId.extraReroll,
      wallet: wallet,
    );
    expect(rerollPurchase, isTrue);
    expect(unlocks.isUnlocked(MetaUnlockId.extraReroll), isTrue);
  });
}
