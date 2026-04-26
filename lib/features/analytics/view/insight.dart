import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mula/features/analytics/controller/insights_controller.dart';
import 'package:mula/features/analytics/widget/allocation_donut_chart.dart';
import 'package:mula/features/analytics/widget/spending_velocity_chart.dart';
import 'package:mula/features/finance/model/category_model.dart';
import 'package:mula/shared/theme/text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class InsightPage extends ConsumerStatefulWidget {
  const InsightPage({super.key});

  @override
  ConsumerState<InsightPage> createState() => _InsightPageState();
}

class _InsightPageState extends ConsumerState<InsightPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insightsAsync = ref.watch(insightsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: insightsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF022A72)),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (data) => _buildContent(context, data),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, InsightsData data) {
    final format = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final compactFormat =
        NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildAppBar()),

        SliverToBoxAdapter(
          child: _buildHeroHeader(data, format, compactFormat),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SpendingVelocityChart(
              weeklySpending: data.weeklySpending,
              velocityPercent: _calcVelocityDelta(data),
              budgetRemaining: data.budgetRemaining,
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: _buildMonthlyOverviewBanner(data, format),
        ),

        SliverToBoxAdapter(
          child: _buildAllocationCard(data),
        ),

        SliverToBoxAdapter(
          child: _buildSmartSuggestions(data, compactFormat),
        ),

        SliverToBoxAdapter(
          child: _buildSmartAllocationBanner(data),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundImage:
                    NetworkImage('https://i.pravatar.cc/150?img=11'),
              ),
              const SizedBox(width: 10),
              Text(
                'Sovereign Ledger',
                style: AppTextStyles.titleMedium.copyWith(
                  color: const Color(0xFF022A72),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(PhosphorIconsRegular.bell,
                    color: Color(0xFF1E293B)),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'PERFORMANCE ANALYTICS',
            style: AppTextStyles.labelSmall.copyWith(
              color: const Color(0xFF94A3B8),
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Financial Insights',
            style: AppTextStyles.headlineMedium.copyWith(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            height: 40,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                )
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF022A72),
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF94A3B8),
              labelStyle: AppTextStyles.labelMedium
                  .copyWith(fontWeight: FontWeight.bold),
              unselectedLabelStyle: AppTextStyles.labelMedium,
              tabs: const [
                Tab(text: 'Daily'),
                Tab(text: 'Weekly'),
                Tab(text: 'Monthly'),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(
      InsightsData data, NumberFormat fmt,
      NumberFormat compact) {
    final spots = <FlSpot>[];
    for (int i = 0; i < data.dailySpending.length; i++) {
      spots.add(FlSpot(i.toDouble(), data.dailySpending[i]));
    }
    if (spots.isEmpty) spots.add(const FlSpot(0, 0));

    final maxY = data.dailySpending.fold(0.0, (m, v) => v > m ? v : m);
    final chartMax = maxY > 0 ? maxY * 1.3 : 10.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spending Velocity',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Trend relative to baseline',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_down,
                          size: 14, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      Text(
                        '${_calcVelocityDelta(data).toStringAsFixed(1)}%',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 100,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (val, meta) {
                          const labels = ['W1', 'W2', 'W3', 'W4'];
                          final idx = (val / 7).floor();
                          if (val % 7 == 0 &&
                              idx >= 0 &&
                              idx < labels.length) {
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
                  minY: 0,
                  maxY: chartMax,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: const Color(0xFF022A72),
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF022A72).withOpacity(0.18),
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

            const SizedBox(height: 16),

            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.donut_large_outlined,
                      color: Color(0xFF10B981), size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'Budget Remaining',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: const Color(0xFF1E293B)),
                  ),
                  const Spacer(),
                  Text(
                    fmt.format(data.budgetRemaining.clamp(0, double.infinity)),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: data.budgetRemaining >= 0
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyOverviewBanner(InsightsData data, NumberFormat fmt) {
    final utilInt = data.budgetUtilizationPercent.toInt();
    final willStayOnTrack =
        data.budgetUtilizationPercent < 85; 
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MONTHLY OVERVIEW',
            style: AppTextStyles.labelSmall.copyWith(
              color: const Color(0xFF94A3B8),
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${data.currentMonth} Budgets',
            style: AppTextStyles.headlineSmall.copyWith(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: AppTextStyles.bodyMedium
                  .copyWith(color: const Color(0xFF64748B)),
              children: [
                const TextSpan(text: "You've utilized "),
                TextSpan(
                  text: '$utilInt%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF022A72),
                  ),
                ),
                const TextSpan(
                    text: ' of your total monthly allowance. '),
                TextSpan(
                  text: willStayOnTrack
                      ? "Your trajectory suggests you'll remain within limits by month end."
                      : "You're exceeding your budget — consider reviewing your expenses.",
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Spent',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  fmt.format(data.totalExpense),
                  style: AppTextStyles.displaySmall.copyWith(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'of ${fmt.format(data.totalBudget)} total budget',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: const Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value:
                        (data.budgetUtilizationPercent / 100).clamp(0.0, 1.0),
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      data.budgetUtilizationPercent >= 100
                          ? const Color(0xFFEF4444)
                          : data.budgetUtilizationPercent >= 80
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF022A72),
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationCard(InsightsData data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Allocation',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: const Color(0xFF0F172A)),
                ),
                Text(
                  'View All',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFF022A72),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AllocationDonutChart(
              budgets: data.budgets,
              categories: data.categories,
              totalAllocated: data.totalBudget,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartSuggestions(InsightsData data, NumberFormat compact) {
    final suggestions = _generateSuggestions(data, compact);
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Smart Suggestions',
                style: AppTextStyles.titleMedium
                    .copyWith(color: const Color(0xFF0F172A)),
              ),
              Text(
                'View All',
                style: AppTextStyles.labelSmall.copyWith(
                  color: const Color(0xFF022A72),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...suggestions.take(3).map((s) => _SuggestionCard(
                icon: s.icon,
                title: s.title,
                description: s.description,
                tag: s.tag,
                tagColor: s.tagColor,
                actionLabel: s.actionLabel,
              )),
        ],
      ),
    );
  }

  List<_Suggestion> _generateSuggestions(
      InsightsData data, NumberFormat compact) {
    final suggestions = <_Suggestion>[];

    if (data.categorySpending.isNotEmpty) {
      final sorted = data.categorySpending.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final top = sorted.first;
      final cat = data.categories.firstWhere(
        (c) => c.id == top.key,
        orElse: () => CategoryModel(id: top.key, name: 'Unknown'),
      );
      suggestions.add(_Suggestion(
        icon: Icons.auto_graph_outlined,
        title: 'Optimize ${cat.name} Spending',
        description:
            'You\'ve spent ${compact.format(top.value)} on ${cat.name} this period. Reviewing this category could save you money.',
        tag: 'HIGH IMPACT',
        tagColor: const Color(0xFFEF4444),
        actionLabel: 'Take Action',
      ));
    }

    for (final budget in data.budgets) {
      final spent = data.categorySpending[budget.categoryid] ?? 0;
      if (spent > budget.allocatedAmount) {
        final cat = data.categories.firstWhere(
          (c) => c.id == budget.categoryid,
          orElse: () => CategoryModel(id: budget.categoryid, name: 'Category'),
        );
        final over = spent - budget.allocatedAmount;
        suggestions.add(_Suggestion(
          icon: Icons.account_balance_wallet_outlined,
          title: '${cat.name} Over Budget',
          description:
              'You\'ve exceeded your ${cat.name} budget by ${compact.format(over)}. Consider reducing spending in this area.',
          tag: 'REVIEW',
          tagColor: const Color(0xFFF59E0B),
          actionLabel: 'Review Budget',
        ));
        break;
      }
    }

    if (data.budgetUtilizationPercent < 60 && data.totalBudget > 0) {
      suggestions.add(_Suggestion(
        icon: Icons.savings_outlined,
        title: 'Investment Opportunity',
        description:
            'You\'re well within budget this month. Consider allocating the surplus ${compact.format(data.budgetRemaining)} to savings.',
        tag: 'SAVE MORE',
        tagColor: const Color(0xFF10B981),
        actionLabel: 'Review Portfolio',
      ));
    }

    return suggestions;
  }

  Widget _buildSmartAllocationBanner(InsightsData data) {
    if (data.totalBudget == 0) return const SizedBox.shrink();

    final transportCat = data.categories.firstWhere(
      (c) => c.name.toLowerCase().contains('transport'),
      orElse: () => CategoryModel(id: '', name: ''),
    );
    final transportSpent =
        transportCat.id.isEmpty ? 0.0 : (data.categorySpending[transportCat.id] ?? 0.0);
    final transportBudget = transportCat.id.isEmpty
        ? 0.0
        : (data.budgets
                .where((b) => b.categoryid == transportCat.id)
                .firstOrNull
                ?.allocatedAmount ??
            0.0);
    final transportPct = transportBudget > 0
        ? (transportSpent / transportBudget * 100).clamp(0.0, 100.0)
        : 0.0;

    if (transportPct < 60) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF022A72), Color(0xFF1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: transportPct / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                    Text(
                      '${transportPct.toInt()}%',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Smart Allocation\nDetected',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "You've spent ${transportPct.toInt()}% on ${transportCat.name} this month. Would you like to reallocate some budget?",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF022A72),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Allocate Now',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: const Color(0xFF022A72),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calcVelocityDelta(InsightsData data) {
    final half = data.dailySpending.length ~/ 2;
    if (half == 0) return 0.0;
    final firstHalf =
        data.dailySpending.take(half).fold(0.0, (s, v) => s + v);
    final secondHalf =
        data.dailySpending.skip(half).fold(0.0, (s, v) => s + v);
    if (firstHalf == 0) return 0.0;
    return ((secondHalf - firstHalf) / firstHalf * 100);
  }
}

class _Suggestion {
  final IconData icon;
  final String title;
  final String description;
  final String tag;
  final Color tagColor;
  final String actionLabel;

  const _Suggestion({
    required this.icon,
    required this.title,
    required this.description,
    required this.tag,
    required this.tagColor,
    required this.actionLabel,
  });
}

class _SuggestionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String tag;
  final Color tagColor;
  final String actionLabel;

  const _SuggestionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.tag,
    required this.tagColor,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF022A72)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTextStyles.titleSmall.copyWith(
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: tagColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: tagColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: const Color(0xFF64748B), height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {},
            child: Text(
              '$actionLabel →',
              style: AppTextStyles.labelSmall.copyWith(
                color: const Color(0xFF022A72),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

