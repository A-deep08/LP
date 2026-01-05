import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:study_mate/app/modules/notes/notes_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  StreamSubscription? _notesSubscription;
  NotesBloc() : super(NotesInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<NotesUpdated>(_onNotesUpdated);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      emit(const NotesError('User not authenticated'));
      return;
    }
    final notesRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('Notes');

    await _notesSubscription?.cancel();
    _notesSubscription = notesRef.snapshots().listen(
      (snapshot) {
        final notes = snapshot.docs.map((doc) => Note.fromDoc(doc)).toList();
        add(NotesUpdated(notes));
      },
      onError: (error) {
        emit(NotesError(error.toString()));
      },
    );
  }

  void _onNotesUpdated(NotesUpdated event, Emitter<NotesState> emit) {
    emit(NotesLoaded(event.notes));
  }

  Future<void> _onAddNote(AddNote event, Emitter<NotesState> emit) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(uid)
          .collection("Notes")
          .add({
            "title": event.title.trim(),
            "body": event.content.trim(),
            "fileUrl": event.fileUrl,
            "fileType": event.fileType,
            "createdAt": DateTime.now(),
          });
    } catch (e) {
      emit(const NotesError("Could not add note"));
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NotesState> emit) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(uid)
          .collection("Notes")
          .doc(event.id)
          .delete();
    } catch (e) {
      emit(const NotesError("Could not delete note"));
    }
  }

  Future<void> _onUpdateNote(UpdateNote event, Emitter<NotesState> emit) async {
  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final data = <String, dynamic>{
      "title": event.title.trim(),
      "body": event.content.trim(),
    };

      
    if (event.fileUrl == null) {
      data["fileUrl"] = FieldValue.delete();
      data["fileType"] = FieldValue.delete();
    } else {
      data["fileUrl"] = event.fileUrl;
      data["fileType"] = event.fileType;
    }

    await FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .collection("Notes")
        .doc(event.id)
        .update(data);
  } catch (e) {
    emit(const NotesError("Could not update note"));
  }
}

}
