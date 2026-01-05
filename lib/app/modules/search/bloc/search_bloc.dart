import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:study_mate/app/modules/notes/notes_model.dart';
import 'package:study_mate/app/modules/to-do/todo_model.dart';

part 'search_event.dart';
part 'search_state.dart';

enum SortOption {
  dateDesc,
  dateAsc,
  az,
  za,
}

enum TodoFilter {
  all,
  completed,
  pending,
}

enum NotesFilter {
  all,
  withImage,
  textOnly,
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  List<Note> allNotes = [];
  List<Todo> allTodos = [];

  SearchBloc() : super(SearchState()) {
    on<UpdateSearchNotes>(onUpdateNotes);
    on<UpdateSearchTodos>(onUpdateTodos);
    on<SearchQueryChanged>(onQueryChanged);
    on<SortOptionChanged>(onSortChanged);
    on<TodoFilterChanged>(onTodoFilterChanged);
    on<NotesFilterChanged>(onNotesFilterChanged);
  }

  void onUpdateNotes(UpdateSearchNotes event, Emitter<SearchState> emit) {
    allNotes = event.notes;
    applySearch(state.query, emit);
  }

  void onUpdateTodos(UpdateSearchTodos event, Emitter<SearchState> emit) {
    allTodos = event.todos;
    applySearch(state.query, emit);
  }

  void onQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) {
    applySearch(event.query, emit);
  }

  void onSortChanged(SortOptionChanged event, Emitter<SearchState> emit) {
    emit(state.copyWith(sortOption: event.sortOption));
    applySearch(state.query, emit);
  }

  void onTodoFilterChanged(TodoFilterChanged event, Emitter<SearchState> emit) {
    emit(state.copyWith(todoFilter: event.filter));
    applySearch(state.query, emit);
  }

  void onNotesFilterChanged(NotesFilterChanged event, Emitter<SearchState> emit) {
    emit(state.copyWith(notesFilter: event.filter));
    applySearch(state.query, emit);
  }

  void applySearch(String query, Emitter<SearchState> emit) {
    final q = query.toLowerCase(); // ← Fixed: use the new query, not state.query

    List<Note> filteredNotes = allNotes.where((note) {
      final matchesText = note.title.toLowerCase().contains(q) ||
          note.content.toLowerCase().contains(q);
      if (!matchesText) return false;

      switch (state.notesFilter) {
        case NotesFilter.withImage:
          return note.fileUrl != null && note.fileType == "image";
        case NotesFilter.textOnly:
          return note.fileUrl == null;
        case NotesFilter.all:
          return true;
      }
    }).toList();

    List<Todo> filteredTodos = allTodos.where((todo) {
      if (!todo.text.toLowerCase().contains(q)) return false;

      switch (state.todoFilter) {
        case TodoFilter.completed:
          return todo.isDone;
        case TodoFilter.pending:
          return !todo.isDone;
        case TodoFilter.all:
          return true;
      }
    }).toList();

    // Sorting
    switch (state.sortOption) {
      case SortOption.az:
        filteredNotes.sort((a, b) => a.title.compareTo(b.title));
        filteredTodos.sort((a, b) => a.text.compareTo(b.text));
        break;
      case SortOption.za:
        filteredNotes.sort((a, b) => b.title.compareTo(a.title));
        filteredTodos.sort((a, b) => b.text.compareTo(a.text));
        break;
      case SortOption.dateAsc:
        filteredNotes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        filteredTodos.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.dateDesc:
        filteredNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        filteredTodos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    emit(state.copyWith(
      query: query,
      notes: filteredNotes,
      todos: filteredTodos,
    ));
  }
}