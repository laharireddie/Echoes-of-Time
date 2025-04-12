import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class AICameraScreen extends StatefulWidget {
  const AICameraScreen({super.key});

  @override
  _AICameraScreenState createState() => _AICameraScreenState();
}

class _AICameraScreenState extends State<AICameraScreen> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  bool isDetecting = false;
  String detectedText = "Detecting...";

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  /// Initialize the Camera
  Future<void> initCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras!.first, ResolutionPreset.medium);
    await controller?.initialize();
    if (mounted) {
      setState(() {});
    }
    startTextRecognition();
  }

  /// Text Recognition with ML Kit
  void startTextRecognition() {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    controller?.startImageStream((CameraImage image) async {
      if (isDetecting) return;
      isDetecting = true;

      try {
        final inputImage = InputImage.fromBytes(
          bytes: image.planes[0].bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: InputImageRotation.rotation0deg,
            format: InputImageFormat.yuv420,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );

        final recognizedText = await textRecognizer.processImage(inputImage);

        if (mounted) {
          setState(() {
            detectedText = recognizedText.text.isNotEmpty
                ? recognizedText.text
                : "No text detected.";
          });
        }
      } catch (e) {
        print("Error during text recognition: $e");
        setState(() {
          detectedText = "Failed to detect text.";
        });
      }

      isDetecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Text Recognition"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          CameraPreview(controller!),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.black87,
              child: Text(
                detectedText,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
