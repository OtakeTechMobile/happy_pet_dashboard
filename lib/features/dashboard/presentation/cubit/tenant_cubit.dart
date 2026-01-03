import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/hotel_repository.dart';
import '../../../../domain/enums/app_enums.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import 'tenant_state.dart';

class TenantCubit extends Cubit<TenantState> {
  final HotelRepository _hotelRepository;
  final AuthCubit _authCubit;
  StreamSubscription? _authSubscription;

  TenantCubit(this._hotelRepository, this._authCubit) : super(const TenantState()) {
    _init();
  }

  void _init() {
    // React to auth changes
    _authSubscription = _authCubit.stream.listen((authState) {
      if (authState.userProfile != null) {
        _loadTenantData(authState.userProfile!.hotelId, authState.userProfile!.role);
      } else {
        emit(const TenantState()); // Reset on logout
      }
    });

    // Initial load if already authenticated
    if (_authCubit.state.userProfile != null) {
      _loadTenantData(_authCubit.state.userProfile!.hotelId, _authCubit.state.userProfile!.role);
    }
  }

  Future<void> _loadTenantData(String? hotelId, UserRole role) async {
    if (hotelId == null || hotelId.isEmpty) {
      emit(state.copyWith(status: TenantStatus.loaded, userRole: role));
      return;
    }

    emit(state.copyWith(status: TenantStatus.loading));
    try {
      final hotel = await _hotelRepository.getById(hotelId);
      emit(state.copyWith(status: TenantStatus.loaded, currentHotel: hotel, userRole: role));
    } catch (e) {
      emit(state.copyWith(status: TenantStatus.error, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
