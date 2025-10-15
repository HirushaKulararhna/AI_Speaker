import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // PASTE YOUR API KEY HERE (between the quotes)
  final String apiKey = 'AIzaSyC2hQruLq3mJ1uMbYcLXDOoYTAOeOGfKUQ';
  
  String get apiUrl => 
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey';

  Future<String> getResponse(String userMessage) async {
    try {
      // Check if API key is still default
      if (apiKey == 'AIzaSyC2hQruLq3mJ1uMbYcLXDOoYTAOeOGfKUQ' || apiKey.isEmpty) {
        return 'Please add your Google Gemini API key in ai_service.dart file';
      }

      print('📤 Sending request...');
      print('🔑 Using API key: ${apiKey.substring(0, 10)}...');
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': 'You are a helpful English teacher. Give short, clear, friendly responses in 2-3 sentences. User says: $userMessage'
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 100,
          }
        }),
      );

      print('✅ Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        return text.trim();
      } else if (response.statusCode == 400) {
        print('❌ Error 400: Invalid API key');
        return 'Invalid API key. Please check your Gemini API key at https://aistudio.google.com/app/apikey';
      } else if (response.statusCode == 429) {
        return 'Too many requests. Please wait a moment.';
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        return 'Error ${response.statusCode}. Please try again.';
      }
    } catch (e) {
      print('❌ Exception: $e');
      return 'Connection error. Please check your internet connection.';
    }
  }
}