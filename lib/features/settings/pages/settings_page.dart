import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/data/seeds.dart';
import 'package:record_of_life/data/settings_store.dart';
import 'package:record_of_life/data/store.dart';
import 'package:record_of_life/features/roll/presentation/providers/repository_provider.dart';
import 'package:record_of_life/features/settings/pages/equipment_setup_page.dart';
import 'package:record_of_life/features/settings/pages/lab_management_page.dart';
import 'package:record_of_life/features/settings/providers/settings_provider.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';
import 'package:record_of_life/shared/widgets/app_bar.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final handedness = settings.value?.handedness;

    return Scaffold(
      appBar: CustomAppBar(title: 'ROL', subtitle: '설정'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _SectionTitle('사용성'),
          _HandednessRow(current: handedness),
          const SizedBox(height: AppSpacing.xxl),
          _SectionTitle('내 장비'),
          _Tile(
            title: '카메라 · 필름 · 렌즈 관리',
            subtitle: '롤·샷 선택 목록에 노출할 소유 장비를 지정.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EquipmentSetupPage(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _Tile(
            title: '현상소 관리',
            subtitle: '자주 이용하는 필름 현상소를 등록.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LabManagementPage(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _SectionTitle('데이터'),
          _Tile(
            title: '기본 카메라·필름·렌즈 카탈로그 다시 채우기',
            subtitle: '삭제된 시드도 다시 나타납니다. 소유(owned)·편집 값은 유지.',
            onTap: () => _reseed(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _reseed(BuildContext context, WidgetRef ref) async {
    final AppStore app = ref.read(appStoreProvider);
    final settings = SettingsStore(app);
    await settings.put({'seededV1': false});
    await Seeds.ensureSeeded(app, settings);
    ref.invalidate(cameraRepositoryProvider);
    ref.invalidate(filmRepositoryProvider);
    ref.invalidate(lensRepositoryProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('기본 데이터 재삽입 완료')),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _HandednessRow extends ConsumerWidget {
  final Handedness? current;
  const _HandednessRow({required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _HandednessOption(
            label: '왼손',
            selected: current == Handedness.left,
            flipIcon: false,
            onTap: () => ref
                .read(settingsProvider.notifier)
                .setHandedness(Handedness.left),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _HandednessOption(
            label: '오른손',
            selected: current == Handedness.right,
            flipIcon: true,
            onTap: () => ref
                .read(settingsProvider.notifier)
                .setHandedness(Handedness.right),
          ),
        ),
      ],
    );
  }
}

class _HandednessOption extends StatelessWidget {
  final String label;
  final bool selected;
  final bool flipIcon;
  final VoidCallback onTap;

  const _HandednessOption({
    required this.label,
    required this.selected,
    required this.flipIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.background,
          border: Border.all(
            color: selected ? AppColors.ink : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Transform.flip(
              flipX: flipIcon,
              child: Icon(
                Icons.back_hand,
                size: 32,
                color: selected ? Colors.white : AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _Tile({required this.title, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyLarge),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
