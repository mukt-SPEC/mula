import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mula/core/enum/transaction_type.dart';
import 'package:mula/features/finance/model/transaction.dart';
import 'package:mula/features/finance/notifier/transaction_notifier.dart';
import 'package:mula/features/finance/view/transaction_page.dart';
import 'package:mula/features/overview/widget/animated_fab.dart';
import 'package:mula/shared/theme/text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mula/features/overview/view/ledger_view_all_page.dart';
class OverviewPage extends ConsumerWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(24.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Header Row
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(
                              'https://i.pravatar.cc/150?img=11',
                            ), // Temporary avatar
                            backgroundColor: Color(0xFFE2E8F0),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Sovereign Ledger",
                            style: AppTextStyles.titleLarge.copyWith(
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Balance Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF022A72),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'LIQUID WEALTH PORTFOLIO',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: const Color(0xFF94A3B8),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    '+12.5%',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: const Color(0xFF34D399),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Consumer(
                              builder: (context, ref, child) {
                                final asyncTransactions = ref.watch(
                                  transactionNotifierProvider,
                                );
                                return asyncTransactions.when(
                                  data: (transactions) {
                                    double totalBalance = 0;
                                    for (var t in transactions) {
                                      if (t.type == TransactionType.income) {
                                        totalBalance += t.amount;
                                      } else {
                                        totalBalance -= t.amount;
                                      }
                                    }
                                    final numberFormat = NumberFormat.currency(
                                      symbol: '\$',
                                      decimalDigits: 2,
                                    );
                                    return Text(
                                      numberFormat.format(totalBalance),
                                      style: AppTextStyles.displayMedium
                                          .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    );
                                  },
                                  loading: () =>
                                      const CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                  error: (_, __) => Text(
                                    '\$0.00',
                                    style: AppTextStyles.displayMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Market valuation as of today',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: const Color(0xFF94A3B8),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Income/Expense buttons
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          PhosphorIconsRegular.arrowDown,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'INCOME',
                                          style: AppTextStyles.labelMedium
                                              .copyWith(
                                                color: Colors.white,
                                                letterSpacing: 1.2,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          PhosphorIconsRegular.arrowUp,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'EXPENSE',
                                          style: AppTextStyles.labelMedium
                                              .copyWith(
                                                color: Colors.white,
                                                letterSpacing: 1.2,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Chart Area
                      _SpendingTrendChart(transactions: transactionsAsync.value ?? []),
                      const SizedBox(height: 32),

                      // Recent Ledger
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Ledger',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const LedgerViewAllPage()),
                              );
                            },
                            child: Text(
                              'VIEW ALL',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: const Color(0xFF022A72),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ]),
                  ),
                ),
                transactionsAsync.when(
                  data: (transactions) {
                    if (transactions.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text("No transactions yet."),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final t = transactions[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 8.0,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    t.type == TransactionType.income
                                        ? PhosphorIconsRegular.wallet
                                        : PhosphorIconsRegular.shoppingCart,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.title,
                                        style: AppTextStyles.titleMedium
                                            .copyWith(
                                              color: const Color(0xFF1E293B),
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat.yMd().format(t.date),
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${t.type == TransactionType.income ? '+' : '-'} \$${t.amount.toStringAsFixed(2)}',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: t.type == TransactionType.income
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }, childCount: transactions.length > 6 ? 6 : transactions.length),
                    );
                  },
                  loading: () => const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const SliverToBoxAdapter(
                    child: Text('Error loading transactions'),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ), // Bottom padding for FAB
              ],
            ),
          ),
          AnimatedFabOverlay(
            pageContext: context,
            actions: [
              AnimatedFabAction(
                icon: PhosphorIconsRegular.bank,
                onPressed: (pageContext) {},
              ),
              AnimatedFabAction(
                icon: PhosphorIconsRegular.pen,
                onPressed: (pageContext) {
                  Navigator.of(pageContext).push(
                    MaterialPageRoute(builder: (_) => const TransactionPage()),
                  );
                },
              ),
              AnimatedFabAction(
                icon: PhosphorIconsRegular.notepad,
                onPressed: (pageContext) {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Real-data Spending Trend Chart
// ---------------------------------------------------------------------------
class _SpendingTrendChart extends StatelessWidget {
  final List<TransactionModel> transactions;

  const _SpendingTrendChart({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    // Build 4 buckets (W1–W4)
    final weekTotals = [0.0, 0.0, 0.0, 0.0];
    for (final t in transactions) {
      if (t.type == TransactionType.expense &&
          t.date.year == now.year &&
          t.date.month == now.month) {
        final dayIndex = t.date.day - 1;
        final weekIndex = (dayIndex / 7).floor().clamp(0, 3);
        weekTotals[weekIndex] += t.amount;
      }
    }

    final maxY = weekTotals.fold(0.0, (m, v) => v > m ? v : m);
    final chartMax = maxY > 0 ? maxY * 1.3 : 10.0;

    final spots = List.generate(
      4,
      (i) => FlSpot(i.toDouble(), weekTotals[i]),
    );

    final dateLabel =
        '${DateFormat('MMM d').format(monthStart)} – ${DateFormat('MMM d, y').format(DateTime(now.year, now.month, daysInMonth))}';

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
              Text(
                'Spending Trend',
                style: AppTextStyles.titleMedium
                    .copyWith(color: const Color(0xFF0F172A)),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF022A72),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            dateLabel,
            style:
                AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: chartMax,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        const labels = ['W1', 'W2', 'W3', 'W4'];
                        final idx = value.toInt();
                        if (idx >= 0 && idx < labels.length) {
                          return Text(
                            labels[idx],
                            style: AppTextStyles.labelSmall
                                .copyWith(color: const Color(0xFF94A3B8)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF022A72),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF022A72).withOpacity(0.15),
                          const Color(0xFF022A72).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
