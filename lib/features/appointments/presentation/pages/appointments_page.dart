import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/pet_repository.dart';
import '../../../../data/repositories/routine_repository.dart';
import '../../../../data/repositories/tutor_repository.dart';
import '../../../../domain/enums/app_enums.dart'; // Needed for RoutineType/Status
import '../../../../domain/models/pet_model.dart';
import '../../../../domain/models/routine_model.dart';
import '../cubit/appointments_cubit.dart';
import '../cubit/appointments_state.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppointmentsCubit(
        routineRepository: RoutineRepository(),
        petRepository: PetRepository(),
        tutorRepository: TutorRepository(),
      )..loadAppointments(),
      child: const AppointmentsView(),
    );
  }
}

class AppointmentsView extends StatelessWidget {
  const AppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) =>
                BlocProvider.value(value: context.read<AppointmentsCubit>(), child: const EditAppointmentDialog()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<AppointmentsCubit, AppointmentsState>(
        builder: (context, state) {
          if (state is AppointmentsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AppointmentsError) {
            return Center(child: Text(state.message));
          } else if (state is AppointmentsLoaded) {
            final appointments = state.appointments;
            if (appointments.isEmpty) {
              return const Center(child: Text('No appointments found'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final vm = appointments[index];
                final time = vm.routine.scheduledTime;
                final isCompleted = vm.routine.status == RoutineStatus.completed;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    title: Text('${vm.routine.title} - ${vm.petName}'),
                    subtitle: Text('Client: ${vm.clientName}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            vm.routine.status.displayName,
                            style: TextStyle(
                              color: isCompleted ? Colors.green : Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => BlocProvider.value(
                                value: context.read<AppointmentsCubit>(),
                                child: EditAppointmentDialog(routine: vm.routine),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class EditAppointmentDialog extends StatefulWidget {
  final RoutineModel? routine;

  const EditAppointmentDialog({super.key, this.routine});

  @override
  State<EditAppointmentDialog> createState() => _EditAppointmentDialogState();
}

class _EditAppointmentDialogState extends State<EditAppointmentDialog> {
  late TextEditingController _titleController;
  late TextEditingController _timeController;
  String? _selectedPetId;
  late RoutineStatus _status;
  List<PetModel> _pets = [];
  bool _isLoadingPets = false;
  // ignore: unused_field
  final RoutineType _type = RoutineType.other;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.routine?.title ?? '');
    _timeController = TextEditingController(text: widget.routine?.scheduledTime ?? '09:00');
    _selectedPetId = widget.routine?.petId;
    _status = widget.routine?.status ?? RoutineStatus.scheduled;

    if (widget.routine == null) {
      _loadPets();
    }
  }

  Future<void> _loadPets() async {
    setState(() => _isLoadingPets = true);
    try {
      final repo = PetRepository();
      final pets = await repo.getAll(limit: 100);
      setState(() {
        _pets = pets.where((p) => p.id.isNotEmpty).toList();
        if (_pets.isNotEmpty && _selectedPetId == null) {
          _selectedPetId = _pets.first.id;
        }
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoadingPets = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.routine == null ? 'New Appointment' : 'Edit Appointment'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(labelText: 'Time (HH:mm)'),
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (picked != null) {
                  // ignore: use_build_context_synchronously
                  // final localizations = MaterialLocalizations.of(context);
                  final formatted =
                      '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                  _timeController.text = formatted;
                }
              },
            ),
            const SizedBox(height: 16),
            if (widget.routine == null) ...[
              if (_isLoadingPets)
                const CircularProgressIndicator()
              else if (_pets.isEmpty)
                const Text('No pets found. Create a pet first.')
              else
                DropdownButtonFormField<String>(
                  initialValue: _selectedPetId,
                  decoration: const InputDecoration(labelText: 'Pet'),
                  items: _pets.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                  onChanged: (val) => setState(() => _selectedPetId = val),
                ),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<RoutineStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: RoutineStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.displayName))).toList(),
              onChanged: (val) => setState(() => _status = val!),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.routine != null)
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: const Text('Delete this appointment?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        context.read<AppointmentsCubit>().deleteAppointment(widget.routine!.id);
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_titleController.text.isEmpty) return;
            if (widget.routine == null && _selectedPetId == null) return;

            if (widget.routine != null) {
              final updated = widget.routine!.copyWith(
                title: _titleController.text,
                scheduledTime: _timeController.text,
                status: _status,
              );
              context.read<AppointmentsCubit>().updateAppointment(updated);
            } else {
              final newRoutine = RoutineModel(
                id: '',
                petId: _selectedPetId!,
                stayId: '',
                type: _type,
                title: _titleController.text,
                scheduledTime: _timeController.text,
                date: DateTime.now(),
                status: _status,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              context.read<AppointmentsCubit>().createAppointment(newRoutine);
            }
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
