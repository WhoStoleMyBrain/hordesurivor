import 'package:flutter/material.dart';

import '../data/ids.dart';

Color itemRarityColor(ItemRarity rarity) {
  switch (rarity) {
    case ItemRarity.common:
      return const Color(0xFFB8C4D9);
    case ItemRarity.uncommon:
      return const Color(0xFF7EE081);
    case ItemRarity.rare:
      return const Color(0xFF6CA6FF);
    case ItemRarity.epic:
      return const Color(0xFFC39BFF);
  }
}

String itemRarityLabel(ItemRarity rarity) {
  switch (rarity) {
    case ItemRarity.common:
      return 'Common';
    case ItemRarity.uncommon:
      return 'Uncommon';
    case ItemRarity.rare:
      return 'Rare';
    case ItemRarity.epic:
      return 'Epic';
  }
}
