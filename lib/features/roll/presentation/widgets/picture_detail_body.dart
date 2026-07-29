// 사진 상세 body. 대형 타이포 헤로 + 컨텍스트 + 메모.
// 사진 첨부는 스코프 밖 (메모장 + EXIF 브릿지).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/domain/models/shot.dart';
import 'package:record_of_life/features/roll/presentation/providers/lens_provider.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';

class PictureDetailBody extends ConsumerWidget {
  final Shot shot;
  final Roll roll;
  final VoidCallback onOpenEdit;
  const PictureDetailBody({
    super.key,
    required this.shot,
    required this.roll,
    required this.onOpenEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lensName = _resolveLensName(ref, shot.lensId ?? roll.defaultLensId);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('#${shot.idx}',
            style: const TextStyle(fontSize: 14, color: AppColors.inkMuted)),
        const SizedBox(height: 4),
        _HeroLine(shot: shot),
        const SizedBox(height: 4),
        Text(
          _subLine(shot),
          style: const TextStyle(color: AppColors.inkMuted),
        ),
        if (shot.date != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.event, size: 14, color: AppColors.inkMuted),
              const SizedBox(width: 6),
              Text(
                _fmtDate(shot.date!),
                style: const TextStyle(color: AppColors.inkMuted),
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),
        if (shot.rating != null && shot.rating! > 0) ...[
          _Stars(rating: shot.rating!),
          const SizedBox(height: 16),
        ],
        _ContextLine(roll: roll, lensName: lensName),
        if (shot.note != null && shot.note!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _NoteBox(text: shot.note!),
        ],
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: onOpenEdit,
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('편집'),
        ),
      ],
    );
  }

  String? _resolveLensName(WidgetRef ref, String? lensId) {
    if (lensId == null) return null;
    final lenses = ref.watch(lensProvider).value?.lenses ?? const [];
    return lenses.where((l) => l.id == lensId).map((l) => l.name).firstOrNull;
  }

  String _subLine(Shot s) {
    final parts = <String>[];
    if (s.exposureComp != null) parts.add('${s.exposureComp!.label} EV');
    final iso = s.iso ?? roll.film?.iso;
    if (iso != null) parts.add('ISO $iso');
    if (s.focalLength != null) parts.add('${s.focalLength}mm');
    return parts.join(' · ');
  }

  String _fmtDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _HeroLine extends StatelessWidget {
  final Shot shot;
  const _HeroLine({required this.shot});

  @override
  Widget build(BuildContext context) {
    final a = shot.aperture == null ? '—' : 'f/${shot.aperture!.value}';
    final s = shot.shutterSpeed?.label ?? '—';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(a,
            style: const TextStyle(
                fontSize: 40, fontWeight: FontWeight.w900)),
        const SizedBox(width: 14),
        const Text('·',
            style: TextStyle(fontSize: 28, color: AppColors.inkMuted)),
        const SizedBox(width: 14),
        Text(s,
            style: const TextStyle(
                fontSize: 40, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _ContextLine extends StatelessWidget {
  final Roll roll;
  final String? lensName;
  const _ContextLine({required this.roll, required this.lensName});

  @override
  Widget build(BuildContext context) {
    final camera = roll.camera?.title;
    final film = roll.film?.name;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_camera_outlined,
                  size: 14, color: AppColors.inkMuted),
              const SizedBox(width: 6),
              Text(camera ?? '—', style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 10),
              const Icon(Icons.filter_center_focus,
                  size: 14, color: AppColors.inkMuted),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  film ?? '—',
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (lensName != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.lens_outlined,
                    size: 14, color: AppColors.inkMuted),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    lensName!,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.inkMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _NoteBox extends StatelessWidget {
  final String text;
  const _NoteBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notes, size: 14, color: AppColors.inkMuted),
              SizedBox(width: 6),
              Text('메모',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.inkMuted)),
            ],
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final int rating;
  const _Stars({required this.rating});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 1; i <= 5; i++)
          Icon(
            i <= rating ? Icons.star : Icons.star_border,
            size: 18,
            color: i <= rating ? AppColors.ink : AppColors.border,
          ),
      ],
    );
  }
}
