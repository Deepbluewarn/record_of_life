import 'package:geolocator/geolocator.dart';

enum LocationAccess { granted, denied, permanentlyDenied, serviceDisabled }

Future<LocationAccess> checkLocationAccess() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    return LocationAccess.serviceDisabled;
  }
  final p = await Geolocator.checkPermission();
  switch (p) {
    case LocationPermission.always:
    case LocationPermission.whileInUse:
      return LocationAccess.granted;
    case LocationPermission.deniedForever:
      return LocationAccess.permanentlyDenied;
    case LocationPermission.denied:
    case LocationPermission.unableToDetermine:
      return LocationAccess.denied;
  }
}

Future<LocationAccess> requestLocationAccess() async {
  final cur = await checkLocationAccess();
  if (cur != LocationAccess.denied) return cur;
  final p = await Geolocator.requestPermission();
  if (p == LocationPermission.always || p == LocationPermission.whileInUse) {
    return LocationAccess.granted;
  }
  if (p == LocationPermission.deniedForever) {
    return LocationAccess.permanentlyDenied;
  }
  return LocationAccess.denied;
}

// 야외 촬영 앱에서 저장 시점 위치를 best-effort로 얻음.
// 실패 = null. 사용자 흐름을 절대 막지 않음.
Future<({double lat, double lng})?> tryGetPosition() async {
  try {
    final access = await requestLocationAccess();
    if (access != LocationAccess.granted) return null;
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 5),
      ),
    );
    return (lat: pos.latitude, lng: pos.longitude);
  } catch (_) {
    return null;
  }
}
