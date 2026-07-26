import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/data/settings_store.dart';
import 'package:record_of_life/features/roll/presentation/providers/repository_provider.dart';

enum Handedness { left, right }

class AppSettings {
  final Handedness? handedness;
  final bool equipmentReady; // 온보딩에서 내 장비 선택 완료 여부

  const AppSettings({this.handedness, this.equipmentReady = false});

  AppSettings copyWith({Handedness? handedness, bool? equipmentReady}) =>
      AppSettings(
        handedness: handedness ?? this.handedness,
        equipmentReady: equipmentReady ?? this.equipmentReady,
      );
}

final settingsStoreProvider = Provider(
  (ref) => SettingsStore(ref.watch(appStoreProvider)),
);

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final map = await ref.read(settingsStoreProvider).load();
    final h = map['handedness'] as String?;
    return AppSettings(
      handedness: h == null
          ? null
          : Handedness.values.firstWhere(
              (v) => v.name == h,
              orElse: () => Handedness.right,
            ),
      equipmentReady: map['equipmentReady'] as bool? ?? false,
    );
  }

  Future<void> setHandedness(Handedness value) async {
    await ref.read(settingsStoreProvider).put({'handedness': value.name});
    state = AsyncData(
      (state.value ?? const AppSettings()).copyWith(handedness: value),
    );
  }

  Future<void> setEquipmentReady(bool value) async {
    await ref.read(settingsStoreProvider).put({'equipmentReady': value});
    state = AsyncData(
      (state.value ?? const AppSettings()).copyWith(equipmentReady: value),
    );
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
