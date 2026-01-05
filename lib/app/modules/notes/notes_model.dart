import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final String? fileUrl;
  final String? fileType;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.fileUrl,
    this.fileType,
    required this.createdAt,
  });

  factory Note.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Note(
      id: doc.id,
      title: data["title"] ?? "",
      content: data["body"] ?? "",
      fileUrl: data["fileUrl"],
      fileType: data["fileType"],
      createdAt: (data["createdAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
