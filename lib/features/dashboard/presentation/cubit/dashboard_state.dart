part of 'dashboard_cubit.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final AdminDashboardMetrics? adminMetrics;
  final OwnerDashboardMetrics? ownerMetrics;

  const DashboardLoaded({this.adminMetrics, this.ownerMetrics});

  @override
  List<Object?> get props => [adminMetrics, ownerMetrics];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}
