import 'package:geolocator/geolocator.dart';

class LocationService {
  bool? _hasPermission;

  Future<bool> checkLocationPermissions() async {
    // Return cached result if already checked
    if (_hasPermission != null) {
      return _hasPermission!;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _hasPermission = false;
      return false; // Location services disabled
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _hasPermission = false;
        return false; // Permission denied or permanently denied
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _hasPermission = false;
      return false; // Permission permanently denied
    }

    _hasPermission = true;
    return true; // Permissions granted
  }

  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null; // Handle location retrieval failure
    }
  }
}