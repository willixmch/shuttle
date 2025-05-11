// lib/models/stop.dart
// Defines the Stop model to represent a shuttle stop in the database.
// Used to store and retrieve stop data from the 'stops' table.

class Stop {
  // Unique identifier for the stop (e.g., '0001').
  final String stopId;

  // Chinese name of the stop (e.g., '帝堡城').
  final String stopNameZh;

  // ID of the route this stop belongs to (e.g., '0005').
  final String routeId;

  // ETA offset in minutes from the origin stop (e.g., 0 for origin, 5 for next stop).
  final int etaOffset;

  // Latitude of the stop location (e.g., 22.383994).
  final double latitude;

  // Longitude of the stop location (e.g., 114.214314).
  final double longitude;

  const Stop({
    required this.stopId,
    required this.stopNameZh,
    required this.routeId,
    required this.etaOffset,
    required this.latitude,
    required this.longitude,
  });

  // Converts a Stop object to a map for database insertion.
  Map<String, dynamic> toMap() {
    return {
      'stopId': stopId,
      'stopNameZh': stopNameZh,
      'routeId': routeId,
      'etaOffset': etaOffset,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Creates a Stop object from a database row (map).
  factory Stop.fromMap(Map<String, dynamic> map) {
    final stopId = map['stopId'];
    final stopNameZh = map['stopNameZh'];
    final routeId = map['routeId'];
    final etaOffset = map['etaOffset'];
    if (stopId == null || stopNameZh == null || routeId == null || etaOffset == null) {
      throw Exception('Invalid stop data: one or more required fields are null in map: $map');
    }
    return Stop(
      stopId: stopId as String,
      stopNameZh: stopNameZh as String,
      routeId: routeId as String,
      etaOffset: etaOffset as int,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
    );
  }

  // String representation for debugging.
  @override
  String toString() {
    return 'Stop{stopId: $stopId, stopNameZh: $stopNameZh, routeId: $routeId, etaOffset: $etaOffset, latitude: $latitude, longitude: $longitude}';
  }
}