import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'nutrition_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isAnalyzing = false;

  void _captureAndAnalyzeFood() async {
    setState(() => _isAnalyzing = true);

    // Simulating camera frame capture and Gemini Vision payload receipt
    await Future.delayed(const Duration(seconds: 2));

    // SAFETY CHECK: Ensure widget is still on screen before navigating
    if (!mounted) return;
    setState(() => _isAnalyzing = false);

    final mockNutrition = {
      'calories': 480.0,
      'protein': 28.0,
      'carbs': 52.0,
      'fats': 12.5,
      'sugar': 8.0
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NutritionScreen(
          nutritionData: mockNutrition,
          scannedImageBytes: Uint8List(0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              alignment: Alignment.center,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF5A5A40), width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          if (_isAnalyzing)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.teal),
                    SizedBox(height: 16),
                    Text('Gemini processing plate layout...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          if (!_isAnalyzing)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton.large(
                  backgroundColor: const Color(0xFF5A5A40),
                  foregroundColor: Colors.white,
                  onPressed: _captureAndAnalyzeFood,
                  child: const Icon(Icons.camera_alt),
                ),
              ),
            )
        ],
      ),
    );
  }
}