import 'package:geolocator/geolocator.dart';

class LocationService {
  bool? _hasPermission;

  Future<bool> checkLocationPermissions() async {
    if (_hasPermission != null) {
      return _hasPermission!;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _hasPermission = false;
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      _hasPermission = false;
      return false;
    }

    _hasPermission = permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    return _hasPermission!;
  }

  Future<Position?> getCurrentPosition() async {
    if (await checkLocationPermissions()) {
      try {
        return await Geolocator.getCurrentPosition();
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}