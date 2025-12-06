import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/camera.dart';
import 'package:record_of_life/features/roll/presentation/providers/camera_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_camera_form_provider.dart';
import 'package:record_of_life/shared/constants/camera_constants.dart';

class AddCameraBottomSheet extends ConsumerStatefulWidget {
  const AddCameraBottomSheet({super.key});

  @override
  ConsumerState<AddCameraBottomSheet> createState() =>
      _AddCameraBottomSheetState();
}

class _AddCameraBottomSheetState extends ConsumerState<AddCameraBottomSheet> {
  String? _selectedBrand;
  String? _selectedFormat;
  String? _selectedMount;
  bool _isCustomBrand = false;
  bool _isCustomFormat = false;
  bool _isCustomMount = false;

  @override
  Widget build(BuildContext context) {
    final cameraFormProvider = ref.watch(newCameraFormProvider);
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
                      '새 카메라 추가',
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

                // 카메라 이름
                TextField(
                  onChanged: (value) {
                    ref.read(newCameraFormProvider.notifier).setTitle(value);
                  },
                  decoration: InputDecoration(
                    labelText: '카메라 이름 *',
                    hintText: '예: AE-1 Program',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                SizedBox(height: 16),

                // 브랜드 선택
                DropdownButtonFormField<String>(
                  initialValue: _selectedBrand,
                  decoration: InputDecoration(
                    labelText: '브랜드 *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: CameraConstants.commonBrands.map((brand) {
                    return DropdownMenuItem(value: brand, child: Text(brand));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBrand = value;
                      _isCustomBrand = value == '기타 (직접 입력)';
                      if (!_isCustomBrand && value != null) {
                        ref
                            .read(newCameraFormProvider.notifier)
                            .setBrand(value);
                      }
                    });
                  },
                ),
                if (_isCustomBrand) ...[
                  SizedBox(height: 12),
                  TextField(
                    onChanged: (value) {
                      ref.read(newCameraFormProvider.notifier).setBrand(value);
                    },
                    decoration: InputDecoration(
                      labelText: '브랜드 직접 입력',
                      hintText: '예: Zenza Bronica',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ],
                SizedBox(height: 16),

                // 포맷 선택
                DropdownButtonFormField<String>(
                  initialValue: _selectedFormat,
                  decoration: InputDecoration(
                    labelText: '필름 포맷 *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: CameraConstants.commonFormats.map((format) {
                    return DropdownMenuItem(value: format, child: Text(format));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFormat = value;
                      _isCustomFormat = value == '기타 (직접 입력)';
                      if (!_isCustomFormat && value != null) {
                        ref
                            .read(newCameraFormProvider.notifier)
                            .setFormat(value);
                      }
                    });
                  },
                ),
                if (_isCustomFormat) ...[
                  SizedBox(height: 12),
                  TextField(
                    onChanged: (value) {
                      ref.read(newCameraFormProvider.notifier).setFormat(value);
                    },
                    decoration: InputDecoration(
                      labelText: '포맷 직접 입력',
                      hintText: '예: 4x5',
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
                    labelText: '렌즈 마운트',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: CameraConstants.commonMounts.map((mount) {
                    return DropdownMenuItem(value: mount, child: Text(mount));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMount = value;
                      _isCustomMount = value == '기타 (직접 입력)';
                      if (!_isCustomMount && value != null) {
                        ref
                            .read(newCameraFormProvider.notifier)
                            .setMount(value);
                      }
                    });
                  },
                ),
                if (_isCustomMount) ...[
                  SizedBox(height: 12),
                  TextField(
                    onChanged: (value) {
                      ref.read(newCameraFormProvider.notifier).setMount(value);
                    },
                    decoration: InputDecoration(
                      labelText: '마운트 직접 입력',
                      hintText: '예: T2',
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
                    ref.read(newCameraFormProvider.notifier).setNotes(value);
                  },
                  decoration: InputDecoration(
                    labelText: '메모 (선택사항)',
                    hintText: '카메라에 대한 추가 정보를 입력하세요',
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
                  child: cameraFormProvider.when(
                    data: (formState) => ElevatedButton(
                      onPressed: () {
                        ref
                            .read(cameraProvider.notifier)
                            .addCamera(formState.toCamera());
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
                        '카메라 추가하기',
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

Camera getRandomCamera() {
  final brands = ['Canon', 'Nikon', 'Pentax', 'Minolta', 'Olympus'];
  final titles = ['AE-1', 'FM2', 'K1000', 'XD5', 'OM-1'];
  final formats = ['35mm', '120', 'Half'];
  final mounts = ['FD', 'F', 'K', 'MD', 'OM'];

  final random = Random();

  return Camera(
    title: titles[random.nextInt(titles.length)],
    brand: brands[random.nextInt(brands.length)],
    format: formats[random.nextInt(formats.length)],
    mount: mounts[random.nextInt(mounts.length)],
  );
}
