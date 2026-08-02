import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/features/settings/providers/settings_provider.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';

class OnboardingArtistPage extends ConsumerStatefulWidget {
  const OnboardingArtistPage({super.key});

  @override
  ConsumerState<OnboardingArtistPage> createState() =>
      _OnboardingArtistPageState();
}

class _OnboardingArtistPageState extends ConsumerState<OnboardingArtistPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish({required bool save}) async {
    await ref.read(settingsProvider.notifier).setArtist(
      name: save ? _controller.text : null,
      asked: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(
                Icons.person_outline,
                size: 72,
                color: AppColors.inkMuted,
              ),
              const SizedBox(height: 20),
              Text(
                '이름을 입력하세요',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'EXIF의 Artist 항목으로 들어갑니다. (선택)',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.inkMuted, height: 1.5),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _finish(save: true),
                decoration: const InputDecoration(
                  hintText: '예: 홍길동',
                  border: OutlineInputBorder(),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _finish(save: true),
                  child: const Text(
                    '저장하고 시작',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => _finish(save: false),
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
