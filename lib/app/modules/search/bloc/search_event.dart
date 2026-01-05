part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  const SearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

class UpdateSearchNotes extends SearchEvent {
  final List<Note> notes;
  const UpdateSearchNotes(this.notes);

  @override
  List<Object> get props => [notes];
}
class SortOptionChanged extends SearchEvent {
  final SortOption sortOption;
  const SortOptionChanged(this.sortOption);
}

class TodoFilterChanged extends SearchEvent {
  final TodoFilter filter;
  const TodoFilterChanged(this.filter);
}

class NotesFilterChanged extends SearchEvent {
  final NotesFilter filter;
  const NotesFilterChanged(this.filter);
}
class UpdateSearchSources extends SearchEvent {
  final List<Note> notes;
  final List<Todo> todos;

  const UpdateSearchSources({
    required this.notes,
    required this.todos,
  });
}


class UpdateSearchTodos extends SearchEvent {
  final List<Todo> todos;
  const UpdateSearchTodos(this.todos);

  @override
  List<Object> get props => [todos];
}
