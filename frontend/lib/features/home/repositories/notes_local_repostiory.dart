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

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "notes.db");
    return openDatabase(
      path,
      version: 4,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          await db.execute(
            'ALTER TABLE $tableName ADD COLUMN isSynced INTEGER NOT NULL',
          );
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
    if (result.isNotEmpty) {
      List<NotesModel> notes = [];
      for (final elem in result) {
        notes.add(NotesModel.fromMap(elem));
      }
      return notes;
    }

    return [];
  }

  Future<List<NotesModel>> getUnsyncedNotes() async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    if (result.isNotEmpty) {
      List<NotesModel> notes = [];
      for (final elem in result) {
        notes.add(NotesModel.fromMap(elem));
      }
      return notes;
    }

    return [];
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
