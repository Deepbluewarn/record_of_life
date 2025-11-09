import 'package:flutter/material.dart';

class SimpleTextField extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final TextInputType keyboardType;

  const SimpleTextField({
    super.key,
    this.onChanged,
    this.hintText,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}
