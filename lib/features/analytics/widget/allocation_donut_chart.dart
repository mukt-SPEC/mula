import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mula/features/finance/model/budget.dart';
import 'package:mula/features/finance/model/category_model.dart';
import 'package:mula/shared/theme/text_styles.dart';
import 'package:intl/intl.dart';

class AllocationDonutChart extends StatefulWidget {
  final List<BudgetModel> budgets;
  final List<CategoryModel> categories;
  final double totalAllocated;

  const AllocationDonutChart({
    super.key,
    required this.budgets,
    required this.categories,
    required this.totalAllocated,
  });

  @override
  State<AllocationDonutChart> createState() => _AllocationDonutChartState();
}

class _AllocationDonutChartState extends State<AllocationDonutChart> {
  int _touchedIndex = -1;

  // Palette for slices
  static const _palette = [
    Color(0xFF022A72),
    Color(0xFF2563EB),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
  ];

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    // Build (category, budget, color) map
    final slices = <({CategoryModel cat, BudgetModel budget, Color color})>[];
    for (int i = 0; i < widget.budgets.length; i++) {
      final b = widget.budgets[i];
      final cat = widget.categories.firstWhere(
        (c) => c.id == b.categoryid,
        orElse: () => CategoryModel(id: b.categoryid, name: 'Other'),
      );
      slices.add((cat: cat, budget: b, color: _palette[i % _palette.length]));
    }

    if (slices.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: Text(
          'No budget allocations yet',
          style:
              AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF94A3B8)),
        ),
      );
    }

    return Column(
      children: [
        // Donut + total
        SizedBox(
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 55,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        _touchedIndex =
                            response?.touchedSection?.touchedSectionIndex ??
                                -1;
                      });
                    },
                  ),
                  sections: List.generate(slices.length, (i) {
                    final s = slices[i];
                    final isTouched = i == _touchedIndex;
                    final pct = widget.totalAllocated > 0
                        ? (s.budget.allocatedAmount / widget.totalAllocated) *
                            100
                        : 0.0;
                    return PieChartSectionData(
                      color: s.color,
                      value: s.budget.allocatedAmount,
                      title: '${pct.toStringAsFixed(0)}%',
                      radius: isTouched ? 44 : 36,
                      titleStyle: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      showTitle: isTouched,
                    );
                  }),
                ),
              ),
              // Center label
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TOTAL',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    format.format(widget.totalAllocated),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Legend
        ...slices.map((s) {
          final pct = widget.totalAllocated > 0
              ? (s.budget.allocatedAmount / widget.totalAllocated * 100)
                  .toStringAsFixed(0)
              : '0';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: s.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.cat.name,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: const Color(0xFF475569)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$pct%',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
