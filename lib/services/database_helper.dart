import 'package:shuttle/data/KR/kowlooncity_kr51.dart';
import 'package:shuttle/data/KR/shamshuipo_kr41_2.dart';
import 'package:shuttle/data/KR/shamshuipo_kr45.dart';
import 'package:shuttle/data/KR/yautsimmong_kr11.dart';
import 'package:shuttle/data/KR/yautsimmong_kr12.dart';
import 'package:shuttle/data/KR/yautsimmong_kr13.dart';
import 'package:shuttle/data/KR/yautsimmong_kr14.dart';
import 'package:shuttle/data/KR/yautsimmong_kr15.dart';
import 'package:shuttle/data/KR/yautsimmong_kr17.dart';
import 'package:shuttle/data/KR/yautsimmong_kr18.dart';
import 'package:shuttle/data/NR/shatin_nr83.dart';
import 'package:shuttle/data/NR/shatin_nr810.dart';
import 'package:shuttle/data/NR/shatin_nr815.dart';
import 'package:shuttle/data/NR/shatin_nr831_8.dart';
import 'package:shuttle/data/NR/shatin_nr833.dart';
import 'package:shuttle/data/NR/shatin_nr835.dart';
import 'package:shuttle/data/NR/shatin_nr837.dart';
import 'package:shuttle/data/NR/shatin_nr839.dart';
import 'package:shuttle/data/NR/shatin_nr840.dart';
import 'package:shuttle/data/NR/shatin_nr841.dart';
import 'package:shuttle/data/NR/shatin_nr842.dart';
import 'package:shuttle/data/NR/shatin_nr843.dart';
import 'package:shuttle/data/NR/shatin_nr845.dart';
import 'package:shuttle/data/NR/taipo_nr538.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shuttle/models/estate.dart';
import 'package:shuttle/models/routes.dart';
import 'package:shuttle/models/schedule.dart';
import 'package:shuttle/models/stop.dart';

// Manages SQLite database for shuttle bus data (singleton)
class DatabaseHelper {
  static final DatabaseHelper instance =
      DatabaseHelper._init(); // Singleton instance
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

    // Create indexes for query optimization
    await db.execute('CREATE INDEX idx_routes_estateId ON routes(estateId)');
    await db.execute('CREATE INDEX idx_schedules_routeId ON schedules(routeId)');
    await db.execute('CREATE INDEX idx_stops_routeId ON stops(routeId)');

    // List of all estate data
    final estateDataList = [

      //KR

      // Kowloon City
      kr51,
      // Sham Shui Po
      kr41_2,
      kr45,
      // Yau Tsim Mong
      kr11,
      kr12,
      kr13,
      kr14,
      kr15,
      kr17,
      kr18,
      
      // NR
      
      // Sha Tin
      nr83,
      nr810,
      nr815,
      nr831_8,
      nr833,
      nr835,
      nr837,
      nr839,
      nr840,
      nr841,
      nr842,
      nr843,
      nr845,
      // Tai Po
      nr538,
    ];

    // Insert all estate data
    for (var estateData in estateDataList) {
      await _insertEstateData(db, estateData);
    }
  }

  // Inserts estate, route, schedule, and stop data using batch transactions
  Future<void> _insertEstateData(Database db, Map<String, dynamic> estateData) async {
    try {
      final batch = db.batch();

      // Insert estate
      batch.insert('estates', {
        'estateId': estateData['estateId'],
        'estateTitleZh': estateData['estateTitleZh'],
        'estateTitleEn': estateData['estateTitleEn'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // Insert routes
      for (var route in estateData['routes']) {
        batch.insert('routes', {
          'routeId': route['routeId'],
          'estateId': estateData['estateId'],
          'routeNameZh': route['routeNameZh'],
          'routeNameEn': route['routeNameEn'],
          'infoZh': route['infoZh'],
          'infoEn': route['infoEn'],
          'residentFare': route['residentFare'],
          'visitorFare': route['visitorFare'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        // Insert schedules for workday/weekend
        if (route['schedules'] != null) {
          for (var dayType in [
            'workday',
            'saturday',
            'sunday',
            'public_holiday',
          ]) {
            for (var time in route['schedules'][dayType] ?? []) {
              batch.insert('schedules', {
                'routeId': route['routeId'],
                'dayType': dayType,
                'departureTime': time,
              }, conflictAlgorithm: ConflictAlgorithm.ignore);
            }
          }
        }

        // Insert stops with ETA offset, coordinates, and boardingStop
        if (route['stops'] != null) {
          for (var i = 0; i < route['stops'].length; i++) {
            var stop = route['stops'][i];
            batch.insert('stops', {
              'stopId': stop['stopId'],
              'routeId': route['routeId'],
              'stopNameZh': stop['stopNameZh'],
              'stopNameEn': stop['stopNameEn'],
              'etaOffset': stop['etaOffset'],
              'latitude': stop['latitude'],
              'longitude': stop['longitude'],
              'boardingStop': stop['boardingStop'] ?? (i == 0 ? 1 : 0),
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      }

      await batch.commit(noResult: true);
    } catch (e) {
      rethrow;
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
  Future<List<Schedule>> getSchedulesForRoute(
    String routeId,
    String dayType,
  ) async {
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

  // Fetches stops for a route where boardingStop = 1
  Future<List<Stop>> getBoardingStopsForRoute(String routeId) async {
    final db = await database;
    final result = await db.query(
      'stops',
      where: 'routeId = ? AND boardingStop = 1',
      whereArgs: [routeId],
    );
    return result.map((e) => Stop.fromMap(e)).toList();
  }

  // Fetches unique boarding stops for an estate
  Future<List<Stop>> getBoardingStopsForEstate(String estateId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT DISTINCT s.stopId, MIN(s.routeId) AS routeId, s.stopNameZh, s.stopNameEn, MIN(s.etaOffset) AS etaOffset, s.latitude, s.longitude, s.boardingStop
      FROM stops s
      JOIN routes r ON s.routeId = r.routeId
      WHERE r.estateId = ? AND s.boardingStop = 1
      GROUP BY s.stopId, s.stopNameZh, s.stopNameEn, s.latitude, s.longitude
    ''',
      [estateId],
    );
    return result.map((e) => Stop.fromMap(e)).toList();
  }
}