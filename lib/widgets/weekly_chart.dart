import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// A bar chart widget displaying weekly calories vs daily goal.
class WeeklyCaloriesChart extends StatelessWidget {

  final List<double> dailyCalories;
  final double dailyGoal;
  const WeeklyCaloriesChart({
    Key? key,
    required this.dailyCalories,
    required this.dailyGoal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: dailyGoal,
        minY: 0,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: dailyGoal / 4,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: theme.textTheme.labelSmall?.copyWith(fontSize: 8),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['M','T','W','T','F','S','S'];
                return Text(days[value.toInt()], style: theme.textTheme.bodySmall);
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: List.generate(7, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: dailyCalories[i],
                color: theme.colorScheme.primary,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }
}
