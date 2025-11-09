import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/film.dart';
import 'package:record_of_life/features/roll/presentation/providers/film_provider.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';
import 'package:record_of_life/shared/widgets/add_film_bottom_sheet.dart';

class FilmSelectionDialog extends ConsumerWidget {
  final Function(Film) onSelected;

  const FilmSelectionDialog({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filmState = ref.watch(filmProvider);

    return AlertDialog(
      title: Text('필름 선택'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.4,
        child: filmState.when(
          data: (data) => ListView.builder(
            itemCount: data.films.length + 1,
            itemBuilder: (context, index) {
              // 마지막 항목: 새 필름 추가 버튼
              if (index == data.films.length) {
                return ListTile(
                  leading: Icon(Icons.add, color: AppColors.primary),
                  title: Text(
                    '새 필름 추가',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      useSafeArea: true,
                      isScrollControlled: true,
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: AddFilmBottomSheet(),
                      ),
                    );
                  },
                );
              }
              final film = data.films[index];
              return ListTile(
                title: Text(film.name),
                subtitle: Text(
                  '${film.brand ?? 'Unknown'} · ${film.format ?? ''}',
                ),
                onTap: () {
                  onSelected(film);
                },
              );
            },
          ),
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Text('Error: $error'),
        ),
      ),
      backgroundColor: AppColors.surfaceLight,
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('취소')),
      ],
    );
  }
}
