
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Conditional imports
import 'health_service_stub.dart'
    if (dart.library.io) 'health_service_mobile.dart';

class HealthState with ChangeNotifier {
  final HealthService _healthService = HealthService();

  int _steps = 0;
  int get steps => _steps;

  double _sleepHours = 0.0;
  double get sleepHours => _sleepHours;

  int _stepGoal = 10000;
  int get stepGoal => _stepGoal;

  List<BarChartGroupData> _sleepData = [];
  List<BarChartGroupData> get sleepData => _sleepData;

  List<BarChartGroupData> _stepsData = [];
  List<BarChartGroupData> get stepsData => _stepsData;

  HealthState() {
    init();
  }

  Future<void> init() async {
    await _loadStepGoal();
    if (!kIsWeb) {
      _healthService.stepCountStream.listen((stepCount) {
        _steps = stepCount;
        notifyListeners();
      });
      await _fetchHealthData();
      await _fetchWeeklyHealthData();
    }
    notifyListeners();
  }

  Future<void> _loadStepGoal() async {
    final prefs = await SharedPreferences.getInstance();
    _stepGoal = prefs.getInt('stepGoal') ?? 10000;
    notifyListeners();
  }

  Future<void> _fetchHealthData() async {
    if (kIsWeb) return;
    try {
      final sleepData = await _healthService.getSleepData();
      _sleepHours = sleepData.fold(0.0, (sum, data) => sum + data) / 60;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching health data: $e');
      }
    }
    notifyListeners();
  }

  Future<void> _fetchWeeklyHealthData() async {
    if (kIsWeb) return;
    try {
      final weeklySteps = await _healthService.getWeeklySteps();
      _stepsData = _generateChartData(weeklySteps, Colors.orange);

      final weeklySleep = await _healthService.getWeeklySleep();
      _sleepData = _generateChartData(weeklySleep, Colors.lightBlue, isSleep: true);

    } catch (e) {
      if (kDebugMode) {
        print('Error fetching weekly health data: $e');
      }
    }
    notifyListeners();
  }

  List<BarChartGroupData> _generateChartData(List<double> weeklyData, Color color, {bool isSleep = false}) {
    return List.generate(7, (index) {
      double value = weeklyData[index];
      if(isSleep) {
        value /= 60; // Convert minutes to hours
      }
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: color,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  @override
  void dispose() {
    _healthService.dispose();
    super.dispose();
  }
}
