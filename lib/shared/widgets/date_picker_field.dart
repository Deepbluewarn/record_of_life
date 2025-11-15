import 'package:flutter/material.dart';

class DatePickerField extends StatelessWidget {
  final ValueChanged<DateTime> onDateChanged;
  final DateTime initialDate;

  DatePickerField({
    super.key,
    required this.onDateChanged,
    DateTime? initialDate,
  }) : initialDate = initialDate ?? DateTime.now();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          onDateChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${initialDate.year}.${initialDate.month}.${initialDate.day}',
              style: TextStyle(color: Colors.black),
            ),
            Icon(Icons.calendar_today, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
