
import 'package:device_calendar/device_calendar.dart';

class CalendarService {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  Future<bool> requestPermissions() async {
    final result = await _deviceCalendarPlugin.requestPermissions();
    return result.isSuccess && result.data == true;
  }

  Future<List<Calendar>> getCalendars() async {
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    return calendarsResult.data ?? [];
  }

  Future<List<Event>> getEvents(String? calendarId, DateTime start, DateTime end) async {
    if (calendarId == null) return [];
    final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
      calendarId,
      RetrieveEventsParams(startDate: start, endDate: end),
    );
    return eventsResult.data ?? [];
  }
}
