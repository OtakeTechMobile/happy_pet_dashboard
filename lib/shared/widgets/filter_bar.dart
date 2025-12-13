import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class FilterBar extends StatelessWidget {
  final String hintText;
  final VoidCallback? onFilterPressed;
  final ValueChanged<String>? onSearchChanged;

  const FilterBar({super.key, required this.hintText, this.onFilterPressed, this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          IconButton(onPressed: onFilterPressed, icon: Icon(Icons.filter_list), tooltip: l10n.filter),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: onSearchChanged,
            ),
          ),
        ],
      ),
    );
  }
}
