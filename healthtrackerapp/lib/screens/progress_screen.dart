// lib/screens/progress_screen.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Progress')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Calories',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(1, 1200),
                        FlSpot(2, 1400),
                        FlSpot(3, 1300),
                        FlSpot(4, 1500),
                        FlSpot(5, 1600),
                        FlSpot(6, 1450),
                        FlSpot(7, 1700),
                      ],
                      isCurved: true,
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(Icons.local_fire_department),
                title: const Text('Daily Goal'),
                subtitle: const Text('You reached 85% of your goal today'),
              ),
            )
          ],
        ),
      ),
    );
  }
}