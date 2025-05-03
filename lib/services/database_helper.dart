import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/estate.dart';
import '../models/routes.dart';
import '../models/schedule.dart';

import '../data/the_regent_data.dart';
import '../data/the_castello_data.dart';

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

  // Sets up database file
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Creates tables and inserts initial data
  Future _createDB(Database db, int version) async {
    // Estates table
    await db.execute('''
      CREATE TABLE estates (
        estateId TEXT PRIMARY KEY,
        estateName TEXT NOT NULL,
        estateTitleZh TEXT NOT NULL,
        estateTitleEn TEXT NOT NULL
      )
    ''');

    // Routes table, linked to estates
    await db.execute('''
      CREATE TABLE routes (
        routeId TEXT PRIMARY KEY,
        routeName TEXT NOT NULL,
        estateId TEXT NOT NULL,
        info TEXT NOT NULL,
        FOREIGN KEY (estateId) REFERENCES estates (estateId)
      )
    ''');

    // Schedules table, linked to routes
    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        routeId TEXT NOT NULL,
        dayType TEXT NOT NULL,
        departureTime TEXT NOT NULL,
        FOREIGN KEY (routeId) REFERENCES routes (routeId)
      )
    ''');

    await _insertEstateData(db); // Insert initial data
  }

  // Inserts data from estate files
  Future _insertEstateData(Database db) async {
    final estateDataSources = [theRegentData, theCastelloData]; // Estate data sources
    for (var estateData in estateDataSources) {
      // Insert estate
      await db.insert('estates', {
        'estateId': estateData['estateId'],
        'estateName': estateData['estateName'],
        'estateTitleZh': estateData['estateTitleZh'],
        'estateTitleEn': estateData['estateTitleEn'],
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      // Insert routes, if any
      final routes = estateData['routes'] as List<dynamic>?;
      if (routes != null) {
        for (var route in routes) {
          await db.insert('routes', {
            'routeId': route['routeId'],
            'routeName': route['routeName'],
            'estateId': estateData['estateId'],
            'info': route['info'],
          }, conflictAlgorithm: ConflictAlgorithm.ignore);

          // Insert workday schedules
          final workdaySchedules = route['schedules']['workday'] as List<dynamic>?;
          if (workdaySchedules != null) {
            for (var time in workdaySchedules) {
              await db.insert('schedules', {
                'routeId': route['routeId'],
                'dayType': 'workday',
                'departureTime': time,
              }, conflictAlgorithm: ConflictAlgorithm.ignore);
            }
          }

          // Insert weekend schedules
          final weekendSchedules = route['schedules']['weekend'] as List<dynamic>?;
          if (weekendSchedules != null) {
            for (var time in weekendSchedules) {
              await db.insert('schedules', {
                'routeId': route['routeId'],
                'dayType': 'weekend',
                'departureTime': time,
              }, conflictAlgorithm: ConflictAlgorithm.ignore);
            }
          }
        }
      }
    }
  }

  // Gets all estates
  Future<List<Estate>> getAllEstates() async {
    final db = await database;
    final maps = await db.query('estates');
    return List.generate(maps.length, (i) => Estate.fromMap(maps[i]));
  }

  // Gets all routes
  Future<List<Routes>> getAllRoutes() async {
    final db = await database;
    final maps = await db.query('routes');
    return List.generate(maps.length, (i) => Routes.fromMap(maps[i]));
  }

  // Gets schedules for a route and day type
  Future<List<Schedule>> getSchedulesForRoute(String routeId, String dayType) async {
    final db = await database;
    final maps = await db.query('schedules',
        where: 'routeId = ? AND dayType = ?', whereArgs: [routeId, dayType]);
    return List.generate(maps.length, (i) => Schedule.fromMap(maps[i]));
  }

  // Gets estate by ID
  Future<Estate?> getEstateById(String estateId) async {
    final db = await database;
    final maps = await db.query('estates',
        where: 'estateId = ?', whereArgs: [estateId]);
    return maps.isNotEmpty ? Estate.fromMap(maps.first) : null;
  }

  // Closes database
  Future close() async {
    final db = await database;
    db.close();
  }
}