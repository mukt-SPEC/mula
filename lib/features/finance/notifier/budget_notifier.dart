import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mula/features/finance/model/budget.dart';
import 'package:mula/features/finance/provider/hive_provider.dart';

class BudgetNotifier extends AsyncNotifier<List<BudgetModel>> {
  @override
  FutureOr<List<BudgetModel>> build() async {
    final box = ref.watch(budgetBoxProvider);
    return box.values.toList();
  }

  Future<void> setBudget(String categoryId, double amount) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final box = ref.read(budgetBoxProvider);
      
      // Look for existing budget for this category
      String? existingBudgetId;
      for (final budget in box.values) {
        if (budget.categoryid == categoryId) {
          existingBudgetId = budget.key.toString(); // Hive keys
          break;
        }
      }

      final budget = BudgetModel(
        categoryid: categoryId,
        allocatedAmount: amount,
      );

      if (existingBudgetId != null && box.containsKey(existingBudgetId)) {
        await box.put(existingBudgetId, budget);
      } else {
        await box.add(budget); // Auto increment key
      }

      return box.values.toList();
    });
  }

  Future<void> deleteBudget(String categoryId) async {
    final box = ref.read(budgetBoxProvider);
    dynamic keyToDelete;
    for (final budget in box.values) {
      if (budget.categoryid == categoryId) {
        keyToDelete = budget.key;
        break;
      }
    }
    if (keyToDelete != null) {
      await box.delete(keyToDelete);
      ref.invalidateSelf();
    }
  }
}

final budgetNotifierProvider =
    AsyncNotifierProvider<BudgetNotifier, List<BudgetModel>>(() {
  return BudgetNotifier();
});
