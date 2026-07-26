import 'package:record_of_life/domain/models/camera.dart';
import 'package:record_of_life/domain/models/film.dart';
import 'package:record_of_life/domain/models/lens.dart';
import 'package:record_of_life/data/settings_store.dart';
import 'package:record_of_life/data/store.dart';
import 'package:sembast/sembast.dart';

// 개발·시연 편의용 초기 데이터. 사용자가 삭제하면 다시 안 채워짐.
// ponytail: 큐레이션은 흔한 필름 사진 장비 중심. 100% 스펙 검증 X — 사용자가 수정.
class Seeds {
  static const _seededKey = 'seededV1';

  static Future<void> ensureSeeded(AppStore app, SettingsStore settings) async {
    final s = await settings.load();
    if (s[_seededKey] == true) return;

    await app.db.transaction((txn) async {
      for (final c in _cameras) {
        await AppStore.cameras.record(c.id).put(txn, c.toMap());
      }
      for (final f in _films) {
        await AppStore.films.record(f.id).put(txn, f.toMap());
      }
      for (final l in _lenses) {
        await AppStore.lenses.record(l.id).put(txn, l.toMap());
      }
    });
    await settings.put({_seededKey: true});
  }

  static final _cameras = [
    Camera(title: 'Canon AE-1', brand: 'Canon', format: '35mm', mount: 'FD'),
    Camera(title: 'Canon AE-1 Program', brand: 'Canon', format: '35mm', mount: 'FD'),
    Camera(title: 'Canon A-1', brand: 'Canon', format: '35mm', mount: 'FD'),
    Camera(title: 'Canon F-1', brand: 'Canon', format: '35mm', mount: 'FD'),
    Camera(title: 'Canon EOS 1V', brand: 'Canon', format: '35mm', mount: 'EF'),
    Camera(title: 'Nikon FM2', brand: 'Nikon', format: '35mm', mount: 'F'),
    Camera(title: 'Nikon FM3A', brand: 'Nikon', format: '35mm', mount: 'F'),
    Camera(title: 'Nikon FE2', brand: 'Nikon', format: '35mm', mount: 'F'),
    Camera(title: 'Nikon F3', brand: 'Nikon', format: '35mm', mount: 'F'),
    Camera(title: 'Nikon F100', brand: 'Nikon', format: '35mm', mount: 'F'),
    Camera(title: 'Pentax K1000', brand: 'Pentax', format: '35mm', mount: 'K'),
    Camera(title: 'Pentax MX', brand: 'Pentax', format: '35mm', mount: 'K'),
    Camera(title: 'Pentax LX', brand: 'Pentax', format: '35mm', mount: 'K'),
    Camera(title: 'Pentax 67', brand: 'Pentax', format: '120', mount: '67'),
    Camera(title: 'Olympus OM-1', brand: 'Olympus', format: '35mm', mount: 'OM'),
    Camera(title: 'Olympus OM-4', brand: 'Olympus', format: '35mm', mount: 'OM'),
    Camera(title: 'Minolta X-700', brand: 'Minolta', format: '35mm', mount: 'MD'),
    Camera(title: 'Contax T2', brand: 'Contax', format: '35mm'),
    Camera(title: 'Contax T3', brand: 'Contax', format: '35mm'),
    Camera(title: 'Contax G2', brand: 'Contax', format: '35mm', mount: 'G'),
    Camera(title: 'Yashica Electro 35', brand: 'Yashica', format: '35mm'),
    Camera(title: 'Leica M3', brand: 'Leica', format: '35mm', mount: 'M'),
    Camera(title: 'Leica M6', brand: 'Leica', format: '35mm', mount: 'M'),
    Camera(title: 'Leica M7', brand: 'Leica', format: '35mm', mount: 'M'),
    Camera(title: 'Rolleiflex 2.8F', brand: 'Rollei', format: '120'),
    Camera(title: 'Hasselblad 500 C/M', brand: 'Hasselblad', format: '120', mount: 'V'),
    Camera(title: 'Hasselblad 503CW', brand: 'Hasselblad', format: '120', mount: 'V'),
    Camera(title: 'Mamiya 7II', brand: 'Mamiya', format: '120'),
    Camera(title: 'Mamiya RB67', brand: 'Mamiya', format: '120'),
    Camera(title: 'Mamiya 645 Pro', brand: 'Mamiya', format: '120'),
  ];

  static final _films = [
    Film(name: 'Kodak Portra 160', brand: 'Kodak', iso: 160, format: '35mm', defaultShots: 36),
    Film(name: 'Kodak Portra 400', brand: 'Kodak', iso: 400, format: '35mm', defaultShots: 36),
    Film(name: 'Kodak Portra 800', brand: 'Kodak', iso: 800, format: '35mm', defaultShots: 36),
    Film(name: 'Kodak Ektar 100', brand: 'Kodak', iso: 100, format: '35mm', defaultShots: 36),
    Film(name: 'Kodak Gold 200', brand: 'Kodak', iso: 200, format: '35mm', defaultShots: 36),
    Film(name: 'Kodak ColorPlus 200', brand: 'Kodak', iso: 200, format: '35mm', defaultShots: 36),
    Film(name: 'Kodak UltraMax 400', brand: 'Kodak', iso: 400, format: '35mm', defaultShots: 36),
    Film(name: 'Kodak Tri-X 400', brand: 'Kodak', iso: 400, format: '35mm', defaultShots: 36),
    Film(name: 'Kodak T-Max 100', brand: 'Kodak', iso: 100, format: '35mm', defaultShots: 36),
    Film(name: 'Kodak T-Max 400', brand: 'Kodak', iso: 400, format: '35mm', defaultShots: 36),
    Film(name: 'Kodak Ektachrome E100', brand: 'Kodak', iso: 100, format: '35mm', defaultShots: 36),
    Film(name: 'Fujifilm Superia 400', brand: 'Fujifilm', iso: 400, format: '35mm', defaultShots: 36),
    Film(name: 'Fujifilm Velvia 50', brand: 'Fujifilm', iso: 50, format: '35mm', defaultShots: 36),
    Film(name: 'Fujifilm Velvia 100', brand: 'Fujifilm', iso: 100, format: '35mm', defaultShots: 36),
    Film(name: 'Fujifilm Provia 100F', brand: 'Fujifilm', iso: 100, format: '35mm', defaultShots: 36),
    Film(name: 'Fujifilm Acros 100 II', brand: 'Fujifilm', iso: 100, format: '35mm', defaultShots: 36),
    Film(name: 'Ilford HP5 Plus 400', brand: 'Ilford', iso: 400, format: '35mm', defaultShots: 36),
    Film(name: 'Ilford Delta 100', brand: 'Ilford', iso: 100, format: '35mm', defaultShots: 36),
    Film(name: 'Ilford Delta 400', brand: 'Ilford', iso: 400, format: '35mm', defaultShots: 36),
    Film(name: 'Ilford FP4 Plus 125', brand: 'Ilford', iso: 125, format: '35mm', defaultShots: 36),
    Film(name: 'Ilford XP2 Super 400', brand: 'Ilford', iso: 400, format: '35mm', defaultShots: 36),
    Film(name: 'Cinestill 400D', brand: 'Cinestill', iso: 400, format: '35mm', defaultShots: 36),
    Film(name: 'Cinestill 800T', brand: 'Cinestill', iso: 800, format: '35mm', defaultShots: 36),
    Film(name: 'Cinestill 50D', brand: 'Cinestill', iso: 50, format: '35mm', defaultShots: 36),
    Film(name: 'Lomography Color 400', brand: 'Lomography', iso: 400, format: '35mm', defaultShots: 36),
  ];

  static final _lenses = [
    // Canon FD
    Lens(name: 'Canon FD 50mm f/1.4', brand: 'Canon', focalLength: 50, maxAperture: 1.4, mount: 'FD', type: 'Prime'),
    Lens(name: 'Canon FD 50mm f/1.8', brand: 'Canon', focalLength: 50, maxAperture: 1.8, mount: 'FD', type: 'Prime'),
    Lens(name: 'Canon FD 35mm f/2.8', brand: 'Canon', focalLength: 35, maxAperture: 2.8, mount: 'FD', type: 'Prime'),
    Lens(name: 'Canon FD 85mm f/1.8', brand: 'Canon', focalLength: 85, maxAperture: 1.8, mount: 'FD', type: 'Prime'),
    Lens(name: 'Canon FD 24mm f/2.8', brand: 'Canon', focalLength: 24, maxAperture: 2.8, mount: 'FD', type: 'Prime'),
    // Nikkor F
    Lens(name: 'Nikkor 50mm f/1.4 AI-S', brand: 'Nikon', focalLength: 50, maxAperture: 1.4, mount: 'F', type: 'Prime'),
    Lens(name: 'Nikkor 50mm f/1.8 AI-S', brand: 'Nikon', focalLength: 50, maxAperture: 1.8, mount: 'F', type: 'Prime'),
    Lens(name: 'Nikkor 28mm f/2.8 AI-S', brand: 'Nikon', focalLength: 28, maxAperture: 2.8, mount: 'F', type: 'Prime'),
    Lens(name: 'Nikkor 105mm f/2.5 AI-S', brand: 'Nikon', focalLength: 105, maxAperture: 2.5, mount: 'F', type: 'Prime'),
    // Pentax K
    Lens(name: 'SMC Pentax 50mm f/1.4', brand: 'Pentax', focalLength: 50, maxAperture: 1.4, mount: 'K', type: 'Prime'),
    Lens(name: 'SMC Pentax 55mm f/1.8', brand: 'Pentax', focalLength: 55, maxAperture: 1.8, mount: 'K', type: 'Prime'),
    // Leica M
    Lens(name: 'Leica Summicron 50mm f/2', brand: 'Leica', focalLength: 50, maxAperture: 2.0, mount: 'M', type: 'Prime'),
    Lens(name: 'Leica Summilux 35mm f/1.4', brand: 'Leica', focalLength: 35, maxAperture: 1.4, mount: 'M', type: 'Prime'),
    // Contax
    Lens(name: 'Zeiss Planar 50mm f/1.4', brand: 'Zeiss', focalLength: 50, maxAperture: 1.4, mount: 'C/Y', type: 'Prime'),
    // Hasselblad
    Lens(name: 'Zeiss Planar 80mm f/2.8', brand: 'Zeiss', focalLength: 80, maxAperture: 2.8, mount: 'V', type: 'Prime'),
  ];
}
