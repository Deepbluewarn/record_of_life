import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_lens_form_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/lens_provider.dart';
import 'package:record_of_life/shared/constants/lens_constants.dart';
import 'package:record_of_life/shared/widgets/bottom_sheets/sheet_shell.dart';

class AddLensBottomSheet extends ConsumerStatefulWidget {
  const AddLensBottomSheet({super.key});

  @override
  ConsumerState<AddLensBottomSheet> createState() => _AddLensBottomSheetState();
}

class _AddLensBottomSheetState extends ConsumerState<AddLensBottomSheet> {
  String? _focal;
  String? _aperture;
  String? _mount;
  bool get _customFocal => _focal == '기타 (직접 입력)';
  bool get _customAperture => _aperture == '기타 (직접 입력)';
  bool get _customMount => _mount == '기타 (직접 입력)';

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(newLensFormProvider);
    return BottomSheetShell(
      title: '새 렌즈 추가',
      saveLabel: '렌즈 추가하기',
      onSave: formState.whenOrNull(
        data: (state) => () {
          ref.read(lensProvider.notifier).addLens(state.toLens());
          Navigator.pop(context);
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (v) =>
                ref.read(newLensFormProvider.notifier).setName(v),
            decoration: const InputDecoration(
              labelText: '렌즈명 *',
              hintText: '예: Canon FD 50mm f/1.4',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _focal,
            decoration: const InputDecoration(labelText: '초점거리 (mm)'),
            items: LensConstants.commonFocalLengths
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (v) {
              setState(() => _focal = v);
              if (v != null && !_customFocal) {
                ref
                    .read(newLensFormProvider.notifier)
                    .setFocalLength(int.tryParse(v));
              }
            },
          ),
          if (_customFocal) ...[
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (v) => ref
                  .read(newLensFormProvider.notifier)
                  .setFocalLength(int.tryParse(v)),
              decoration: const InputDecoration(
                labelText: '초점거리 직접 입력',
                hintText: '예: 135',
              ),
            ),
          ],
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _aperture,
            decoration: const InputDecoration(labelText: '최대 조리개'),
            items: LensConstants.commonMaxApertures
                .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                .toList(),
            onChanged: (v) {
              setState(() => _aperture = v);
              if (v != null && !_customAperture) {
                ref.read(newLensFormProvider.notifier).setMaxAperture(v);
              }
            },
          ),
          if (_customAperture) ...[
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) =>
                  ref.read(newLensFormProvider.notifier).setMaxAperture(v),
              decoration: const InputDecoration(
                labelText: '조리개 직접 입력',
                hintText: '예: f/2.8',
              ),
            ),
          ],
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _mount,
            decoration: const InputDecoration(labelText: '마운트'),
            items: LensConstants.commonMounts
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (v) {
              setState(() => _mount = v);
              if (v != null && !_customMount) {
                ref.read(newLensFormProvider.notifier).setMount(v);
              }
            },
          ),
          if (_customMount) ...[
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) =>
                  ref.read(newLensFormProvider.notifier).setMount(v),
              decoration: const InputDecoration(
                labelText: '마운트 직접 입력',
                hintText: '예: Sony E',
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            onChanged: (v) =>
                ref.read(newLensFormProvider.notifier).setNotes(v),
            decoration: const InputDecoration(
              labelText: '메모 (선택)',
              hintText: '렌즈 특성·상태',
              alignLabelWithHint: true,
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
