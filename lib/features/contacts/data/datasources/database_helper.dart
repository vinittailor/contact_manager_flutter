import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/contact_model.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  static const String _dbName = 'contacts.db';
  static const int _dbVersion = 1;

  // ── Table & Column Constants ──────────────────────────────────────────
  static const String tableContacts = 'contacts';
  static const String colId = 'id';
  static const String colFirstName = 'first_name';
  static const String colLastName = 'last_name';
  static const String colPhoneNumber = 'phone_number';
  static const String colEmail = 'email';
  static const String colIsFavorite = 'is_favorite';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  // ── Database Getter ───────────────────────────────────────────────────
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // ── Initialization ────────────────────────────────────────────────────
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableContacts (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colFirstName TEXT NOT NULL,
        $colLastName TEXT NOT NULL DEFAULT '',
        $colPhoneNumber TEXT NOT NULL,
        $colEmail TEXT DEFAULT '',
        $colIsFavorite INTEGER NOT NULL DEFAULT 0,
        $colCreatedAt TEXT NOT NULL,
        $colUpdatedAt TEXT NOT NULL
      )
    ''');

    // Index on favorite column for fast filtering
    await db.execute('''
      CREATE INDEX idx_is_favorite ON $tableContacts ($colIsFavorite)
    ''');

    // Index on names for sorted queries
    await db.execute('''
      CREATE INDEX idx_name ON $tableContacts ($colFirstName, $colLastName)
    ''');
  }

  // ── CREATE ────────────────────────────────────────────────────────────
  Future<int> insertContact(Contact contact) async {
    try {
      final db = await database;
      return await db.insert(
        tableContacts,
        contact.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert contact: $e');
    }
  }

  // ── READ — All ────────────────────────────────────────────────────────
  Future<List<Contact>> getAllContacts() async {
    try {
      final db = await database;
      final maps = await db.query(
        tableContacts,
        orderBy: '$colFirstName ASC, $colLastName ASC',
      );
      return maps.map((map) => Contact.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch contacts: $e');
    }
  }

  // ── READ — Favorites ─────────────────────────────────────────────────
  Future<List<Contact>> getFavoriteContacts() async {
    try {
      final db = await database;
      final maps = await db.query(
        tableContacts,
        where: '$colIsFavorite = ?',
        whereArgs: [1],
        orderBy: '$colFirstName ASC, $colLastName ASC',
      );
      return maps.map((map) => Contact.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch favorite contacts: $e');
    }
  }

  // ── READ — Single ────────────────────────────────────────────────────
  Future<Contact?> getContactById(int id) async {
    try {
      final db = await database;
      final maps = await db.query(
        tableContacts,
        where: '$colId = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return Contact.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to fetch contact: $e');
    }
  }

  // ── UPDATE ────────────────────────────────────────────────────────────
  Future<int> updateContact(Contact contact) async {
    try {
      final db = await database;
      return await db.update(
        tableContacts,
        contact.toMap(),
        where: '$colId = ?',
        whereArgs: [contact.id],
      );
    } catch (e) {
      throw Exception('Failed to update contact: $e');
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────
  Future<int> deleteContact(int id) async {
    try {
      final db = await database;
      return await db.delete(
        tableContacts,
        where: '$colId = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete contact: $e');
    }
  }

  // ── SEARCH ────────────────────────────────────────────────────────────
  Future<List<Contact>> searchContacts(String query) async {
    try {
      final db = await database;
      final searchTerm = '%$query%';
      final maps = await db.query(
        tableContacts,
        where: '''
          $colFirstName LIKE ? OR
          $colLastName LIKE ? OR
          $colPhoneNumber LIKE ? OR
          $colEmail LIKE ?
        ''',
        whereArgs: [searchTerm, searchTerm, searchTerm, searchTerm],
        orderBy: '$colFirstName ASC, $colLastName ASC',
      );
      return maps.map((map) => Contact.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to search contacts: $e');
    }
  }

  // ── CLOSE ─────────────────────────────────────────────────────────────
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
