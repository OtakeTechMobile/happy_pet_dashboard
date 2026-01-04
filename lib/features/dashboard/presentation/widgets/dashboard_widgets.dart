import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../domain/models/dashboard_metrics.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final Widget chart;
  final double width;

  const MetricCard({
    super.key,
    required this.title,
    required this.chart,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 300,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              Expanded(child: chart),
            ],
          ),
        ),
      ),
    );
  }
}

class LineMetricChart extends StatelessWidget {
  final List<ChartDataPoint> data;
  final Color? color;

  const LineMetricChart({super.key, required this.data, this.color});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('Sem dados'));

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
            isCurved: true,
            color: color ?? Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true, 
              color: (color ?? Theme.of(context).colorScheme.primary).withValues(alpha: 0.1)
            ),
          ),
        ],
      ),
    );
  }
}

class BarMetricChart extends StatelessWidget {
  final List<ChartDataPoint> data;
  final Color? color;

  const BarMetricChart({super.key, required this.data, this.color});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('Sem dados'));

    return BarChart(
      BarChartData(
        barGroups: data.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [BarChartRodData(toY: e.value.value, color: color ?? Theme.of(context).colorScheme.secondary)],
          );
        }).toList(),
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class PieMetricChart extends StatelessWidget {
  final List<ChartDataPoint> data;

  const PieMetricChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('Sem dados'));

    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
      Colors.orange,
      Colors.teal,
    ];

    return PieChart(
      PieChartData(
        sections: data.asMap().entries.map((e) {
          return PieChartSectionData(
            color: colors[e.key % colors.length],
            value: e.value.value,
            title: e.value.label,
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodySmall),
                Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
