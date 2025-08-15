import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/work_entry.dart';
import '../models/user.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pavimentazione.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        role TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE works(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT,
        date TEXT,
        latitude REAL,
        longitude REAL,
        address TEXT,
        unitNumber TEXT,
        status TEXT,
        meters REAL,
        photoBeforePath TEXT,
        photoAfterPath TEXT,
        startTime TEXT,
        endTime TEXT,
        notes TEXT,
        invoiceCode TEXT
      )
    ''');

    // Insert default users
    await db.insert('users', {'username': 'operaio', 'password': '1234', 'role': 'operaio'});
    await db.insert('users', {'username': 'supervisore', 'password': '4321', 'role': 'supervisore'});
  }

  // User methods
  Future<AppUser?> getUserByCredentials(String username, String password) async {
    final db = await instance.database;
    final res = await db.query('users', where: 'username = ? AND password = ?', whereArgs: [username, password]);
    if (res.isEmpty) return null;
    return AppUser.fromMap(res.first);
  }

  // Work methods
  Future<WorkEntry> createWork(WorkEntry entry) async {
    final db = await instance.database;
    final id = await db.insert('works', entry.toMap());
    entry.id = id;
    return entry;
  }

  Future<List<WorkEntry>> readAllWorks() async {
    final db = await instance.database;
    final res = await db.query('works', orderBy: 'date DESC, id DESC');
    return res.map((e) => WorkEntry.fromMap(e)).toList();
  }

  Future<List<WorkEntry>> readWorksByUser(String userId) async {
    final db = await instance.database;
    final res = await db.query('works', where: 'userId = ?', whereArgs: [userId], orderBy: 'date DESC, id DESC');
    return res.map((e) => WorkEntry.fromMap(e)).toList();
  }

  Future<List<WorkEntry>> readWorksByDate(String date) async {
    final db = await instance.database;
    final res = await db.query('works', where: 'date = ?', whereArgs: [date], orderBy: 'id DESC');
    return res.map((e) => WorkEntry.fromMap(e)).toList();
  }

  Future<void> updateInvoiceCode(int id, String code) async {
    final db = await instance.database;
    await db.update('works', {'invoiceCode': code}, where: 'id = ?', whereArgs: [id]);
  }
}
