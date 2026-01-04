import 'package:equatable/equatable.dart';

class ChartDataPoint extends Equatable {
  final String label;
  final double value;

  const ChartDataPoint({required this.label, required this.value});

  @override
  List<Object?> get props => [label, value];
}

class AdminDashboardMetrics extends Equatable {
  final int activeHotels;
  final int inactiveHotels;
  final List<ChartDataPoint> hotelGrowth;
  final int totalPets;
  final double totalRevenue;
  final Map<String, double> hotelDistribution; // e.g., {'Small': 30, 'Medium': 50, ...}

  const AdminDashboardMetrics({
    required this.activeHotels,
    required this.inactiveHotels,
    required this.hotelGrowth,
    required this.totalPets,
    required this.totalRevenue,
    required this.hotelDistribution,
  });

  @override
  List<Object?> get props => [
    activeHotels,
    inactiveHotels,
    hotelGrowth,
    totalPets,
    totalRevenue,
    hotelDistribution,
  ];
}

class OwnerDashboardMetrics extends Equatable {
  final int occupation;
  final int capacity;
  final List<ChartDataPoint> bookingTrends;
  final List<ChartDataPoint> petTypes;
  final int expiringVaccinations;
  final int upcomingCheckouts;
  final double monthlyRevenue;
  final List<ChartDataPoint> peakHours; // Hours of entry/exit

  const OwnerDashboardMetrics({
    required this.occupation,
    required this.capacity,
    required this.bookingTrends,
    required this.petTypes,
    required this.expiringVaccinations,
    required this.upcomingCheckouts,
    required this.monthlyRevenue,
    required this.peakHours,
  });

  double get occupationRate => capacity > 0 ? (occupation / capacity) * 100 : 0.0;

  @override
  List<Object?> get props => [
    occupation,
    capacity,
    bookingTrends,
    petTypes,
    expiringVaccinations,
    upcomingCheckouts,
    monthlyRevenue,
    peakHours,
  ];
}
