import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mula/features/finance/model/category_model.dart';

class CategoryNotifier extends AsyncNotifier<List<CategoryModel>> {
  @override
  FutureOr<List<CategoryModel>> build() async {
    final box = await Hive.openBox<CategoryModel>('categories_v2');

    // Seed initial categories if the box is empty
    if (box.isEmpty) {
      await _seedDefaultCategories(box);
    }

    return box.values.toList();
  }

  Future<void> _seedDefaultCategories(Box<CategoryModel> box) async {
    final defaults = [
      CategoryModel(id: '1', name: 'Food', iconCodePoint: Icons.fastfood.codePoint),
      CategoryModel(id: '2', name: 'Home', iconCodePoint: Icons.home.codePoint),
      CategoryModel(id: '3', name: 'Transport', iconCodePoint: Icons.directions_car.codePoint),
      CategoryModel(id: '4', name: 'Shopping', iconCodePoint: Icons.local_mall.codePoint),
      CategoryModel(id: '5', name: 'Health', iconCodePoint: Icons.favorite.codePoint),
    ];
    for (var cat in defaults) {
      await box.put(cat.id, cat);
    }
  }

  /// Returns the newly created [CategoryModel] on success, or [null] if a
  /// category with the same name already exists. The caller should use the
  /// returned model directly instead of re-reading this provider's value
  /// (which may be in a loading state right after [invalidateSelf] is called).
  Future<CategoryModel?> addCustomCategory(
      String name, int iconCodePoint, int colorValue) async {
    final box = Hive.box<CategoryModel>('categories_v2');

    // Duplicate-name prevention (case-insensitive)
    final nameFormatted = name.trim().toLowerCase();
    final exists = box.values
        .any((cat) => cat.name.trim().toLowerCase() == nameFormatted);
    if (exists) return null;

    final newCat = CategoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
    );
    await box.put(newCat.id, newCat);
    ref.invalidateSelf();
    return newCat; // Return the model directly — no provider read required
  }
}

final categoryNotifierProvider =
    AsyncNotifierProvider<CategoryNotifier, List<CategoryModel>>(() {
  return CategoryNotifier();
});
