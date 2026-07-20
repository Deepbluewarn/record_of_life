import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/data/store.dart';
import 'package:record_of_life/features/roll/presentation/pages/home_page.dart';
import 'package:record_of_life/features/roll/presentation/providers/repository_provider.dart';
import 'package:record_of_life/features/settings/pages/handedness_onboarding.dart';
import 'package:record_of_life/features/settings/providers/settings_provider.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await AppStore.open();
  runApp(
    ProviderScope(
      overrides: [appStoreProvider.overrideWithValue(store)],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: kIsWeb ? 480 : double.infinity,
            ),
            child: child,
          ),
        );
      },
      home: const _Root(),
    );
  }
}

// 손잡이 미설정 = 온보딩. 설정 완료 = 홈.
class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return settings.when(
      data: (s) => s.handedness == null
          ? const HandednessOnboardingPage()
          : const HomePage(),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('설정 로드 실패: $e'))),
    );
  }
}
