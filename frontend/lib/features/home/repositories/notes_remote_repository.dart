import 'dart:convert';

import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/models/notes_model.dart';
import 'package:http/http.dart' as http;

class NotesRemoteRepository {
  Future<NotesModel> createNote({
    required String title,
    required String content,
    required String token,
    required String hexColor,
  }) async {
    // Implementation for creating a note
    try {
      final res = await http.post(
        Uri.parse('${Constants.backendUri}/notes'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({
          'title': title,
          'content': content,
          'hexColor': hexColor,
        }),
      );

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['error'];
      }
      return NotesModel.fromJson(res.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<NotesModel>> getNotes({required String token}) async {
    // Implementation for creating a note
    try {
      final res = await http.get(
        Uri.parse('${Constants.backendUri}/notes'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'];
      }
      final listOfNotes = jsonDecode(res.body);
      List<NotesModel> notesList = [];

      for (var element in listOfNotes) {
        notesList.add(NotesModel.fromMap(element));
      }

      return notesList;
    } catch (e) {
      rethrow;
    }
  }
}
