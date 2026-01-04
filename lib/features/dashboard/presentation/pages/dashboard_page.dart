import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../data/repositories/dashboard_repository.dart';
import '../../../../domain/enums/app_enums.dart';
import '../../../../domain/models/dashboard_metrics.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/tenant_cubit.dart';
import '../widgets/dashboard_widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tenantState = context.watch<TenantCubit>().state;
    final role = tenantState.userRole;
    final hotelId = tenantState.currentHotel?.id;

    return BlocProvider(
      create: (context) => DashboardCubit(DashboardRepository())
        ..loadDashboardData(role: role, hotelId: hotelId),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final tenantState = context.read<TenantCubit>().state;
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Scaffold(
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }

          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardCubit>().loadDashboardData(
                      role: tenantState.userRole,
                      hotelId: tenantState.currentHotel?.id,
                    );
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tenantState.userRole == UserRole.admin 
                        ? 'Saúde da Rede' 
                        : 'Dashboard Operacional - ${tenantState.currentHotel?.name ?? ""}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    if (tenantState.userRole == UserRole.admin)
                      _AdminDashboardBody(metrics: state.adminMetrics!, currencyFormat: currencyFormat)
                    else
                      _OwnerDashboardBody(metrics: state.ownerMetrics!, currencyFormat: currencyFormat),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _AdminDashboardBody extends StatelessWidget {
  final dynamic metrics; // AdminDashboardMetrics
  final NumberFormat currencyFormat;

  const _AdminDashboardBody({required this.metrics, required this.currencyFormat});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SummaryCard(
                  title: 'Hotéis Ativos',
                  value: metrics.activeHotels.toString(),
                  icon: Icons.hotel,
                  color: Colors.green,
                ),
                SummaryCard(
                  title: 'Pets na Rede',
                  value: metrics.totalPets.toString(),
                  icon: Icons.pets,
                  color: Colors.blue,
                ),
                SummaryCard(
                  title: 'Faturamento Total',
                  value: currencyFormat.format(metrics.totalRevenue),
                  icon: Icons.payments,
                  color: Colors.purple,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final chartWidth = (constraints.maxWidth - 16) / (constraints.maxWidth > 1100 ? 2 : 1);
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                MetricCard(
                  title: 'Crescimento de Hotéis',
                  chart: LineMetricChart(data: metrics.hotelGrowth),
                  width: chartWidth,
                ),
                MetricCard(
                  title: 'Distribuição de Porte',
                  chart: PieMetricChart(
                    data: (metrics.hotelDistribution as Map<String, double>)
                        .entries
                        .map((e) => ChartDataPoint(label: e.key, value: e.value))
                        .toList(),
                  ),
                  width: chartWidth,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _OwnerDashboardBody extends StatelessWidget {
  final dynamic metrics; // OwnerDashboardMetrics
  final NumberFormat currencyFormat;

  const _OwnerDashboardBody({required this.metrics, required this.currencyFormat});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SummaryCard(
                  title: 'Ocupação',
                  value: '${metrics.occupation} / ${metrics.capacity}',
                  icon: Icons.pie_chart,
                  color: metrics.occupationRate > 80 ? Colors.orange : Colors.green,
                ),
                SummaryCard(
                  title: 'Check-outs em breve',
                  value: metrics.upcomingCheckouts.toString(),
                  icon: Icons.exit_to_app,
                  color: Colors.blue,
                ),
                SummaryCard(
                  title: 'Vacinas Vencendo',
                  value: metrics.expiringVaccinations.toString(),
                  icon: Icons.vaccines,
                  color: Colors.red,
                ),
                SummaryCard(
                  title: 'Receita Mensal',
                  value: currencyFormat.format(metrics.monthlyRevenue),
                  icon: Icons.monetization_on,
                  color: Colors.teal,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final fullWidth = constraints.maxWidth;
            final halfWidth = (constraints.maxWidth - 16) / 2;
            final isDesktop = constraints.maxWidth > 1100;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                MetricCard(
                  title: 'Tendência de Entradas/Saídas (Horários de Pico)',
                  chart: BarMetricChart(data: metrics.peakHours, color: Colors.indigo),
                  width: isDesktop ? halfWidth : fullWidth,
                ),
                MetricCard(
                  title: 'Tipos de Pets',
                  chart: PieMetricChart(data: metrics.petTypes),
                  width: isDesktop ? halfWidth : fullWidth,
                ),
                MetricCard(
                  title: 'Agendamentos da Semana',
                  chart: LineMetricChart(data: metrics.bookingTrends, color: Colors.teal),
                  width: fullWidth,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
