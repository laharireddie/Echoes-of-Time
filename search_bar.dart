import 'package:flutter/material.dart';
import 'package:history_finder/screens/recommendations_screen.dart';
import '../services/recommendations_service.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  _SearchBarWidgetState createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _onSearch() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoading = true);

    final coordinates = await RecommendationsService.getCoordinates(query);

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
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Search for a place...',
            filled: true,
            fillColor: Colors.grey[900],
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (_) => _onSearch(),
        ),
        if (_isLoading) const CircularProgressIndicator(),
      ],
    );
  }
}