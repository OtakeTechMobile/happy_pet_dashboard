import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardInitial());

  void loadDashboardData() async {
    emit(DashboardLoading());
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    emit(DashboardLoaded());
  }
}
