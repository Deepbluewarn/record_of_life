// Lens Repository Implementation
import 'package:record_of_life/domain/models/lens.dart';
import 'package:record_of_life/domain/repositories/lens_repository.dart';

class LensRepositoryImpl extends LensRepository {
  static final List<Lens> _lens = [];

  Future<List<Lens>> getAllLenses() async {
    return List.from(_lens);
  }

  @override
  Future<void> addLens(Lens lens) async {
    if (_lens.any((l) => l.id == lens.id)) {
      return;
    }
    _lens.add(lens);
  }

  @override
  Future<bool> deleteLens(String id) async {
    _lens.removeWhere((l) => l.id == id);

    return true;
  }

  @override
  Future<List<Lens>> getLenses(List<String> ids) async {
    return (_lens.where((l) => ids.contains(l.id))).toList();
  }

  @override
  Future<void> updateLens(Lens lens) async {
    final idx = _lens.indexWhere((l) => l.id != lens.id);
    if (idx >= 0) {
      _lens[idx] = lens;
    }
  }
}
