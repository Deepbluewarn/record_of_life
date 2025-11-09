import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/film.dart';
import 'package:record_of_life/infra/repositories_impl/film_repository_impl.dart';

class FilmState {
  final List<Film> films;

  FilmState({required this.films});
}

class FilmNotifier extends AsyncNotifier<FilmState> {
  final filmRepository = FilmRepositoryImpl();

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
