import 'package:sqflite/sqflite.dart'; // SQLite database plugin
import 'package:path/path.dart'; // Path utilities
import '../data/the_castello_data.dart'; // Castello estate data
import '../data/the_regent_data.dart'; // Regent estate data
import '../models/estate.dart'; // Estate model
import '../models/routes.dart'; // Route model
import '../models/schedule.dart'; // Schedule model
import '../models/stop.dart'; // Stop model

// Manages SQLite database for shuttle bus data (singleton)
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init(); // Singleton instance
  static Database? _database; // Database instance

  DatabaseHelper._init(); // Private constructor

  // Gets database, initializes if null
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shuttle.db');
    return _database!;
  }

  // Sets up database file with version 1
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Creates tables for estates, routes, schedules, and stops
  Future _createDB(Database db, int version) async {
    // Estates table
    await db.execute('''
    CREATE TABLE estates (
      estateId TEXT PRIMARY KEY,
      estateName TEXT,
      estateTitleZh TEXT,
      estateTitleEn TEXT
    )
    ''');

    // Routes table, linked to estates
    await db.execute('''
    CREATE TABLE routes (
      routeId TEXT PRIMARY KEY,
      estateId TEXT,
      routeName TEXT,
      info TEXT,
      FOREIGN KEY (estateId) REFERENCES estates (estateId)
    )
    ''');

    // Schedules table, linked to routes
    await db.execute('''
    CREATE TABLE schedules (
      scheduleId INTEGER PRIMARY KEY AUTOINCREMENT,
      routeId TEXT,
      dayType TEXT,
      departureTime TEXT,
      FOREIGN KEY (routeId) REFERENCES routes (routeId)
    )
    ''');

    // Stops table, linked to routes with ETA offset and coordinates
    await db.execute('''
    CREATE TABLE stops (
      stopId TEXT,
      routeId TEXT,
      stopNameZh TEXT,
      etaOffset INTEGER,
      latitude REAL,
      longitude REAL,
      PRIMARY KEY (stopId, routeId),
      FOREIGN KEY (routeId) REFERENCES routes (routeId)
    )
    ''');

    // Insert initial data
    await _insertEstateData(db, theCastelloData);
    await _insertEstateData(db, theRegentData);
  }

  // Inserts estate, route, schedule, and stop data
  Future<void> _insertEstateData(Database db, Map<String, dynamic> estateData) async {
    // Insert estate
    await db.insert(
      'estates',
      {
        'estateId': estateData['estateId'],
        'estateName': estateData['estateName'],
        'estateTitleZh': estateData['estateTitleZh'],
        'estateTitleEn': estateData['estateTitleEn'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insert routes
    for (var route in estateData['routes']) {
      await db.insert(
        'routes',
        {
          'routeId': route['routeId'],
          'estateId': estateData['estateId'],
          'routeName': route['routeName'],
          'info': route['info'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert schedules for workday/weekend
      if (route['schedules'] != null) {
        for (var dayType in ['workday', 'weekend']) {
          for (var time in route['schedules'][dayType] ?? []) {
            await db.insert(
              'schedules',
              {
                'routeId': route['routeId'],
                'dayType': dayType,
                'departureTime': time,
              },
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
        }
      }

      // Insert stops with ETA offset and coordinates
      if (route['stops'] != null) {
        for (var stop in route['stops']) {
          await db.insert(
            'stops',
            {
              'stopId': stop['stopId'],
              'routeId': route['routeId'],
              'stopNameZh': stop['stopNameZh'],
              'etaOffset': stop['etaOffset'],
              'latitude': stop['latitude'],
              'longitude': stop['longitude'],
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    }
  }

  // Fetches all estates
  Future<List<Estate>> getAllEstates() async {
    final db = await database;
    final result = await db.query('estates');
    return result.map((e) => Estate.fromMap(e)).toList();
  }

  // Fetches estate by ID
  Future<Estate?> getEstateById(String estateId) async {
    final db = await database;
    final result = await db.query(
      'estates',
      where: 'estateId = ?',
      whereArgs: [estateId],
    );
    return result.isNotEmpty ? Estate.fromMap(result.first) : null;
  }

  // Fetches all routes
  Future<List<Routes>> getAllRoutes() async {
    final db = await database;
    final result = await db.query('routes');
    return result.map((e) => Routes.fromMap(e)).toList();
  }

  // Fetches schedules for a route and day type
  Future<List<Schedule>> getSchedulesForRoute(String routeId, String dayType) async {
    final db = await database;
    final result = await db.query(
      'schedules',
      where: 'routeId = ? AND dayType = ?',
      whereArgs: [routeId, dayType],
    );
    return result.map((e) => Schedule.fromMap(e)).toList();
  }

  // Fetches stops for a route
  Future<List<Stop>> getStopsForRoute(String routeId) async {
    final db = await database;
    final result = await db.query(
      'stops',
      where: 'routeId = ?',
      whereArgs: [routeId],
    );
    return result.map((e) => Stop.fromMap(e)).toList();
  }

  // Fetches unique stops for an estate
  Future<List<Stop>> getStopsForEstate(String estateId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT DISTINCT s.stopId, MIN(s.routeId) AS routeId, s.stopNameZh, s.etaOffset, s.latitude, s.longitude
      FROM stops s
      JOIN routes r ON s.routeId = r.routeId
      WHERE r.estateId = ?
      GROUP BY s.stopId, s.stopNameZh, s.etaOffset, s.latitude, s.longitude
    ''', [estateId]);
    return result.map((e) => Stop.fromMap(e)).toList();
  }
}