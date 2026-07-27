import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/lab.dart';
import 'package:record_of_life/features/roll/presentation/providers/repository_provider.dart';

class LabState {
  final List<Lab> labs;
  const LabState({required this.labs});
}

class LabNotifier extends AsyncNotifier<LabState> {
  late final _repo = ref.read(labRepositoryProvider);

  @override
  Future<LabState> build() async {
    return LabState(labs: await _repo.getAllLabs());
  }

  Future<void> _refresh() async {
    state = AsyncValue.data(LabState(labs: await _repo.getAllLabs()));
  }

  Future<void> add(Lab lab) async {
    await _repo.addLab(lab);
    await _refresh();
  }

  Future<void> save(Lab lab) async {
    await _repo.updateLab(lab);
    await _refresh();
  }

  Future<void> delete(String id) async {
    await _repo.deleteLab(id);
    await _refresh();
  }

  Future<void> touch(String id) async {
    await _repo.touchLab(id);
    await _refresh();
  }
}

final labProvider = AsyncNotifierProvider.autoDispose<LabNotifier, LabState>(
  LabNotifier.new,
);
