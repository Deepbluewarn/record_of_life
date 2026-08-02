import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/enums/aperture.dart';
import 'package:record_of_life/domain/enums/exposure_comp.dart';
import 'package:record_of_life/domain/enums/shutter_speed.dart';
import 'package:record_of_life/domain/models/shot.dart';

class NewShotFormState {
  final int idx;
  final DateTime? date;
  final String? lensId;
  final Aperture? aperture;
  final ShutterSpeed? shutterSpeed;
  final ExposureComp? exposureComp;
  final int? iso;
  final int? focalLength;
  final String? note;
  final int? rating;
  final bool? flash;
  final String? filter;
  final bool? tripod;

  NewShotFormState({
    this.idx = 1,
    DateTime? date,
    this.lensId,
    this.aperture,
    this.shutterSpeed,
    ExposureComp? exposureComp,
    this.iso,
    this.focalLength,
    this.note,
    this.rating,
    this.flash,
    this.filter,
    this.tripod,
  }) : date = date ?? DateTime.now(),
       exposureComp = exposureComp ?? ExposureComp.zero;

  NewShotFormState copyWith({
    int? idx,
    DateTime? date,
    String? lensId,
    Aperture? aperture,
    ShutterSpeed? shutterSpeed,
    ExposureComp? exposureComp,
    int? iso,
    int? focalLength,
    String? note,
    int? rating,
    bool? flash,
    String? filter,
    bool? tripod,
  }) {
    return NewShotFormState(
      idx: idx ?? this.idx,
      date: date ?? this.date,
      lensId: lensId ?? this.lensId,
      aperture: aperture ?? this.aperture,
      shutterSpeed: shutterSpeed ?? this.shutterSpeed,
      exposureComp: exposureComp ?? this.exposureComp,
      iso: iso ?? this.iso,
      focalLength: focalLength ?? this.focalLength,
      note: note ?? this.note,
      rating: rating ?? this.rating,
      flash: flash ?? this.flash,
      filter: filter ?? this.filter,
      tripod: tripod ?? this.tripod,
    );
  }

  Shot toShot({String? shotId, required String rollId}) {
    return Shot(
      id: shotId,
      rollId: rollId,
      idx: idx,
      date: date,
      lensId: lensId,
      aperture: aperture,
      shutterSpeed: shutterSpeed,
      exposureComp: exposureComp,
      iso: iso,
      focalLength: focalLength,
      note: note,
      rating: rating,
      flash: flash,
      filter: filter,
      tripod: tripod,
    );
  }

  bool get apertureValid => aperture != null;
  bool get ratingValid => rating == null || (rating! >= 1 && rating! <= 5);

  bool get isValid {
    return apertureValid && ratingValid;
  }
}

class NewShotFormNotifier extends Notifier<NewShotFormState> {
  final Shot? _shot;

  NewShotFormNotifier(this._shot);

  @override
  NewShotFormState build() {
    if (_shot != null) {
      return NewShotFormState(
        idx: _shot.idx,
        date: _shot.date,
        lensId: _shot.lensId,
        aperture: _shot.aperture,
        shutterSpeed: _shot.shutterSpeed,
        exposureComp: _shot.exposureComp,
        iso: _shot.iso,
        focalLength: _shot.focalLength,
        note: _shot.note,
        rating: _shot.rating,
        flash: _shot.flash,
        filter: _shot.filter,
        tripod: _shot.tripod,
      );
    }
    return NewShotFormState();
  }

  void setDate(DateTime? date) => state = state.copyWith(date: date);
  void setLensId(String? lensId) => state = state.copyWith(lensId: lensId);
  void setAperture(Aperture? aperture) =>
      state = state.copyWith(aperture: aperture);
  void setShutterSpeed(ShutterSpeed? shutterSpeed) =>
      state = state.copyWith(shutterSpeed: shutterSpeed);
  void setExposureComp(ExposureComp? exposureComp) =>
      state = state.copyWith(exposureComp: exposureComp);
  void setIso(int? iso) => state = state.copyWith(iso: iso);
  void setFocalLength(int? focalLength) =>
      state = state.copyWith(focalLength: focalLength);
  void setNote(String? note) => state = state.copyWith(note: note);
  void setRating(int? rating) => state = state.copyWith(rating: rating);
  void setFlash(bool? flash) => state = state.copyWith(flash: flash);
  void setFilter(String? filter) => state = state.copyWith(filter: filter);
  void setTripod(bool? tripod) => state = state.copyWith(tripod: tripod);

  void reset() {
    state = NewShotFormState();
  }

  // 입력 모드에서 저장 후: 기술 세팅(조리개/셔터/노출/렌즈/iso/focal) 유지,
  // 샷별 콘텐츠(평점/메모/사진)와 date는 리셋.
  void resetForNextShot() {
    state = NewShotFormState(
      lensId: state.lensId,
      aperture: state.aperture,
      shutterSpeed: state.shutterSpeed,
      exposureComp: state.exposureComp,
      iso: state.iso,
      focalLength: state.focalLength,
    );
  }
}

final newShotFormProvider = NotifierProvider.family
    .autoDispose<NewShotFormNotifier, NewShotFormState, Shot?>(
      NewShotFormNotifier.new,
    );
