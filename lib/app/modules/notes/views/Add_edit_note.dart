  // ignore_for_file: file_names

  import 'dart:io';
  import 'package:flutter/foundation.dart';
  import 'package:flutter/material.dart';
  import 'package:file_picker/file_picker.dart';
  import 'package:cloudinary_public/cloudinary_public.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:path/path.dart' as p;
  import 'package:study_mate/app/modules/notes/bloc/notes_bloc.dart';
  import 'package:url_launcher/url_launcher.dart';

  import 'package:study_mate/app/modules/notes/notes_model.dart';

  class AddEditNote extends StatefulWidget {
    final Note? note;
    const AddEditNote({super.key, this.note});

    @override
    State<AddEditNote> createState() => _AddEditNoteState();
  }

  class _AddEditNoteState extends State<AddEditNote> {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    Uint8List? pickedBytes;
    File? pickedFile;
    String? pickedFileName;
    String? pickedFileType;
    String? existingFileUrl;
    String? existingFileType;

    bool isUploading = false;

    final cloudinary = CloudinaryPublic("doc0fq9vq", "preset", cache: false);

    @override
    void initState() {
      super.initState();

      if (widget.note != null) {
        titleCtrl.text = widget.note!.title;
        bodyCtrl.text = widget.note!.content;
        pickedFileType = widget.note!.fileType;

        existingFileUrl = widget.note!.fileUrl;
        existingFileType = widget.note!.fileType;
      }
    }

    void removeAttachment() {
      setState(() {
        pickedBytes = null;
        pickedFile = null;
        pickedFileName = null;
        pickedFileType = null;

        existingFileUrl = null;
        existingFileType = null;
      });
    }

    Future<void> pickFile() async {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ["jpg", "jpeg", "png", "pdf"],
      );

      if (result != null) {
        pickedFileName = result.files.single.name;
        final ext = p.extension(pickedFileName!).toLowerCase();
        pickedFileType = ext == ".pdf" ? "pdf" : "image";

        if (kIsWeb) {
          pickedBytes = result.files.single.bytes;
          pickedFile = null;
        } else {
          pickedFile = File(result.files.single.path!);
          pickedBytes = null;
        }
        setState(() {});
      }
    }

    Future<void> previewPdf() async {
      final url = existingFileUrl;

      if (url == null) return;

      final uri = Uri.parse(url);

      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Could not open PDF")));
      }
    }

    Future<void> saveNote() async {
      if (titleCtrl.text.trim().isEmpty || bodyCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Title and Body cannot be empty")),
        );
        return;
      }

      setState(() => isUploading = true);

      String? fileUrl = existingFileUrl;
      String? fileType = existingFileType;

      if (pickedFile != null || pickedBytes != null) {
        try {
          final response = await cloudinary.uploadFile(
            kIsWeb
                ? CloudinaryFile.fromBytesData(
                    pickedBytes!,
                    identifier: pickedFileName!,
                    resourceType: CloudinaryResourceType.Auto,
                  )
                : CloudinaryFile.fromFile(
                    pickedFile!.path,
                    resourceType: CloudinaryResourceType.Auto,
                  ),
          );

          fileUrl = response.secureUrl;
          fileType = pickedFileType;
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("File upload failed")));
          }
          setState(() => isUploading = false);
          return;
        }
      }

      if (!mounted) return;
      if (widget.note == null) {
        context.read<NotesBloc>().add(
          AddNote(
            title: titleCtrl.text.trim(),
            content: bodyCtrl.text.trim(),
            fileUrl: fileUrl,
            fileType: fileType,
          ),
        );
      } else {
        context.read<NotesBloc>().add(
          UpdateNote(
            id: widget.note!.id,
            title: titleCtrl.text.trim(),
            content: bodyCtrl.text.trim(),
            fileUrl: fileUrl,
            fileType: fileType,
          ),
        );
      }

      setState(() => isUploading = false);
    }

    @override
    Widget build(BuildContext context) {
      return BlocListener<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NotesLoaded) {
            Navigator.pop(context);
          }
          if (state is NotesError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.note == null ? "Add Note" : "Edit Note"),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: bodyCtrl,
                  decoration: const InputDecoration(labelText: "Body"),
                  maxLines: 6,
                ),
                const SizedBox(height: 24),
                if (pickedFile != null ||
                    pickedBytes != null ||
                    existingFileUrl != null) ...[
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child:
                            pickedFileType == "image" ||
                                (pickedFileType == null &&
                                    existingFileType == "image")
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: pickedBytes != null
                                    ? Image.memory(
                                        pickedBytes!,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      )
                                    : pickedFile != null
                                    ? Image.file(
                                        pickedFile!,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        existingFileUrl!,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                              )
                            : ListTile(
                                onTap: previewPdf,
                                leading: const Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.red,
                                  size: 40,
                                ),
                                title: Text(pickedFileName ?? "PDF attached"),
                                subtitle: existingFileUrl != null
                                    ? const Text("Tap to preview")
                                    : null,
                              ),
                      ),

                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: removeAttachment,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text("Attach File"),
                ),
                const SizedBox(height: 16),
                if (isUploading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: saveNote,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Save Note",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
  }
