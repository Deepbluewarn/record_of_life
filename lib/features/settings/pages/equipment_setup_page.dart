import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/camera.dart';
import 'package:record_of_life/domain/models/film.dart';
import 'package:record_of_life/domain/models/lens.dart';
import 'package:record_of_life/features/roll/presentation/providers/camera_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/film_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/lens_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/repository_provider.dart';
import 'package:record_of_life/features/settings/providers/settings_provider.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';
import 'package:record_of_life/shared/widgets/bottom_sheets/add_camera_bottom_sheet.dart';
import 'package:record_of_life/shared/widgets/bottom_sheets/add_film_bottom_sheet.dart';
import 'package:record_of_life/shared/widgets/bottom_sheets/add_lens_bottom_sheet.dart';

// 온보딩 및 '내 장비 관리' 페이지 공용.
// isOnboarding=true → 하단 '완료' 버튼이 setEquipmentReady(true).
class EquipmentSetupPage extends ConsumerWidget {
  final bool isOnboarding;
  const EquipmentSetupPage({super.key, this.isOnboarding = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isOnboarding ? '내 장비를 골라주세요' : '내 장비 관리'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          if (isOnboarding)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Text(
                '자주 쓰는 것만 체크하세요. 롤·샷 추가 시 이 목록만 보입니다. '
                '없으면 "직접 추가"로.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          _CamerasSection(),
          _FilmsSection(),
          _LensesSection(),
        ],
      ),
      bottomNavigationBar: isOnboarding
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref
                          .read(settingsProvider.notifier)
                          .setEquipmentReady(true);
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
            )
          : null,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? hint;
  const _SectionHeader({required this.title, this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (hint != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(hint!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.add, color: AppColors.ink),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
      ),
      onTap: onTap,
    );
  }
}

void _openAddSheet(BuildContext context, Widget sheet) {
  showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: sheet,
    ),
  );
}

class _CamerasSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cameraProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(title: '카메라'),
        state.when(
          data: (data) => Column(
            children: [
              for (final c in data.cameras) _CameraCheck(camera: c),
              _AddTile(
                label: '새 카메라 추가',
                onTap: () => _openAddSheet(context, const AddCameraBottomSheet()),
              ),
            ],
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('$e'),
          ),
        ),
      ],
    );
  }
}

class _CameraCheck extends ConsumerWidget {
  final Camera camera;
  const _CameraCheck({required this.camera});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CheckboxListTile(
      value: camera.owned,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(camera.title),
      subtitle: Text(
        '${camera.brand ?? ''}${camera.format != null ? ' · ${camera.format}' : ''}',
        style: const TextStyle(color: AppColors.inkMuted),
      ),
      onChanged: (v) async {
        await ref
            .read(cameraRepositoryProvider)
            .setCameraOwned(camera.id, v ?? false);
        ref.invalidate(cameraProvider);
      },
    );
  }
}

class _FilmsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(filmProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(title: '필름'),
        state.when(
          data: (data) => Column(
            children: [
              for (final f in data.films) _FilmCheck(film: f),
              _AddTile(
                label: '새 필름 추가',
                onTap: () => _openAddSheet(context, const AddFilmBottomSheet()),
              ),
            ],
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('$e'),
          ),
        ),
      ],
    );
  }
}

class _FilmCheck extends ConsumerWidget {
  final Film film;
  const _FilmCheck({required this.film});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CheckboxListTile(
      value: film.owned,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(film.name),
      subtitle: Text(
        '${film.brand ?? ''}${film.iso != null ? ' · ISO ${film.iso}' : ''}',
        style: const TextStyle(color: AppColors.inkMuted),
      ),
      onChanged: (v) async {
        await ref
            .read(filmRepositoryProvider)
            .setFilmOwned(film.id, v ?? false);
        ref.invalidate(filmProvider);
      },
    );
  }
}

class _LensesSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lensProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(title: '렌즈', hint: '선택'),
        state.when(
          data: (data) => Column(
            children: [
              for (final l in data.lenses) _LensCheck(lens: l),
              _AddTile(
                label: '새 렌즈 추가',
                onTap: () => _openAddSheet(context, const AddLensBottomSheet()),
              ),
            ],
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('$e'),
          ),
        ),
      ],
    );
  }
}

class _LensCheck extends ConsumerWidget {
  final Lens lens;
  const _LensCheck({required this.lens});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parts = <String>[
      if (lens.focalLength != null) '${lens.focalLength}mm',
      if (lens.maxAperture != null) 'f/${lens.maxAperture}',
      if (lens.mount != null) lens.mount!,
    ];
    return CheckboxListTile(
      value: lens.owned,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(lens.name),
      subtitle: Text(
        parts.join(' · '),
        style: const TextStyle(color: AppColors.inkMuted),
      ),
      onChanged: (v) async {
        await ref
            .read(lensRepositoryProvider)
            .setLensOwned(lens.id, v ?? false);
        ref.invalidate(lensProvider);
      },
    );
  }
}
