import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/features/roll/presentation/providers/film_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_film_form_provider.dart';
import 'package:record_of_life/shared/constants/film_constants.dart';
import 'package:record_of_life/shared/widgets/bottom_sheets/sheet_shell.dart';

class AddFilmBottomSheet extends ConsumerStatefulWidget {
  const AddFilmBottomSheet({super.key});

  @override
  ConsumerState<AddFilmBottomSheet> createState() => _AddFilmBottomSheetState();
}

class _AddFilmBottomSheetState extends ConsumerState<AddFilmBottomSheet> {
  String? _brand;
  String? _iso;
  String? _format;
  bool get _customBrand => _brand == '기타 (직접 입력)';
  bool get _customIso => _iso == '기타 (직접 입력)';
  bool get _customFormat => _format == '기타 (직접 입력)';

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(newFilmFormProvider);
    return BottomSheetShell(
      title: '새 필름 추가',
      saveLabel: '필름 추가하기',
      onSave: formState.whenOrNull(
        data: (state) => () {
          ref.read(filmProvider.notifier).addFilm(state.toFilm());
          Navigator.pop(context);
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (v) =>
                ref.read(newFilmFormProvider.notifier).setName(v),
            decoration: const InputDecoration(
              labelText: '필름명 *',
              hintText: '예: Portra 400',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _brand,
            decoration: const InputDecoration(labelText: '제조사 *'),
            items: FilmConstants.commonBrands
                .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                .toList(),
            onChanged: (v) {
              setState(() => _brand = v);
              if (v != null && !_customBrand) {
                ref.read(newFilmFormProvider.notifier).setBrand(v);
              }
            },
          ),
          if (_customBrand) ...[
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) =>
                  ref.read(newFilmFormProvider.notifier).setBrand(v),
              decoration: const InputDecoration(
                labelText: '제조사 직접 입력',
                hintText: '예: Rollei',
              ),
            ),
          ],
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _iso,
            decoration: const InputDecoration(labelText: 'ISO *'),
            items: FilmConstants.commonIsos
                .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                .toList(),
            onChanged: (v) {
              setState(() => _iso = v);
              if (v != null && !_customIso) {
                ref
                    .read(newFilmFormProvider.notifier)
                    .setIso(int.tryParse(v));
              }
            },
          ),
          if (_customIso) ...[
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (v) => ref
                  .read(newFilmFormProvider.notifier)
                  .setIso(int.tryParse(v)),
              decoration: const InputDecoration(
                labelText: 'ISO 직접 입력',
                hintText: '예: 125',
              ),
            ),
          ],
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _format,
            decoration: const InputDecoration(labelText: '포맷 *'),
            items: FilmConstants.commonFormats
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (v) {
              setState(() => _format = v);
              if (v != null && !_customFormat) {
                ref.read(newFilmFormProvider.notifier).setFormat(v);
              }
            },
          ),
          if (_customFormat) ...[
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) =>
                  ref.read(newFilmFormProvider.notifier).setFormat(v),
              decoration: const InputDecoration(
                labelText: '포맷 직접 입력',
                hintText: '예: APS',
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            onChanged: (v) =>
                ref.read(newFilmFormProvider.notifier).setNote(v),
            decoration: const InputDecoration(
              labelText: '메모 (선택)',
              hintText: '필름 특성, 유통기한 등',
              alignLabelWithHint: true,
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
