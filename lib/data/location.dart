import 'package:geolocator/geolocator.dart';

// 야외 촬영 앱에서 저장 시점 위치를 best-effort로 얻음.
// 권한·서비스·타임아웃 실패 = null 반환. 사용자 흐름 절대 막지 않음.
Future<({double lat, double lng})?> tryGetPosition() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return null;
    }
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
