import 'package:sembast/sembast.dart';
import 'store.dart';

// 사용자 설정용 단일 record store. codegen·shared_preferences 없이
// 이미 붙어있는 sembast만 재활용.
class SettingsStore {
  static final _store = stringMapStoreFactory.store('settings');
  static const _recordKey = 'app';

  final AppStore _app;
  SettingsStore(this._app);

  Future<Map<String, Object?>> load() async {
    final snap = await _store.record(_recordKey).getSnapshot(_app.db);
    if (snap == null) return const {};
    return Map<String, Object?>.from(snap.value);
  }

  Future<void> put(Map<String, Object?> patch) async {
    final current = await load();
    await _store.record(_recordKey).put(_app.db, {...current, ...patch});
  }
}
