import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:history_finder/services/image_service.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _controller;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  static const String apiKey = "AIzaSyBMgvFKi7ACg64SOIiEjVx6Q3NoT84bdBc";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _addMarker(_currentPosition!, "You are here", "");
    });

    _controller?.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 15));
    _fetchNearbyPlaces(position.latitude, position.longitude);
  }

  Future<void> _fetchNearbyPlaces(double lat, double lng) async {
    String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=2000&type=historical&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      for (var place in data['results']) {
        String? photoReference = place['photos'] != null
            ? place['photos'][0]['photo_reference']
            : null;

        if (photoReference != null) {
          String imageUrl = await ImageService.fetchPlaceImage(photoReference);
          _addMarker(
            LatLng(
              place['geometry']['location']['lat'],
              place['geometry']['location']['lng'],
            ),
            place['name'],
            imageUrl,
          );
        }
      }
      setState(() {});
    }
  }

  void _addMarker(LatLng position, String title, String imageUrl) {
    _markers.add(
      Marker(
        markerId: MarkerId(title),
        position: position,
        infoWindow: InfoWindow(
          title: title,
          snippet: imageUrl.isNotEmpty ? "Tap for Image" : "No Image Available",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        onTap: () {
          _showImagePopup(title, imageUrl);
        },
      ),
    );
  }

  void _showImagePopup(String title, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: imageUrl.isNotEmpty
              ? Image.network(imageUrl)
              : const Text("No image available"),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: GoogleMap(
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
        markers: _markers,
        initialCameraPosition: CameraPosition(
          target: _currentPosition ?? const LatLng(0, 0),
          zoom: 15,
          tilt: 45,
        ),
      ),
    );
  }
}
