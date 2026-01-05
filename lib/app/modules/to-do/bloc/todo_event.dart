part of 'todo_bloc.dart';

abstract class TodoEvent {
  const TodoEvent();
}

class LoadTodos extends TodoEvent {
  const LoadTodos();
}

class AddTodo extends TodoEvent {
  final String text;
  const AddTodo({required this.text});
}

class DeleteTodo extends TodoEvent {
  final String id;
  const DeleteTodo({required this.id});
}

class ToggleTodo extends TodoEvent {
  final String id;
  final bool isDone;
  const ToggleTodo({required this.id, required this.isDone});
}

class EditTodo extends TodoEvent {
  final String id;
  final String newText;
  const EditTodo({required this.id, required this.newText});
}
