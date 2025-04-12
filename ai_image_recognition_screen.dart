import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
import 'package:history_finder/screens/place_details_screen.dart';
import '../services/image_service.dart';

class AIImageRecognitionScreen extends StatefulWidget {
  const AIImageRecognitionScreen({super.key});

  @override
  _AIImageRecognitionScreenState createState() => _AIImageRecognitionScreenState();
}

class _AIImageRecognitionScreenState extends State<AIImageRecognitionScreen> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  String _recognizedObject = "No object detected";
  final ImagePicker _picker = ImagePicker();
  final ImageService _imageService = ImageService();
  bool _isLoading = false;
  List<String> _geminiLabels = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras.first, ResolutionPreset.medium);
    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage(File imageFile) async {
    setState(() => _isLoading = true);

    // Google ML Kit Detection
    final inputImage = InputImage.fromFile(imageFile);
    final imageLabeler = ImageLabeler(options: ImageLabelerOptions());
    final labels = await imageLabeler.processImage(inputImage);

    if (labels.isNotEmpty) {
      setState(() {
        _recognizedObject = labels.first.label;
      });

      // Gemini AI Detection
      final result = await _imageService.analyzeWithGemini(imageFile);
      if (result['success']) {
        _geminiLabels = List<String>.from(result['labels']);
      } else {
        print("Gemini Error: ${result['error']}");
      }

      // Navigate to Place Details Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlaceDetailsScreen(placeName: _recognizedObject),
        ),
      );
    } else {
      setState(() {
        _recognizedObject = "No object recognized.";
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _captureAndAnalyze() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final XFile file = await _controller!.takePicture();
      await _analyzeImage(File(file.path));
    }
  }

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      await _analyzeImage(File(file.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Image Recognition with Gemini')),
      body: Column(
        children: [
          Expanded(
            child: _controller == null
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      return snapshot.connectionState == ConnectionState.done
                          ? CameraPreview(_controller!)
                          : const Center(child: CircularProgressIndicator());
                    },
                  ),
          ),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            Column(
              children: [
                Text("Detected: $_recognizedObject", style: const TextStyle(fontSize: 18)),
                const Divider(),
                ..._geminiLabels.map((label) => ListTile(
                      title: Text(label),
                      leading: const Icon(Icons.label),
                    ))
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                onPressed: _captureAndAnalyze,
                child: const Icon(Icons.camera),
              ),
              FloatingActionButton(
                onPressed: _pickImage,
                child: const Icon(Icons.image),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}