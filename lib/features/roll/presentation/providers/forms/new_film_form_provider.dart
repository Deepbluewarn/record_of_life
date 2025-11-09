import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/film.dart';

class NewFilmFormState {
  String name;
  String? brand;
  int? iso;
  String? format;
  String? note;

  NewFilmFormState({
    required this.name,
    this.brand,
    this.iso,
    this.format,
    this.note,
  });

  NewFilmFormState copyWith({
    String? name,
    String? brand,
    int? iso,
    String? format,
    String? note,
  }) {
    return NewFilmFormState(
      name: name ?? this.name,
      brand: brand ?? this.brand,
      iso: iso ?? this.iso,
      format: format ?? this.format,
      note: note ?? this.note,
    );
  }

  Film toFilm() {
    return Film(name: name, brand: brand, iso: iso, format: format, note: note);
  }
}

class NewFilmFormProvider extends AsyncNotifier<NewFilmFormState> {
  @override
  FutureOr<NewFilmFormState> build() async {
    return NewFilmFormState(name: '');
  }

  void setName(String name) {
    state = AsyncValue.data(state.value!.copyWith(name: name));
  }

  void setBrand(String? brand) {
    state = AsyncValue.data(state.value!.copyWith(brand: brand));
  }

  void setIso(int? iso) {
    state = AsyncValue.data(state.value!.copyWith(iso: iso));
  }

  void setFormat(String? format) {
    state = AsyncValue.data(state.value!.copyWith(format: format));
  }

  void setNote(String? note) {
    state = AsyncValue.data(state.value!.copyWith(note: note));
  }

  void reset() {
    state = AsyncValue.data(NewFilmFormState(name: ''));
  }
}

final newFilmFormProvider =
    AsyncNotifierProvider.autoDispose<NewFilmFormProvider, NewFilmFormState>(
      NewFilmFormProvider.new,
    );
