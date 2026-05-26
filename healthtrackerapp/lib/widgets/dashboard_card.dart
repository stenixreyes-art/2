import 'package:flutter/material.dart';
import 'package:healthtrackerapp/screens/scanner_screen.dart';
import 'package:healthtrackerapp/screens/statistics_screen.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const DashboardHome(),
    const ScannerScreen(),
    const StatisticsScreen(userId: "group_active_user"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.teal.shade700,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), activeIcon: Icon(Icons.camera_alt), label: 'Scanner'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Statistics'),
        ],
      ),
    );
  }
}

// FIXED: Re-built cut-off DashboardHome container with rounded elements to prevent crash
class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nutra Dashboard'), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily Calories Logged', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
                    SizedBox(height: 8),
                    Text('1,450 / 2,000 kcal', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Recent Log Entries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.fastfood, color: Colors.white)),
              title: const Text('Grilled Chicken Salad'),
              subtitle: const Text('350 kcal • High Protein'),
              trailing: Icon(Icons.check_circle, color: Colors.green.shade600),
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.local_drink, color: Colors.white)),
              title: const Text('Protein Shake Smoothie'),
              subtitle: const Text('250 kcal • Breakfast Daily'),
              trailing: Icon(Icons.check_circle, color: Colors.green.shade600),
            ),
          ],
        ),
      ),
    );
  }
}