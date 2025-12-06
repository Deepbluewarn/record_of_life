import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/lens.dart';

class NewLensFormState {
  final String name;
  final int? focalLength;
  final String? maxAperture;
  final String? mount;
  final String? notes;

  NewLensFormState({
    required this.name,
    this.focalLength,
    this.maxAperture,
    this.mount,
    this.notes,
  });

  NewLensFormState copyWith({
    String? name,
    int? focalLength,
    String? maxAperture,
    String? mount,
    String? notes,
  }) {
    return NewLensFormState(
      name: name ?? this.name,
      focalLength: focalLength ?? this.focalLength,
      maxAperture: maxAperture ?? this.maxAperture,
      mount: mount ?? this.mount,
      notes: notes ?? this.notes,
    );
  }

  Lens toLens() {
    return Lens(
      name: name,
      focalLength: focalLength,
      maxAperture: maxAperture != null
          ? double.tryParse(maxAperture!.replaceAll('f/', ''))
          : null,
      mount: mount,
      notes: notes,
    );
  }
}

class NewLensFormProvider extends AsyncNotifier<NewLensFormState> {
  @override
  FutureOr<NewLensFormState> build() async {
    return NewLensFormState(name: '');
  }

  void setName(String name) {
    state = AsyncValue.data(state.value!.copyWith(name: name));
  }

  void setFocalLength(int? focalLength) {
    state = AsyncValue.data(state.value!.copyWith(focalLength: focalLength));
  }

  void setMaxAperture(String? maxAperture) {
    state = AsyncValue.data(state.value!.copyWith(maxAperture: maxAperture));
  }

  void setMount(String? mount) {
    state = AsyncValue.data(state.value!.copyWith(mount: mount));
  }

  void setNotes(String? notes) {
    state = AsyncValue.data(state.value!.copyWith(notes: notes));
  }

  void reset() {
    state = AsyncValue.data(NewLensFormState(name: ''));
  }
}

final newLensFormProvider =
    AsyncNotifierProvider.autoDispose<NewLensFormProvider, NewLensFormState>(
      NewLensFormProvider.new,
    );
