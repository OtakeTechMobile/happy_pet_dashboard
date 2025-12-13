import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/filter_bar.dart';
import '../../../../shared/widgets/pagination_controls.dart';

class PetsPage extends StatefulWidget {
  const PetsPage({super.key});

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
  // Dummy data
  final List<Map<String, dynamic>> _allPets = List.generate(
    25, // Increased to show pagination
    (index) => {
      'id': index,
      'name': 'Doggo ${index + 1}',
      'breed': 'Golden Retriever',
      'age': '${index + 2} years',
      'status': index % 3 == 0 ? 'Checkup Due' : 'Healthy',
      'image': 'https://placedog.net/100/100?id=${index + 1}',
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
    final filteredPets = _allPets.where((pet) {
      final name = pet['name'].toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    // Pagination logic
    final totalRows = filteredPets.length;
    final start = _currentPage * _rowsPerPage;
    final end = (start + _rowsPerPage).clamp(0, totalRows);
    final currentPets = filteredPets.sublist(start, end);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pets)),
      body: Column(
        children: [
          FilterBar(
            hintText: '${l10n.search} ${l10n.pets}...',
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
                _currentPage = 0; // Reset to first page on search
              });
            },
          ),
          Expanded(
            child: ListView.separated(
              itemCount: currentPets.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final pet = currentPets[index];
                return _buildPetRow(context, pet);
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

  Widget _buildPetRow(BuildContext context, Map<String, dynamic> pet) {
    return InkWell(
      onTap: () {
        // Toggle selection or open details
        setState(() {
          pet['isSelected'] = !pet['isSelected'];
        });
      },
      child: Container(
        color: pet['isSelected'] ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Checkbox(
              value: pet['isSelected'],
              onChanged: (value) {
                setState(() {
                  pet['isSelected'] = value;
                });
              },
            ),
            IconButton(
              icon: Icon(
                pet['isStarred'] ? Icons.star : Icons.star_border,
                color: pet['isStarred'] ? Colors.amber : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  pet['isStarred'] = !pet['isStarred'];
                });
              },
            ),
            const SizedBox(width: 8),
            CircleAvatar(backgroundImage: NetworkImage(pet['image']), backgroundColor: Colors.grey.shade200),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Text(pet['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              flex: 2,
              child: Text(
                pet['breed'],
                style: TextStyle(color: Colors.grey.shade600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: pet['status'] == 'Healthy' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                pet['status'] == 'Healthy' ? AppLocalizations.of(context)!.healthy : AppLocalizations.of(context)!.checkupDue,
                  style: TextStyle(
                  color: pet['status'] == 'Healthy' ? Colors.green : Colors.orange,
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
                  builder: (context) => EditPetDialog(pet: pet),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EditPetDialog extends StatelessWidget {
  final Map<String, dynamic> pet;

  const EditPetDialog({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: pet['name']);
    final ageController = TextEditingController(text: pet['age']);
    final statusController = TextEditingController(text: pet['status']);

    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.editPet),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: l10n.name),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: ageController,
            decoration: InputDecoration(labelText: l10n.age),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: statusController,
            decoration: InputDecoration(labelText: l10n.status),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: () {
            // TODO: Implement save logic
            Navigator.pop(context);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
