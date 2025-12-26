import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../data/repositories/pet_repository.dart';
import '../../../../data/repositories/routine_repository.dart';
import '../../../../data/repositories/tutor_repository.dart';
import '../../../../domain/enums/app_enums.dart'; // Needed for RoutineType/Status
import '../../../../domain/models/pet_model.dart';
import '../../../../domain/models/routine_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/responsive_helper.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appointments)),
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
              return Center(child: Text(l10n.noAppointmentsFound));
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
                    subtitle: Text(l10n.clientLabel(vm.clientName)),
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
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _notesController;

  String? _selectedPetId;
  late RoutineStatus _status;
  late RoutineType _type;

  List<PetModel> _pets = [];
  bool _isLoadingPets = false;

  @override
  void initState() {
    super.initState();
    final routine = widget.routine;

    _titleController = TextEditingController(text: routine?.title ?? '');
    _descriptionController = TextEditingController(text: routine?.description ?? '');
    _dateController = TextEditingController(
      text: routine?.date != null
          ? DateFormat('dd/MM/yyyy').format(routine!.date)
          : DateFormat('dd/MM/yyyy').format(DateTime.now()),
    );
    _timeController = TextEditingController(text: routine?.scheduledTime ?? '09:00');
    _notesController = TextEditingController(text: routine?.notes ?? '');

    _selectedPetId = routine?.petId;
    _status = routine?.status ?? RoutineStatus.scheduled;
    _type = routine?.type ?? RoutineType.other;

    if (routine == null) {
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
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.routine != null;
    final l10n = AppLocalizations.of(context)!;
    final title = isEditing ? l10n.editAppointment : l10n.newAppointment;

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.55,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isEditing) ...[
                    if (_isLoadingPets)
                      const CircularProgressIndicator()
                    else if (_pets.isEmpty)
                      Text(l10n.noPetsFoundCreateFirst)
                    else
                      DropdownButtonFormField<String>(
                        initialValue: _selectedPetId,
                        decoration: InputDecoration(labelText: l10n.petRequired),
                        items: _pets.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                        onChanged: (val) => setState(() => _selectedPetId = val),
                        validator: (val) => val == null ? l10n.selectPet : null,
                      ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: l10n.titleRequired),
                    validator: (v) => v!.isEmpty ? l10n.requiredField : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: l10n.description),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  ResponsiveFormFieldRow(
                    children: [
                      DropdownButtonFormField<RoutineType>(
                        initialValue: _type,
                        decoration: InputDecoration(labelText: l10n.type),
                        items: RoutineType.values
                            .map((t) => DropdownMenuItem(value: t, child: Text(t.displayName)))
                            .toList(),
                        onChanged: (val) => setState(() => _type = val!),
                      ),
                      DropdownButtonFormField<RoutineStatus>(
                        initialValue: _status,
                        decoration: InputDecoration(labelText: l10n.status),
                        items: RoutineStatus.values
                            .map((s) => DropdownMenuItem(value: s, child: Text(s.displayName)))
                            .toList(),
                        onChanged: (val) => setState(() => _status = val!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ResponsiveFormFieldRow(
                    children: [
                      TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(labelText: l10n.datePlaceholder),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, DataInputFormatter()],
                      ),
                      TextFormField(
                        controller: _timeController,
                        decoration: InputDecoration(labelText: l10n.timePlaceholder),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, HoraInputFormatter()],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(labelText: l10n.internalNotes),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        if (isEditing)
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.confirmDelete),
                  content: Text(l10n.confirmDeleteAppointmentMessage),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
                    TextButton(
                      onPressed: () {
                        context.read<AppointmentsCubit>().deleteAppointment(widget.routine!.id);
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Parse Date
              DateTime date = DateTime.now();
              if (_dateController.text.isNotEmpty) {
                try {
                  date = DateFormat('dd/MM/yyyy').parse(_dateController.text);
                } catch (_) {}
              }

              if (widget.routine != null) {
                final updated = widget.routine!.copyWith(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  scheduledTime: _timeController.text,
                  date: date,
                  status: _status,
                  type: _type,
                  notes: _notesController.text,
                );
                context.read<AppointmentsCubit>().updateAppointment(updated);
              } else {
                final newRoutine = RoutineModel(
                  id: '',
                  petId: _selectedPetId!,
                  stayId: '', // Optional or handle later
                  type: _type,
                  title: _titleController.text,
                  description: _descriptionController.text,
                  scheduledTime: _timeController.text,
                  date: date,
                  status: _status,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  notes: _notesController.text,
                );
                context.read<AppointmentsCubit>().createAppointment(newRoutine);
              }
              Navigator.pop(context);
            }
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
