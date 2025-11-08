import 'package:record_of_life/domain/models/lens.dart';

abstract class LensRepository {
  Future<List<Lens>> getLenss(List<String> ids);
  Future<void> addLens(Lens lens);
  Future<void> updateLens(Lens lens);
  Future<bool> deleteLens(String id);
}
