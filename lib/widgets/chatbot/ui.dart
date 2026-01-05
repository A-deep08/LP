import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String apiUrl =
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=AIzaSyAXokjt0RJNqGG32oK_V1nA8dr85z7jXOc";

class Message {
  final String text;
  final bool isUserMessage;
  final String id;

  const Message({
    required this.text,
    required this.isUserMessage,
    required this.id,
  });

  factory Message.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      text: data['text'] ?? '',
      isUserMessage: data['isUserMessage'] ?? false,
    );
  }
}

class Ui extends StatefulWidget {
  const Ui({super.key});

  @override
  State<Ui> createState() => _UiState();
}

class _UiState extends State<Ui> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController textController = TextEditingController();
  bool isTyping = false;

  User? get user => FirebaseAuth.instance.currentUser;

  CollectionReference get chatRef {
    if (user == null) throw Exception("User not logged in");
    return FirebaseFirestore.instance
        .collection("Users")
        .doc(user!.uid)
        .collection("Chats");
  }

  @override
  void initState() {
    super.initState();
    _initializeBotIntro();
  }

  Future<void> _initializeBotIntro() async {
    final introText =
        "Hello! I'm StudyBot, your personal study assistant. How can I help you today?";
    final existing = await chatRef.get();
    if (existing.docs.isEmpty) {
      await chatRef.add({
        "text": introText,
        "isUserMessage": false,
        "timestamp": FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> getGeminiResponse(String userPrompt) async {
    setState(() => isTyping = true);

    final payload = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": userPrompt},
          ],
        },
      ],
      "systemInstruction": {
        "parts": [
          {
            "text":
                "You are a helpful and encouraging study assistant. Keep your responses clear, accurate, and concise.",
          },
        ],
      },
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: payload,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        String botResponse = 'Sorry, I could not generate a response.';
        if (decoded['candidates'] != null && decoded['candidates'].isNotEmpty) {
          botResponse =
              decoded['candidates'][0]['content']['parts'][0]['text'] ??
              botResponse;
        }

        await chatRef.add({
          "text": botResponse,
          "isUserMessage": false,
          "timestamp": FieldValue.serverTimestamp(),
        });
      } else {
        await chatRef.add({
          "text": "Error: API request failed (${response.statusCode})",
          "isUserMessage": false,
          "timestamp": FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      await chatRef.add({
        "text": "Error: Could not connect to the service.",
        "isUserMessage": false,
        "timestamp": FieldValue.serverTimestamp(),
      });
    } finally {
      setState(() => isTyping = false);
    }
  }

  Future<void> handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    textController.clear();

    await chatRef.add({
      "text": text.trim(),
      "isUserMessage": true,
      "timestamp": FieldValue.serverTimestamp(),
    });

    await getGeminiResponse(text);
  }

  Widget buildMessage(Message message) {
    return Align(
      alignment: message.isUserMessage
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: message.isUserMessage ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUserMessage ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget buildTextComposer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              onSubmitted: handleSubmitted,
              decoration: const InputDecoration(
                hintText: 'Send a message',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () => handleSubmitted(textController.text),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to chat.")),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'StudyBot',
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatRef.orderBy("timestamp").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading messages"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("Start chatting with StudyBot!"),
                  );
                }

                final messages = snapshot.data!.docs
                    .map((doc) => Message.fromDoc(doc))
                    .toList();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!scrollController.hasClients) return;

                  scrollController.jumpTo(
                    scrollController.position.maxScrollExtent,
                  );

                  Future.delayed(const Duration(milliseconds: 20), () {
                    if (scrollController.hasClients) {
                      scrollController.jumpTo(
                        scrollController.position.maxScrollExtent,
                      );
                    }
                  });
                });

                return ListView.builder(
                  controller: scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return buildMessage(messages[index]);
                  },
                );
              },
            ),
          ),
          if (isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("StudyBot is typing..."),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: buildTextComposer(),
          ),
        ],
      ),
    );
  }
}
