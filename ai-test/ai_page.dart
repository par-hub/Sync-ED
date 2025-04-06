// import 'package:flutter/material.dart';
// import '../services/ai_service.dart';

// class AIPage extends StatefulWidget {
//   const AIPage({super.key});

//   @override
//   State<AIPage> createState() => _AIPageState();
// }

// class _AIPageState extends State<AIPage> {
//   final TextEditingController _controller = TextEditingController();
//   final List<Map<String, dynamic>> _messages = [
//     {"text": "Welcome! Please paste your resume text here for analysis.", "isMe": false}
//   ];
//   bool _isLoading = false;

//   void _sendMessage() async {
//     if (_controller.text.trim().isEmpty) return;

//     final userMessage = _controller.text.trim();
//     setState(() {
//       _messages.add({"text": userMessage, "isMe": true});
//       _isLoading = true;
//     });
//     _controller.clear();

//     try {
//       final analysis = await AIService.analyzeResume(userMessage);
//       setState(() {
//         _messages.add({"text": analysis, "isMe": false});
//       });
//     } catch (e) {
//       setState(() {
//         _messages.add({
//           "text": "Sorry, there was an error analyzing your resume. Please try again.",
//           "isMe": false
//         });
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF6D3F00),
//         title: const Text(
//           "Resume Analyzer",
//           style: TextStyle(color: Color(0xFFFAF3E0), fontFamily: 'Serif'),
//         ),
//         actions: const [
//           Padding(
//             padding: EdgeInsets.only(right: 16),
//             child: Icon(Icons.settings, color: Color(0xFFFAF3E0)),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(12),
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final msg = _messages[index];
//                 return Align(
//                   alignment: msg["isMe"]
//                       ? Alignment.centerRight
//                       : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(vertical: 6),
//                     padding: const EdgeInsets.all(12),
//                     constraints: const BoxConstraints(maxWidth: 250),
//                     decoration: BoxDecoration(
//                       color: msg["isMe"]
//                           ? const Color(0xFFF4B860)
//                           : const Color(0xFFFFA726),
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 4,
//                           offset: const Offset(2, 2),
//                         ),
//                       ],
//                     ),
//                     child: Text(
//                       msg["text"],
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontFamily: 'Serif',
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           if (_isLoading)
//             const Padding(
//               padding: EdgeInsets.all(20),
//               child: CircularProgressIndicator(
//                 color: Color(0xFFFAF3E0),
//               ),
//             ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             color: const Color(0xFFFAF3E0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: const InputDecoration(
//                       hintText: "Paste your resume text here...",
//                       border: InputBorder.none,
//                     ),
//                     maxLines: 4,
//                     minLines: 1,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _isLoading ? null : _sendMessage,
//                   color: Colors.black,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
