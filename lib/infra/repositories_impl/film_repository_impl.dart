import 'package:sembast/sembast.dart';
import 'package:record_of_life/data/store.dart';
import 'package:record_of_life/domain/models/film.dart';
import 'package:record_of_life/domain/repositories/film_repository.dart';

class FilmRepositoryImpl extends FilmRepository {
  final AppStore _store;
  FilmRepositoryImpl(this._store);

  @override
  Future<void> addFilm(Film film) async {
    await AppStore.films.record(film.id).put(_store.db, film.toMap());
  }

  @override
  Future<bool> deleteFilm(String id) async {
    final removed = await AppStore.films.record(id).delete(_store.db);
    return removed != null;
  }

  @override
  Future<List<Film>> getFilms(List<String> ids) async {
    final snaps = await AppStore.films.records(ids).getSnapshots(_store.db);
    return [
      for (final s in snaps)
        if (s != null) Film.fromMap(Map<String, Object?>.from(s.value)),
    ];
  }

  @override
  Future<List<Film>> getAllFilms() async {
    final snaps = await AppStore.films.find(_store.db);
    final list = snaps
        .map((s) => Film.fromMap(Map<String, Object?>.from(s.value)))
        .toList();
    list.sort(_byRecency);
    return list;
  }

  @override
  Future<void> updateFilm(Film film) async {
    await AppStore.films.record(film.id).put(_store.db, film.toMap());
  }

  @override
  Future<void> touchFilm(String id) async {
    await AppStore.films.record(id).update(_store.db, {
      'lastUsedAt': DateTime.now().toIso8601String(),
    });
  }
}

int _byRecency(Film a, Film b) {
  final aT = a.lastUsedAt;
  final bT = b.lastUsedAt;
  if (aT == null && bT == null) return a.name.compareTo(b.name);
  if (aT == null) return 1;
  if (bT == null) return -1;
  return bT.compareTo(aT);
}
