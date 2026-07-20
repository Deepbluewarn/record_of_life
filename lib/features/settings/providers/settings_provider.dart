import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/data/settings_store.dart';
import 'package:record_of_life/features/roll/presentation/providers/repository_provider.dart';

enum Handedness { left, right }

class AppSettings {
  final Handedness? handedness; // null = 아직 온보딩 미완
  const AppSettings({this.handedness});

  AppSettings copyWith({Handedness? handedness}) =>
      AppSettings(handedness: handedness ?? this.handedness);
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
    );
  }

  Future<void> setHandedness(Handedness value) async {
    await ref.read(settingsStoreProvider).put({'handedness': value.name});
    state = AsyncData((state.value ?? const AppSettings())
        .copyWith(handedness: value));
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
