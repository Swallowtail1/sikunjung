import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/kunjungan.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sikunjung.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Membuat tabel users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL
      )
    ''');

    // Membuat tabel kunjungan
    await db.execute('''
      CREATE TABLE kunjungan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_pelanggan TEXT NOT NULL,
        alamat TEXT NOT NULL,
        no_hp TEXT NOT NULL,
        catatan TEXT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        tanggal TEXT NOT NULL
      )
    ''');
  }

  // --- CRUD KUNJUNGAN ---

  Future<int> insertKunjungan(Kunjungan kunjungan) async {
    final db = await instance.database;
    return await db.insert('kunjungan', kunjungan.toMap());
  }

  Future<List<Kunjungan>> getAllKunjungan() async {
    final db = await instance.database;
    final result = await db.query('kunjungan', orderBy: 'tanggal DESC');
    return result.map((json) => Kunjungan.fromMap(json)).toList();
  }

  Future<int> updateKunjungan(Kunjungan kunjungan) async {
    final db = await instance.database;
    // Menggunakan parameter (whereArgs) untuk mencegah SQL Injection[cite: 1]
    return db.update(
      'kunjungan',
      kunjungan.toMap(),
      where: 'id = ?',
      whereArgs: [kunjungan.id],
    );
  }

  Future<int> deleteKunjungan(int id) async {
    final db = await instance.database;
    return await db.delete(
      'kunjungan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- FUNGSI USER (Untuk Login & Register) ---

  Future<int> insertUser(User user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser(String username) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      columns: ['id', 'username', 'password_hash'],
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }
}