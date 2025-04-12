import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static Future<String> fetchWikipediaData(String place) async {
    try {
      String url = 'https://en.wikipedia.org/api/rest_v1/page/summary/$place';
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data['extract'] ?? 'No information available.';
      } else {
        return 'Error fetching historical data.';
      }
    } catch (e) {
      return 'An error occurred: $e';
    }
  }
}