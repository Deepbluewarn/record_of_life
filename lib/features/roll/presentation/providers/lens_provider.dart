import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/lens.dart';
import 'package:record_of_life/infra/repositories_impl/lens_repository_impl.dart';

class LensState {
  final List<Lens> lenses;

  LensState({required this.lenses});
}

class LensNotifier extends AsyncNotifier<LensState> {
  final lensRepository = LensRepositoryImpl();

  @override
  Future<LensState> build() async {
    final allLenses = await lensRepository.getAllLenses();
    return LensState(lenses: allLenses);
  }

  Future<List<Lens>> getLenses(List<String> ids) async {
    return await lensRepository.getLenses(ids);
  }

  Future<void> addLens(Lens lens) async {
    await lensRepository.addLens(lens);
    // 전체 렌즈 목록을 다시 가져올 방법이 필요
    // 임시로 현재 state에 추가
    state = state.whenData((data) {
      return LensState(lenses: [...data.lenses, lens]);
    });
  }

  Future<void> updateLens(Lens lens) async {
    await lensRepository.updateLens(lens);
    state = state.whenData((data) {
      final updatedLenses = data.lenses.map((l) {
        return l.id == lens.id ? lens : l;
      }).toList();
      return LensState(lenses: updatedLenses);
    });
  }

  Future<void> deleteLens(String id) async {
    await lensRepository.deleteLens(id);
    state = state.whenData((data) {
      final updatedLenses = data.lenses.where((l) => l.id != id).toList();
      return LensState(lenses: updatedLenses);
    });
  }
}

final lensProvider = AsyncNotifierProvider<LensNotifier, LensState>(
  LensNotifier.new,
);
