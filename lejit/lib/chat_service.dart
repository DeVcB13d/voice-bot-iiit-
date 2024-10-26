import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ChatService {
  final File chatFile;

  ChatService({required this.chatFile});

  // Replace <YOUR_GEMINI_API_KEY> with your actual Gemini API key
  final String apiKey = 'AIzaSyAoT44Tgw6qSFtqwf3EBfHHRCn1cAYKPSU';

  // Update the endpoint for Gemini API
  

  Future<String> sendMessageToGemini(String message) async {
    final String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': message,
              },
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print(responseData);
      final reply = responseData['candidates'][0]['content']['parts'][0]['text'].trim();

      await saveMessage(message, reply);
      return reply;
    } else {
      // Handle different error responses
      print('Error: ${response.statusCode} ${response.reasonPhrase}');
      throw Exception('Failed to get response from Gemini: ${response.reasonPhrase}');
    }
  }

  Future<void> saveMessage(String userMessage, String botReply) async {
    final String content = 'user:$userMessage\nbot:$botReply\n';
    await chatFile.writeAsString(content, mode: FileMode.append);
  }
}
