// lib/models/route.dart
// Defines the Route model to represent a shuttle route (e.g., A 線) in the database.
// Used to store and retrieve route data from the 'routes' table.

class Route {
  // Unique identifier for the route (e.g., '0001').
  final String routeId;

  // Name of the route (e.g., 'A 線').
  final String routeName;

  // ID of the estate this route belongs to (e.g., '0001').
  final String estateId;

  // Additional information about the route (e.g., '由天鑽第2座開出').
  final String info;

  const Route({
    required this.routeId,
    required this.routeName,
    required this.estateId,
    required this.info,
  });

  // Converts a Route object to a map for database insertion.
  Map<String, dynamic> toMap() {
    return {
      'routeId': routeId,
      'routeName': routeName,
      'estateId': estateId,
      'info': info,
    };
  }

  // Creates a Route object from a database row (map).
  factory Route.fromMap(Map<String, dynamic> map) {
    return Route(
      routeId: map['routeId'] as String,
      routeName: map['routeName'] as String,
      estateId: map['estateId'] as String,
      info: map['info'] as String,
    );
  }

  // String representation for debugging.
  @override
  String toString() {
    return 'Route{routeId: $routeId, routeName: $routeName, estateId: $estateId, info: $info}';
  }
}