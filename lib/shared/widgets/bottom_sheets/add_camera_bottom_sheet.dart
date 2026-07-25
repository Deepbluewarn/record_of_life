import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/features/roll/presentation/providers/camera_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_camera_form_provider.dart';
import 'package:record_of_life/shared/constants/camera_constants.dart';
import 'package:record_of_life/shared/widgets/bottom_sheets/sheet_shell.dart';

class AddCameraBottomSheet extends ConsumerStatefulWidget {
  const AddCameraBottomSheet({super.key});

  @override
  ConsumerState<AddCameraBottomSheet> createState() =>
      _AddCameraBottomSheetState();
}

class _AddCameraBottomSheetState extends ConsumerState<AddCameraBottomSheet> {
  String? _brand;
  String? _format;
  String? _mount;
  bool get _customBrand => _brand == '기타 (직접 입력)';
  bool get _customFormat => _format == '기타 (직접 입력)';
  bool get _customMount => _mount == '기타 (직접 입력)';

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(newCameraFormProvider);
    return BottomSheetShell(
      title: '새 카메라 추가',
      saveLabel: '카메라 추가하기',
      onSave: formState.whenOrNull(
        data: (state) => () {
          ref.read(cameraProvider.notifier).addCamera(state.toCamera());
          Navigator.pop(context);
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (v) =>
                ref.read(newCameraFormProvider.notifier).setTitle(v),
            decoration: const InputDecoration(
              labelText: '카메라 이름 *',
              hintText: '예: AE-1 Program',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _brand,
            decoration: const InputDecoration(labelText: '브랜드 *'),
            items: CameraConstants.commonBrands
                .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                .toList(),
            onChanged: (v) {
              setState(() => _brand = v);
              if (v != null && !_customBrand) {
                ref.read(newCameraFormProvider.notifier).setBrand(v);
              }
            },
          ),
          if (_customBrand) ...[
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) =>
                  ref.read(newCameraFormProvider.notifier).setBrand(v),
              decoration: const InputDecoration(
                labelText: '브랜드 직접 입력',
                hintText: '예: Zenza Bronica',
              ),
            ),
          ],
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _format,
            decoration: const InputDecoration(labelText: '필름 포맷 *'),
            items: CameraConstants.commonFormats
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (v) {
              setState(() => _format = v);
              if (v != null && !_customFormat) {
                ref.read(newCameraFormProvider.notifier).setFormat(v);
              }
            },
          ),
          if (_customFormat) ...[
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) =>
                  ref.read(newCameraFormProvider.notifier).setFormat(v),
              decoration: const InputDecoration(
                labelText: '포맷 직접 입력',
                hintText: '예: 4x5',
              ),
            ),
          ],
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _mount,
            decoration: const InputDecoration(labelText: '렌즈 마운트'),
            items: CameraConstants.commonMounts
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (v) {
              setState(() => _mount = v);
              if (v != null && !_customMount) {
                ref.read(newCameraFormProvider.notifier).setMount(v);
              }
            },
          ),
          if (_customMount) ...[
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) =>
                  ref.read(newCameraFormProvider.notifier).setMount(v),
              decoration: const InputDecoration(
                labelText: '마운트 직접 입력',
                hintText: '예: T2',
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            onChanged: (v) =>
                ref.read(newCameraFormProvider.notifier).setNotes(v),
            decoration: const InputDecoration(
              labelText: '메모 (선택)',
              hintText: '카메라 상태·특이사항',
              alignLabelWithHint: true,
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
