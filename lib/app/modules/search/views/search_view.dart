import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_mate/app/modules/search/bloc/search_bloc.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SearchUI();
  }
}

class _SearchUI extends StatelessWidget {
  const _SearchUI();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
  final bool isWeb = width >= 900;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWeb ? 700 : double.infinity),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Search Notes & Todos",
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (text) {
                    context.read<SearchBloc>().add(SearchQueryChanged(text));
                  },
                ),
              ),
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state.query.isEmpty) {
                      return const Center(child: Text("Start typing to search"));
                    }
                    if (state.notes.isEmpty && state.todos.isEmpty) {
                      return const Center(child: Text("No results"));
                    }
          
                    return ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 4.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.filter_list),
                                tooltip: "Filters & Sorting",
                                onSelected: (value) {
                                  switch (value) {
                                    case 'sort_az':
                                      context.read<SearchBloc>().add(
                                        SortOptionChanged(SortOption.az),
                                      );
                                      break;
                                    case 'sort_za':
                                      context.read<SearchBloc>().add(
                                        SortOptionChanged(SortOption.za),
                                      );
                                      break;
                                    case 'notes_all':
                                      context.read<SearchBloc>().add(
                                        NotesFilterChanged(NotesFilter.all),
                                      );
                                      break;
                                    case 'notes_with_image':
                                      context.read<SearchBloc>().add(
                                        NotesFilterChanged(NotesFilter.withImage),
                                      );
                                      break;
                                    case 'todos_all':
                                      context.read<SearchBloc>().add(
                                        TodoFilterChanged(TodoFilter.all),
                                      );
                                      break;
                                    case 'todos_completed':
                                      context.read<SearchBloc>().add(
                                        TodoFilterChanged(TodoFilter.completed),
                                      );
                                      break;
                                    case 'todos_pending':
                                      context.read<SearchBloc>().add(
                                        TodoFilterChanged(TodoFilter.pending),
                                      );
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'sort_az',
                                    child: ListTile(
                                      leading: Icon(Icons.arrow_upward),
                                      title: Text("Sort A → Z"),
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'sort_za',
                                    child: ListTile(
                                      leading: Icon(Icons.arrow_downward),
                                      title: Text("Sort Z → A"),
                                    ),
                                  ),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem(
                                    value: 'notes_all',
                                    child: ListTile(
                                      leading: Icon(Icons.notes),
                                      title: Text("All Notes"),
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'notes_with_image',
                                    child: ListTile(
                                      leading: Icon(Icons.image),
                                      title: Text("Notes with Images"),
                                    ),
                                  ),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem(
                                    value: 'todos_all',
                                    child: ListTile(
                                      leading: Icon(Icons.list),
                                      title: Text("All Todos"),
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'todos_completed',
                                    child: ListTile(
                                      leading: Icon(Icons.check_circle),
                                      title: Text("Completed Todos"),
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'todos_pending',
                                    child: ListTile(
                                      leading: Icon(Icons.access_time),
                                      title: Text("Pending Todos"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (state.notes.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "Notes",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...state.notes.map(
                            (n) => ListTile(
                              key: ValueKey(n.id),
                              leading: n.fileUrl != null && n.fileType == "image"
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        n.fileUrl!,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.note),
                              title: Text(n.title),
                              subtitle: Text(n.content),
                            ),
                          ),
                        ],
                        if (state.todos.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "Todos",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...state.todos.map(
                            (t) => ListTile(
                              key: ValueKey(t.id),
                              leading: Checkbox(value: t.isDone, onChanged: null),
                              title: Text(
                                t.text,
                                style: TextStyle(
                                  decoration: t.isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
