import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/film.dart';
import 'package:record_of_life/features/roll/presentation/providers/repository_provider.dart';

class FilmState {
  final List<Film> films;

  FilmState({required this.films});
}

class FilmNotifier extends AsyncNotifier<FilmState> {
  late final filmRepository = ref.read(filmRepositoryProvider);

  @override
  Future<FilmState> build() async {
    final films = await filmRepository.getAllFilms();
    return FilmState(films: films);
  }

  Future<Film?> getFilm(String id) async {
    return state.whenData((data) {
      return data.films[0];
    }).value;
  }

  Future<List<Film>> getAllFilms() async {
    final films = await filmRepository.getAllFilms();

    return films;
  }

  void addFilm(Film film) async {
    await filmRepository.addFilm(film);
    final updatedFilms = await filmRepository.getAllFilms();

    state = AsyncValue.data(FilmState(films: updatedFilms));
  }
}

final filmProvider = AsyncNotifierProvider.autoDispose<FilmNotifier, FilmState>(
  FilmNotifier.new,
);
