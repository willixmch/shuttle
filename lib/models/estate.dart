// lib/models/estate.dart
// Defines the Estate model to represent an estate (e.g., theRegent) in the database.
// Used to store and retrieve estate data from the 'estates' table.

class Estate {
  // Unique identifier for the estate (e.g., '0001').
  final String estateId;

  // Name of the estate (e.g., 'theRegent'), kept for database compatibility.
  final String estateName;

  // Chinese title of the estate (e.g., '天鑽').
  final String estateTitleZh;

  // English title of the estate (e.g., 'The Regent').
  final String estateTitleEn;

  const Estate({
    required this.estateId,
    required this.estateName,
    required this.estateTitleZh,
    required this.estateTitleEn,
  });

  // Converts an Estate object to a map for database insertion.
  Map<String, dynamic> toMap() {
    return {
      'estateId': estateId,
      'estateName': estateName,
      'estateTitleZh': estateTitleZh,
      'estateTitleEn': estateTitleEn,
    };
  }

  // Creates an Estate object from a database row (map).
  factory Estate.fromMap(Map<String, dynamic> map) {
    return Estate(
      estateId: map['estateId'] as String,
      estateName: map['estateName'] as String,
      estateTitleZh: map['estateTitleZh'] as String,
      estateTitleEn: map['estateTitleEn'] as String,
    );
  }

  // String representation for debugging.
  @override
  String toString() {
    return 'Estate{estateId: $estateId, estateName: $estateName, estateTitleZh: $estateTitleZh, estateTitleEn: $estateTitleEn}';
  }
}