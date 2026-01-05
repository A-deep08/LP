part of 'notes_bloc.dart';

sealed class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object> get props => [];
}

class LoadNotes extends NotesEvent {}

class NotesUpdated extends NotesEvent {
  final List<Note> notes;

  const NotesUpdated(this.notes);

  @override
  List<Object> get props => [notes];
}

class AddNote extends NotesEvent {
  final String title;
  final String content;
  final String? fileUrl;
  final String? fileType;
  const AddNote({
    required this.title,
    required this.content,
    this.fileUrl,
    this.fileType,
  });
  @override
  List<Object> get props => [title, content, ?fileUrl, ?fileType];
}

class DeleteNote extends NotesEvent {
  final String id;

  const DeleteNote({required this.id});

  @override
  List<Object> get props => [id];
}

class UpdateNote extends NotesEvent {
  final String id;
  final String title;
  final String content;
  final String? fileUrl;
  final String? fileType;

  const UpdateNote({
    required this.id,
    required this.title,
    required this.content,
    this.fileUrl,
    this.fileType,
  });

  @override
  List<Object> get props => [id, title, content, ?fileUrl, ?fileType];
}
