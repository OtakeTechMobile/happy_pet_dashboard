import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/hotel_repository.dart';
import '../../../../domain/models/hotel_model.dart';
import '../cubit/hotel_owners_cubit.dart';
import '../widgets/register_hotel_dialog.dart';

class HotelOwnersPage extends StatelessWidget {
  const HotelOwnersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HotelOwnersCubit(HotelRepository(), AuthRepository())..loadHotels(),
      child: const HotelOwnersView(),
    );
  }
}

class HotelOwnersView extends StatelessWidget {
  const HotelOwnersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Creches'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => context.read<HotelOwnersCubit>().loadHotels()),
        ],
      ),
      body: BlocBuilder<HotelOwnersCubit, HotelOwnersState>(
        builder: (context, state) {
          if (state is HotelOwnersLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HotelOwnersError) {
            return Center(child: Text('Erro: ${state.message}'));
          }
          if (state is HotelOwnersLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.hotels.length,
              itemBuilder: (context, index) {
                final hotel = state.hotels[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.corporate_fare)),
                    title: Text(hotel.name),
                    subtitle: Text('Capacidade: ${hotel.capacity} | Limite Func.: ${hotel.maxStaff}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showRegisterDialog(context, hotel: hotel),
                    ),
                    onTap: () {
                      // Detailed view could be here
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRegisterDialog(context),
        label: const Text('Nova Creche'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showRegisterDialog(BuildContext context, {HotelModel? hotel}) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<HotelOwnersCubit>(),
        child: RegisterHotelDialog(hotel: hotel),
      ),
    );
  }
}
