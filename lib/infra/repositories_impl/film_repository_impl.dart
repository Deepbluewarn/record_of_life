// Film Repository Implementation

import 'package:record_of_life/domain/models/film.dart';
import 'package:record_of_life/domain/repositories/film_repository.dart';

class FilmRepositoryImpl extends FilmRepository {
  final List<Film> _films = [];
  @override
  Future<void> addFilm(Film film) async {
    if (_films.any((f) => f.id == film.id)) {
      return;
    }
    _films.add(film);
  }

  @override
  Future<bool> deleteFilm(String id) async {
    _films.removeWhere((f) => f.id == id);

    return true;
  }

  @override
  Future<List<Film>> getFilms(List<String> ids) async {
    return (_films.where((t) => ids.contains(t.id))).toList();
  }

  @override
  Future<void> updateFilm(Film film) async {
    final index = _films.indexWhere((f) => f.id == film.id);
    if (index >= 0) {
      _films[index] = film;
    }
  }
}
