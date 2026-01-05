import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_mate/app/modules/to-do/bloc/todo_bloc.dart';

class TodoView extends StatelessWidget {
  const TodoView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TodoBloc()..add(LoadTodos()),
      child: const TodoViewBody(),
    );
  }
}

class TodoViewBody extends StatefulWidget {
  const TodoViewBody({super.key});

  @override
  State<TodoViewBody> createState() => _TodoViewBodyState();
}

class _TodoViewBodyState extends State<TodoViewBody> {
  final TextEditingController taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodoBloc, TodoState>(
      listener: (context, state) {
        if (state is TodoError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final bloc = context.read<TodoBloc>();
        final width = MediaQuery.of(context).size.width;
        final bool isWeb = width >= 900;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "To-Do List",
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWeb ? 600 : double.infinity,
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: taskController,
                          decoration: InputDecoration(
                            labelText: 'New Task',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                if (taskController.text.trim().isNotEmpty) {
                                  bloc.add(AddTodo(text: taskController.text));
                                  taskController.clear();
                                }
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Expanded(
                          child: Builder(
                            builder: (context) {
                              if (state is TodoLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (state is TodoError) {
                                return Center(child: Text(state.message));
                              }

                              if (state is TodoLoaded) {
                                final todos = state.todos;

                                if (todos.isEmpty) {
                                  return const Center(
                                    child: Text("No tasks yet. Add one!"),
                                  );
                                }

                                return ListView.builder(
                                  itemCount: todos.length,
                                  itemBuilder: (context, index) {
                                    final todo = todos[index];

                                    return Dismissible(
                                      key: Key(todo.id),
                                      direction: DismissDirection.endToStart,
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.only(
                                          right: 20,
                                        ),
                                        color: Colors.red,
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onDismissed: (_) {
                                        bloc.add(DeleteTodo(id: todo.id));
                                      },
                                      child: ListTile(
                                        leading: Checkbox(
                                          value: todo.isDone,
                                          onChanged: (value) {
                                            bloc.add(
                                              ToggleTodo(
                                                id: todo.id,
                                                isDone: value!,
                                              ),
                                            );
                                          },
                                        ),
                                        title: Text(
                                          todo.text,
                                          style: TextStyle(
                                            decoration: todo.isDone
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),

                                        // Tap to EDIT
                                        onTap: () {
                                          final controller =
                                              TextEditingController(
                                                text: todo.text,
                                              );

                                          showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text("Edit Task"),
                                              content: TextField(
                                                controller: controller,
                                                decoration:
                                                    const InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    if (controller.text
                                                        .trim()
                                                        .isNotEmpty) {
                                                      bloc.add(
                                                        EditTodo(
                                                          id: todo.id,
                                                          newText: controller
                                                              .text
                                                              .trim(),
                                                        ),
                                                      );
                                                    }
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("Save"),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              }

                              return const SizedBox();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }
}
