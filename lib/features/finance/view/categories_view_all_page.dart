import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mula/core/enum/transaction_type.dart';
import 'package:mula/features/finance/model/budget.dart';
import 'package:mula/features/finance/model/category_model.dart';
import 'package:mula/features/finance/notifier/budget_notifier.dart';
import 'package:mula/features/finance/notifier/category_notifier.dart';
import 'package:mula/features/finance/notifier/transaction_notifier.dart';
import 'package:mula/shared/theme/text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CategoriesViewAllPage extends ConsumerWidget {
  const CategoriesViewAllPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryNotifierProvider);
    final transactionsAsync = ref.watch(transactionNotifierProvider);
    final budgetsAsync = ref.watch(budgetNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(PhosphorIconsRegular.arrowLeft,
              color: const Color(0xFF1E293B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Allocated Categories',
          style:
              AppTextStyles.titleMedium.copyWith(color: const Color(0xFF1E293B)),
        ),
      ),
      body: _buildContent(categoriesAsync, transactionsAsync, budgetsAsync),
    );
  }

  Widget _buildContent(
    AsyncValue<List<CategoryModel>> categoriesAsync,
    AsyncValue transactionsAsync,
    AsyncValue<List<BudgetModel>> budgetsAsync,
  ) {
    if (categoriesAsync.isLoading ||
        transactionsAsync.isLoading ||
        budgetsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (categoriesAsync.hasError ||
        transactionsAsync.hasError ||
        budgetsAsync.hasError) {
      return const Center(child: Text('Error loading data'));
    }

    final categories = categoriesAsync.value ?? <CategoryModel>[];
    final transactions = transactionsAsync.value ?? [];
    final budgets = budgetsAsync.value ?? <BudgetModel>[];

    if (categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('No categories yet.', style: AppTextStyles.bodyMedium),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];

        // Find the budget for this category, if any
        final matchingBudgets =
            budgets.where((b) => b.categoryid == category.id);
        final BudgetModel? budget =
            matchingBudgets.isNotEmpty ? matchingBudgets.first : null;
        final bool hasBudget = budget != null;

        // Sum expenses
        double spent = 0;
        for (final t in transactions) {
          if (t.type == TransactionType.expense &&
              t.categoryid == category.id) {
            spent += t.amount;
          }
        }

        final double budgetLimit =
            hasBudget ? budget.allocatedAmount : 0.0; // FIX: was budget.amount
        final double progress = hasBudget && budgetLimit > 0
            ? (spent / budgetLimit).clamp(0.0, 1.0)
            : 0.0;
        final bool isWarning = hasBudget && progress >= 0.8;

        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(category.colorValue).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      IconData(category.iconCodePoint,
                          fontFamily: 'MaterialIcons'),
                      color: Color(category.colorValue),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(category.name,
                            style: AppTextStyles.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          hasBudget
                              ? '${(progress * 100).toInt()}% consumed'
                              : 'No limit set',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isWarning
                                ? Colors.red
                                : const Color(0xFF64748B),
                            fontWeight: isWarning
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${spent.toStringAsFixed(2)}',
                        style: AppTextStyles.titleMedium
                            .copyWith(color: const Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasBudget
                            ? '/ \$${budgetLimit.toStringAsFixed(2)}'
                            : 'spent',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: const Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ],
              ),
              // Only show a progress bar when a budget limit has been set
              if (hasBudget) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFF1F5F9),
                    color: isWarning ? Colors.red : Color(category.colorValue),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
