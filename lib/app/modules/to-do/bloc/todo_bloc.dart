import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_mate/app/modules/to-do/todo_model.dart';


part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  TodoBloc() : super(TodoLoading()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<ToggleTodo>(_onToggleTodo);
    on<EditTodo>(_onEditTodo);
  }

  CollectionReference get _todosRef {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    return FirebaseFirestore.instance
        .collection("Users")
        .doc(user.uid)
        .collection("Todos");
  }

  Future<void> _onLoadTodos(
      LoadTodos event, Emitter<TodoState> emit) async {
    try {
      emit(TodoLoading());

      final snapshot = await _todosRef.get();

      final todos = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Todo(
          
          id: doc.id,
          text: data['text'] ?? '',
          isDone: data['isDone'] ?? false,
          createdAt: (data["createdAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

      emit(TodoLoaded(todos));
    } catch (e) {
      emit( TodoError("Failed to load tasks."));
    }
  }

  Future<void> _onAddTodo(
      AddTodo event, Emitter<TodoState> emit) async {
    try {
      await _todosRef.add({
        "text": event.text.trim(),
        "isDone": false,
      });

      add(LoadTodos());
    } catch (e) {
      emit(TodoError("Failed to add task."));
    }
  }

  Future<void> _onDeleteTodo(
      DeleteTodo event, Emitter<TodoState> emit) async {
    try {
      await _todosRef.doc(event.id).delete();
      add(LoadTodos());
    } catch (e) {
      emit( TodoError("Failed to delete task."));
    }
  }

  Future<void> _onToggleTodo(
      ToggleTodo event, Emitter<TodoState> emit) async {
    try {
      await _todosRef.doc(event.id).update({
        "isDone": event.isDone,
      });
      add(LoadTodos());
    } catch (e) {
      emit( TodoError("Failed to update task."));
    }
  }

  Future<void> _onEditTodo(
      EditTodo event, Emitter<TodoState> emit) async {
    try {
      await _todosRef.doc(event.id).update({
        "text": event.newText.trim(),
      });
      add(LoadTodos());
    } catch (e) {
      emit( TodoError("Failed to edit task."));
    }
  }
}
