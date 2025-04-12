import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String apiKey = 'AIzaSyCvW6FJR-ymvKdPbd4TzQ1ZUU-AI1qoz9s';  // Replace with your Gemini API key

  static Future<String> analyzeImage(File imageFile) async {
    try {
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1/models/gemini-pro-vision:generateContent?key=$apiKey');

      final base64Image = base64Encode(await imageFile.readAsBytes());

      final requestBody = jsonEncode({
        "contents": [
          {
            "parts": [
              {"inlineData": {"mimeType": "image/jpeg", "data": base64Image}}
            ]
          }
        ]
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final description = data['candidates'][0]['content']['parts'][0]['text'];

        return description.isNotEmpty ? description : "No description found.";
      } else {
        return "Failed to analyze image: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}