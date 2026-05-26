import 'dart:math';

/// Represents a single daily log of calories consumed against a target threshold.
class CalorieLog {
  final DateTime date;
  final int caloriesConsumed;
  final int targetCalories;

  CalorieLog({
    required this.date,
    required this.caloriesConsumed,
    required this.targetCalories,
  });

  /// Factory constructor to map a Cloud Firestore JSON document to a typed structure.
  factory CalorieLog.fromFirestore(Map<String, dynamic> data) {
    DateTime parsedDate;
    if (data['date'] != null) {
      parsedDate = DateTime.parse(data['date'] as String);
    } else {
      parsedDate = DateTime.now();
    }

    return CalorieLog(
      date: parsedDate,
      caloriesConsumed: (data['totalCalories'] ?? 0).toInt(),
      targetCalories: (data['targetCalories'] ?? 2000).toInt(),
    );
  }

  /// Converts this Log object into a JSON map.
  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String().substring(0, 10),
      'totalCalories': caloriesConsumed,
      'targetCalories': targetCalories,
    };
  }
}

/// Represents an individual grouped entry optimized for charts (like FL Chart or Syncfusion).
class GroupedStatEntry {
  final String label; // e.g., "Mon", "Week 1", "Jan"
  final int calories;
  final int targetCalories;

  GroupedStatEntry({
    required this.label,
    required this.calories,
    required this.targetCalories,
  });
}

/// Consolidated statistics result carrying calculated averages, sums, and chart groups.
class CalorieStatsResult {
  final int totalCalories;
  final double averageCalories;
  final List<GroupedStatEntry> groupedData;

  CalorieStatsResult({
    required this.totalCalories,
    required this.averageCalories,
    required this.groupedData,
  });
}

/// Service to fetch and calculate user calorie statistics across modern intervals.
class CalorieStatsService {

  /// Simulated Mock database accessor to feed visual widgets on startup.
  /// Shows how data queries would flow from the 'daily_calorie_logs' Firestore subcollection.
  Future<List<CalorieLog>> fetchUserLogs(String userId) async {
    // Note: In development with actual Firebase integrations, query directly:
    //
    // final querySnapshot = await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(userId)
    //     .collection('daily_calorie_logs')
    //     .orderBy('date', descending: true)
    //     .get();
    //
    // return querySnapshot.docs.map((doc) =>
    //   CalorieLog.fromFirestore(doc.data() as Map<String, dynamic>)
    // ).toList();

    // Setup realistic historical sample logs (365 entries)
    final List<CalorieLog> mockLogs = [];
    final DateTime now = DateTime.now();
    final Random random = Random();

    for (int i = 0; i < 365; i++) {
      final DateTime logDate = now.subtract(Duration(days: i));

      // Dynamic noise: slightly higher calories on weekends (Fri, Sat, Sun)
      int baseCal = 1950;
      if (logDate.weekday >= 5) {
        baseCal = 2250;
      } else {
        baseCal = 1800;
      }

      final int variance = random.nextInt(500) - 250; // Fluctuation: +/- 250 kcal
      final int caloriesConsumed = baseCal + variance;
      const int targetCalories = 2000;

      mockLogs.add(CalorieLog(
        date: logDate,
        caloriesConsumed: max(500, caloriesConsumed),
        targetCalories: targetCalories,
      ));
    }

    // Return with a realistic network simulation latency delay (350 ms)
    return Future.delayed(const Duration(milliseconds: 350), () => mockLogs);
  }

  /// Calculates Weekly statistics (filtered to current the last 7 calendar days).
  Future<CalorieStatsResult> getWeeklyStats(String userId) async {
    final List<CalorieLog> allLogs = await fetchUserLogs(userId);
    final DateTime now = DateTime.now();
    final DateTime sevenDaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

    final weeklyLogs = allLogs.where((log) =>
    log.date.isAfter(sevenDaysAgo.subtract(const Duration(seconds: 1))) &&
        log.date.isBefore(now.add(const Duration(days: 1)))
    ).toList();

    final List<GroupedStatEntry> groupedData = [];
    final List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    int totalCalories = 0;

    for (int i = 0; i < 7; i++) {
      final DateTime day = sevenDaysAgo.add(Duration(days: i));
      final String label = weekdays[day.weekday - 1];

      final index = weeklyLogs.indexWhere((log) =>
      log.date.year == day.year &&
          log.date.month == day.month &&
          log.date.day == day.day
      );

      int calories = 0;
      int target = 2000;

      if (index != -1) {
        calories = weeklyLogs[index].caloriesConsumed;
        target = weeklyLogs[index].targetCalories;
        totalCalories += calories;
      }

      groupedData.add(GroupedStatEntry(
        label: label,
        calories: calories,
        targetCalories: target,
      ));
    }

    final double averageDailyCal = totalCalories / 7.0;

    return CalorieStatsResult(
      totalCalories: totalCalories,
      averageCalories: double.parse(averageDailyCal.toStringAsFixed(1)),
      groupedData: groupedData,
    );
  }

  /// Calculates Monthly statistics (groups last 30 calendar days into weekly averages).
  Future<CalorieStatsResult> getMonthlyStats(String userId) async {
    final List<CalorieLog> allLogs = await fetchUserLogs(userId);
    final DateTime now = DateTime.now();
    final DateTime thirtyDaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));

    final monthlyLogs = allLogs.where((log) =>
    log.date.isAfter(thirtyDaysAgo.subtract(const Duration(seconds: 1))) &&
        log.date.isBefore(now.add(const Duration(days: 1)))
    ).toList();

    int totalCalories = 0;
    final List<int> weekCalories = [0, 0, 0, 0];
    final List<int> weekCounts = [0, 0, 0, 0];

    for (var log in monthlyLogs) {
      totalCalories += log.caloriesConsumed;

      final int ageInDays = now.difference(log.date).inDays;
      int weekIdx = 3;
      if (ageInDays >= 21) {
        weekIdx = 0; // Week 1 (oldest range)
      } else if (ageInDays >= 14) {
        weekIdx = 1; // Week 2
      } else if (ageInDays >= 7) {
        weekIdx = 2; // Week 3
      }

      weekCalories[weekIdx] += log.caloriesConsumed;
      weekCounts[weekIdx] += 1;
    }

    final List<GroupedStatEntry> groupedData = [];
    for (int i = 0; i < 4; i++) {
      groupedData.add(GroupedStatEntry(
        label: 'Week ${i + 1}',
        calories: weekCounts[i] > 0 ? (weekCalories[i] ~/ weekCounts[i]) : 0,
        targetCalories: 2000,
      ));
    }

    final double averageDailyCal = monthlyLogs.isNotEmpty ? totalCalories / monthlyLogs.length : 0.0;

    return CalorieStatsResult(
      totalCalories: totalCalories,
      averageCalories: double.parse(averageDailyCal.toStringAsFixed(1)),
      groupedData: groupedData,
    );
  }

  /// Calculates Yearly statistics (grouped of preceding 12 calendar months).
  Future<CalorieStatsResult> getYearlyStats(String userId) async {
    final List<CalorieLog> allLogs = await fetchUserLogs(userId);
    final DateTime now = DateTime.now();

    final List<String> monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final List<int> yearlyMonthTotalCals = List.filled(12, 0);
    final List<int> yearlyMonthLogCount = List.filled(12, 0);

    int totalYearCalories = 0;
    int totalLoggedDays = 0;

    final DateTime oneYearAgo = DateTime(now.year - 1, now.month, now.day);
    final yearlyLogs = allLogs.where((log) =>
    log.date.isAfter(oneYearAgo) &&
        log.date.isBefore(now.add(const Duration(days: 1)))
    ).toList();

    for (var log in yearlyLogs) {
      final int monthIndex = log.date.month - 1;
      yearlyMonthTotalCals[monthIndex] += log.caloriesConsumed;
      yearlyMonthLogCount[monthIndex] += 1;

      totalYearCalories += log.caloriesConsumed;
      totalLoggedDays += 1;
    }

    final List<GroupedStatEntry> groupedData = [];
    for (int i = 11; i >= 0; i--) {
      final DateTime monthDate = DateTime(now.year, now.month - i, 1);
      final int monthIdx = monthDate.month - 1;
      final String label = monthLabels[monthIdx];

      final int loggedCount = yearlyMonthLogCount[monthIdx];
      final int avgCals = loggedCount > 0 ? (yearlyMonthTotalCals[monthIdx] ~/ loggedCount) : 0;

      groupedData.add(GroupedStatEntry(
        label: label,
        calories: avgCals,
        targetCalories: 2000,
      ));
    }

    final double averageDailyCal = totalLoggedDays > 0 ? totalYearCalories / totalLoggedDays : 0.0;

    return CalorieStatsResult(
      totalCalories: totalYearCalories,
      averageCalories: double.parse(averageDailyCal.toStringAsFixed(1)),
      groupedData: groupedData,
    );
  }
}