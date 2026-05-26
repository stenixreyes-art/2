import 'dart:typed_data';
import 'package:flutter/material.dart';

class NutritionScreen extends StatefulWidget {
  final Map<String, dynamic> nutritionData;
  final Uint8List scannedImageBytes;

  const NutritionScreen({
    super.key,
    required this.nutritionData,
    required this.scannedImageBytes,
  });

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  bool _isSaving = false;
  bool _hasSaved = false;

  Future<void> _saveRecord() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 600)); // Write timeline lock

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _hasSaved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged macro logs successfully!')),
    );
  }

  Widget _buildFieldCard(String title, String value, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(Icons.fitness_center, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calories = widget.nutritionData['calories'] ?? 0.0;
    final protein = widget.nutritionData['protein'] ?? 0.0;
    final carbs = widget.nutritionData['carbs'] ?? 0.0;
    final fats = widget.nutritionData['fats'] ?? 0.0;
    final sugar = widget.nutritionData['sugar'] ?? 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(title: const Text('Nutrition Analysis'), backgroundColor: const Color(0xFF5A5A40), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF5A5A40), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const Text('ESTIMATED ENERGY COUNT', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${calories.toStringAsFixed(0)} kcal', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildFieldCard('Protein', '${protein.toStringAsFixed(1)} g', Colors.redAccent),
            _buildFieldCard('Carbs', '${carbs.toStringAsFixed(1)} g', Colors.orangeAccent),
            _buildFieldCard('Fats', '${fats.toStringAsFixed(1)} g', Colors.amberAccent),
            _buildFieldCard('Sugar', '${sugar.toStringAsFixed(1)} g', Colors.pinkAccent),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: (_isSaving || _hasSaved) ? null : _saveRecord,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                backgroundColor: const Color(0xFF5A5A40),
                foregroundColor: Colors.white,
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_hasSaved ? 'Saved in Daily Metrics Log' : 'Save To Local Log'),
            )
          ],
        ),
      ),
    );
  }
}