import 'package:record_of_life/domain/models/lab.dart';

abstract class LabRepository {
  Future<List<Lab>> getAllLabs();
  Future<Lab?> getLab(String id);
  Future<void> addLab(Lab lab);
  Future<void> updateLab(Lab lab);
  Future<bool> deleteLab(String id);
  Future<void> touchLab(String id);
}
