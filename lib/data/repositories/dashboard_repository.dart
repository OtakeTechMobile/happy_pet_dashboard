import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/dashboard_metrics.dart';
import 'base_repository.dart';

class DashboardRepository extends BaseRepository {
  /// Fetch metrics for the platform administrator
  Future<AdminDashboardMetrics> getAdminMetrics() async {
    // 1. Hotel counts
    final activeHotelsCount = await _safeCount('hotels', (q) => q.eq('is_active', true));
    final inactiveHotelsCount = await _safeCount('hotels', (q) => q.eq('is_active', false));

    // 2. Total pets
    final petsCount = await _safeCount('pets', (q) => q.eq('is_active', true));

    // 3. Global revenue
    double totalRevenue = 0.0;
    try {
      final revenueRes = await from('invoices').select('total_amount').eq('status', 'paid');
      totalRevenue = (revenueRes as List).fold<double>(0.0, (sum, item) => sum + (item['total_amount'] ?? 0.0));
    } catch (e) {
      // Log error but don't fail the whole dashboard
    }

    // 4. Hotel growth (Simplified for mockup purposes)
    final hotelGrowth = [
      const ChartDataPoint(label: 'Jan', value: 5),
      const ChartDataPoint(label: 'Fev', value: 8),
      const ChartDataPoint(label: 'Mar', value: 12),
      const ChartDataPoint(label: 'Abr', value: 15),
    ];

    return AdminDashboardMetrics(
      activeHotels: activeHotelsCount,
      inactiveHotels: inactiveHotelsCount,
      hotelGrowth: hotelGrowth,
      totalPets: petsCount,
      totalRevenue: totalRevenue,
      hotelDistribution: {'Pequeno': 40, 'Médio': 35, 'Grande': 25},
    );
  }

  /// Fetch metrics for a specific hotel owner/staff
  Future<OwnerDashboardMetrics> getOwnerMetrics(String hotelId) async {
    // 1. Occupation & Capacity
    int capacity = 0;
    try {
      final hotelRes = await from('hotels').select('capacity').eq('id', hotelId).maybeSingle();
      capacity = hotelRes?['capacity'] as int? ?? 0;
    } catch (e) {
      // Ignore
    }
    
    final occupation = await _safeCount('stays', (q) => q.eq('hotel_id', hotelId).eq('status', 'checked_in'));

    // 2. Expiring Vaccinations
    int expiredCount = 0;
    try {
      final petsRes = await from('pets').select('vaccinations').eq('hotel_id', hotelId).eq('is_active', true);
      final now = DateTime.now();
      for (final pet in petsRes as List) {
        final vaccinations = pet['vaccinations'] as List?;
        if (vaccinations != null) {
          final hasExpired = vaccinations.any((v) {
            final date = DateTime.tryParse(v['date'] ?? '');
            return date != null && now.difference(date).inDays > 365;
          });
          if (hasExpired) expiredCount++;
        }
      }
    } catch (e) {
      // Ignore
    }

    // 3. Peak Hours (Simplified mockup for UAU effect)
    final peakHours = [
      const ChartDataPoint(label: '08h', value: 12),
      const ChartDataPoint(label: '09h', value: 15),
      const ChartDataPoint(label: '10h', value: 8),
      const ChartDataPoint(label: '17h', value: 10),
      const ChartDataPoint(label: '18h', value: 18),
      const ChartDataPoint(label: '19h', value: 6),
    ];

    // 4. Monthly Revenue
    double monthlyRevenue = 0.0;
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final revenueRes = await from('invoices')
          .select('total_amount')
          .eq('hotel_id', hotelId)
          .eq('status', 'paid')
          .gte('issue_date', startOfMonth.toIso8601String());
      monthlyRevenue = (revenueRes as List).fold<double>(0.0, (sum, item) => sum + (item['total_amount'] ?? 0.0));
    } catch (e) {
      // Ignore
    }

    return OwnerDashboardMetrics(
      occupation: occupation,
      capacity: capacity,
      bookingTrends: [
        const ChartDataPoint(label: 'Seg', value: 10),
        const ChartDataPoint(label: 'Ter', value: 12),
        const ChartDataPoint(label: 'Qua', value: 8),
        const ChartDataPoint(label: 'Qui', value: 15),
        const ChartDataPoint(label: 'Sex', value: 20),
      ],
      petTypes: [
        const ChartDataPoint(label: 'Cachorro', value: 70),
        const ChartDataPoint(label: 'Gato', value: 25),
        const ChartDataPoint(label: 'Outro', value: 5),
      ],
      expiringVaccinations: expiredCount,
      upcomingCheckouts: 3, // Mockup
      monthlyRevenue: monthlyRevenue,
      peakHours: peakHours,
    );
  }

  /// Helper to safely count rows from a table, returning 0 on error
  Future<int> _safeCount(String table, Function(dynamic) queryBuilder) async {
    try {
      final res = await queryBuilder(from(table).select('id')).count(CountOption.exact);
      return res.count;
    } catch (e) {
      return 0;
    }
  }
}
