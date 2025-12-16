import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/tutor_repository.dart';
import '../../../../domain/models/tutor_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/filter_bar.dart';
import '../../../../shared/widgets/pagination_controls.dart';
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
              child: const EditClientDialog(), // No client implies creation
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
                    return const Center(child: Text('No clients found'));
                  }

                  final totalRows = clients.length;
                  final start = _currentPage * _rowsPerPage;
                  final end = (start + _rowsPerPage).clamp(0, totalRows);

                  if (start >= totalRows && totalRows > 0) {
                    return const Center(child: Text('Page out of bounds'));
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
                client.isActive ? 'Active' : 'Inactive',
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

class EditClientDialog extends StatelessWidget {
  final TutorModel? client; // Null for creation

  const EditClientDialog({super.key, this.client});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: client?.fullName ?? '');
    final emailController = TextEditingController(text: client?.email ?? '');
    final phoneController = TextEditingController(text: client?.phone ?? '');
    // Address handling simplified for now

    final isEditing = client != null;
    final title = isEditing ? 'Edit Client' : 'New Client';

    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
      ),
      actions: [
        if (isEditing)
          TextButton(
            onPressed: () {
              // Confirm delete
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: const Text('Are you sure you want to delete this client?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        context.read<ClientsCubit>().deleteClient(client!.id);
                        Navigator.pop(ctx); // Close confirm
                        Navigator.pop(context); // Close edit dialog
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
            final name = nameController.text;
            final email = emailController.text;
            final phone = phoneController.text;

            if (name.isEmpty || email.isEmpty) return; // Simple validation

            if (isEditing) {
              final updatedClient = client!.copyWith(fullName: name, email: email, phone: phone);
              context.read<ClientsCubit>().updateClient(updatedClient);
            } else {
              // For creation, we need mock/default other values or change model to allow clean defaults
              // Model has mandatory ID, but creation logic usually ignores ID or generates one DB-side?
              // The DB generates default UUIDv4. But Model demands a String id.
              // We should send an empty string or null?
              // Supabase insert ignores ID if we don't send it, but Model needs it for internal struct.
              // Best practice: Use empty string and Repository handles exclusion of ID field or lets Supabase gen it.

              // But wait, the repository uses `insert(tutor.toJson())`.
              // `toJson()` includes `id`. If ID is empty string, Supabase might not like it if it expects UUID format or NULL for auto-generation.
              // We might need to ensure `toJson()` or Repository handles ID generation/omission.
              // `tutor_repository.dart`: `from(tableName).insert(tutor.toJson())`.
              // `tutor_model.dart`: `toJson` includes `id`.
              // If ID is empty string, Supabase UUID parser might fail.
              // We should probably generate a UUID locally or change repository to strip empty ID.
              // For now, I'll let repository fail if so, but ideally I should fix repo or generate UUID here.
              // To be safe without extra deps (uuid package), I will change Repository to remove ID if empty?
              // Or I assume `uuid-ossp` is enabled in DB (it is) and I should NOT send the ID key.
              // In Model `toJson`, it sends ID.
              // I will modify `toJson` or `Repository`?
              // Let's modify Repository Create method to exclude ID if it's empty.

              final newClient = TutorModel(
                id: '', // Will be ignored/handled by repo hopefully, or I need to fix repo
                fullName: name,
                email: email,
                phone: phone,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              context.read<ClientsCubit>().createClient(newClient);
            }
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
