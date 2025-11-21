// Film Repository Implementation

import 'package:record_of_life/domain/models/film.dart';
import 'package:record_of_life/domain/repositories/film_repository.dart';

class FilmRepositoryImpl extends FilmRepository {
  static final List<Film> _films = [
    Film(name: 'Kodak Portra 400', brand: 'Kodak', iso: 400),
    Film(name: 'Fujifilm Pro 400H', brand: 'Fujifilm', iso: 400),
    Film(name: 'Ilford HP5 Plus', brand: 'Ilford', iso: 400),
    Film(name: 'Tri-X 400', brand: 'Kodak', iso: 400),
  ];
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
  Future<List<Film>> getAllFilms() async {
    return [..._films];
  }

  @override
  Future<void> updateFilm(Film film) async {
    final index = _films.indexWhere((f) => f.id == film.id);
    if (index >= 0) {
      _films[index] = film;
    }
  }
}
