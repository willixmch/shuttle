// lib/models/route.dart
// Defines the Routes model to represent a shuttle route (e.g., A 線) in the database.
// Used to store and retrieve route data from the 'routes' table.

class Routes {
  // Unique identifier for the route (e.g., '0001').
  final String routeId;

  // Name of the route (e.g., 'A 線').
  final String routeName;

  // ID of the estate this route belongs to (e.g., '0001').
  final String estateId;

  // Additional information about the route (e.g., '由天鑽第2座開出').
  final String info;

  // Fare for residents (e.g., '$4').
  final String residentFare;

  // Fare for visitors (e.g., '$6').
  final String visitorFare;

  const Routes({
    required this.routeId,
    required this.routeName,
    required this.estateId,
    required this.info,
    required this.residentFare,
    required this.visitorFare,
  });

  // Converts a Routes object to a map for database insertion.
  Map<String, dynamic> toMap() {
    return {
      'routeId': routeId,
      'routeName': routeName,
      'estateId': estateId,
      'info': info,
      'residentFare': residentFare,
      'visitorFare': visitorFare,
    };
  }

  // Creates a Routes object from a database row (map).
  factory Routes.fromMap(Map<String, dynamic> map) {
    final routeId = map['routeId'];
    final routeName = map['routeName'];
    final estateId = map['estateId'];
    final info = map['info'];
    final residentFare = map['residentFare'];
    final visitorFare = map['visitorFare'];
    if (routeId == null ||
        routeName == null ||
        estateId == null ||
        info == null ||
        residentFare == null ||
        visitorFare == null) {
      throw Exception('Invalid route data: one or more fields are null in map: $map');
    }
    return Routes(
      routeId: routeId as String,
      routeName: routeName as String,
      estateId: estateId as String,
      info: info as String,
      residentFare: residentFare as String,
      visitorFare: visitorFare as String,
    );
  }

  // String representation for debugging.
  @override
  String toString() {
    return 'Routes{routeId: $routeId, routeName: $routeName, estateId: $estateId, info: $info, residentFare: $residentFare, visitorFare: $visitorFare}';
  }
}