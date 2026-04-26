import 'package:flutter/material.dart';

const Map<int, IconData> _categoryIconRegistry = {
  0xe59a: Icons.shopping_bag,
  0xe39a: Icons.local_mall,
  0xe1d7: Icons.directions_car,
  0xe318: Icons.home,
  0xe25a: Icons.fastfood,
  0xe25b: Icons.favorite,
  0xe5e8: Icons.sports_esports,
  0xe297: Icons.flight,
  0xe185: Icons.computer,
  0xe559: Icons.school,
  0xe4a1: Icons.pets,
  0xe38d: Icons.local_cafe,
  0xf05a2: Icons.water_drop,
  0xe0ee: Icons.bolt,
  0xe13e: Icons.card_giftcard,
  0xe1af: Icons.dangerous,
};

IconData resolveCategoryIcon(int codePoint) {
  return _categoryIconRegistry[codePoint] ?? Icons.category;
}

