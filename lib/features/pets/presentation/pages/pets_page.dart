import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/pet_repository.dart';
import '../../../../data/repositories/tutor_repository.dart';
import '../../../../domain/models/pet_model.dart';
import '../../../../domain/models/tutor_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/filter_bar.dart';
import '../../../../shared/widgets/pagination_controls.dart';
import '../cubit/pets_cubit.dart';
import '../cubit/pets_state.dart';

class PetsPage extends StatelessWidget {
  const PetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => PetsCubit(PetRepository())..loadPets(), child: const PetsView());
  }
}

class PetsView extends StatefulWidget {
  const PetsView({super.key});

  @override
  State<PetsView> createState() => _PetsViewState();
}

class _PetsViewState extends State<PetsView> {
  String _searchQuery = '';
  int _currentPage = 0;
  int _rowsPerPage = 10;
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pets)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => BlocProvider.value(
              value: context.read<PetsCubit>(),
              child: const EditPetDialog(), // Creation mode
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          FilterBar(
            hintText: '${l10n.search} ${l10n.pets}...',
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
                _currentPage = 0;
              });
              context.read<PetsCubit>().searchPets(value);
            },
          ),
          Expanded(
            child: BlocBuilder<PetsCubit, PetsState>(
              builder: (context, state) {
                if (state is PetsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PetsError) {
                  return Center(child: Text(state.message));
                } else if (state is PetsLoaded) {
                  final pets = state.pets;
                  if (pets.isEmpty) {
                    return const Center(child: Text('No pets found'));
                  }

                  final totalRows = pets.length;
                  final start = _currentPage * _rowsPerPage;
                  final end = (start + _rowsPerPage).clamp(0, totalRows);

                  if (start >= totalRows && totalRows > 0) {
                    return const Center(child: Text('Page out of bounds'));
                  }

                  final currentPets = totalRows > 0 ? pets.sublist(start, end) : [];

                  return ListView.separated(
                    itemCount: currentPets.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
                    itemBuilder: (context, index) {
                      final pet = currentPets[index];

                      return _buildPetRow(context, pet);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          BlocBuilder<PetsCubit, PetsState>(
            builder: (context, state) {
              if (state is PetsLoaded) {
                return PaginationControls(
                  currentPage: _currentPage,
                  rowsPerPage: _rowsPerPage,
                  totalRows: state.pets.length,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  onRowsPerPageChanged: (rows) => setState(() {
                    _rowsPerPage = rows;
                    _currentPage = 0;
                  }),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPetRow(BuildContext context, PetModel pet) {
    final isSelected = _selectedIds.contains(pet.id);
    final status = pet.hasExpiredVaccinations ? 'Checkup Due' : (pet.isActive ? 'Healthy' : 'Inactive');
    final isHealthy = status == 'Healthy';

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedIds.remove(pet.id);
          } else {
            _selectedIds.add(pet.id);
          }
        });
      },
      child: Container(
        color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedIds.add(pet.id);
                  } else {
                    _selectedIds.remove(pet.id);
                  }
                });
              },
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundImage: pet.photoUrl != null && pet.photoUrl!.isNotEmpty ? NetworkImage(pet.photoUrl!) : null,
              backgroundColor: Colors.grey.shade200,
              child: pet.photoUrl == null || pet.photoUrl!.isEmpty ? const Icon(Icons.pets) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              flex: 2,
              child: Text(
                pet.breed ?? 'Unknown Breed',
                style: TextStyle(color: Colors.grey.shade600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isHealthy ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isHealthy
                    ? (AppLocalizations.of(context)?.healthy ?? 'Healthy')
                    : (status == 'Checkup Due' ? (AppLocalizations.of(context)?.checkupDue ?? 'Checkup Due') : status),
                style: TextStyle(
                  color: isHealthy ? Colors.green : Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => BlocProvider.value(
                    value: context.read<PetsCubit>(),
                    child: EditPetDialog(pet: pet),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EditPetDialog extends StatefulWidget {
  final PetModel? pet;

  const EditPetDialog({super.key, this.pet});

  @override
  State<EditPetDialog> createState() => _EditPetDialogState();
}

class _EditPetDialogState extends State<EditPetDialog> {
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  String? _selectedTutorId;
  List<TutorModel> _tutors = [];
  bool _isLoadingTutors = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet?.name ?? '');
    _breedController = TextEditingController(text: widget.pet?.breed ?? '');
    _selectedTutorId = widget.pet?.tutorId;

    if (widget.pet == null) {
      _loadTutors();
    }
  }

  Future<void> _loadTutors() async {
    setState(() => _isLoadingTutors = true);
    try {
      final repo = TutorRepository();
      final tutors = await repo.getAll(limit: 100);
      setState(() {
        _tutors = tutors;
      });
    } catch (e) {
      // basic error handling
    } finally {
      setState(() => _isLoadingTutors = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.pet != null;

    return AlertDialog(
      title: Text(isEditing ? l10n.editPet : 'New Pet'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.name),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _breedController,
              decoration: const InputDecoration(labelText: 'Breed'),
            ),
            if (!isEditing) ...[
              const SizedBox(height: 16),
              if (_isLoadingTutors)
                const CircularProgressIndicator()
              else if (_tutors.isEmpty)
                const Text('No tutors found. Create a tutor first.')
              else
                DropdownButtonFormField<String>(
                  initialValue: _selectedTutorId,
                  decoration: const InputDecoration(labelText: 'Tutor'),
                  items: _tutors.map((t) {
                    return DropdownMenuItem(value: t.id, child: Text(t.fullName));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedTutorId = val;
                    });
                  },
                ),
            ],
          ],
        ),
      ),
      actions: [
        if (isEditing)
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: const Text('Are you sure you want to delete this pet?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        context.read<PetsCubit>().deletePet(widget.pet!.id);
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
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: () {
            // Validate
            if (_nameController.text.isEmpty) return;
            if (!isEditing && _selectedTutorId == null) return;

            if (isEditing) {
              final updated = widget.pet!.copyWith(name: _nameController.text, breed: _breedController.text);
              context.read<PetsCubit>().updatePet(updated);
            } else {
              final newPet = PetModel(
                id: '',
                tutorId: _selectedTutorId!,
                name: _nameController.text,
                species: 'Dog', // Hardcoded for now
                breed: _breedController.text,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              context.read<PetsCubit>().createPet(newPet);
            }
            Navigator.pop(context);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
