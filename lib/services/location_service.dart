import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> checkLocationPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false; // Location services disabled
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false; // Permission denied
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false; // Permission permanently denied
    }

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