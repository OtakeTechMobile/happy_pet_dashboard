import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/filter_bar.dart';
import '../../../../shared/widgets/pagination_controls.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  // Dummy data
  final List<Map<String, dynamic>> _allClients = List.generate(
    50,
    (index) => {
      'id': index,
      'name': 'Client ${index + 1}',
      'email': 'client${index + 1}@example.com',
      'phone': '(11) 99999-${1000 + index}',
      'status': index % 4 == 0 ? 'Inactive' : 'Active',
      'isStarred': false,
      'isSelected': false,
    },
  );

  String _searchQuery = '';
  int _currentPage = 0;
  int _rowsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Filter logic
    final filteredClients = _allClients.where((client) {
      final name = client['name'].toString().toLowerCase();
      final email = client['email'].toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) || email.contains(_searchQuery.toLowerCase());
    }).toList();

    // Pagination logic
    final totalRows = filteredClients.length;
    final start = _currentPage * _rowsPerPage;
    final end = (start + _rowsPerPage).clamp(0, totalRows);
    final currentClients = filteredClients.sublist(start, end);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.clients)),
      body: Column(
        children: [
          FilterBar(
            hintText: '${l10n.search} ${l10n.clients}...',
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
                _currentPage = 0;
              });
            },
          ),
          Expanded(
            child: ListView.separated(
              itemCount: currentClients.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final client = currentClients[index];
                return _buildClientRow(context, client);
              },
            ),
          ),
          PaginationControls(
            currentPage: _currentPage,
            rowsPerPage: _rowsPerPage,
            totalRows: totalRows,
            onPageChanged: (page) => setState(() => _currentPage = page),
            onRowsPerPageChanged: (rows) => setState(() {
              _rowsPerPage = rows;
              _currentPage = 0;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildClientRow(BuildContext context, Map<String, dynamic> client) {
    return InkWell(
      onTap: () {
        setState(() {
          client['isSelected'] = !client['isSelected'];
        });
      },
      child: Container(
        color: client['isSelected'] ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Checkbox(
              value: client['isSelected'],
              onChanged: (value) {
                setState(() {
                  client['isSelected'] = value;
                });
              },
            ),
            IconButton(
              icon: Icon(
                client['isStarred'] ? Icons.star : Icons.star_border,
                color: client['isStarred'] ? Colors.amber : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  client['isStarred'] = !client['isStarred'];
                });
              },
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Text(client['name'][0]),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(client['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(client['email'], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(client['phone'], style: TextStyle(color: Colors.grey.shade600)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: client['status'] == 'Active' ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                client['status'],
                style: TextStyle(
                  color: client['status'] == 'Active' ? Colors.green : Colors.grey,
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
                  builder: (context) => EditClientDialog(client: client),
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
  final Map<String, dynamic> client;

  const EditClientDialog({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: client['name']);
    final phoneController = TextEditingController(text: client['phone']);
    final addressController = TextEditingController(text: client['address']);

    return AlertDialog(
      title: const Text('Edit Client'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(labelText: 'Phone'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: addressController,
            decoration: const InputDecoration(labelText: 'Address'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            // TODO: Implement save logic
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
