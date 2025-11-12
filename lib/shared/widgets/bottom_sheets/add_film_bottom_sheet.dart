import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/features/roll/presentation/providers/film_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_film_form_provider.dart';

class AddFilmBottomSheet extends ConsumerWidget {
  const AddFilmBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filmFormProvider = ref.watch(newFilmFormProvider);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 드래그 핸들
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                Text(
                  '새 필름 추가',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 20),

                TextField(
                  onChanged: (value) {
                    ref.read(newFilmFormProvider.notifier).setName(value);
                  },
                  decoration: InputDecoration(
                    labelText: '필름명',
                    hintText: '예: Portra 400',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                TextField(
                  onChanged: (value) {
                    ref.read(newFilmFormProvider.notifier).setBrand(value);
                  },
                  decoration: InputDecoration(
                    labelText: '제조사',
                    hintText: '예: Kodak',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                TextField(
                  onChanged: (value) {
                    final iso = int.tryParse(value);
                    ref.read(newFilmFormProvider.notifier).setIso(iso);
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'ISO',
                    hintText: '예: 400',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                TextField(
                  onChanged: (value) {
                    ref.read(newFilmFormProvider.notifier).setFormat(value);
                  },
                  decoration: InputDecoration(
                    labelText: '포맷',
                    hintText: '예: 35mm',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                TextField(
                  onChanged: (value) {
                    ref.read(newFilmFormProvider.notifier).setNote(value);
                  },
                  decoration: InputDecoration(
                    labelText: '메모',
                    hintText: '예: 따뜻한 톤',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: filmFormProvider.when(
                    data: (formState) => ElevatedButton(
                      onPressed: () {
                        ref
                            .read(filmProvider.notifier)
                            .addFilm(formState.toFilm());
                        Navigator.pop(context);
                      },
                      child: Text('추가'),
                    ),
                    loading: () =>
                        ElevatedButton(onPressed: null, child: Text('추가 중...')),
                    error: (error, stackTrace) =>
                        ElevatedButton(onPressed: null, child: Text('오류 발생')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
