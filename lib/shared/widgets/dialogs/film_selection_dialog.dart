import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/film.dart';
import 'package:record_of_life/features/roll/presentation/providers/film_provider.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';
import 'package:record_of_life/shared/widgets/bottom_sheets/add_film_bottom_sheet.dart';

class FilmSelectionDialog extends ConsumerWidget {
  final Function(Film) onSelected;
  final String? matchFormat; // 매칭 필름을 상단으로 정렬 + 강조.

  const FilmSelectionDialog({
    super.key,
    required this.onSelected,
    this.matchFormat,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filmState = ref.watch(filmProvider);

    return AlertDialog(
      title: const Text('필름 선택'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.4,
        child: filmState.when(
          data: (data) {
            final films = [...data.films];
            if (matchFormat != null) {
              films.sort((a, b) {
                final aMatch = a.format == matchFormat ? 0 : 1;
                final bMatch = b.format == matchFormat ? 0 : 1;
                return aMatch - bMatch;
              });
            }
            return ListView.builder(
              itemCount: films.length + 1,
              itemBuilder: (context, index) {
                if (index == films.length) {
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
                final film = films[index];
                final mismatched =
                    matchFormat != null && film.format != matchFormat;
                return ListTile(
                  title: Text(
                    film.name,
                    style: TextStyle(
                      color: mismatched ? Colors.grey : null,
                    ),
                  ),
                  subtitle: Text(
                    '${film.brand ?? 'Unknown'} · ${film.format ?? ''}',
                    style: TextStyle(
                      color: mismatched ? Colors.grey : null,
                    ),
                  ),
                  trailing: mismatched
                      ? const Icon(
                          Icons.warning_amber,
                          color: Colors.amber,
                          size: 18,
                        )
                      : null,
                  onTap: () => onSelected(film),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Text('Error: $error'),
        ),
      ),
      backgroundColor: AppColors.surfaceLight,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
      ],
    );
  }
}
