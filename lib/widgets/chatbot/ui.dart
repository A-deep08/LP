import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String apiKey = "AIzaSyDACBDXCrIAJBxolPOI0nnfUgsGZ-5KJQg";
const String apiUrl =
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent?key=$apiKey";

class Message {
  final String text;
  final bool isUserMessage;
  const Message({required this.isUserMessage, required this.text});
}

class Ui extends StatefulWidget {
  const Ui({super.key});
  @override
  State<Ui> createState() => _UiState();
}

class _UiState extends State<Ui> {
  final List<Message> messages = [];
  final TextEditingController textController = TextEditingController();
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    messages.add(
      const Message(
        isUserMessage: false,
        text:
            "Hello! I'm StudyBot, your personal study assistant. How can I help you today?",
      ),
    );
  }

  Future<void> getGeminiResponse(String userPrompt) async {
    setState(() {
      isTyping = true;
    });

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

        setState(() {
          messages.add(Message(text: botResponse, isUserMessage: false));
        });
      } else {
        setState(() {
          messages.add(
            Message(
              text:
                  'Error: API request failed with status ${response.statusCode}',
              isUserMessage: false,
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        messages.add(
          Message(
            text: 'Error: Could not connect to the service.',
            isUserMessage: false,
          ),
        );
      });
    } finally {
      setState(() {
        isTyping = false;
      });
    }
  }

  void handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    textController.clear();
    messages.add(Message(text: text, isUserMessage: true));
    getGeminiResponse(text);
  }

  Widget buildMessage(Message message) {
    return Align(
      alignment: message.isUserMessage
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: (Text('StudyBot')), centerTitle: true),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(messages[index]);
              },
            ),
          ),
          Divider(height: 1.0),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: buildTextComposer(),
            ),
          ),
        ],
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
}
