import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/via_cep_service.dart';
import '../../../data/repositories/tutor_repository.dart';
import '../../../domain/models/tutor_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/responsive_helper.dart';
import '../../../shared/widgets/filter_bar.dart';
import '../../../shared/widgets/pagination_controls.dart';
import '../cubit/clients_cubit.dart';
import '../cubit/clients_state.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClientsCubit(TutorRepository())..loadClients(),
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
            builder: (dialogContext) => BlocProvider.value(
              value: context.read<ClientsCubit>(), // Pass existing Cubit
              child: const Dialog(), // No client implies creation
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          FilterBar(
            hintText: '${l10n.search} ${l10n.clients}...',
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
                _currentPage = 0;
              });
              context.read<ClientsCubit>().searchClients(value);
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
    final isEditing = widget.client != null;
    final l10n = AppLocalizations.of(context)!;
    final title = isEditing ? l10n.editClient : l10n.newClient;

    return AlertDialog(
      title: Row(children: [Text(title)]),
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
                id: widget.client?.id ?? '', // Keeps existing ID or empty for new
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
