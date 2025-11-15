import 'package:flutter/material.dart';

class SimpleTextFormField extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final TextInputType keyboardType;
  final String? initialValue;

  const SimpleTextFormField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.hintText,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
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
