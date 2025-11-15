import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/infra/repositories_impl/roll_repository_impl.dart';
import 'package:record_of_life/infra/repositories_impl/shot_repository_impl.dart';

final shotRepositoryProvider = Provider((ref) {
  return ShotRepositoryImpl();
});

final rollRepositoryProvider = Provider((ref) {
  return RollRepositoryImpl();
});
