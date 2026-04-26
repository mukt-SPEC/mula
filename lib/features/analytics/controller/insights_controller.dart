import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mula/core/enum/transaction_type.dart';
import 'package:mula/features/finance/model/budget.dart';
import 'package:mula/features/finance/model/category_model.dart';
import 'package:mula/features/finance/model/transaction.dart';
import 'package:mula/features/finance/notifier/budget_notifier.dart';
import 'package:mula/features/finance/notifier/category_notifier.dart';
import 'package:mula/features/finance/notifier/transaction_notifier.dart';

/// Aggregated analytics snapshot derived from live app data.
class InsightsData {
  final List<TransactionModel> transactions;
  final List<BudgetModel> budgets;
  final List<CategoryModel> categories;

  // --- Computed fields ---
  final double totalIncome;
  final double totalExpense;
  final double totalBudget;
  final double budgetUtilizationPercent; // 0–100
  final double budgetRemaining;

  /// Daily spending for the current month (index = day-of-month, value = sum of expenses).
  final List<double> dailySpending;

  /// Weekly spending for the last 7 days indexed MON–SUN.
  final List<double> weeklySpending;

  /// Per-category spending totals (only expense transactions).
  final Map<String, double> categorySpending;

  /// Current month name, e.g. "September".
  final String currentMonth;

  InsightsData({
    required this.transactions,
    required this.budgets,
    required this.categories,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalBudget,
    required this.budgetUtilizationPercent,
    required this.budgetRemaining,
    required this.dailySpending,
    required this.weeklySpending,
    required this.categorySpending,
    required this.currentMonth,
  });

  double get netBalance => totalIncome - totalExpense;
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final insightsProvider = Provider<AsyncValue<InsightsData>>((ref) {
  final txAsync = ref.watch(transactionNotifierProvider);
  final budgetsAsync = ref.watch(budgetNotifierProvider);
  final categoriesAsync = ref.watch(categoryNotifierProvider);

  if (txAsync is AsyncLoading ||
      budgetsAsync is AsyncLoading ||
      categoriesAsync is AsyncLoading) {
    return const AsyncValue.loading();
  }

  if (txAsync is AsyncError) return AsyncValue.error(txAsync.error!, txAsync.stackTrace!);
  if (budgetsAsync is AsyncError) return AsyncValue.error(budgetsAsync.error!, budgetsAsync.stackTrace!);
  if (categoriesAsync is AsyncError) return AsyncValue.error(categoriesAsync.error!, categoriesAsync.stackTrace!);

  final transactions = txAsync.value ?? [];
  final budgets = budgetsAsync.value ?? [];
  final categories = categoriesAsync.value ?? [];

  return AsyncValue.data(_compute(transactions, budgets, categories));
});

InsightsData _compute(
  List<TransactionModel> transactions,
  List<BudgetModel> budgets,
  List<CategoryModel> categories,
) {
  final now = DateTime.now();
  final monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  double totalIncome = 0;
  double totalExpense = 0;
  final Map<String, double> categorySpending = {};

  // Daily spending for the current month (1-indexed → 0-indexed array)
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  final dailySpending = List<double>.filled(daysInMonth, 0.0);

  // Weekly spending: indexed 0=Mon … 6=Sun, over the last 7 days
  final weeklySpending = List<double>.filled(7, 0.0);
  final sevenDaysAgo = now.subtract(const Duration(days: 7));

  for (final t in transactions) {
    if (t.type == TransactionType.income) {
      totalIncome += t.amount;
    } else {
      totalExpense += t.amount;

      // Daily (current month only)
      if (t.date.year == now.year && t.date.month == now.month) {
        dailySpending[t.date.day - 1] += t.amount;
      }

      // Weekly (last 7 days)
      if (t.date.isAfter(sevenDaysAgo)) {
        // weekday: 1=Mon, 7=Sun  →  index 0–6
        weeklySpending[t.date.weekday - 1] += t.amount;
      }

      // Category breakdown
      if (t.categoryid != null) {
        categorySpending[t.categoryid!] =
            (categorySpending[t.categoryid!] ?? 0) + t.amount;
      }
    }
  }

  final totalBudget =
      budgets.fold(0.0, (sum, b) => sum + b.allocatedAmount);
  final budgetRemaining = (totalBudget - totalExpense);
  final budgetUtil = totalBudget > 0
      ? ((totalExpense / totalBudget) * 100).clamp(0.0, 100.0)
      : 0.0;

  return InsightsData(
    transactions: transactions,
    budgets: budgets,
    categories: categories,
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    totalBudget: totalBudget,
    budgetUtilizationPercent: budgetUtil,
    budgetRemaining: budgetRemaining,
    dailySpending: dailySpending,
    weeklySpending: weeklySpending,
    categorySpending: categorySpending,
    currentMonth: monthNames[now.month - 1],
  );
}
