import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/shot.dart';

class NewShotFormState {
  final DateTime? date;
  final double? aperture; // 2.8
  final String? shutterSpeed; // 1/125
  final String? focusDistance; // 3m
  final double? exposureComp; // +0.3
  final String? note; // 컷 메모
  final int? rating; // 1~5

  NewShotFormState({
    DateTime? date,
    this.aperture,
    this.shutterSpeed,
    this.focusDistance,
    this.exposureComp,
    this.note,
    this.rating,
  }) : date = date ?? DateTime.now();

  NewShotFormState copyWith({
    DateTime? date,
    double? aperture,
    String? shutterSpeed,
    String? focusDistance,
    double? exposureComp,
    String? note,
    int? rating,
  }) {
    return NewShotFormState(
      date: date ?? this.date,
      aperture: aperture ?? this.aperture,
      shutterSpeed: shutterSpeed ?? this.shutterSpeed,
      focusDistance: focusDistance ?? this.focusDistance,
      exposureComp: exposureComp ?? this.exposureComp,
      note: note ?? this.note,
      rating: rating ?? this.rating,
    );
  }

  Shot toShot({required String rollId}) {
    return Shot(
      rollId: rollId,
      date: date,
      aperture: aperture,
      shutterSpeed: shutterSpeed,
      focusDistance: focusDistance,
      exposureComp: exposureComp,
      note: note,
      rating: rating,
    );
  }

  // 필드별 유효성 검사 (필요에 따라 확장)
  bool get apertureValid => aperture == null || aperture! > 0;
  bool get ratingValid => rating == null || (rating! >= 1 && rating! <= 5);

  // 폼 전체 유효성
  bool get isValid {
    return apertureValid && ratingValid;
  }
}

class NewShotFormNotifier extends Notifier<NewShotFormState> {
  @override
  NewShotFormState build() => NewShotFormState();

  void setDate(DateTime? date) {
    state = state.copyWith(date: date);
  }

  void setAperture(double? aperture) {
    state = state.copyWith(aperture: aperture);
  }

  void setShutterSpeed(String? shutterSpeed) {
    state = state.copyWith(shutterSpeed: shutterSpeed);
  }

  void setFocusDistance(String? focusDistance) {
    state = state.copyWith(focusDistance: focusDistance);
  }

  void setExposureComp(double? exposureComp) {
    state = state.copyWith(exposureComp: exposureComp);
  }

  void setNote(String? note) {
    state = state.copyWith(note: note);
  }

  void setRating(int? rating) {
    state = state.copyWith(rating: rating);
  }

  void reset() {
    state = NewShotFormState();
  }
}

final newShotFormProvider =
    NotifierProvider.autoDispose<NewShotFormNotifier, NewShotFormState>(
      NewShotFormNotifier.new,
    );
