import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIPage extends StatefulWidget {
  const AIPage({super.key});

  @override
  State<AIPage> createState() => _AIPageState();
}

class _AIPageState extends State<AIPage> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> messages = [
    {"text": "Here is my CV.", "isMe": true},
    {"text": "Thanks! I'm reviewing it now...", "isMe": false},
  ];

  // The Botpress webhook URL
  final String botpressWebhookUrl = "https://webhook.botpress.cloud/a767ea7d-3706-4ad0-877a-1cae5e01405c";

  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();

    setState(() {
      // Add user's message to the chat
      messages.add({
        "text": userMessage,
        "isMe": true,
      });
      // Clear the text field
      _controller.clear();
      // Optionally, add a "typing" indicator from the bot
      messages.add({"text": "Typing...", "isMe": false});
    });

    try {
      final response = await http.post(
        Uri.parse(botpressWebhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': userMessage,
          // You can include additional parameters here (like sender/session id) if needed
          'sender': 'user' // or use a unique user identifier
        }),
      );

      // Remove the "Typing..." message
      setState(() {
        messages.removeWhere((msg) => msg['text'] == 'Typing...');
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Adjust this part depending on the actual response structure from your bot
        final botReply = data['reply'] ?? "No reply";

        setState(() {
          messages.add({
            "text": botReply,
            "isMe": false,
          });
        });
      } else {
        setState(() {
          messages.add({
            "text": "Error: ${response.statusCode}",
            "isMe": false,
          });
        });
      }
    } catch (e) {
      // Remove the "Typing..." message if an exception occurs
      setState(() {
        messages.removeWhere((msg) => msg['text'] == 'Typing...');
        messages.add({
          "text": "Failed to send message.",
          "isMe": false,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // avoids white strip on keyboard
      backgroundColor: const Color(0xFF4E2A00),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D3F00),
        title: const Text("AI", style: TextStyle(fontFamily: 'Serif')),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg['isMe'];

                  return Align(
                    alignment: isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(maxWidth: 250, minHeight: 40),
                      decoration: BoxDecoration(
                        color: isMe
                            ? const Color(0xFFF4B860)
                            : const Color(0xFFFFA726),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        msg['text'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Serif',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: const Color(0xFFFAF3E0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Type your message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
