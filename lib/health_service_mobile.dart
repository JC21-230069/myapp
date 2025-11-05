
import 'dart:async';
import 'package:health/health.dart';
import 'package:pedometer/pedometer.dart';

class HealthService {
  final Health _health = Health();
  StreamSubscription<StepCount>? _stepCountSubscription;

  Stream<int> get stepCountStream =>
      Pedometer.stepCountStream.map((event) => event.steps);

  Future<List<double>> getSleepData() async {
    if (await _requestAuth([HealthDataType.SLEEP_IN_BED])) {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final healthData = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: [HealthDataType.SLEEP_IN_BED],
      );
      return healthData.map((e) => (e.value as NumericHealthValue).numericValue.toDouble()).toList();
    } else {
      return [];
    }
  }

  Future<List<double>> getWeeklySteps() async {
    return _getWeeklyData(HealthDataType.STEPS);
  }

  Future<List<double>> getWeeklySleep() async {
    return _getWeeklyData(HealthDataType.SLEEP_IN_BED);
  }

  Future<List<double>> _getWeeklyData(HealthDataType type) async {
    if (await _requestAuth([type])) {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final healthData = await _health.getHealthDataFromTypes(
        startTime: sevenDaysAgo,
        endTime: now,
        types: [type],
      );
      List<double> weeklyData = List.filled(7, 0.0);
      for (var data in healthData) {
        final dayIndex = data.dateFrom.weekday - 1;
        weeklyData[dayIndex] += (data.value as NumericHealthValue).numericValue.toDouble();
      }
      return weeklyData;
    } else {
      return List.filled(7, 0.0);
    }
  }


  Future<bool> _requestAuth(List<HealthDataType> types) async {
    return await _health.requestAuthorization(types);
  }

  void dispose() {
    _stepCountSubscription?.cancel();
  }
}
