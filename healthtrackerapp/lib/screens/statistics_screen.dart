import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:healthtrackerapp/services/calorie_stats_service.dart';
enum StatsInterval { weekly, monthly, yearly }

class StatisticsScreen extends StatefulWidget {
  final String userId;

  const StatisticsScreen({super.key, required this.userId});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final CalorieStatsService _statsService = CalorieStatsService(); //
  StatsInterval _selectedInterval = StatsInterval.weekly;
  bool _isLoading = false;
  CalorieStatsResult? _statsResult; //
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      CalorieStatsResult result; //
      switch (_selectedInterval) {
        case StatsInterval.weekly:
          result = await _statsService.getWeeklyStats(widget.userId); //
          break;
        case StatsInterval.monthly:
          result = await _statsService.getMonthlyStats(widget.userId); //
          break;
        case StatsInterval.yearly:
          result = await _statsService.getYearlyStats(widget.userId); //
          break;
      }
      setState(() {
        _statsResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0), // Matches group wireframe theme
      appBar: AppBar(
        title: const Text('Calorie Progress', style: TextStyle(color: Color(0xFF2D2D2A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: StatsInterval.values.map((interval) {
                final isSelected = _selectedInterval == interval;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text(
                      interval.name.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF5A5A40),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedInterval = interval;
                        });
                        _loadData();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF5A5A40)))
                : _errorMessage != null
                ? Center(child: Text('Error: $_errorMessage'))
                : _statsResult == null
                ? const Center(child: Text('No data recorded yet'))
                : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Wireframe Graph Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 220,
                        child: BarChart(
                          BarChartData(
                            borderData: FlBorderData(show: false),
                            titlesData: const FlTitlesData(
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            // FIXED: Changed .groupedEntries to .groupedData to match service structure
                            barGroups: _statsResult!.groupedData.asMap().entries.map((e) {
                              return BarChartGroupData(
                                x: e.key,
                                barRods: [
                                  BarChartRodData(
                                    // FIXED: Changed .value to .calories to match service model
                                    toY: e.value.calories.toDouble(),
                                    color: const Color(0xFF5A5A40),
                                    width: 14,
                                    borderRadius: BorderRadius.circular(4),
                                  )
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Descriptive List Items below chart
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    // FIXED: Changed .groupedEntries to .groupedData
                    itemCount: _statsResult!.groupedData.length,
                    itemBuilder: (context, index) {
                      // FIXED: Changed .groupedEntries to .groupedData
                      final item = _statsResult!.groupedData[index];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          // FIXED: Correctly matching .label and .calories from GroupedStatEntry
                          title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Avg Daily: ${item.calories} kcal'),
                          trailing: const Icon(Icons.add, color: Color(0xFF5A5A40)),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}