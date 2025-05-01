import 'package:shuttle/data/the_castello_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/estate.dart';
import '../models/routes.dart';
import '../models/schedule.dart';

import '../data/the_regent_data.dart';

// Singleton class to manage the SQLite database for shuttle bus data.
class DatabaseHelper {
  // Singleton instance to ensure one database connection.
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Getter for the database, initializes if not created.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shuttle.db');
    return _database!;
  }

  // Initializes the database file.
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    // Open database and create tables on first run.
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Creates database schema and inserts data from estate files.
  Future _createDB(Database db, int version) async {
    // Table for estates (e.g., theRegent).
    await db.execute('''
      CREATE TABLE estates (
        estateId TEXT PRIMARY KEY,
        estateName TEXT NOT NULL
      )
    ''');

    // Table for routes (e.g., A 線), linked to an estate.
    await db.execute('''
      CREATE TABLE routes (
        routeId TEXT PRIMARY KEY,
        routeName TEXT NOT NULL,
        estateId TEXT NOT NULL,
        info TEXT NOT NULL,
        FOREIGN KEY (estateId) REFERENCES estates (estateId)
      )
    ''');

    // Table for schedules (departure times), linked to a route.
    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        routeId TEXT NOT NULL,
        dayType TEXT NOT NULL,
        departureTime TEXT NOT NULL,
        FOREIGN KEY (routeId) REFERENCES routes (routeId)
      )
    ''');

    // Insert data from estate files.
    await _insertEstateData(db);
  }

  // Loads data from all estate data files into the database.
  Future _insertEstateData(Database db) async {
    // List of estate data sources (add new estate files here) !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    final estateDataSources = [theRegentData, theCastelloData];

    for (var estateData in estateDataSources) {
      // Insert estate.
      await db.insert(
        'estates',
        {
          'estateId': estateData['estateId'],
          'estateName': estateData['estateName'],
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      // Insert routes and schedules, if routes exist.
      final routes = estateData['routes'] as List<dynamic>?;
      if (routes != null) {
        for (var route in routes) {
          // Insert route.
          await db.insert(
            'routes',
            {
              'routeId': route['routeId'],
              'routeName': route['routeName'],
              'estateId': estateData['estateId'],
              'info': route['info'],
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );

          // Insert workday schedules, if they exist.
          final workdaySchedules = route['schedules']['workday'] as List<dynamic>?;
          if (workdaySchedules != null) {
            for (var time in workdaySchedules) {
              await db.insert(
                'schedules',
                {
                  'routeId': route['routeId'],
                  'dayType': 'workday',
                  'departureTime': time,
                },
                conflictAlgorithm: ConflictAlgorithm.ignore,
              );
            }
          }

          // Insert weekend schedules, if they exist.
          final weekendSchedules = route['schedules']['weekend'] as List<dynamic>?;
          if (weekendSchedules != null) {
            for (var time in weekendSchedules) {
              await db.insert(
                'schedules',
                {
                  'routeId': route['routeId'],
                  'dayType': 'weekend',
                  'departureTime': time,
                },
                conflictAlgorithm: ConflictAlgorithm.ignore,
              );
            }
          }
        }
      }
    }
  }

  // Fetches all routes from the database, including estate information.
  Future<List<Routes>> getAllRoutes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('routes');
    return List.generate(maps.length, (i) => Routes.fromMap(maps[i]));
  }

  // Fetches schedules for a specific route and day type (workday or weekend).
  Future<List<Schedule>> getSchedulesForRoute(String routeId, String dayType) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'schedules',
      where: 'routeId = ? AND dayType = ?',
      whereArgs: [routeId, dayType],
    );
    return List.generate(maps.length, (i) => Schedule.fromMap(maps[i]));
  }

  // Fetches the estate for a given estateId.
  Future<Estate?> getEstateById(String estateId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'estates',
      where: 'estateId = ?',
      whereArgs: [estateId],
    );
    if (maps.isNotEmpty) {
      return Estate.fromMap(maps.first);
    }
    return null;
  }

  // Closes the database connection.
  Future close() async {
    final db = await database;
    db.close();
  }
}