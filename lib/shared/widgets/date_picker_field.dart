import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_roll_form_provider.dart';

class DatePickerField extends ConsumerWidget {
  final ValueChanged<DateTime> onDateChanged;

  const DatePickerField({super.key, required this.onDateChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rollFormState = ref.watch(newRollFormProvider);
    final selectedDate = rollFormState.startedAt;

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
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
              selectedDate != null
                  ? '${selectedDate.year}.${selectedDate.month}.${selectedDate.day}'
                  : '날짜 선택',
              style: TextStyle(
                color: selectedDate != null ? Colors.black : Colors.grey[400],
              ),
            ),
            Icon(Icons.calendar_today, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
