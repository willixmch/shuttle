import 'package:geolocator/geolocator.dart';
import 'package:shuttle/models/stop.dart';
import 'package:shuttle/services/database_helper.dart';

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
    if (await checkLocationPermissions()) {
      try {
        return await Geolocator.getCurrentPosition(
        );
      } catch (e) {
        return null; // Handle location retrieval failure
      }
    }
    return null; // No permissions or services
  }

  Future<Stop?> findClosestStop(Position userPosition, String estateId, DatabaseHelper dbHelper) async {
    final stops = await dbHelper.getStopsForEstate(estateId);
    if (stops.isEmpty) {
      return null; // No stops available
    }

    Stop? closestStop;
    double minDistance = double.infinity;

    for (var stop in stops) {
      final distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        stop.latitude,
        stop.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestStop = stop;
      }
    }

    return closestStop;
  }
}