import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mula/shared/theme/text_styles.dart';

class SpendingVelocityChart extends StatelessWidget {
  final List<double> weeklySpending;
  final double velocityPercent; 
  final double budgetRemaining;

  const SpendingVelocityChart({
    super.key,
    required this.weeklySpending,
    required this.velocityPercent,
    required this.budgetRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = weeklySpending.fold(0.0, (m, v) => v > m ? v : m);
    final chartMax = maxY > 0 ? maxY * 1.25 : 100.0;
    final isDown = velocityPercent <= 0;
    final pctLabel =
        '${isDown ? '↓' : '↑'} ${velocityPercent.abs().toStringAsFixed(1)}%';

    return Container(
      padding: const EdgeInsets.all(24),
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
                'Spending Velocity',
                style: AppTextStyles.titleMedium
                    .copyWith(color: const Color(0xFF0F172A)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (isDown
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444))
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isDown
                          ? Icons.trending_down_rounded
                          : Icons.trending_up_rounded,
                      size: 14,
                      color: isDown
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      pctLabel,
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
            style: AppTextStyles.bodySmall
                .copyWith(color: const Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 28),

          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: chartMax,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '\$${rod.toY.toStringAsFixed(0)}',
                        AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
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
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (i) {
                  final value = i < weeklySpending.length
                      ? weeklySpending[i]
                      : 0.0;
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
                        borderRadius: BorderRadius.circular(5),
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

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  '\$${budgetRemaining.toStringAsFixed(2)}',
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
}

