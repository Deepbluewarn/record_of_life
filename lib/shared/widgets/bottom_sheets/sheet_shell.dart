import 'package:flutter/material.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';

// 새 카메라/필름/렌즈 추가 시 공통 껍데기: 드래그 핸들, 타이틀, 닫기,
// 스크롤 본문, 하단 저장 버튼. 인라인 스타일 대신 테마에 위임.
class BottomSheetShell extends StatelessWidget {
  final String title;
  final Widget body;
  final VoidCallback? onSave;
  final String saveLabel;

  const BottomSheetShell({
    super.key,
    required this.title,
    required this.body,
    required this.onSave,
    this.saveLabel = '추가하기',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                body,
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onSave,
                    child: Text(saveLabel),
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
