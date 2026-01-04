import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../data/repositories/dashboard_repository.dart';
import '../../../../domain/enums/app_enums.dart';
import '../../../../domain/models/dashboard_metrics.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repository;

  DashboardCubit(this._repository) : super(DashboardInitial());

  void loadDashboardData({required UserRole role, String? hotelId}) async {
    emit(DashboardLoading());
    try {
      if (role == UserRole.admin) {
        final metrics = await _repository.getAdminMetrics();
        emit(DashboardLoaded(adminMetrics: metrics));
      } else {
        if (hotelId == null) {
          emit(const DashboardError('ID do Hotel não encontrado para este perfil.'));
          return;
        }
        final metrics = await _repository.getOwnerMetrics(hotelId);
        emit(DashboardLoaded(ownerMetrics: metrics));
      }
    } catch (e) {
      log(e.toString());
      emit(DashboardError(e.toString()));
    }
  }
}
