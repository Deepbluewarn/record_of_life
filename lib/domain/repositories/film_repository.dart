import 'package:record_of_life/domain/models/film.dart';

abstract class FilmRepository {
  Future<List<Film>> getFilms(List<String> ids);
  Future<void> addFilm(Film film);
  Future<void> updateFilm(Film film);
  Future<bool> deleteFilm(String id);
}
