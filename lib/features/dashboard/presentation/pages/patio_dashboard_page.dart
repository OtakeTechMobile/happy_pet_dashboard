import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/daily_log_repository.dart';
import '../../../../data/repositories/pet_repository.dart';
import '../../../../domain/models/daily_log_model.dart';
import '../../../../domain/models/pet_model.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/patio_cubit.dart';
import '../cubit/patio_state.dart';
import '../cubit/tenant_cubit.dart';

class PatioDashboardPage extends StatelessWidget {
  const PatioDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final hotelId = context.read<TenantCubit>().state.currentHotel?.id ?? '';
        return PatioCubit(PetRepository(), DailyLogRepository(), hotelId)..loadPatioData();
      },
      child: const PatioDashboardView(),
    );
  }
}

class PatioDashboardView extends StatelessWidget {
  const PatioDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final hotelId = context.read<TenantCubit>().state.currentHotel?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Pátio'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => context.read<PatioCubit>().loadPatioData()),
        ],
      ),
      body: BlocBuilder<PatioCubit, PatioState>(
        builder: (context, state) {
          if (state is PatioLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PatioError) {
            return Center(child: Text('Erro: ${state.message}'));
          }
          if (state is PatioLoaded) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: state.activePets.length,
              itemBuilder: (context, index) {
                final pet = state.activePets[index];
                return _PetActionCard(pet: pet, hotelId: hotelId);
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _PetActionCard extends StatelessWidget {
  final PetModel pet;
  final String hotelId;

  const _PetActionCard({required this.pet, required this.hotelId});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showLogOptions(context),
        child: Column(
          children: [
            Expanded(
              child: pet.photoUrl != null && pet.photoUrl!.isNotEmpty
                  ? Image.network(pet.photoUrl!, fit: BoxFit.cover, width: double.infinity)
                  : Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(Icons.pets, size: 48, color: Theme.of(context).colorScheme.primary),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  if (pet.dietRestrictions != null && pet.dietRestrictions!.isNotEmpty)
                    const Icon(Icons.warning, color: Colors.orange, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogOptions(BuildContext context) {
    final patioCubit = context.read<PatioCubit>();
    final authCubit = context.read<AuthCubit>();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: patioCubit),
            BlocProvider.value(value: authCubit),
          ],
          child: Builder(
            builder: (innerContext) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.restaurant, color: Colors.green),
                      title: const Text('Registrar Alimentação'),
                      onTap: () => _addQuickLog(innerContext, LogType.feeding, 'Alimentação'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.directions_run, color: Colors.blue),
                      title: const Text('Registrar Atividade'),
                      onTap: () => _addQuickLog(innerContext, LogType.activity, 'Atividade Física'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.report_problem, color: Colors.red),
                      title: const Text('Registrar Incidente'),
                      onTap: () => _addQuickLog(innerContext, LogType.incident, 'Incidente'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.note, color: Colors.grey),
                      title: const Text('Nota Geral'),
                      onTap: () => _addQuickLog(innerContext, LogType.notes, 'Observação'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _addQuickLog(BuildContext context, LogType type, String title) {
    final userId = context.read<AuthCubit>().state.userProfile?.id ?? '';
    final log = DailyLogModel(
      id: '',
      petId: pet.id,
      hotelId: hotelId,
      type: type,
      title: title,
      createdBy: userId,
      createdAt: DateTime.now(),
    );

    context.read<PatioCubit>().addLog(log);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registro de $title para ${pet.name} salvo!')));
  }
}
