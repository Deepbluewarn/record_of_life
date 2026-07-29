// 사진 입력(capture) 폼 — Dial cluster 확정.
// 조리개·셔터·EV·ISO를 2×2 다이얼(WheelSelector). 렌즈·날짜 위, 옵션 접기 아래.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/enums/aperture.dart';
import 'package:record_of_life/domain/enums/exposure_comp.dart';
import 'package:record_of_life/domain/enums/shutter_speed.dart';
import 'package:record_of_life/domain/models/shot.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_shot_form_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/lens_provider.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';
import 'package:record_of_life/shared/widgets/dialogs/lens_selection_dialog.dart';
import 'package:record_of_life/shared/widgets/marquee_text.dart';
import 'package:record_of_life/shared/widgets/wheel_selector.dart';

const List<int?> _commonIsos = [
  null, 25, 50, 100, 125, 160, 200, 250, 320, 400, 500, 640,
  800, 1000, 1250, 1600, 2000, 2500, 3200, 6400,
];

class CaptureForm extends ConsumerWidget {
  final Shot? shot;
  const CaptureForm({super.key, this.shot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(newShotFormProvider(shot));
    final n = ref.read(newShotFormProvider(shot).notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _lensAndDateRow(context, ref, form, n),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            _Dial<Aperture>(
              title: '조리개',
              items: Aperture.values,
              selected: form.aperture,
              labelBuilder: (a) => 'f/${a.value}',
              onSelected: n.setAperture,
            ),
            _Dial<ShutterSpeed>(
              title: '셔터',
              items: ShutterSpeed.values,
              selected: form.shutterSpeed,
              labelBuilder: (s) => s.label,
              onSelected: n.setShutterSpeed,
            ),
            _Dial<ExposureComp>(
              title: '노출 보정',
              items: ExposureComp.values,
              selected: form.exposureComp,
              labelBuilder: (e) => e.label,
              onSelected: n.setExposureComp,
            ),
            _Dial<int?>(
              title: 'ISO 감도',
              items: _commonIsos,
              selected: form.iso,
              labelBuilder: (v) => v == null ? '상속' : v.toString(),
              onSelected: n.setIso,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _OptionsFold(form: form, n: n),
      ],
    );
  }
}

class _Dial<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final T? selected;
  final String Function(T) labelBuilder;
  final void Function(T) onSelected;
  const _Dial({
    required this.title,
    required this.items,
    required this.selected,
    required this.labelBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: WheelSelector<T>(
        title: title,
        items: items,
        selectedItem: selected,
        labelBuilder: labelBuilder,
        onSelected: onSelected,
        itemFontSize: 15,
      ),
    );
  }
}

Widget _lensAndDateRow(
  BuildContext context,
  WidgetRef ref,
  NewShotFormState form,
  NewShotFormNotifier n,
) {
  final lensState = ref.watch(lensProvider);
  final lensName = lensState.when(
    data: (d) {
      if (form.lensId == null || d.lenses.isEmpty) return '렌즈 -';
      final l = d.lenses.firstWhere(
        (l) => l.id == form.lensId,
        orElse: () => d.lenses.first,
      );
      return l.name;
    },
    loading: () => '…',
    error: (_, __) => '렌즈 -',
  );
  final d = form.date;
  return Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => LensSelectionDialog(
              onSelected: (lens) {
                n.setLensId(lens.id);
                Navigator.pop(context);
              },
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.camera_outlined, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: MarqueeText(
                  text: lensName,
                  style: DefaultTextStyle.of(context).style,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: OutlinedButton.icon(
          icon: const Icon(Icons.calendar_today_outlined, size: 16),
          label: Text(
            d != null
                ? '${d.year}. ${d.month.toString().padLeft(2, '0')}. ${d.day.toString().padLeft(2, '0')}'
                : '오늘',
            overflow: TextOverflow.ellipsis,
          ),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: d ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) n.setDate(picked);
          },
        ),
      ),
    ],
  );
}

class _OptionsFold extends StatefulWidget {
  final NewShotFormState form;
  final NewShotFormNotifier n;
  const _OptionsFold({required this.form, required this.n});

  @override
  State<_OptionsFold> createState() => _OptionsFoldState();
}

class _OptionsFoldState extends State<_OptionsFold> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            child: Row(
              children: [
                Icon(_open ? Icons.expand_less : Icons.expand_more, size: 18),
                const SizedBox(width: 8),
                Text('추가 옵션', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
        if (_open) ...[
          const SizedBox(height: 14),
          TextFormField(
            initialValue: widget.form.focalLength?.toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '초점거리 (mm)',
              hintText: '렌즈 값 상속',
            ),
            onChanged: (v) => widget.n.setFocalLength(int.tryParse(v)),
          ),
          const SizedBox(height: 14),
          _RatingRow(
            rating: widget.form.rating,
            onSelect: widget.n.setRating,
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: widget.n.setNote,
            decoration: const InputDecoration(hintText: '사진에 대한 메모'),
            maxLines: 2,
          ),
        ],
      ],
    );
  }
}

class _RatingRow extends StatelessWidget {
  final int? rating;
  final ValueChanged<int> onSelect;
  const _RatingRow({required this.rating, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final star = i + 1;
        final on = rating != null && star <= rating!;
        return IconButton(
          icon: Icon(
            on ? Icons.star : Icons.star_border,
            color: on ? AppColors.ink : AppColors.border,
            size: 26,
          ),
          onPressed: () => onSelect(star),
        );
      }),
    );
  }
}

