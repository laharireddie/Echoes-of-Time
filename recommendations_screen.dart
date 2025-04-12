import 'package:flutter/material.dart';
import '../services/image_service.dart';

class RecommendationsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> places;

  const RecommendationsScreen({super.key, required this.places});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nearby Historical Places")),
      body: ListView.builder(
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          final photoRef = place['photoReference'];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(
                place['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(place['address'] ?? "No address available"),
              
              // Use FutureBuilder to fetch and display image asynchronously
              leading: photoRef != null
                  ? FutureBuilder<String>(
                      future: ImageService.fetchPlaceImage(photoRef),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator(); // Loading indicator
                        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Icon(Icons.image_not_supported, size: 70); // Fallback icon
                        } else {
                          return Image.network(
                            snapshot.data!,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 70),
                          );
                        }
                      },
                    )
                  : const Icon(Icons.image_not_supported, size: 70),
              
              onTap: () {
                // Navigate to Place Details Screen
                Navigator.pushNamed(context, '/place_details',
                    arguments: place['name']);
              },
            ),
          );
        },
      ),
    );
  }
}