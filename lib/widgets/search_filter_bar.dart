import 'package:flutter/material.dart';

class SearchFilterBar extends StatelessWidget {
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onFilterTap;
  const SearchFilterBar(
      {super.key, required this.onQueryChanged, required this.onFilterTap});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: TextField(
              onChanged: onQueryChanged,
              decoration: const InputDecoration(
                  hintText: 'пошук...', prefixIcon: Icon(Icons.search)))),
      const SizedBox(width: 8),
      IconButton.filledTonal(
          onPressed: onFilterTap, icon: const Icon(Icons.filter_list))
    ]);
  }
}
