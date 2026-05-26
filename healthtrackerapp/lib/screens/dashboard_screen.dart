import 'package:flutter/material.dart';
import 'scanner_screen.dart';
import 'statistics_screen.dart'; // FIXED: Swapped out placeholder for your real fl_chart script

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
    const StatisticsScreen(userId: "group_active_user"), // FIXED: Injected the required user variable
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFF5A5A40),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scanner'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progress'),
        ],
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(title: const Text('Health Dashboard'), backgroundColor: const Color(0xFF5A5A40), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                // FIXED: Removed invalid crossAxisAlignment parameter from the Padding widget itself
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Daily Calories',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '1,450 kcal',
                      style: TextStyle(fontSize: 30, color: Colors.green, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Recent Foods',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2A)),
            ),
            const SizedBox(height: 10),
            const Card(
              child: ListTile(
                leading: Icon(Icons.fastfood, color: Color(0xFF5A5A40)),
                title: Text('Chicken Salad'),
                subtitle: Text('350 kcal'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.fastfood, color: Color(0xFF5A5A40)),
                title: Text('Fruit Smoothie'),
                subtitle: Text('250 kcal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}