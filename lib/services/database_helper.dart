import 'package:shuttle/data/NR818_golden_time_villa.dart';
import 'package:shuttle/data/nr810_parc_royal.dart';
import 'package:shuttle/data/nr819_granville_garden.dart';
import 'package:shuttle/data/nr820_shatin_heights.dart';
import 'package:shuttle/data/nr822_vista_paradiso.dart';
import 'package:shuttle/data/nr826_villa_athena.dart';
import 'package:shuttle/data/nr83_kwong_yuen_estate.dart';
import 'package:shuttle/data/nr817_lakeview_garden.dart';
import 'package:shuttle/data/nr815_royal_ascot.dart';
import 'package:shuttle/data/nr829_the_castello.dart';
import 'package:shuttle/data/nr538_the_regent.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shuttle/models/estate.dart';
import 'package:shuttle/models/routes.dart';
import 'package:shuttle/models/schedule.dart';
import 'package:shuttle/models/stop.dart';

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
      estateTitleZh TEXT,
      estateTitleEn TEXT
    )
    ''');

    // Routes table, linked to estates
    await db.execute('''
    CREATE TABLE routes (
      routeId TEXT PRIMARY KEY,
      estateId TEXT,
      routeNameZh TEXT,
      routeNameEn TEXT,
      infoZh TEXT,
      infoEn TEXT,
      residentFare TEXT,
      visitorFare TEXT,
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

    // Stops table, linked to routes with ETA offset, coordinates, and boardingStop
    await db.execute('''
    CREATE TABLE stops (
      stopId TEXT,
      routeId TEXT,
      stopNameZh TEXT,
      stopNameEn TEXT,
      etaOffset INTEGER,
      latitude REAL,
      longitude REAL,
      boardingStop INTEGER DEFAULT 0,
      PRIMARY KEY (stopId, routeId),
      FOREIGN KEY (routeId) REFERENCES routes (routeId)
    )
    ''');

    // Insert initial data
    await _insertEstateData(db, theRegentData);
    // await _insertEstateData(db, kwongYuenEstateData);
    // await _insertEstateData(db, royalAscotData);
    // await _insertEstateData(db, lakeviewGardenData);
    // await _insertEstateData(db, parcRoyaleData);
    // await _insertEstateData(db, goldenTimeVillasData);
    // await _insertEstateData(db, granvilleGardenData);
    // await _insertEstateData(db, shatinHeightsData);
    // await _insertEstateData(db, vistaParadisoData);
    // await _insertEstateData(db, villaAthenaData);
    // await _insertEstateData(db, theCastelloData);
  }

  // Inserts estate, route, schedule, and stop data
  Future<void> _insertEstateData(Database db, Map<String, dynamic> estateData) async {
    // Insert estate
    await db.insert(
      'estates',
      {
        'estateId': estateData['estateId'],
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
          'routeNameZh': route['routeNameZh'],
          'routeNameEn': route['routeNameEn'],
          'infoZh': route['infoZh'],
          'infoEn': route['infoEn'],
          'residentFare': route['residentFare'],
          'visitorFare': route['visitorFare'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert schedules for workday/weekend
      if (route['schedules'] != null) {
        for (var dayType in ['workday', 'saturday', 'sunday', 'public_holiday']) {
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

      // Insert stops with ETA offset, coordinates, and boardingStop
      if (route['stops'] != null) {
        for (var i = 0; i < route['stops'].length; i++) {
          var stop = route['stops'][i];
          await db.insert(
            'stops',
            {
              'stopId': stop['stopId'],
              'routeId': route['routeId'],
              'stopNameZh': stop['stopNameZh'],
              'stopNameEn': stop['stopNameEn'],
              'etaOffset': stop['etaOffset'],
              'latitude': stop['latitude'],
              'longitude': stop['longitude'],
              'boardingStop': stop['boardingStop'] ?? (i == 0 ? 1 : 0), // Default first stop as boarding
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

  // Fetches unique boarding stops for an estate
  Future<List<Stop>> getBordingStopsForEstate(String estateId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT DISTINCT s.stopId, MIN(s.routeId) AS routeId, s.stopNameZh, s.stopNameEn, MIN(s.etaOffset) AS etaOffset, s.latitude, s.longitude, s.boardingStop
      FROM stops s
      JOIN routes r ON s.routeId = r.routeId
      WHERE r.estateId = ? AND s.boardingStop = 1
      GROUP BY s.stopId, s.stopNameZh, s.stopNameEn, s.latitude, s.longitude
    ''', [estateId]);
    return result.map((e) => Stop.fromMap(e)).toList();
  }
}