// lib/models/schedule.dart
// Defines the Schedule model to represent a shuttle departure time in the database.
// Used to store and retrieve schedule data from the 'schedules' table.

class Schedule {
  // Unique identifier for the schedule entry (auto-incremented by database).
  final int? id;

  // ID of the route this schedule belongs to (e.g., '0001').
  final String routeId;

  // Type of day (e.g., 'workday' or 'weekend').
  final String dayType;

  // Departure time (e.g., '06:30').
  final String departureTime;

  const Schedule({
    this.id,
    required this.routeId,
    required this.dayType,
    required this.departureTime,
  });

  // Converts a Schedule object to a map for database insertion.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routeId': routeId,
      'dayType': dayType,
      'departureTime': departureTime,
    };
  }

  // Creates a Schedule object from a database row (map).
  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'] as int?,
      routeId: map['routeId'] as String,
      dayType: map['dayType'] as String,
      departureTime: map['departureTime'] as String,
    );
  }

  // String representation for debugging.
  @override
  String toString() {
    return 'Schedule{id: $id, routeId: $routeId, dayType: $dayType, departureTime: $departureTime}';
  }
}