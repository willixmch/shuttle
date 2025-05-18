import 'package:geolocator/geolocator.dart';
import 'package:shuttle/models/stop.dart';
import 'package:shuttle/services/database_helper.dart';
import 'package:shuttle/services/location_service.dart';

class StopQuery {
  final DatabaseHelper _dbHelper;
  final LocationService _locationService;

  StopQuery(this._dbHelper, this._locationService);

  Future<Stop?> selectStop(String? estateId, Position? userPosition) async {
    if (estateId == null) {
      return null; // No estate selected
    }

    final stops = await _dbHelper.getBordingStopsForEstate(estateId);
    if (stops.isEmpty) {
      return null; // No stops available
    }

    // If user position is provided and valid, find closest stop
    if (userPosition != null) {
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

      if (closestStop != null) {
        return closestStop; // Return closest stop if found
      }
    }

    // Fallback to first stop if no position or no closest stop found
    return stops.first;
  }

  Future<Stop?> getInitialStop(String? estateId, bool hasPermission) async {
    Position? userPosition = hasPermission ? await _locationService.getCurrentPosition() : null;
    return selectStop(estateId, userPosition);
  }
}