import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/data/store.dart';
import 'package:record_of_life/infra/repositories_impl/camera_repository_impl.dart';
import 'package:record_of_life/infra/repositories_impl/film_repository_impl.dart';
import 'package:record_of_life/infra/repositories_impl/lab_repository_impl.dart';
import 'package:record_of_life/infra/repositories_impl/lens_repository_impl.dart';
import 'package:record_of_life/infra/repositories_impl/roll_repository_impl.dart';
import 'package:record_of_life/infra/repositories_impl/shot_repository_impl.dart';

// main()에서 override 필수.
final appStoreProvider = Provider<AppStore>(
  (ref) => throw UnimplementedError('appStoreProvider must be overridden'),
);

final rollRepositoryProvider = Provider(
  (ref) => RollRepositoryImpl(ref.watch(appStoreProvider)),
);
final shotRepositoryProvider = Provider(
  (ref) => ShotRepositoryImpl(ref.watch(appStoreProvider)),
);
final cameraRepositoryProvider = Provider(
  (ref) => CameraRepositoryImpl(ref.watch(appStoreProvider)),
);
final filmRepositoryProvider = Provider(
  (ref) => FilmRepositoryImpl(ref.watch(appStoreProvider)),
);
final lensRepositoryProvider = Provider(
  (ref) => LensRepositoryImpl(ref.watch(appStoreProvider)),
);
final labRepositoryProvider = Provider(
  (ref) => LabRepositoryImpl(ref.watch(appStoreProvider)),
);
