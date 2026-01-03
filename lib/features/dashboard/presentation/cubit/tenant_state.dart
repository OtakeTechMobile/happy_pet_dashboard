import 'package:equatable/equatable.dart';

import '../../../../domain/enums/app_enums.dart';
import '../../../../domain/models/hotel_model.dart';

enum TenantStatus { initial, loading, loaded, error }

class TenantState extends Equatable {
  final TenantStatus status;
  final HotelModel? currentHotel;
  final UserRole userRole;
  final String? error;

  const TenantState({
    this.status = TenantStatus.initial,
    this.currentHotel,
    this.userRole = UserRole.staff,
    this.error,
  });

  bool get isAdmin => userRole == UserRole.admin || userRole == UserRole.owner;
  bool get isOwner => userRole == UserRole.owner;

  TenantState copyWith({TenantStatus? status, HotelModel? currentHotel, UserRole? userRole, String? error}) {
    return TenantState(
      status: status ?? this.status,
      currentHotel: currentHotel ?? this.currentHotel,
      userRole: userRole ?? this.userRole,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, currentHotel, userRole, error];
}
