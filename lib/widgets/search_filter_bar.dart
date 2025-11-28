
import 'package:flutter/material.dart';

class SearchFilterBar extends StatelessWidget {
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onFilterTap;
  final bool showFilterButton;

  const SearchFilterBar({
    super.key,
    required this.onQueryChanged,
    required this.onFilterTap,
    this.showFilterButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: TextField(
          onChanged: onQueryChanged,
          decoration: const InputDecoration(
            hintText: 'пошук...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
      ),
      if (showFilterButton) ...[
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: onFilterTap,
          icon: const Icon(Icons.filter_list),
        ),
      ]
    ]);
  }
}
