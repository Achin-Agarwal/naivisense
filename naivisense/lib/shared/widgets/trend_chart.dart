import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TrendChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final String title;
  final Color? lineColor;

  const TrendChart({
    super.key,
    required this.values,
    required this.labels,
    required this.title,
    this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final textScale = mediaQuery.textScaler.scale(1.0);
    final color = lineColor ?? AppColors.primaryBlue;
    final spots = List.generate(
      values.length,
      (i) => FlSpot(i.toDouble(), values[i]),
    );
    final spacing = (screenWidth * 0.04).clamp(12.0, 16.0);
    final chartHeight = (screenWidth * 0.45).clamp(160.0, 220.0);
    final barWidth = (screenWidth * 0.0065).clamp(2.0, 2.5);
    final labelReservedSize = (screenWidth * 0.1 * textScale).clamp(20.0, 36.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: spacing),
        LayoutBuilder(
          builder: (context, constraints) {
            final effectiveWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : screenWidth;
            final labelSlotWidth = labels.isEmpty
                ? effectiveWidth
                : (effectiveWidth / labels.length);

            return SizedBox(
              height: chartHeight,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: labelReservedSize,
                        getTitlesWidget: (v, meta) {
                          final i = v.toInt();
                          if (i < 0 || i >= labels.length)
                            return const SizedBox.shrink();
                          return Padding(
                            padding: EdgeInsets.only(top: spacing * 0.25),
                            child: SizedBox(
                              width: labelSlotWidth,
                              child: Text(
                                labels[i],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: barWidth,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
