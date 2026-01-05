part of 'todo_bloc.dart';

abstract class TodoState {
  const TodoState();
}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Todo> todos;
  const TodoLoaded(this.todos);
}

class TodoError extends TodoState {
  final String message;
  const TodoError(this.message);
}
