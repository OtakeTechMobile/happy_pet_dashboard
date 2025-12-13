import 'package:equatable/equatable.dart';

import '../../../../domain/models/hotel_model.dart';

class HotelState extends Equatable {
  final bool isLoading;
  final HotelModel? hotel;
  final String? error;

  const HotelState({this.isLoading = false, this.hotel, this.error});

  HotelState copyWith({bool? isLoading, HotelModel? hotel, String? error}) {
    return HotelState(isLoading: isLoading ?? this.isLoading, hotel: hotel ?? this.hotel, error: error);
  }

  @override
  List<Object?> get props => [isLoading, hotel, error];
}
