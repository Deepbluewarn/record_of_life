import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HorizontalSelector<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final T? selectedItem;
  final String Function(T) labelBuilder;
  final void Function(T) onSelected;

  const HorizontalSelector({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.labelBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, idx) => SizedBox(width: 12),
            itemBuilder: (context, idx) {
              final item = items[idx];
              final isSelected = selectedItem == item;
              return GestureDetector(
                onTap: () {
                  onSelected(item);
                  HapticFeedback.selectionClick();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.black.withAlpha(15)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    labelBuilder(item),
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
