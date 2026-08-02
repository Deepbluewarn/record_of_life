// RECONSTRUCTED: 이 파일의 원본 WIP 은 실수로 revert 되어 git blob 에 남지 않음.
// T9 작업 중 여러 번 읽었던 기억 기반으로 재구성. IDE local history 있으면 대조 필요.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/data/settings_store.dart';
import 'package:record_of_life/features/roll/presentation/providers/repository_provider.dart';

enum Handedness { left, right }

class AppSettings {
  final Handedness? handedness;
  final bool equipmentReady; // 온보딩에서 내 장비 선택 완료 여부
  final String? artist; // EXIF Artist. 빈 문자열/null 모두 미지정.
  final bool artistAsked; // 온보딩에서 Artist 물어봤는지 (스킵 포함)

  const AppSettings({
    this.handedness,
    this.equipmentReady = false,
    this.artist,
    this.artistAsked = false,
  });

  AppSettings copyWith({
    Handedness? handedness,
    bool? equipmentReady,
    String? artist,
    bool? artistAsked,
  }) => AppSettings(
        handedness: handedness ?? this.handedness,
        equipmentReady: equipmentReady ?? this.equipmentReady,
        artist: artist ?? this.artist,
        artistAsked: artistAsked ?? this.artistAsked,
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
      artist: map['artist'] as String?,
      artistAsked: map['artistAsked'] as bool? ?? false,
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

  Future<void> setArtist({required String? name, required bool asked}) async {
    final normalized = name?.trim();
    await ref.read(settingsStoreProvider).put({
      'artist': (normalized == null || normalized.isEmpty) ? null : normalized,
      'artistAsked': asked,
    });
    state = AsyncData(
      (state.value ?? const AppSettings()).copyWith(
        artist: normalized,
        artistAsked: asked,
      ),
    );
  }

  Future<void> resetOnboarding() async {
    await ref.read(settingsStoreProvider).put({
      'handedness': null,
      'equipmentReady': false,
      'artistAsked': false,
    });
    state = const AsyncData(AppSettings());
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
