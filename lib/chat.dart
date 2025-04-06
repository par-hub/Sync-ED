import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottom.dart';
import 'package:flutter_application_1/reciver.dart';
import 'package:flutter_application_1/sender.dart';
import 'supabase.dart';
import 'dart:async';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Timer? _timer;
  static const int _refreshInterval = 3;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _timer = Timer.periodic(
      const Duration(seconds: _refreshInterval),
      (_) => _loadMessages(),
    );
  }
  final TextEditingController _controller = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();

  List<Map<String, dynamic>> messages = [];
  bool _isLoading = false;

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabaseService.getData('Messages');
      setState(() {
        messages = data.map((msg) => {
          "text": msg['message'],
          "isMe": msg['user_id'] == _supabaseService.currentUserId,
          "timestamp": DateTime.parse(msg['date_time']),
        }).toList();
        
        // Sort messages by timestamp
        messages.sort((a, b) => 
          (a["timestamp"] as DateTime).compareTo(b["timestamp"] as DateTime)
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading messages: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    
    final message = _controller.text.trim();
    _controller.clear();

    try {
      await _supabaseService.sendMessage(message: message);
      // Reload messages to get the new one
      await _loadMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomBottomBar(),
      backgroundColor: Colors.brown[800],
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Text(
          "Unofficial talks",
          style: TextStyle(fontFamily: 'Serif'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['isMe'];

                return isMe
                    ? Sender(text: msg['text'])
                    : Receiver(text: msg['text']);
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            color: Colors.brown[100],
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
