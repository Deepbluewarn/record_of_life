import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/camera.dart';

class NewCameraFormState {
  String title;
  String? brand;
  String? format;
  String? mount;
  String? notes;

  NewCameraFormState({
    required this.title,
    this.brand,
    this.format,
    this.mount,
    this.notes,
  });

  NewCameraFormState copyWith({
    String? title,
    String? brand,
    String? format,
    String? mount,
    String? notes,
  }) {
    return NewCameraFormState(
      title: title ?? this.title,
      brand: brand ?? this.brand,
      format: format ?? this.format,
      mount: mount ?? this.mount,
      notes: notes ?? this.notes,
    );
  }

  Camera toCamera() {
    return Camera(
      title: title,
      brand: brand,
      format: format,
      mount: mount,
      notes: notes,
    );
  }
}

class NewCameraFormProvider extends AsyncNotifier<NewCameraFormState> {
  @override
  FutureOr<NewCameraFormState> build() async {
    return NewCameraFormState(title: '');
  }

  void setTitle(String title) {
    state = AsyncValue.data(state.value!.copyWith(title: title));
  }

  void setBrand(String? brand) {
    state = AsyncValue.data(state.value!.copyWith(brand: brand));
  }

  void setFormat(String? format) {
    state = AsyncValue.data(state.value!.copyWith(format: format));
  }

  void setMount(String? mount) {
    state = AsyncValue.data(state.value!.copyWith(mount: mount));
  }

  void setNotes(String? notes) {
    state = AsyncValue.data(state.value!.copyWith(notes: notes));
  }
}

final newCameraFormProvider =
    AsyncNotifierProvider.autoDispose<
      NewCameraFormProvider,
      NewCameraFormState
    >(NewCameraFormProvider.new);
