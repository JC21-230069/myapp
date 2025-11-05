
class CalendarService {
  Future<bool> requestPermissions() async => false;

  Future<List<dynamic>> getCalendars() async => [];

  Future<List<dynamic>> getEvents(String? calendarId, DateTime start, DateTime end) async => [];
}
