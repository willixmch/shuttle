// lib/models/stop.dart
// Defines the Stop model to represent a shuttle stop in the database.
// Used to store and retrieve stop data from the 'stops' table.

class Stop {
  // Unique identifier for the stop (e.g., '0001').
  final String stopId;

  // Chinese name of the stop (e.g., '新城市廣場').
  final String stopNameZh;

  // Chinese name of the stop (e.g., 'New Town Plaza').
  final String stopNameEn;

  // ID of the route this stop belongs to (e.g., '0005').
  final String routeId;

  // ETA offset in minutes from the origin stop (e.g., 0 for origin, 5 for next stop).
  final int etaOffset;

  // Latitude of the stop location (e.g., 22.383994).
  final double latitude;

  // Longitude of the stop location (e.g., 114.214314).
  final double longitude;

  // Indicates if this stop is a boarding stop.
  final bool boardingStop;

  const Stop({
    required this.stopId,
    required this.stopNameZh,
    required this.stopNameEn,
    required this.routeId,
    required this.etaOffset,
    required this.latitude,
    required this.longitude,
    required this.boardingStop,
  });

  // Converts a Stop object to a map for database insertion.
  Map<String, dynamic> toMap() {
    return {
      'stopId': stopId,
      'stopNameZh': stopNameZh,
      'stopNameEn': stopNameEn,
      'routeId': routeId,
      'etaOffset': etaOffset,
      'latitude': latitude,
      'longitude': longitude,
      'boardingStop': boardingStop ? 1 : 0,
    };
  }

  // Creates a Stop object from a database row (map).
  factory Stop.fromMap(Map<String, dynamic> map) {
    final stopId = map['stopId'];
    final stopNameZh = map['stopNameZh'];
    final stopNameEn = map['stopNameEn'];
    final routeId = map['routeId'];
    final etaOffset = map['etaOffset'];
    final boardingStop = map['boardingStop'] ?? 0;
    if (stopId == null || stopNameZh == null || routeId == null || etaOffset == null) {
      throw Exception('Invalid stop data: one or more required fields are null in map: $map');
    }
    return Stop(
      stopId: stopId as String,
      stopNameZh: stopNameZh as String,
      stopNameEn: stopNameEn as String,
      routeId: routeId as String,
      etaOffset: etaOffset as int,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      boardingStop: (boardingStop as int) == 1,
    );
  }

  // String representation for debugging.
  @override
  String toString() {
    return 'Stop{stopId: $stopId, stopNameZh: $stopNameZh, stopNameEn: $stopNameEn, routeId: $routeId, etaOffset: $etaOffset, latitude: $latitude, longitude: $longitude, boardingStop: $boardingStop}';
  }
}