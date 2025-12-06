import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_lens_form_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/lens_provider.dart';
import 'package:record_of_life/shared/constants/lens_constants.dart';

class AddLensBottomSheet extends ConsumerStatefulWidget {
  const AddLensBottomSheet({super.key});

  @override
  ConsumerState<AddLensBottomSheet> createState() => _AddLensBottomSheetState();
}

class _AddLensBottomSheetState extends ConsumerState<AddLensBottomSheet> {
  String? _selectedFocalLength;
  String? _selectedAperture;
  String? _selectedMount;
  bool _isCustomFocalLength = false;
  bool _isCustomAperture = false;
  bool _isCustomMount = false;

  @override
  Widget build(BuildContext context) {
    final lensFormProvider = ref.watch(newLensFormProvider);
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '새 렌즈 추가',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.all(14),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // 렌즈명
                TextField(
                  onChanged: (value) {
                    ref.read(newLensFormProvider.notifier).setName(value);
                  },
                  decoration: InputDecoration(
                    labelText: '렌즈명 *',
                    hintText: '예: Canon FD 50mm f/1.4',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                SizedBox(height: 16),

                // 초점거리 선택
                DropdownButtonFormField<String>(
                  initialValue: _selectedFocalLength,
                  decoration: InputDecoration(
                    labelText: '초점거리 (mm)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: LensConstants.commonFocalLengths.map((focal) {
                    return DropdownMenuItem(value: focal, child: Text(focal));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFocalLength = value;
                      _isCustomFocalLength = value == '기타 (직접 입력)';
                      if (!_isCustomFocalLength && value != null) {
                        final focalValue = int.tryParse(value);
                        ref
                            .read(newLensFormProvider.notifier)
                            .setFocalLength(focalValue);
                      }
                    });
                  },
                ),
                if (_isCustomFocalLength) ...[
                  SizedBox(height: 12),
                  TextField(
                    onChanged: (value) {
                      final focalValue = int.tryParse(value);
                      ref
                          .read(newLensFormProvider.notifier)
                          .setFocalLength(focalValue);
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '초점거리 직접 입력',
                      hintText: '예: 135',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ],
                SizedBox(height: 16),

                // 최대 조리개 선택
                DropdownButtonFormField<String>(
                  initialValue: _selectedAperture,
                  decoration: InputDecoration(
                    labelText: '최대 조리개',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: LensConstants.commonMaxApertures.map((aperture) {
                    return DropdownMenuItem(
                      value: aperture,
                      child: Text(aperture),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAperture = value;
                      _isCustomAperture = value == '기타 (직접 입력)';
                      if (!_isCustomAperture && value != null) {
                        ref
                            .read(newLensFormProvider.notifier)
                            .setMaxAperture(value);
                      }
                    });
                  },
                ),
                if (_isCustomAperture) ...[
                  SizedBox(height: 12),
                  TextField(
                    onChanged: (value) {
                      ref
                          .read(newLensFormProvider.notifier)
                          .setMaxAperture(value);
                    },
                    decoration: InputDecoration(
                      labelText: '조리개 직접 입력',
                      hintText: '예: f/2.8',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ],
                SizedBox(height: 16),

                // 마운트 선택
                DropdownButtonFormField<String>(
                  initialValue: _selectedMount,
                  decoration: InputDecoration(
                    labelText: '마운트',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: LensConstants.commonMounts.map((mount) {
                    return DropdownMenuItem(value: mount, child: Text(mount));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMount = value;
                      _isCustomMount = value == '기타 (직접 입력)';
                      if (!_isCustomMount && value != null) {
                        ref.read(newLensFormProvider.notifier).setMount(value);
                      }
                    });
                  },
                ),
                if (_isCustomMount) ...[
                  SizedBox(height: 12),
                  TextField(
                    onChanged: (value) {
                      ref.read(newLensFormProvider.notifier).setMount(value);
                    },
                    decoration: InputDecoration(
                      labelText: '마운트 직접 입력',
                      hintText: '예: Sony E',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ],
                SizedBox(height: 16),

                // 메모
                TextField(
                  onChanged: (value) {
                    ref.read(newLensFormProvider.notifier).setNotes(value);
                  },
                  decoration: InputDecoration(
                    labelText: '메모 (선택사항)',
                    hintText: '렌즈에 대한 추가 정보를 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 24),

                // 추가 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: lensFormProvider.when(
                    data: (formState) => ElevatedButton(
                      onPressed: () {
                        ref
                            .read(lensProvider.notifier)
                            .addLens(formState.toLens());
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '렌즈 추가하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    loading: () => ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text('추가 중...'),
                    ),
                    error: (error, stackTrace) => ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text('오류 발생'),
                    ),
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
