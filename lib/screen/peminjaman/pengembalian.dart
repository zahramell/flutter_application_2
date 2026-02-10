import 'package:flutter/material.dart';


class FieldPengembalian extends StatelessWidget {
  final String kondisiAlat;
  final Function(String) onChanged;

  const FieldPengembalian({
    super.key,
    required this.kondisiAlat,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: kondisiAlat,
      decoration: const InputDecoration(
        labelText: 'Kondisi Alat',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'baik', child: Text('Baik')),
        DropdownMenuItem(value: 'rusak', child: Text('Rusak')),
      ],
      onChanged: (value) => onChanged(value!),
    );
  }
}
