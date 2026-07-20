import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/features/settings/providers/settings_provider.dart';

// 최초 실행 시 뜨는 손잡이 선택 화면.
// 이후 설정에서 변경 가능(설정 화면은 후속 작업).
class HandednessOnboardingPage extends ConsumerWidget {
  const HandednessOnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Text(
                '어느 손으로\n폰을 잡나요?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '자주 쓰는 버튼을 엄지 사거리에 배치합니다. 설정에서 언제든 바꿀 수 있어요.',
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: _Choice(
                      label: '왼손',
                      icon: Icons.back_hand,
                      onTap: () => _pick(ref, Handedness.left),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _Choice(
                      label: '오른손',
                      icon: Icons.back_hand,
                      flipIcon: true,
                      onTap: () => _pick(ref, Handedness.right),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _pick(WidgetRef ref, Handedness h) {
    ref.read(settingsProvider.notifier).setHandedness(h);
  }
}

class _Choice extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool flipIcon;
  final VoidCallback onTap;

  const _Choice({
    required this.label,
    required this.icon,
    required this.onTap,
    this.flipIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Transform.flip(flipX: flipIcon, child: Icon(icon, size: 48)),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
