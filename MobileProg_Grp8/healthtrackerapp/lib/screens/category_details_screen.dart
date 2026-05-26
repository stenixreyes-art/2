import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final String categoryName;

  const CategoryDetailsScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<CategoryDetailsScreen> createState() =>
      _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState
    extends State<CategoryDetailsScreen> {
  bool lowCarb = false;
  bool lowFat = false;
  bool highProtein = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.categoryName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            CheckboxListTile(
              title: const Text('Low Carb'),
              value: lowCarb,
              onChanged: (value) {
                setState(() {
                  lowCarb = value!;
                });
              },
            ),

            CheckboxListTile(
              title: const Text('Low Fat'),
              value: lowFat,
              onChanged: (value) {
                setState(() {
                  lowFat = value!;
                });
              },
            ),

            CheckboxListTile(
              title: const Text('High Protein'),
              value: highProtein,
              onChanged: (value) {
                setState(() {
                  highProtein = value!;
                });
              },
            ),

            const Spacer(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardScreen(),
                  ),
                );
              },
              child: const Text('Save Preferences'),
            )
          ],
        ),
      ),
    );
  }
}