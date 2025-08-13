import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/features/home/repositories/notes_remote_repository.dart';

import 'package:frontend/models/notes_model.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(NotesInitial());
  final notesRemoteRepository = NotesRemoteRepository();

  Future<void> createNewNote({
    required String title,
    required String content,
    required String token,
    required Color color,
  }) async {
    try {
      emit(NotesLoading());
      final notesModel = await notesRemoteRepository.createNote(
        title: title,
        content: content,
        token: token,
        hexColor: rgbToHex(color),
      );

      emit(NotesSuccess(notesModel));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> getAllNotes({required String token}) async {
    try {
      emit(NotesLoading());
      final notes = await notesRemoteRepository.getNotes(token: token);

      emit(GetNotesSuccess(notes));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }
}
