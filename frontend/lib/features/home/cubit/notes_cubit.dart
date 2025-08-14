import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/features/home/repositories/notes_local_repostiory.dart';
import 'package:frontend/features/home/repositories/notes_remote_repository.dart';
import 'package:frontend/models/notes_model.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(NotesInitial());
  final notesRemoteRepository = NotesRemoteRepository();
  final notesLocalRepository = NotesLocalRepostiory();

  Future<void> createNewNote({
    required String title,
    required String content,
    required Color color,
    required String token,
    required String uid,
    required DateTime dueAt,
  }) async {
    try {
      emit(NotesLoading());
      final notesModel = await notesRemoteRepository.createNote(
        uid: uid,
        title: title,
        content: content,
        hexColor: rgbToHex(color),
        token: token,
        dueAt: dueAt,
      );
      await notesLocalRepository.insertNote(notesModel);

      emit(AddNewNoteSuccess(notesModel));
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

  Future<void> syncNotes(String token) async {
    // get all unsynced notes from our sqlite db
    final unsyncedNotes = await notesLocalRepository.getUnsyncedNotes();
    if (unsyncedNotes.isEmpty) {
      return;
    }

    // talk to our postgresql db to add the new notes
    final isSynced = await notesRemoteRepository.syncNotes(
      token: token,
      notes: unsyncedNotes,
    );
    // change the notes that were added to the db from 0 to 1
    if (isSynced) {
      print("synced done");
      for (final note in unsyncedNotes) {
        notesLocalRepository.updateRowValue(note.id, 1);
      }
    }
  }
}
