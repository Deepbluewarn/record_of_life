import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/enums/aperture.dart';
import 'package:record_of_life/domain/enums/exposure_comp.dart';
import 'package:record_of_life/domain/enums/shutter_speed.dart';
import 'package:record_of_life/domain/models/shot.dart';

class NewShotFormState {
  final DateTime? date;
  final Aperture? aperture;
  final ShutterSpeed? shutterSpeed;
  final ExposureComp? exposureComp;
  final String? note;
  final int? rating;

  NewShotFormState({
    DateTime? date,
    this.aperture,
    this.shutterSpeed,
    this.exposureComp,
    this.note,
    this.rating,
  }) : date = date ?? DateTime.now();

  NewShotFormState copyWith({
    DateTime? date,
    Aperture? aperture,
    ShutterSpeed? shutterSpeed,
    ExposureComp? exposureComp,
    String? note,
    int? rating,
  }) {
    return NewShotFormState(
      date: date ?? this.date,
      aperture: aperture ?? this.aperture,
      shutterSpeed: shutterSpeed ?? this.shutterSpeed,
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
      exposureComp: exposureComp,
      note: note,
      rating: rating,
    );
  }

  bool get apertureValid => aperture != null;
  bool get ratingValid => rating == null || (rating! >= 1 && rating! <= 5);

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

  void reset() {
    state = NewShotFormState();
  }
}

final newShotFormProvider =
    NotifierProvider.autoDispose<NewShotFormNotifier, NewShotFormState>(
      NewShotFormNotifier.new,
    );
