import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mula/core/enum/transaction_type.dart';
import 'package:mula/features/finance/notifier/budget_notifier.dart';
import 'package:mula/features/finance/notifier/category_notifier.dart';
import 'package:mula/features/finance/notifier/transaction_notifier.dart';
import 'package:mula/features/finance/view/new_category_page.dart';
import 'package:mula/shared/theme/text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mula/features/finance/view/categories_view_all_page.dart';

class BudgetsPage extends ConsumerWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionNotifierProvider);
    final categoriesAsync = ref.watch(categoryNotifierProvider);
    final budgetsAsync = ref.watch(budgetNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
          ),
        ),
        title: Text(
          'Sovereign Ledger',
          style: AppTextStyles.titleMedium.copyWith(color: const Color(0xFF022A72), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.bell),
            color: const Color(0xFF1E293B),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Monthly Burn Card
              _buildMonthlyBurnCard(transactionsAsync, budgetsAsync),
              const SizedBox(height: 24),

              // Spending Velocity
              _buildSpendingVelocity(transactionsAsync, budgetsAsync),
              const SizedBox(height: 32),

              // Category Row
              Text(
                'CATEGORY',
                style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF94A3B8), letterSpacing: 1.5),
              ),
              const SizedBox(height: 16),
              _buildCategoryRow(context, categoriesAsync),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NewCategoryPage())),
                icon: const Icon(PhosphorIconsRegular.plus, size: 18),
                label: const Text('Add New Category'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF022A72),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 32),

              // Categories Breakdown Output
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Categories', style: AppTextStyles.titleLarge.copyWith(color: const Color(0xFF0F172A))),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CategoriesViewAllPage()),
                      );
                    },
                    child: Text('VIEW ALL', style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF022A72), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCategoryBudgets(categoriesAsync, budgetsAsync, transactionsAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyBurnCard(AsyncValue transactionsAsync, AsyncValue budgetsAsync) {
    if (transactionsAsync is! AsyncData || budgetsAsync is! AsyncData) {
      return Container(
        height: 150,
        decoration: BoxDecoration(color: const Color(0xFF022A72), borderRadius: BorderRadius.circular(24)),
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    
    final transactions = transactionsAsync.value! as List;
    final budgets = budgetsAsync.value! as List;

    double totalBudget = budgets.fold(0.0, (sum, b) => sum + b.allocatedAmount);
    double totalSpent = 0;
    
    for (final t in transactions) {
      if (t.type == TransactionType.expense) { // Assuming all expenses burn the budget
        totalSpent += t.amount;
      }
    }

    final format = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final progress = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
    final leftInfo = totalBudget - totalSpent;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF022A72), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MONTHLY BURN',
                style: AppTextStyles.labelSmall.copyWith(color: Colors.white70, letterSpacing: 1.5),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                ),
                child: Text(
                  'ON TRACK',
                  style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF34D399), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            format.format(totalSpent),
            style: AppTextStyles.displayMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% of ${format.format(totalBudget)} limit',
                style: AppTextStyles.labelSmall.copyWith(color: Colors.white70),
              ),
              Text(
                '${format.format(leftInfo)} left',
                style: AppTextStyles.labelSmall.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingVelocity(
    AsyncValue transactionsAsync,
    AsyncValue budgetsAsync,
  ) {
    // Compute weekly spending (last 7 days, Mon–Sun) from real transactions
    final weeklySpending = List<double>.filled(7, 0.0);
    double totalExpense = 0;
    double totalBudget = 0;

    if (transactionsAsync is AsyncData) {
      final transactions = transactionsAsync.value as List;
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      for (final t in transactions) {
        if (t.type == TransactionType.expense) {
          totalExpense += t.amount as double;
          if (t.date.isAfter(sevenDaysAgo)) {
            // weekday: 1=Mon … 7=Sun → index 0–6
            weeklySpending[(t.date.weekday - 1).clamp(0, 6)] +=
                t.amount as double;
          }
        }
      }
    }

    if (budgetsAsync is AsyncData) {
      final budgets = budgetsAsync.value as List;
      for (final b in budgets) {
        totalBudget += b.allocatedAmount as double;
      }
    }

    final budgetRemaining = totalBudget - totalExpense;
    final maxY = weeklySpending.fold(0.0, (m, v) => v > m ? v : m);
    final chartMax = maxY > 0 ? maxY * 1.3 : 10.0;

    // Compute velocity % delta vs previous week (simple heuristic)
    final firstHalf = weeklySpending.take(3).fold(0.0, (s, v) => s + v);
    final secondHalf = weeklySpending.skip(4).fold(0.0, (s, v) => s + v);
    final delta = firstHalf > 0
        ? ((secondHalf - firstHalf) / firstHalf * 100)
        : 0.0;
    final isDown = delta <= 0;

    final format = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Spending Velocity',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: const Color(0xFF0F172A))),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isDown
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444))
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      isDown
                          ? PhosphorIconsRegular.trendDown
                          : PhosphorIconsRegular.trendUp,
                      color: isDown
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${delta.abs().toStringAsFixed(1)}%',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDown
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Trend relative to baseline',
            style:
                AppTextStyles.bodySmall.copyWith(color: const Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: chartMax,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                        BarTooltipItem(
                      '\$${rod.toY.toStringAsFixed(0)}',
                      AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'
                        ];
                        final idx = value.toInt();
                        if (idx < 0 || idx >= days.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            days[idx],
                            style: AppTextStyles.labelSmall
                                .copyWith(color: const Color(0xFF94A3B8)),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (i) {
                  final value = weeklySpending[i];
                  final isToday = i == DateTime.now().weekday - 1;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        color: isToday
                            ? const Color(0xFF022A72)
                            : const Color(0xFF94A3B8).withOpacity(0.45),
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: chartMax,
                          color: const Color(0xFFF1F5F9),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(PhosphorIconsRegular.chartPie,
                    color: Color(0xFF10B981), size: 18),
                const SizedBox(width: 8),
                Text('Budget Remaining',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: const Color(0xFF1E293B))),
                const Spacer(),
                Text(
                  format.format(budgetRemaining.clamp(0, double.infinity)),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: budgetRemaining >= 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context, AsyncValue categoriesAsync) {
    if (categoriesAsync is! AsyncData) {
      return const CircularProgressIndicator();
    }
    final categories = categoriesAsync.value! as List;
    
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == categories.length) {
            // New Button
            return GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NewCategoryPage())),
              child: Container(
                width: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF), // Light blue tint
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(PhosphorIconsRegular.plus, color: Color(0xFF022A72)),
                    const SizedBox(height: 4),
                    Text('New', style: AppTextStyles.labelMedium.copyWith(color: const Color(0xFF022A72))),
                  ],
                ),
              ),
            );
          }

          final cat = categories[index];
          return GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NewCategoryPage(
                  existingCategoryId: cat.id,
                  prefillName: cat.name,
                  prefillIcon: IconData(
                    cat.iconCodePoint,
                    fontFamily: 'MaterialIcons',
                  ),
                ),
              ),
            ),
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons'),
                    color: const Color(0xFF022A72),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cat.name,
                    style: AppTextStyles.labelMedium
                        .copyWith(color: const Color(0xFF022A72)),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryBudgets(
    AsyncValue categoriesAsync,
    AsyncValue budgetsAsync,
    AsyncValue transactionsAsync,
  ) {
    if (categoriesAsync is! AsyncData ||
        budgetsAsync is! AsyncData ||
        transactionsAsync is! AsyncData) {
      return const SizedBox.shrink();
    }

    final categories = categoriesAsync.value! as List;
    final budgets = budgetsAsync.value! as List;
    final transactions = transactionsAsync.value! as List;

    if (categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('No categories yet.', style: AppTextStyles.bodyMedium),
        ),
      );
    }

    final format = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final List<Widget> widgets = [];

    // Iterate categories — not budgets — so every category is always visible
    for (final category in categories) {
      // Find the budget record for this category, if any
      final matchingBudgetsList =
          budgets.where((b) => b.categoryid == category.id);
      final budget =
          matchingBudgetsList.isNotEmpty ? matchingBudgetsList.first : null;
      final bool hasBudget = budget != null;

      // Sum expenses for this category
      double spent = 0;
      for (final t in transactions) {
        if (t.type == TransactionType.expense &&
            t.categoryid == category.id) {
          spent += t.amount;
        }
      }

      final double limit = hasBudget ? budget.allocatedAmount : 0.0;
      final double remaining = hasBudget ? (limit - spent) : 0.0;
      final double progress =
          hasBudget && limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
      final bool overshot = hasBudget && remaining < 0;

      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      IconData(category.iconCodePoint,
                          fontFamily: 'MaterialIcons'),
                      color: const Color(0xFF022A72),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category.name,
                      style: AppTextStyles.titleSmall
                          .copyWith(color: const Color(0xFF1E293B)),
                    ),
                  ),
                  if (!hasBudget)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'No limit',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: const Color(0xFF94A3B8)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (hasBudget) ...[  
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        overshot ? Colors.red : const Color(0xFF022A72)),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      format.format(spent),
                      style: AppTextStyles.titleMedium
                          .copyWith(color: const Color(0xFF022A72)),
                    ),
                    Text(
                      '${format.format(remaining.clamp(0, double.infinity))} LEFT',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: overshot ? Colors.red : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ] else ...[  
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      format.format(spent),
                      style: AppTextStyles.titleMedium
                          .copyWith(color: const Color(0xFF022A72)),
                    ),
                    Text(
                      'spent',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    }

    final limitedWidgets =
        widgets.length > 6 ? widgets.sublist(0, 6) : widgets;
    return Column(children: limitedWidgets);
  }
}
