import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/enums/aperture.dart';
import 'package:record_of_life/domain/enums/exposure_comp.dart';
import 'package:record_of_life/domain/enums/shutter_speed.dart';
import 'package:record_of_life/domain/models/shot.dart';

class NewShotFormState {
  final DateTime? date;
  final String? lensId;
  final Aperture? aperture;
  final ShutterSpeed? shutterSpeed;
  final ExposureComp? exposureComp;
  final String? note;
  final int? rating;
  final String? imagePath;

  NewShotFormState({
    DateTime? date,
    this.lensId,
    this.aperture,
    this.shutterSpeed,
    this.exposureComp,
    this.note,
    this.rating,
    this.imagePath,
  }) : date = date ?? DateTime.now();

  NewShotFormState copyWith({
    DateTime? date,
    String? lensId,
    Aperture? aperture,
    ShutterSpeed? shutterSpeed,
    ExposureComp? exposureComp,
    String? note,
    int? rating,
    String? imagePath,
  }) {
    return NewShotFormState(
      date: date ?? this.date,
      lensId: lensId ?? this.lensId,
      aperture: aperture ?? this.aperture,
      shutterSpeed: shutterSpeed ?? this.shutterSpeed,
      exposureComp: exposureComp ?? this.exposureComp,
      note: note ?? this.note,
      rating: rating ?? this.rating,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Shot toShot({String? shotId, required String rollId}) {
    return Shot(
      id: shotId,
      rollId: rollId,
      date: date,
      lensId: lensId,
      aperture: aperture,
      shutterSpeed: shutterSpeed,
      exposureComp: exposureComp,
      note: note,
      rating: rating,
      imagePath: imagePath,
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
        date: _shot.date,
        lensId: _shot.lensId,
        aperture: _shot.aperture,
        shutterSpeed: _shot.shutterSpeed,
        exposureComp: _shot.exposureComp,
        note: _shot.note,
        rating: _shot.rating,
        imagePath: _shot.imagePath,
      );
    }
    return NewShotFormState();
  }

  void setDate(DateTime? date) {
    state = state.copyWith(date: date);
  }

  void setLensId(String? lensId) {
    state = state.copyWith(lensId: lensId);
  }

  void setAperture(Aperture? aperture) {
    state = state.copyWith(aperture: aperture);
  }

  void setShutterSpeed(ShutterSpeed? shutterSpeed) {
    state = state.copyWith(shutterSpeed: shutterSpeed);
  }

  void setExposureComp(ExposureComp? exposureComp) {
    state = state.copyWith(exposureComp: exposureComp);
  }

  void setNote(String? note) {
    state = state.copyWith(note: note);
  }

  void setRating(int? rating) {
    state = state.copyWith(rating: rating);
  }

  void setImagePath(String? imagePath) {
    state = state.copyWith(imagePath: imagePath);
  }

  void reset() {
    state = NewShotFormState();
  }
}

final newShotFormProvider = NotifierProvider.family
    .autoDispose<NewShotFormNotifier, NewShotFormState, Shot?>(
      NewShotFormNotifier.new,
    );
