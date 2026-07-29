import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/features/settings/providers/settings_provider.dart';
import 'package:record_of_life/features/settings/widgets/equipment_sections.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';

class OnboardingEquipmentPage extends ConsumerWidget {
  const OnboardingEquipmentPage({super.key});

  Future<void> _finish(WidgetRef ref) =>
      ref.read(settingsProvider.notifier).setEquipmentReady(true);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(
                Icons.camera_outlined,
                size: 72,
                color: AppColors.inkMuted,
              ),
              const SizedBox(height: 20),
              Text(
                '장비 등록',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const Text(
                '카메라, 필름, 렌즈를 미리 등록할 수 있습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.inkMuted, height: 1.5),
              ),
              const Spacer(),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _RegisterHub(onComplete: () => _finish(ref)),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text(
                    '장비 등록하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => _finish(ref),
                  child: const Text(
                    '지금은 건너뛰기',
                    style: TextStyle(
                      color: AppColors.inkMuted,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 온보딩 등록 허브 = 설정 '내 장비 관리'와 동일 섹션 + 하단 '완료' 버튼.
// onComplete: '완료' 전용. 뒤로가기는 온보딩 안 넘김.
class _RegisterHub extends StatelessWidget {
  final VoidCallback? onComplete;
  const _RegisterHub({this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('장비 등록')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  CamerasSection(),
                  SizedBox(height: 16),
                  FilmsSection(),
                  SizedBox(height: 16),
                  LensesSection(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    onComplete?.call();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '완료',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
