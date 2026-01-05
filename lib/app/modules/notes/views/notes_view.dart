import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_mate/app/modules/notes/bloc/notes_bloc.dart';
import 'package:study_mate/app/modules/notes/views/Add_edit_note.dart';

class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotesBloc()..add(LoadNotes()),
      child: const NotesViewUI(),
    );
  }
}

class NotesViewUI extends StatelessWidget {
  const NotesViewUI({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotesBloc, NotesState>(
      listener: (context, state) {
        if (state is NotesError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Notes',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<NotesBloc>(),
                      child: const AddEditNote(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: BlocBuilder<NotesBloc, NotesState>(
            builder: (context, state) {
              if (state is NotesLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is NotesError) {
                return Center(child: Text(state.message));
              }

              if (state is NotesLoaded) {
                final notes = state.notes;

                if (notes.isEmpty) {
                  return const Center(child: Text("No notes yet. Add one!"));
                }

                final width = MediaQuery.of(context).size.width;
                int crossAxisCount = width < 600
                    ? 2
                    : width < 1000
                    ? 3
                    : 4;

                return GridView.builder(
                  itemCount: notes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final note = notes[index];

                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(note.title),
                            content: SingleChildScrollView(
                              child: Column(
                                children: [
                                  if (note.fileUrl != null &&
                                      note.fileType == "image")
                                    Image.network(note.fileUrl!, height: 200),

                                  if (note.fileUrl != null &&
                                      note.fileType == "pdf")
                                    Row(
                                      children: const [
                                        Icon(
                                          Icons.picture_as_pdf,
                                          size: 35,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text("PDF attached"),
                                      ],
                                    ),

                                  const SizedBox(height: 10),
                                  Text(note.content),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Close"),
                              ),
                            ],
                          ),
                        );
                      },

                    
                      onLongPress: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (_) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.edit),
                                    title: const Text("Edit"),
                                    onTap: () {
                                      Navigator.pop(context);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider.value(
                                            value: context.read<NotesBloc>(),
                                            child: AddEditNote(note: note),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    title: const Text("Delete"),
                                    onTap: () {
                                      Navigator.pop(context);

                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Delete Note'),
                                          content: const Text(
                                            'Are you sure you want to delete this note?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                context.read<NotesBloc>().add(
                                                  DeleteNote(id: note.id),
                                                );
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Delete"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },

                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (note.fileUrl != null &&
                                note.fileType == "image")
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Image.network(
                                    note.fileUrl!,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                            if (note.fileUrl != null && note.fileType == "pdf")
                              Row(
                                children: const [
                                  Icon(
                                    Icons.picture_as_pdf,
                                    size: 35,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text("PDF attached"),
                                ],
                              ),

                            const SizedBox(height: 8),

                            Text(
                              note.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 5),

                            Expanded(
                              child: Text(
                                note.content,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
