import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../data/repositories/pet_repository.dart';
import '../../../../data/repositories/tutor_repository.dart';
import '../../../../domain/models/pet_model.dart';
import '../../../../domain/models/tutor_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/responsive_helper.dart';
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
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _birthDateController; // dd/mm/yyyy
  late TextEditingController _weightController;
  late TextEditingController _microchipController;
  late TextEditingController _colorController;
  late TextEditingController _medicalConditionsController;
  late TextEditingController _allergiesController;
  late TextEditingController _specialNeedsController;
  late TextEditingController _foodBrandController;
  late TextEditingController _foodAmountController;
  late TextEditingController _feedingTimesController;
  late TextEditingController _vetNameController;
  late TextEditingController _vetPhoneController;
  late TextEditingController _photoUrlController;

  String? _selectedSpecies;
  String? _selectedGender;
  String? _selectedTutorId;
  List<TutorModel> _tutors = [];
  bool _isLoadingTutors = false;

  final List<String> _speciesOptions = ['Cachorro', 'Gato', 'Ave', 'Outro'];
  final List<String> _genderOptions = ['Macho', 'Fêmea'];

  @override
  void initState() {
    super.initState();
    final pet = widget.pet;

    _selectedTutorId = pet?.tutorId;
    _selectedSpecies = pet?.species;
    if (_selectedSpecies == 'Dog') _selectedSpecies = 'Cachorro'; // Mapping legacy
    if (_selectedSpecies == 'Cat') _selectedSpecies = 'Gato';

    _selectedGender = pet?.gender;

    _nameController = TextEditingController(text: pet?.name ?? '');
    _breedController = TextEditingController(text: pet?.breed ?? '');
    _birthDateController = TextEditingController(
      text: pet?.birthDate != null ? DateFormat('dd/MM/yyyy').format(pet!.birthDate!) : '',
    );
    _weightController = TextEditingController(text: pet?.weight?.toString() ?? '');
    _microchipController = TextEditingController(text: pet?.microchipNumber ?? '');
    _colorController = TextEditingController(text: pet?.color ?? '');
    _medicalConditionsController = TextEditingController(text: pet?.medicalConditions ?? '');
    _allergiesController = TextEditingController(text: pet?.allergies ?? '');
    _specialNeedsController = TextEditingController(text: pet?.specialNeeds ?? '');
    _foodBrandController = TextEditingController(text: pet?.foodBrand ?? '');
    _foodAmountController = TextEditingController(text: pet?.foodAmount ?? '');
    _feedingTimesController = TextEditingController(text: pet?.feedingTimes.toString() ?? '2');
    _vetNameController = TextEditingController(text: pet?.veterinarianName ?? '');
    _vetPhoneController = TextEditingController(text: pet?.veterinarianPhone ?? '');
    _photoUrlController = TextEditingController(text: pet?.photoUrl ?? '');

    if (pet == null) {
      _loadTutors();
      _selectedSpecies = _speciesOptions.first;
    }
  }

  Future<void> _loadTutors() async {
    setState(() => _isLoadingTutors = true);
    try {
      final repo = TutorRepository();
      final tutors = await repo.getAll(limit: 100);
      setState(() {
        _tutors = tutors;
        if (_tutors.isNotEmpty) {
          _selectedTutorId = _tutors.first.id;
        }
      });
    } catch (e) {
      // error handling
    } finally {
      setState(() => _isLoadingTutors = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _birthDateController.dispose();
    _weightController.dispose();
    _microchipController.dispose();
    _colorController.dispose();
    _medicalConditionsController.dispose();
    _allergiesController.dispose();
    _specialNeedsController.dispose();
    _foodBrandController.dispose();
    _foodAmountController.dispose();
    _feedingTimesController.dispose();
    _vetNameController.dispose();
    _vetPhoneController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.pet != null;
    final title = isEditing ? 'Editar Pet' : 'Novo Pet';

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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSectionHeader('Informações Básicas'),
                  if (!isEditing) ...[
                    if (_isLoadingTutors)
                      const CircularProgressIndicator()
                    else if (_tutors.isEmpty)
                      const Text('Nenhum tutor encontrado.', style: TextStyle(color: Colors.red))
                    else
                      DropdownButtonFormField<String>(
                        initialValue: _selectedTutorId,
                        decoration: const InputDecoration(labelText: 'Tutor *'),
                        items: _tutors.map((t) {
                          return DropdownMenuItem(value: t.id, child: Text(t.fullName));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedTutorId = val),
                        validator: (val) => val == null ? 'Selecione um tutor' : null,
                      ),
                    const SizedBox(height: 16),
                  ],
                  ResponsiveFormFieldRow(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nome do Pet *'),
                        validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSpecies,
                        decoration: const InputDecoration(labelText: 'Espécie'),
                        items: _speciesOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) => setState(() => _selectedSpecies = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ResponsiveFormFieldRow(
                    children: [
                      TextFormField(
                        controller: _breedController,
                        decoration: const InputDecoration(labelText: 'Raça'),
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedGender,
                        decoration: const InputDecoration(labelText: 'Gênero'),
                        items: _genderOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) => setState(() => _selectedGender = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ResponsiveFormFieldRow(
                    children: [
                      TextFormField(
                        controller: _birthDateController,
                        decoration: const InputDecoration(labelText: 'Nascimento (dd/mm/aaaa)'),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, DataInputFormatter()],
                      ),
                      TextFormField(
                        controller: _weightController,
                        decoration: const InputDecoration(labelText: 'Peso (Kg)'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ResponsiveFormFieldRow(
                    children: [
                      TextFormField(
                        controller: _microchipController,
                        decoration: const InputDecoration(labelText: 'Microchip'),
                      ),
                      TextFormField(
                        controller: _colorController,
                        decoration: const InputDecoration(labelText: 'Cor'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Saúde'),
                  ResponsiveFormFieldRow(
                    children: [
                      TextFormField(
                        controller: _vetNameController,
                        decoration: const InputDecoration(labelText: 'Veterinário'),
                      ),
                      TextFormField(
                        controller: _vetPhoneController,
                        decoration: const InputDecoration(labelText: 'Telefone Vet'),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, TelefoneInputFormatter()],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _medicalConditionsController,
                    decoration: const InputDecoration(labelText: 'Condições Médicas'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _allergiesController,
                    decoration: const InputDecoration(labelText: 'Alergias'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _specialNeedsController,
                    decoration: const InputDecoration(labelText: 'Necessidades Especiais'),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Alimentação'),
                  ResponsiveFormFieldRow(
                    children: [
                      TextFormField(
                        controller: _foodBrandController,
                        decoration: const InputDecoration(labelText: 'Marca da Ração'),
                      ),
                      TextFormField(
                        controller: _feedingTimesController,
                        decoration: const InputDecoration(labelText: 'Vezes/Dia'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _foodAmountController,
                    decoration: const InputDecoration(labelText: 'Quantidade (g) ou Medida'),
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
                  title: const Text('Confirmar Exclusão'),
                  content: const Text('Tem certeza que deseja excluir este pet?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                    TextButton(
                      onPressed: () {
                        context.read<PetsCubit>().deletePet(widget.pet!.id);
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Parse Date
              DateTime? bDate;
              if (_birthDateController.text.isNotEmpty) {
                try {
                  bDate = DateFormat('dd/MM/yyyy').parse(_birthDateController.text);
                } catch (_) {}
              }

              final newPet = PetModel(
                id: widget.pet?.id ?? '',
                tutorId: _selectedTutorId!,
                name: _nameController.text,
                species: _selectedSpecies ?? 'Cachorro',
                breed: _breedController.text,
                gender: _selectedGender,
                birthDate: bDate,
                weight: double.tryParse(_weightController.text.replaceAll(',', '.')),
                microchipNumber: _microchipController.text,
                color: _colorController.text,
                medicalConditions: _medicalConditionsController.text,
                allergies: _allergiesController.text,
                specialNeeds: _specialNeedsController.text,
                foodBrand: _foodBrandController.text,
                foodAmount: _foodAmountController.text,
                feedingTimes: int.tryParse(_feedingTimesController.text) ?? 2,
                veterinarianName: _vetNameController.text,
                veterinarianPhone: _vetPhoneController.text,
                photoUrl: _photoUrlController.text,
                createdAt: widget.pet?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );

              if (isEditing) {
                context.read<PetsCubit>().updatePet(newPet);
              } else {
                context.read<PetsCubit>().createPet(newPet);
              }
              Navigator.pop(context);
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
        ),
        const Divider(),
        const SizedBox(height: 8),
      ],
    );
  }
}
