import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shuttle/models/stop.dart';
import 'package:shuttle/services/database_helper.dart';

class StopQuery {
  final DatabaseHelper _dbHelper;

  StopQuery(this._dbHelper);

  Future<Stop?> selectStop(String? estateId, LatLng? userPosition) async {
    if (estateId == null) {
      return null;
    }

    final stops = await _dbHelper.getBoardingStopsForEstate(estateId);
    if (stops.isEmpty) {
      return null;
    }

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
        return closestStop;
      }
    }

    return stops.first; // Fallback to first stop if no position
  }

  Future<Stop?> getInitialStop(String? estateId, bool hasPermission, {LatLng? currentLocation}) async {
    LatLng? userPosition = currentLocation ??
        (hasPermission ? await Geolocator.getCurrentPosition().then((pos) => LatLng(pos.latitude, pos.longitude)) : null);
    return selectStop(estateId, userPosition);
  }
}