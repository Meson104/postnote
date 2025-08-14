part of 'notes_cubit.dart';

sealed class NotesState {
  const NotesState();
}

final class NotesInitial extends NotesState {}

final class NotesLoading extends NotesState {}

final class NotesError extends NotesState {
  final String error;
  NotesError(this.error);
}

final class AddNewNoteSuccess extends NotesState {
  final NotesModel notesModel;
  const AddNewNoteSuccess(this.notesModel);
}

final class GetNotesSuccess extends NotesState {
  final List<NotesModel> notes;
  const GetNotesSuccess(this.notes);
}
