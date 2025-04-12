import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

class RecommendationsService {
  static const String googleApiKey = "AIzaSyBMgvFKi7ACg64SOIiEjVx6Q3NoT84bdBc";

  // 1. Get coordinates of the searched place
  static Future<Map<String, double>?> getCoordinates(String place) async {
    try {
      List<Location> locations = await locationFromAddress(place);
      if (locations.isNotEmpty) {
        return {
          "latitude": locations.first.latitude,
          "longitude": locations.first.longitude
        };
      }
    } catch (e) {
      print("Error fetching coordinates: $e");
    }
    return null;
  }

  // 2. Fetch nearby historical places using coordinates
  static Future<List<Map<String, dynamic>>> fetchNearbyHistoricalPlaces(
      double latitude, double longitude) async {
    String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=3000&type=tourist_attraction&keyword=historical&key=$googleApiKey";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<Map<String, dynamic>> places = [];

        if (data['results'] != null) {
          for (var result in data['results']) {
            places.add({
              "name": result['name'],
              "address": result['vicinity'],
              "photoReference": result['photos'] != null
                  ? result['photos'][0]['photo_reference']
                  : null,
              "placeId": result['place_id'],
            });
          }
        }
        return places;
      } else {
        throw Exception('Failed to fetch nearby places');
      }
    } catch (e) {
      print("Error fetching historical places: $e");
      return [];
    }
  }
}