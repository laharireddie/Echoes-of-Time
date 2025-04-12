import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService extends ChangeNotifier {
  String? currentPlace;

  Future<void> fetchLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      currentPlace = await getPlaceName(position.latitude, position.longitude);
      notifyListeners();
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<String> getPlaceName(double lat, double lon) async {
    String apiKey = 'AIzaSyBMgvFKi7ACg64SOIiEjVx6Q3NoT84bdBc';
    String url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=$apiKey';

    var response = await http.get(Uri.parse(url));
    var data = json.decode(response.body);
    if (data['status'] == 'OK') {
      return data['results'][0]['formatted_address'];
    }
    return 'Unknown Location';
  }
}