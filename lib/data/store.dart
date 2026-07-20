import 'package:sembast/sembast.dart';
import 'store_factory.dart'
    if (dart.library.js_interop) 'store_factory_web.dart'
    if (dart.library.io) 'store_factory_io.dart';

class AppStore {
  final Database db;
  AppStore(this.db);

  static Future<AppStore> open() async => AppStore(await openAppDatabase());

  // ponytail: 문서 id = 도메인 모델의 id(String).
  static final rolls = stringMapStoreFactory.store('rolls');
  static final shots = stringMapStoreFactory.store('shots');
  static final cameras = stringMapStoreFactory.store('cameras');
  static final films = stringMapStoreFactory.store('films');
  static final lenses = stringMapStoreFactory.store('lenses');
}
