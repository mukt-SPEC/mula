import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mula/features/finance/model/budget.dart';
import 'package:mula/features/finance/model/transaction.dart';

final transactionBoxProvider = Provider<Box<TransactionModel>>((ref) {
  return Hive.box<TransactionModel>('transactions_v2');
});

final budgetBoxProvider = Provider<Box<BudgetModel>>((ref) {
  return Hive.box<BudgetModel>('budgets_v2');
});