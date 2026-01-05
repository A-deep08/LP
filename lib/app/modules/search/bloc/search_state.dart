part of 'search_bloc.dart';

class SearchState extends Equatable {
  final String query;
  final List<Note> notes;
  final List<Todo> todos;
  final SortOption sortOption;
  final TodoFilter todoFilter;
  final NotesFilter notesFilter;
  
  const SearchState({
    this.query = '',
    this.notes = const [],
    this.todos = const [],
    this.sortOption = SortOption.dateDesc,
    this.todoFilter = TodoFilter.all,
    this.notesFilter = NotesFilter.all,
  });

  SearchState copyWith({
    String? query,
    List<Note>? notes,
    List<Todo>? todos,
    SortOption? sortOption,
    TodoFilter? todoFilter,
    NotesFilter? notesFilter,
  }) {
    return SearchState(
      query: query ?? this.query,
      notes: notes ?? this.notes,
      todos: todos ?? this.todos,
      sortOption: sortOption ?? this.sortOption,
      todoFilter: todoFilter ?? this.todoFilter,
      notesFilter: notesFilter ?? this.notesFilter,
    );
  }

  @override
  List<Object?> get props => [query, notes, todos, sortOption, todoFilter, notesFilter];
}
