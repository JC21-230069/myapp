import 'dart:async';

class HealthService {
  Stream<int> get stepCountStream => Stream.value(0);

  Future<List<double>> getSleepData() async => [];

  Future<List<double>> getWeeklySteps() async => List.filled(7, 0.0);

  Future<List<double>> getWeeklySleep() async => List.filled(7, 0.0);

  void dispose() {}
}
