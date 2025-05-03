import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../data/the_castello_data.dart';
import '../data/the_regent_data.dart';
import '../models/estate.dart';
import '../models/routes.dart';
import '../models/schedule.dart';
import '../models/stop.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shuttle.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE estates (
      estateId TEXT PRIMARY KEY,
      estateName TEXT,
      estateTitleZh TEXT,
      estateTitleEn TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE routes (
      routeId TEXT PRIMARY KEY,
      estateId TEXT,
      routeName TEXT,
      info TEXT,
      FOREIGN KEY (estateId) REFERENCES estates (estateId)
    )
    ''');

    await db.execute('''
    CREATE TABLE schedules (
      scheduleId INTEGER PRIMARY KEY AUTOINCREMENT,
      routeId TEXT,
      dayType TEXT,
      departureTime TEXT,
      FOREIGN KEY (routeId) REFERENCES routes (routeId)
    )
    ''');

    await db.execute('''
    CREATE TABLE stops (
      stopId TEXT,
      routeId TEXT,
      stopNameZh TEXT,
      etaOffset INTEGER,
      PRIMARY KEY (stopId, routeId),
      FOREIGN KEY (routeId) REFERENCES routes (routeId)
    )
    ''');

    await _insertEstateData(db, theCastelloData);
    await _insertEstateData(db, theRegentData);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE stops');
      await db.execute('''
      CREATE TABLE stops (
        stopId TEXT,
        routeId TEXT,
        stopNameZh TEXT,
        etaOffset INTEGER,
        PRIMARY KEY (stopId, routeId),
        FOREIGN KEY (routeId) REFERENCES routes (routeId)
      )
      ''');
      await _insertEstateData(db, theCastelloData);
      await _insertEstateData(db, theRegentData);
    }
  }

  Future<void> _insertEstateData(Database db, Map<String, dynamic> estateData) async {
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

      if (route['stops'] != null) {
        for (var stop in route['stops']) {
          await db.insert(
            'stops',
            {
              'stopId': stop['stopId'],
              'routeId': route['routeId'],
              'stopNameZh': stop['stopNameZh'],
              'etaOffset': stop['etaOffset'],
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    }
  }

  Future<List<Estate>> getAllEstates() async {
    final db = await database;
    final result = await db.query('estates');
    return result.map((e) => Estate.fromMap(e)).toList();
  }

  Future<Estate?> getEstateById(String estateId) async {
    final db = await database;
    final result = await db.query(
      'estates',
      where: 'estateId = ?',
      whereArgs: [estateId],
    );
    return result.isNotEmpty ? Estate.fromMap(result.first) : null;
  }

  Future<List<Routes>> getAllRoutes() async {
    final db = await database;
    final result = await db.query('routes');
    return result.map((e) => Routes.fromMap(e)).toList();
  }

  Future<List<Schedule>> getSchedulesForRoute(String routeId, String dayType) async {
    final db = await database;
    final result = await db.query(
      'schedules',
      where: 'routeId = ? AND dayType = ?',
      whereArgs: [routeId, dayType],
    );
    return result.map((e) => Schedule.fromMap(e)).toList();
  }

  Future<List<Stop>> getStopsForRoute(String routeId) async {
    final db = await database;
    final result = await db.query(
      'stops',
      where: 'routeId = ?',
      whereArgs: [routeId],
    );
    return result.map((e) => Stop.fromMap(e)).toList();
  }

  Future<List<Stop>> getStopsForEstate(String estateId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT DISTINCT s.stopId, MIN(s.routeId) AS routeId, s.stopNameZh, s.etaOffset
      FROM stops s
      JOIN routes r ON s.routeId = r.routeId
      WHERE r.estateId = ?
      GROUP BY s.stopId, s.stopNameZh, s.etaOffset
    ''', [estateId]);
    return result.map((e) => Stop.fromMap(e)).toList();
  }
}