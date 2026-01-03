import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/via_cep_service.dart';
import '../../../data/repositories/hotel_repository.dart';
import '../../../data/repositories/pet_repository.dart';
import '../../../data/repositories/tutor_repository.dart';
import '../../../domain/enums/app_enums.dart';
import '../../../domain/models/hotel_model.dart';
import '../../../domain/models/pet_model.dart';
import '../../../domain/models/tutor_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/responsive_helper.dart';
import '../../../shared/widgets/filter_bar.dart';
import '../../../shared/widgets/pagination_controls.dart';
import '../../dashboard/presentation/cubit/tenant_cubit.dart';
import '../../pets/presentation/cubit/pets_cubit.dart';
import '../../pets/presentation/pages/pets_page.dart';
import '../cubit/clients_cubit.dart';
import '../cubit/clients_state.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tenantState = context.watch<TenantCubit>().state;

    if (tenantState.userRole == UserRole.tutor) {
      return const Scaffold(body: Center(child: Text('Acesso negado')));
    }

    return BlocProvider(
      create: (context) => ClientsCubit(TutorRepository())..loadClients(hotelId: tenantState.currentHotel?.id),
      child: const ClientsView(),
    );
  }
}

class ClientsView extends StatefulWidget {
  const ClientsView({super.key});

  @override
  State<ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends State<ClientsView> {
  String _searchQuery = '';
  int _currentPage = 0;
  int _rowsPerPage = 10;
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.clients)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialogContext) =>
                BlocProvider.value(value: context.read<ClientsCubit>(), child: const EditClientDialog()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          FilterBar(
            hintText: '${l10n.search} ${l10n.clients}...',
            onSearchChanged: (value) {
              final hotelId = context.read<TenantCubit>().state.currentHotel?.id;
              setState(() {
                _searchQuery = value;
                _currentPage = 0;
              });
              context.read<ClientsCubit>().searchClients(value, hotelId: hotelId);
            },
          ),
          Expanded(
            child: BlocBuilder<ClientsCubit, ClientsState>(
              builder: (context, state) {
                if (state is ClientsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ClientsError) {
                  return Center(child: Text(state.message));
                } else if (state is ClientsLoaded) {
                  final clients = state.clients;
                  if (clients.isEmpty) {
                    return Center(child: Text(l10n.noClientsFound));
                  }

                  final totalRows = clients.length;
                  final start = _currentPage * _rowsPerPage;
                  final end = (start + _rowsPerPage).clamp(0, totalRows);

                  if (start >= totalRows && totalRows > 0) {
                    return Center(child: Text(l10n.pageOutOfBounds));
                  }

                  final currentClients = totalRows > 0 ? clients.sublist(start, end) : [];

                  return ListView.separated(
                    itemCount: currentClients.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
                    itemBuilder: (context, index) {
                      final client = currentClients[index];
                      return _buildClientRow(context, client);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          BlocBuilder<ClientsCubit, ClientsState>(
            builder: (context, state) {
              if (state is ClientsLoaded) {
                return PaginationControls(
                  currentPage: _currentPage,
                  rowsPerPage: _rowsPerPage,
                  totalRows: state.clients.length,
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

  Widget _buildClientRow(BuildContext context, TutorModel client) {
    final l10n = AppLocalizations.of(context)!;
    final isSelected = _selectedIds.contains(client.id);

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedIds.remove(client.id);
          } else {
            _selectedIds.add(client.id);
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
                    _selectedIds.add(client.id);
                  } else {
                    _selectedIds.remove(client.id);
                  }
                });
              },
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Text(client.fullName.isNotEmpty ? client.fullName[0].toUpperCase() : '?'),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(client.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(client.email, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(client.phone, style: TextStyle(color: Colors.grey.shade600)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: client.isActive ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                client.isActive ? l10n.active : l10n.inactive,
                style: TextStyle(
                  color: client.isActive ? Colors.green : Colors.grey,
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
                  builder: (dialogContext) => BlocProvider.value(
                    value: context.read<ClientsCubit>(),
                    child: EditClientDialog(client: client),
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

class EditClientDialog extends StatefulWidget {
  final TutorModel? client; // Null for creation

  const EditClientDialog({super.key, this.client});

  @override
  State<EditClientDialog> createState() => _EditClientDialogState();
}

class _EditClientDialogState extends State<EditClientDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _secondaryPhoneController;
  late TextEditingController _cpfController;
  late TextEditingController _streetController;
  late TextEditingController _numberController;
  late TextEditingController _complementController;
  late TextEditingController _neighborhoodController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;
  late TextEditingController _notesController;

  bool _isLoadingCep = false;
  String? _selectedHotelId;
  List<HotelModel> _hotels = [];
  bool _isLoadingHotels = false;
  List<PetModel> _tutorPets = [];
  bool _isLoadingPets = false;

  bool get isEditing => widget.client != null;

  @override
  void initState() {
    super.initState();
    final client = widget.client;
    _nameController = TextEditingController(text: client?.fullName ?? '');
    _emailController = TextEditingController(text: client?.email ?? '');
    _phoneController = TextEditingController(text: client?.phone ?? '');
    _secondaryPhoneController = TextEditingController(text: client?.secondaryPhone ?? '');
    _cpfController = TextEditingController(text: client?.cpf ?? '');
    _streetController = TextEditingController(text: client?.addressStreet ?? '');
    _numberController = TextEditingController(text: client?.addressNumber ?? '');
    _complementController = TextEditingController(text: client?.addressComplement ?? '');
    _neighborhoodController = TextEditingController(text: client?.addressNeighborhood ?? '');
    _cityController = TextEditingController(text: client?.addressCity ?? '');
    _stateController = TextEditingController(text: client?.addressState ?? '');
    _zipController = TextEditingController(text: client?.addressZip ?? '');
    _emergencyNameController = TextEditingController(text: client?.emergencyContactName ?? '');
    _emergencyPhoneController = TextEditingController(text: client?.emergencyContactPhone ?? '');
    _notesController = TextEditingController(text: client?.notes ?? '');

    _zipController.addListener(_onZipChanged);

    _selectedHotelId = client?.hotelId;
    _initTenantData();
    if (isEditing) {
      _loadTutorPets();
    }
  }

  void _initTenantData() {
    final tenantState = context.read<TenantCubit>().state;
    if (tenantState.userRole == UserRole.admin) {
      _loadHotels();
    } else {
      _selectedHotelId ??= tenantState.currentHotel?.id;
    }
  }

  Future<void> _loadHotels() async {
    setState(() => _isLoadingHotels = true);
    try {
      final repo = HotelRepository();
      final hotels = await repo.getAll(isActive: true);
      setState(() => _hotels = hotels);
    } catch (e) {
      // Error
    } finally {
      setState(() => _isLoadingHotels = false);
    }
  }

  Future<void> _loadTutorPets() async {
    if (widget.client == null) return;
    setState(() => _isLoadingPets = true);
    try {
      final repo = PetRepository();
      final pets = await repo.getByTutorId(widget.client!.id);
      setState(() => _tutorPets = pets);
    } catch (e) {
      // Error
    } finally {
      setState(() => _isLoadingPets = false);
    }
  }

  void _onZipChanged() {
    final zip = _zipController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (zip.length == 8) {
      _fetchAddress(zip);
    }
  }

  Future<void> _fetchAddress(String zip) async {
    setState(() => _isLoadingCep = true);
    final service = ViaCepService();
    final data = await service.getAddress(zip);
    if (data != null && mounted) {
      setState(() {
        _streetController.text = data['logradouro'] ?? '';
        _neighborhoodController.text = data['bairro'] ?? '';
        _cityController.text = data['localidade'] ?? '';
        _stateController.text = data['uf'] ?? '';
        _complementController.text = data['complemento'] ?? '';
      });
    }
    if (mounted) {
      setState(() => _isLoadingCep = false);
    }
  }

  @override
  void dispose() {
    _zipController.removeListener(_onZipChanged);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _secondaryPhoneController.dispose();
    _cpfController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = isEditing ? l10n.editClient : l10n.newClient;
    final userRole = context.watch<TenantCubit>().state.userRole;

    return DefaultTabController(
      length: isEditing ? 2 : 1,
      child: AlertDialog(
        titlePadding: EdgeInsets.zero,
        title: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                children: [
                  Text(title),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            if (isEditing)
              const TabBar(
                tabs: [
                  Tab(text: 'Informações'),
                  Tab(text: 'Pets'),
                ],
              ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.65,
          height: MediaQuery.of(context).size.height * 0.7,
          child: TabBarView(children: [_buildGeneralTab(l10n, userRole), if (isEditing) _buildPetsTab(l10n)]),
        ),
        actions: [
          if (isEditing)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n.confirmDelete),
                    content: Text(l10n.confirmDeleteClientMessage),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
                      TextButton(
                        onPressed: () {
                          context.read<ClientsCubit>().deleteClient(widget.client!.id);
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
                final newClient = TutorModel(
                  id: widget.client?.id ?? '',
                  hotelId: _selectedHotelId,
                  fullName: _nameController.text,
                  email: _emailController.text,
                  phone: _phoneController.text,
                  secondaryPhone: _secondaryPhoneController.text,
                  cpf: _cpfController.text,
                  addressStreet: _streetController.text,
                  addressNumber: _numberController.text,
                  addressComplement: _complementController.text,
                  addressNeighborhood: _neighborhoodController.text,
                  addressCity: _cityController.text,
                  addressState: _stateController.text,
                  addressZip: _zipController.text,
                  emergencyContactName: _emergencyNameController.text,
                  emergencyContactPhone: _emergencyPhoneController.text,
                  notes: _notesController.text,
                  createdAt: widget.client?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                if (isEditing) {
                  context.read<ClientsCubit>().updateClient(newClient);
                } else {
                  context.read<ClientsCubit>().createClient(newClient);
                }
                Navigator.pop(context);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTab(AppLocalizations l10n, UserRole userRole) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userRole == UserRole.admin) ...[
              _buildSectionHeader('Configuração de Filial'),
              if (_isLoadingHotels)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<String>(
                  initialValue: _selectedHotelId,
                  decoration: const InputDecoration(labelText: 'Creche / Hotel (Obrigatório) *'),
                  items: _hotels.map((h) {
                    return DropdownMenuItem(value: h.id, child: Text(h.name));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedHotelId = val),
                  validator: (val) => val == null ? l10n.requiredField : null,
                ),
              const SizedBox(height: 24),
            ],
            _buildSectionHeader(l10n.personalData),
            ResponsiveFormFieldRow(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.fullNameRequired),
                  validator: (value) => value == null || value.isEmpty ? l10n.requiredField : null,
                ),
                TextFormField(
                  controller: _cpfController,
                  decoration: InputDecoration(labelText: l10n.cpf),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, CpfInputFormatter()],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ResponsiveFormFieldRow(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: l10n.emailRequired),
                  validator: (value) => value == null || value.isEmpty ? l10n.requiredField : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ResponsiveFormFieldRow(
              children: [
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: l10n.primaryPhoneRequired),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, TelefoneInputFormatter()],
                  validator: (value) => value == null || value.isEmpty ? l10n.requiredField : null,
                ),
                TextFormField(
                  controller: _secondaryPhoneController,
                  decoration: InputDecoration(labelText: l10n.secondaryPhone),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, TelefoneInputFormatter()],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(l10n.address),
            ResponsiveFormFieldRow(
              children: [
                TextFormField(
                  controller: _zipController,
                  decoration: InputDecoration(
                    labelText: l10n.zipCode,
                    suffixIcon: _isLoadingCep
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, CepInputFormatter()],
                ),
                TextFormField(
                  controller: _streetController,
                  decoration: InputDecoration(labelText: l10n.street),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ResponsiveFormFieldRow(
              children: [
                TextFormField(
                  controller: _numberController,
                  decoration: InputDecoration(labelText: l10n.number),
                ),
                TextFormField(
                  controller: _complementController,
                  decoration: InputDecoration(labelText: l10n.complement),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ResponsiveFormFieldRow(
              children: [
                TextFormField(
                  controller: _neighborhoodController,
                  decoration: InputDecoration(labelText: l10n.neighborhood),
                ),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(labelText: l10n.city),
                ),
                TextFormField(
                  controller: _stateController,
                  decoration: InputDecoration(labelText: l10n.stateAbbr),
                  maxLength: 2,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(l10n.emergencyContact),
            ResponsiveFormFieldRow(
              children: [
                TextFormField(
                  controller: _emergencyNameController,
                  decoration: InputDecoration(labelText: l10n.contactName),
                ),
                TextFormField(
                  controller: _emergencyPhoneController,
                  decoration: InputDecoration(labelText: l10n.contactPhone),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, TelefoneInputFormatter()],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(l10n.observations),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(labelText: l10n.generalNotes),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetsTab(AppLocalizations l10n) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pets Vinculados', style: Theme.of(context).textTheme.titleMedium),
              FilledButton.icon(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (ctx) => BlocProvider(
                      create: (context) => PetsCubit(PetRepository()),
                      child: EditPetDialog(tutorId: widget.client?.id, hotelId: _selectedHotelId),
                    ),
                  );
                  _loadTutorPets();
                },
                icon: const Icon(Icons.add),
                label: const Text('Novo Pet'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingPets
              ? const Center(child: CircularProgressIndicator())
              : _tutorPets.isEmpty
              ? const Center(child: Text('Nenhum pet cadastrado.'))
              : ListView.separated(
                  itemCount: _tutorPets.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final pet = _tutorPets[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: pet.photoUrl != null && pet.photoUrl!.isNotEmpty
                            ? NetworkImage(pet.photoUrl!)
                            : null,
                        child: pet.photoUrl == null || pet.photoUrl!.isEmpty ? const Icon(Icons.pets) : null,
                      ),
                      title: Text(pet.name),
                      subtitle: Text('${pet.species} - ${pet.breed ?? "SRD"}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: pet.status == PetStatus.active
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              pet.status.displayName,
                              style: TextStyle(
                                color: pet.status == PetStatus.active ? Colors.green : Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (ctx) => BlocProvider(
                                  create: (context) => PetsCubit(PetRepository()),
                                  child: EditPetDialog(pet: pet, hotelId: _selectedHotelId),
                                ),
                              );
                              _loadTutorPets();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
