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
        if (_open)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          const SizedBox(height: 8),
          _row(
            '플래시',
            Align(
              alignment: Alignment.centerRight,
              child: _togglePill(
                Icons.flash_on,
                '플래시',
                widget.form.flash == true,
                () => widget.n
                    .setFlash(widget.form.flash == true ? null : true),
              ),
            ),
          ),
          _row(
            '초점거리',
            _textField(
              hint: '렌즈 값 상속 (mm)',
              value: widget.form.focalLength?.toString(),
              keyboard: TextInputType.number,
              onChanged: (v) => widget.n.setFocalLength(int.tryParse(v)),
            ),
          ),
          _row(
            '평점',
            _StarPicker(
              rating: widget.form.rating,
              onSelect: widget.n.setRating,
            ),
          ),
          _row(
            '메모',
            _textField(
              hint: '이 사진에 대한 메모',
              value: null,
              onChanged: widget.n.setNote,
              maxLines: null,
            ),
            last: true,
          ),
            ],
          ),
      ],
    );
  }
}

class _StarPicker extends StatelessWidget {
  final int? rating;
  final ValueChanged<int> onSelect;
  const _StarPicker({required this.rating, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: List.generate(5, (i) {
        final star = i + 1;
        final on = rating != null && star <= rating!;
        return GestureDetector(
          onTap: () => onSelect(star),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Icon(
              on ? Icons.star : Icons.star_border,
              size: 22,
              color: on ? AppColors.ink : AppColors.border,
            ),
          ),
        );
      }),
    );
  }
}

Widget _row(String label, Widget child, {bool last = false}) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.inkMuted, fontSize: 12),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    ),
    if (!last) const Divider(height: 1),
  ],
);

Widget _textField({
  required String hint,
  required String? value,
  required ValueChanged<String> onChanged,
  TextInputType? keyboard,
  int? maxLines = 1,
}) {
  return TextFormField(
    initialValue: value,
    keyboardType: keyboard,
    maxLines: maxLines,
    style: const TextStyle(fontSize: 14),
    decoration: InputDecoration(
      border: InputBorder.none,
      isDense: true,
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
    ),
    onChanged: onChanged,
  );
}

Widget _togglePill(IconData icon, String label, bool on, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(999),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: on ? AppColors.ink : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14, color: on ? Colors.white : AppColors.inkMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: on ? Colors.white : AppColors.ink,
            ),
          ),
        ],
      ),
    ),
  );
}

