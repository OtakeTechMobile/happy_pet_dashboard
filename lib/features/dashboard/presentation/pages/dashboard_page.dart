import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/dashboard_cubit.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => DashboardCubit()..loadDashboardData(), child: const DashboardView());
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overview', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    // Responsive grid: 1 column on mobile, 2 on tablet, 3 on desktop
                    int crossAxisCount = 1;
                    if (width > 600) crossAxisCount = 2;
                    if (width > 1100) crossAxisCount = 3;

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildChartCard(
                          context,
                          'Revenue Trend',
                          const _LineChartSample(),
                          width: (width - (crossAxisCount - 1) * 16) / crossAxisCount,
                        ),
                        _buildChartCard(
                          context,
                          'Appointments',
                          const _BarChartSample(),
                          width: (width - (crossAxisCount - 1) * 16) / crossAxisCount,
                        ),
                        _buildChartCard(
                          context,
                          'Pet Types',
                          const _PieChartSample(),
                          width: (width - (crossAxisCount - 1) * 16) / crossAxisCount,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartCard(BuildContext context, String title, Widget chart, {required double width}) {
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

class _LineChartSample extends StatelessWidget {
  const _LineChartSample();

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3),
              FlSpot(2.6, 2),
              FlSpot(4.9, 5),
              FlSpot(6.8, 3.1),
              FlSpot(8, 4),
              FlSpot(9.5, 3),
              FlSpot(11, 4),
            ],
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }
}

class _BarChartSample extends StatelessWidget {
  const _BarChartSample();

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: Theme.of(context).colorScheme.secondary)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: Theme.of(context).colorScheme.secondary)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: Theme.of(context).colorScheme.secondary)]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: Theme.of(context).colorScheme.secondary)]),
          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 13, color: Theme.of(context).colorScheme.secondary)]),
        ],
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _PieChartSample extends StatelessWidget {
  const _PieChartSample();

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: Theme.of(context).colorScheme.primary,
            value: 40,
            title: '40%',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            color: Theme.of(context).colorScheme.secondary,
            value: 30,
            title: '30%',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            color: Theme.of(context).colorScheme.tertiary,
            value: 15,
            title: '15%',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            color: Colors.grey,
            value: 15,
            title: '15%',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
        sectionsSpace: 0,
        centerSpaceRadius: 40,
      ),
    );
  }
}
