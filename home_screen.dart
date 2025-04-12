import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:history_finder/screens/place_details_screen.dart';
import 'package:history_finder/services/location_service.dart';
import 'package:history_finder/widgets/map_widget.dart';
import 'package:history_finder/widgets/logo_widget.dart';
import 'package:history_finder/screens/ ai_image_recognition_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool darkMode = true;
  bool showPopup = false;

  @override
  void initState() {
    super.initState();
    Provider.of<LocationService>(context, listen: false).fetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    var locationService = Provider.of<LocationService>(context);

    return Scaffold(
      backgroundColor: darkMode ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: const Text('Echoes of Time'),
        actions: [
          IconButton(
            icon: darkMode ? const Icon(Icons.wb_sunny) : const Icon(Icons.nightlight_round),
            onPressed: () {
              setState(() {
                darkMode = !darkMode;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera),
  onPressed: () {
    Navigator.push(
      context,
     MaterialPageRoute(builder: (context) => const AIImageRecognitionScreen()));
      

            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const LogoWidget(size: 120).animate().fade(duration: 1000.ms),
          const SizedBox(height: 20),

          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: "Search Historical Places...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: darkMode ? Colors.black87 : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onSubmitted: (query) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaceDetailsScreen(placeName: query),
                ),
              );
            },
          ).animate().slideY(duration: 800.ms),

          const SizedBox(height: 20),

          // Google Map
          const MapWidget().animate().fade(duration: 1200.ms),

          const SizedBox(height: 20),

          // Show Nearby Places
          ElevatedButton(
            onPressed: () => setState(() => showPopup = !showPopup),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Show Nearby Historical Places"),
          ).animate().shake(duration: 1000.ms),

          const SizedBox(height: 20),

          if (locationService.currentPlace != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.green),
                title: Text(locationService.currentPlace!),
                subtitle: const Text("Tap for historical details"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PlaceDetailsScreen(placeName: locationService.currentPlace!),
                    ),
                  );
                },
              ),
            ).animate().fade(duration: 1000.ms),

          if (showPopup)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: darkMode ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Nearby Historical Places are displayed here...",
                textAlign: TextAlign.center,
              ).animate().fade(duration: 1200.ms),
            ),
        ],
      ),
    );
  }
}