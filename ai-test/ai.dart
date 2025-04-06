// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:io';
// import 'dart:async';

// void main() {
//   runApp(const ResumeAnalyzerApp());
// }

// class ResumeAnalyzerApp extends StatelessWidget {
//   const ResumeAnalyzerApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Resume Analyzer AI',
//       theme: ThemeData(
//         primarySwatch: Colors.orange,
//         fontFamily: 'Serif',
//       ),
//       home: const ChatScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final List<ChatMessage> _messages = [];
//   bool _isLoading = false;
//   final ScrollController _scrollController = ScrollController();

//   // Botpress configuration
//   static const String _botId = 'd272fa61-6114-40c9-a141-e0f683795759';
//   static const String _authToken = 'bp_pat_dJ05UW5NDsmlHQHhTkjo05sBLuu3eWVgELVe';
//   String? _conversationId;

//   @override
//   void initState() {
//     super.initState();
//     _addSystemMessage("Welcome to Resume Analyzer AI! How can I help you today?");
//   }

//   void _addSystemMessage(String text) {
//     setState(() {
//       _messages.add(ChatMessage(
//         text: text,
//         isUser: false,
//         timestamp: DateTime.now(),
//       ));
//     });
//   }

//   Future<void> _sendMessage() async {
//     if (_controller.text.trim().isEmpty) return;

//     final message = _controller.text.trim();
//     _addMessage(message, true);
//     _controller.clear();

//     setState(() => _isLoading = true);
//     await Future.delayed(const Duration(milliseconds: 100));

//     try {
//       // 1. Verify internet connectivity
//       await _verifyNetworkConnection();

//       // 2. Initialize conversation if needed
//       if (_conversationId == null) {
//         await _initializeBotpressConversation();
//       }

//       // 3. Send user message
//       await _sendMessageToBot(message);

//       // 4. Retrieve bot response
//       final response = await _retrieveBotResponse();
//       _addMessage(response, false);
//     } catch (e) {
//       _handleError(e);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _verifyNetworkConnection() async {
//     try {
//       // Try DNS resolution first
//       final addresses = await InternetAddress.lookup('google.com');
//       if (addresses.isEmpty) throw Exception('DNS resolution failed');

//       // Then verify actual connectivity
//       final response = await http.get(
//         Uri.parse('https://www.google.com/favicon.ico'),
//       ).timeout(const Duration(seconds: 5));

//       if (response.statusCode != 200) {
//         throw Exception('Internet connection unstable');
//       }
//     } on SocketException {
//       throw Exception('Network unavailable. Please check your connection.');
//     } on TimeoutException {
//       throw Exception('Connection timeout. Please try again.');
//     }
//   }

//   Future<void> _initializeBotpressConversation() async {
//     const url = 'https://api.botpress.cloud/v1/bots/$_botId/conversations';
//     final headers = _buildHeaders();

//     final response = await http.post(
//       Uri.parse(url),
//       headers: headers,
//       body: jsonEncode({
//         "user": {
//           "id": "user_${DateTime.now().millisecondsSinceEpoch}",
//           "name": "Resume Analyzer User",
//           "tags": {"platform": "flutter"}
//         }
//       }),
//     ).timeout(const Duration(seconds: 10));

//     if (response.statusCode == 201) {
//       final data = jsonDecode(response.body);
//       _conversationId = data['id'];
//       debugPrint('New conversation started: $_conversationId');
//     } else {
//       throw _parseApiError(response, 'Failed to start conversation');
//     }
//   }

//   Future<void> _sendMessageToBot(String message) async {
//     final url = 'https://api.botpress.cloud/v1/bots/$_botId/conversations/$_conversationId/messages';
//     final headers = _buildHeaders();

//     final response = await http.post(
//       Uri.parse(url),
//       headers: headers,
//       body: jsonEncode({
//         "type": "text",
//         "text": message,
//         "payload": {"metadata": {"source": "flutter_app"}}
//       }),
//     ).timeout(const Duration(seconds: 10));

//     if (response.statusCode != 200) {
//       throw _parseApiError(response, 'Failed to send message');
//     }
//   }

//   Future<String> _retrieveBotResponse() async {
//     const maxRetries = 5;
//     final url = 'https://api.botpress.cloud/v1/bots/$_botId/conversations/$_conversationId/messages';
//     final headers = _buildHeaders();

//     for (int attempt = 0; attempt < maxRetries; attempt++) {
//       await Future.delayed(const Duration(seconds: 1));

//       try {
//         final response = await http.get(Uri.parse(url), headers: headers)
//             .timeout(const Duration(seconds: 5));

//         if (response.statusCode == 200) {
//           final messages = jsonDecode(response.body)['messages'] as List;
//           final botMessages = messages.where((msg) =>
//               msg['type'] == 'text' &&
//               msg['role'] == 'bot' &&
//               msg['direction'] == 'outgoing');

//           if (botMessages.isNotEmpty) {
//             return botMessages.last['payload']['text'] as String;
//           }
//         }
//       } catch (e) {
//         debugPrint('Bot response attempt $attempt failed: $e');
//       }
//     }
//     return "I'm having trouble responding. Please try again later.";
//   }

//   Map<String, String> _buildHeaders() {
//     return {
//       'Authorization': 'Bearer $_authToken',
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//       'Accept-Encoding': 'gzip',
//     };
//   }

//   Exception _parseApiError(http.Response response, String context) {
//     try {
//       final error = jsonDecode(response.body)?['error'] ?? {};
//       return Exception('$context: ${error['message'] ?? 'Unknown error'} (${response.statusCode})');
//     } catch (e) {
//       return Exception('$context: ${response.statusCode} - ${response.body}');
//     }
//   }

//   void _addMessage(String text, bool isUser) {
//     setState(() {
//       _messages.add(ChatMessage(
//         text: text,
//         isUser: isUser,
//         timestamp: DateTime.now(),
//       ));
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       });
//     });
//   }

//   void _handleError(dynamic error) {
//     final errorMessage = error is Exception ? error.toString() : 'An unexpected error occurred';
//     final safeErrorMessage = errorMessage
//         .replaceAll(_authToken, '***')
//         .replaceAll(_botId, '***');

//     _addMessage('Error: $safeErrorMessage', false);
//     debugPrint('Full error details: $error');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF4E2A00),
//       appBar: AppBar(
//         title: const Text('Resume Analyzer AI'),
//         backgroundColor: const Color(0xFF6D3F00),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.info_outline),
//             onPressed: _showInfoDialog,
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _resetConversation,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               padding: const EdgeInsets.all(16),
//               itemCount: _messages.length,
//               itemBuilder: (context, index) => _messages[index],
//             ),
//           ),
//           if (_isLoading)
//             const Padding(
//               padding: EdgeInsets.all(12),
//               child: CircularProgressIndicator(
//                 color: Color(0xFFF4B860),
//               ),
//             ),
//           _buildMessageInput(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageInput() {
//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//         left: 16,
//         right: 16,
//         top: 8,
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _controller,
//               decoration: InputDecoration(
//                 hintText: "Ask about resume analysis...",
//                 filled: true,
//                 fillColor: const Color(0xFFFAF3E0),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(24),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 16,
//                 ),
//               ),
//               onSubmitted: (_) => _sendMessage(),
//               maxLines: null,
//             ),
//           ),
//           const SizedBox(width: 12),
//           CircleAvatar(
//             backgroundColor: const Color(0xFFF4B860),
//             child: IconButton(
//               icon: const Icon(Icons.send, color: Colors.white),
//               onPressed: _sendMessage,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showInfoDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('About'),
//         content: const Text(
//           'Resume Analyzer AI helps you optimize your resume with AI-powered suggestions.\n\n'
//           'You can ask about:\n'
//           '- Resume formatting tips\n'
//           '- Industry-specific advice\n'
//           '- Keyword optimization\n'
//           '- ATS compatibility',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _resetConversation() {
//     setState(() {
//       _conversationId = null;
//       _messages.clear();
//       _addSystemMessage("Conversation reset. How can I help you now?");
//     });
//   }
// }

// class ChatMessage extends StatelessWidget {
//   final String text;
//   final bool isUser;
//   final DateTime timestamp;

//   const ChatMessage({
//     super.key,
//     required this.text,
//     required this.isUser,
//     required this.timestamp,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Align(
//         alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               color: isUser ? const Color(0xFFF4B860) : const Color(0xFFFFA726),
//               borderRadius: BorderRadius.only(
//                 topLeft: const Radius.circular(20),
//                 topRight: const Radius.circular(20),
//                 bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
//                 bottomRight: isUser ? Radius.zero : const Radius.circular(20),
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 4,
//                   offset: const Offset(2, 2),
//                 ),
//               ],
//             ),
//             padding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 12,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   text,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   DateFormat('hh:mm a').format(timestamp),
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: Colors.black.withOpacity(0.6),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }