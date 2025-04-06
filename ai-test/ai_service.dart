// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class AIService {
//   static Future<String> analyzeResume(String resumeText) async {
//     final apiKey = dotenv.env['NEBIUS_API_KEY'];
//     final apiUrl = dotenv.env['API_URL'];

//     try {
//       final response = await http.post(
//         Uri.parse('$apiUrl/chat/completions'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $apiKey',
//           'X-API-Version': '2023-10-01' // Often required by Nebius
//         },
//         body: jsonEncode({
//           'model': 'deepseek-ai/DeepSeek-V3',
//           'messages': [
//             {
//               'role': 'system',
//               'content': '''You are an expert resume reviewer...''' // Keep your prompt
//             },
//             {'role': 'user', 'content': resumeText},
//           ],
//           'temperature': 0.3,
//           'max_tokens': 512,
//           'top_p': 0.95,
//         }),
//       );

//       final data = jsonDecode(response.body);
//       if (response.statusCode == 200) {
//         return data['choices'][0]['message']['content'];
//       } else {
//         throw Exception('API Error: ${data['error']['message']}');
//       }
//     } catch (e) {
//       throw Exception('Request failed: $e');
//     }
//   }
// }