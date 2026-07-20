import 'package:sembast/sembast_memory.dart';

// ponytail: idb_shim JS interop 버그로 sembast_web 사용 불가 (Dart 3.9.2).
// 웹은 세션 인메모리로 대체 — 새로고침 시 데이터 손실.
// SDK를 3.10+로 올리면 sembast_web으로 교체.
Future<Database> openAppDatabase() =>
    databaseFactoryMemory.openDatabase('record_of_life.db');
