import 'package:flutter/material.dart';
import 'package:history_finder/utils/api_service.dart';
import 'package:history_finder/screens/recommendations_screen.dart';
import 'package:history_finder/services/recommendations_service.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final String placeName;

  const PlaceDetailsScreen({super.key, required this.placeName});

  @override
  _PlaceDetailsScreenState createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  String details = "Loading...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory(widget.placeName);
  }

  Future<void> fetchHistory(String place) async {
    try {
      String info = await ApiService.fetchWikipediaData(place);
      setState(() {
        details = info.isNotEmpty ? info : "No historical information found.";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        details = "Failed to fetch information.";
        isLoading = false;
      });
    }
  }

  Future<void> _navigateToRecommendations() async {
    setState(() => isLoading = true);

    final coordinates = await RecommendationsService.getCoordinates(widget.placeName);

    if (coordinates != null) {
      final places = await RecommendationsService.fetchNearbyHistoricalPlaces(
        coordinates['latitude']!,
        coordinates['longitude']!,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecommendationsScreen(places: places),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch nearby places.")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.placeName)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.placeName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    details,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                 ElevatedButton(
                    onPressed: _navigateToRecommendations,
                    child: const Text('Nearby Historical Places'),
                  ),
                 
                ],
              ),
            ),
    );
  }
}