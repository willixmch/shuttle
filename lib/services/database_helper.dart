import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
    // List of estate data sources (add new estate files here).
    final estateDataSources = [theRegentData];

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

  // Closes the database connection.
  Future close() async {
    final db = await database;
    db.close();
  }
}