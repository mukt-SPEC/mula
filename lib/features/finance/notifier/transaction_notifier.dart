import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mula/features/finance/model/transaction.dart';
import 'package:mula/features/finance/provider/hive_provider.dart';

class TransactionNotifier extends AsyncNotifier<List<TransactionModel>> {
  @override
  FutureOr<List<TransactionModel>> build() async {
    final box = ref.watch(transactionBoxProvider);
    return box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final box = ref.read(transactionBoxProvider);
      await box.put(transaction.id, transaction);
      return box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  Future<void> deleteTransaction(String id) async {
    final box = ref.read(transactionBoxProvider);
    await box.delete(id);
    ref.invalidateSelf(); 
  }
}

final transactionNotifierProvider = AsyncNotifierProvider<TransactionNotifier, List<TransactionModel>>(() {
  return TransactionNotifier();
});
