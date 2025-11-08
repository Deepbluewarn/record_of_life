import 'package:record_of_life/domain/models/shot.dart';

abstract class ShotRepository {
  Future<List<Shot>> getShots(List<String> ids);
  Future<void> addShot(Shot shot);
  Future<void> updateShot(Shot shot);
  Future<bool> deleteShot(String id);
}
