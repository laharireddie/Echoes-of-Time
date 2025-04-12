import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageService {
  static const String googleApiKey = "AIzaSyBMgvFKi7ACg64SOIiEjVx6Q3NoT84bdBc";
  static const String geminiApiKey = "AIzaSyCvW6FJR-ymvKdPbd4TzQ1ZUU-AI1qoz9s";
  static const String geminiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent?key=$geminiApiKey";

  // Fetch image from Google Places
  static Future<String> fetchPlaceImage(String placeId) async {
    String url =
        "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$placeId&key=$googleApiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return url;
    } else {
      return "";
    }
  }

  // Analyze image with Gemini AI
  Future<Map<String, dynamic>> analyzeWithGemini(File image) async {
    try {
      List<int> imageBytes = await image.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final payload = {
        "contents": [
          {
            "parts": [
              {
                "inlineData": {
                  "mimeType": "image/jpeg",
                  "data": base64Image
                }
              }
            ]
          }
        ]
      };

      final response = await http.post(
        Uri.parse(geminiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<String> labels = [];

        if (data['candidates'] != null) {
          for (var candidate in data['candidates']) {
            if (candidate['content'] != null && candidate['content']['parts'] != null) {
              for (var part in candidate['content']['parts']) {
                labels.add(part['text']);
              }
            }
          }
        }

        return {"success": true, "labels": labels};
      } else {
        return {"success": false, "error": "Failed to analyze image"};
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
}