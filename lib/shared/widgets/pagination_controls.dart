import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int rowsPerPage;
  final int totalRows;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int>? onRowsPerPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.rowsPerPage,
    required this.totalRows,
    this.onPageChanged,
    this.onRowsPerPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final startRow = (currentPage * rowsPerPage) + 1;
    final endRow = ((currentPage + 1) * rowsPerPage).clamp(0, totalRows);
    final totalPages = (totalRows / rowsPerPage).ceil();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.rowsPerPage),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: rowsPerPage,
            underline: const SizedBox(),
            items: [10, 25, 50].map((e) {
              return DropdownMenuItem(value: e, child: Text(e.toString()));
            }).toList(),
            onChanged: onRowsPerPageChanged != null ? (v) => onRowsPerPageChanged!(v!) : null,
          ),
          const SizedBox(width: 24),
          Text('$startRow-$endRow ${l10n.textOf} $totalRows'),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 0 ? () => onPageChanged?.call(currentPage - 1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages - 1 ? () => onPageChanged?.call(currentPage + 1) : null,
          ),
        ],
      ),
    );
  }
}
