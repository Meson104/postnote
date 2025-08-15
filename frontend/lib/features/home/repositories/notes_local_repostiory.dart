import 'package:frontend/models/notes_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NotesLocalRepostiory {
  String tableName = "notes";

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDb();
    return _database!;
  }

  /// Helper to check if a column exists in a table
  Future<bool> _columnExists(Database db, String table, String column) async {
    final result = await db.rawQuery('PRAGMA table_info($table)');
    return result.any((row) => row['name'] == column);
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "notes.db");
    return openDatabase(
      path,
      version: 5,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          if (!await _columnExists(db, tableName, 'isSynced')) {
            await db.execute(
              'ALTER TABLE $tableName ADD COLUMN isSynced INTEGER NOT NULL DEFAULT 0',
            );
          }
        }
      },
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $tableName(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            uid TEXT NOT NULL,
            dueAt TEXT NOT NULL,
            hexColor TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            isSynced INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertNote(NotesModel note) async {
    final db = await database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [note.id]);
    await db.insert(tableName, note.toMap());
  }

  Future<void> insertNotes(List<NotesModel> notes) async {
    final db = await database;
    final batch = db.batch();
    for (final note in notes) {
      batch.insert(
        tableName,
        note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<NotesModel>> getNotes() async {
    final db = await database;
    final result = await db.query(tableName);
    return result.map((elem) => NotesModel.fromMap(elem)).toList();
  }

  Future<List<NotesModel>> getUnsyncedNotes() async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return result.map((elem) => NotesModel.fromMap(elem)).toList();
  }

  Future<void> updateRowValue(String id, int newValue) async {
    final db = await database;
    await db.update(
      tableName,
      {'isSynced': newValue},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
