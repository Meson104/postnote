import 'dart:convert';

import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/features/home/repositories/notes_local_repostiory.dart';
import 'package:frontend/models/notes_model.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class NotesRemoteRepository {
  final notesLocalRepository = NotesLocalRepostiory();

  Future<NotesModel> createNote({
    required String title,
    required String content,
    required String hexColor,
    required String token,
    required String uid,
    required DateTime dueAt,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("${Constants.backendUri}/notes"),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({
          'title': title,
          'content': content,
          'hexColor': hexColor,
          'dueAt': dueAt.toIso8601String(),
        }),
      );

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['error'];
      }

      return NotesModel.fromJson(res.body);
    } catch (e) {
      try {
        final notesModel = NotesModel(
          id: const Uuid().v6(),
          uid: uid,
          title: title,
          content: content,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          dueAt: dueAt,
          color: hexToRgb(hexColor),
          isSynced: 0,
        );
        await notesLocalRepository.insertNotes([notesModel]);
        return notesModel;
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<List<NotesModel>> getNotes({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse("${Constants.backendUri}/notes"),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'];
      }

      final listOfNotes = jsonDecode(res.body);
      List<NotesModel> notesList = [];

      for (var elem in listOfNotes) {
        notesList.add(NotesModel.fromMap(elem));
      }

      await notesLocalRepository.insertNotes(notesList);

      return notesList;
    } catch (e) {
      final notes = await notesLocalRepository.getNotes();
      if (notes.isNotEmpty) {
        return notes;
      }
      rethrow;
    }
  }

  Future<bool> syncNotes({
    required String token,
    required List<NotesModel> notes,
  }) async {
    try {
      final notesListInMap = [];
      for (final note in notes) {
        notesListInMap.add(note.toMap());
      }
      final res = await http.post(
        Uri.parse("${Constants.backendUri}/notes/sync"),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode(notesListInMap),
      );

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['error'];
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
