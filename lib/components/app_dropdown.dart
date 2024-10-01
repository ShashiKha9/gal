import 'package:flutter/material.dart';

class AppDropdown extends StatelessWidget {
  const AppDropdown({
    super.key,
    this.value,
    required this.labelText,
    required this.items,
    required this.onChanged,
  });
  final String? value;
  final String? labelText;
  final List<String> items;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      items: items.map((value) {
        return DropdownMenuItem(
          value: value,
          child: Text(
            value.toString(),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
