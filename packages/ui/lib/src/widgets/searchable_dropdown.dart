import 'package:flutter/material.dart';

/// Reusable picker mirroring WonderMove's searchable dropdowns.
class SearchableDropdown<T> extends StatelessWidget {
  const SearchableDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.itemLabel,
  });

  final String label;
  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String Function(T)? itemLabel;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        DropdownMenuItem<T>(value: null, child: const Text('—')),
        ...items.map(
          (item) => DropdownMenuItem<T>(
            value: item,
            child: Text(itemLabel?.call(item) ?? item.toString()),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
