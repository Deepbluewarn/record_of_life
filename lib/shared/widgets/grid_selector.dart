import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 야외/장갑 조작을 위한 큰 그리드 버튼 셀렉터.
// HorizontalSelector 대체용. 가로 스크롤 정밀 조작이 필요 없음.
class GridSelector<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final T? selectedItem;
  final String Function(T) labelBuilder;
  final void Function(T) onSelected;
  final int columns;
  final double cellHeight;
  // ponytail: 60+개 항목(셔터 등)은 스크롤 허용. 세로 최대 높이 지정.
  final double? maxHeight;

  const GridSelector({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.labelBuilder,
    required this.onSelected,
    this.columns = 4,
    this.cellHeight = 56,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final rows = (items.length / columns).ceil();
    final gridHeight = rows * cellHeight + (rows - 1) * 8;
    final effectiveHeight = maxHeight != null && gridHeight > maxHeight!
        ? maxHeight!
        : gridHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: effectiveHeight,
          child: GridView.builder(
            physics: gridHeight > effectiveHeight
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisExtent: cellHeight,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: items.length,
            itemBuilder: (context, idx) {
              final item = items[idx];
              final selected = selectedItem == item;
              return GestureDetector(
                onTap: () {
                  onSelected(item);
                  HapticFeedback.selectionClick();
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? Colors.black : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? Colors.black : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    labelBuilder(item),
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
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
