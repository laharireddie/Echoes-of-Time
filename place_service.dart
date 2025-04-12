import 'package:http/http.dart' as http;
import 'dart:convert';

class PlaceService {
  static const String apiKey = "AIzaSyBMgvFKi7ACg64SOIiEjVx6Q3NoT84bdBc";

  static Future<String> fetchPlaceImage(String placeName) async {
    final url = Uri.parse(
        "https://api.unsplash.com/search/photos?query=$placeName&client_id=YOUR_UNSPLASH_API_KEY");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        return data['results'][0]['urls']['small'];
      }
    }
    return "https://via.placeholder.com/400"; // Default image
  }
}